# Q‑FoTEC AKG Cypher Interface → SafeAICoin Integration (Detailed Design)

**Owner:** Q‑FoTEC Research / SafeAICoin Core
**Version:** 0.1 (Design for implementation)
**Target platforms:** macOS (Apple Silicon), optional Linux gateway
**Goals:**

* Offer a **Cypher** interface over the Apple‑native **AKG** (Audit Knowledge Graph) without requiring Neo4j.
* Enforce **deterministic validation** and produce **on‑chain attestations** anchored to the SafeAICoin Field‑of‑Truth (FoT).
* Preserve opt‑in passthrough to **Neo4j/Memgraph** while keeping validation **local and mandatory**.

---

## 1. System Architecture

**Layers**

1. **Storage (L0)** — Local verifiable store (SQLite + optional Parquet/Arrow).
2. **Cypher Frontend (L1)** — Parser + Planner + Translator (Cypher → SQL) with Bolt/HTTP endpoints.
3. **Validator (L2)** — Schema + Domain rules + Canonicalization + BLAKE3/Merkle + Ed25519 signing.
4. **Anchor Bridge (L3)** — SafeAICoin client for on‑chain anchoring & proof serving.
5. **Optional Remotes** — Neo4j/Memgraph passthrough backend (read analytics, bulk ops).

**Process Model**

* **AKGService** (Swift) runs as a local daemon or in‑app service.
* Exposes **HTTP/JSON** and **Bolt** (read‑only; writes must use the validated envelope).
* Integrates with Q‑FoTEC compute via shared SQLite and file manifests.

**Data Flow (WRITE)**

```
Client → BEGIN WRITE (Cypher batch) → Cypher Parser → Logical Plan →
Validation Pipeline → Canonical JSON → BLAKE3 leaves → Merkle Root →
Ed25519 Sign → Attestation row → SafeAICoin Anchor (tx hash) → COMMIT
```

**Data Flow (READ)**

```
Client → Cypher → Planner → SQL → Execute → Canonical result JSON →
Result BLAKE3 → Read Receipt (sig + nonce + attestation coverage) → Return
```

---

## 2. Storage Layer (L0)

### 2.1 SQLite Schema (minimal, normalized)

```sql
-- Nodes
CREATE TABLE nodes (
  id TEXT PRIMARY KEY,        -- ULID
  labels TEXT NOT NULL,       -- JSON array of strings
  props  TEXT NOT NULL,       -- Canonical JSON (RFC 8785)
  hash   BLOB NOT NULL,       -- BLAKE3-256 (32 bytes)
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
CREATE INDEX nodes_label_idx ON nodes( labels ); -- json1-> simple index via virtual col optional

-- Edges
CREATE TABLE edges (
  id TEXT PRIMARY KEY,
  src TEXT NOT NULL REFERENCES nodes(id),
  dst TEXT NOT NULL REFERENCES nodes(id),
  type TEXT NOT NULL,
  props TEXT NOT NULL,
  hash  BLOB NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
CREATE INDEX edges_src_idx ON edges(src);
CREATE INDEX edges_dst_idx ON edges(dst);
CREATE INDEX edges_type_idx ON edges(type);

-- Artifacts (binary or external URIs)
CREATE TABLE artifacts (
  id TEXT PRIMARY KEY,
  uri TEXT NOT NULL,
  blake3 TEXT NOT NULL,
  mime TEXT,
  bytes INTEGER,
  created_at INTEGER NOT NULL
);

-- Lineage (immutable relationship between records)
CREATE TABLE lineage (
  parent_id TEXT NOT NULL,
  child_id  TEXT NOT NULL,
  op TEXT NOT NULL,           -- e.g., "YIELDED", "DERIVES_FROM"
  ts INTEGER NOT NULL
);
CREATE INDEX lineage_parent_idx ON lineage(parent_id);
CREATE INDEX lineage_child_idx  ON lineage(child_id);

-- Attestations (per write batch)
CREATE TABLE attestations (
  id TEXT PRIMARY KEY,           -- ULID
  merkle_root BLOB NOT NULL,     -- 32 bytes
  sig BLOB NOT NULL,             -- Ed25519 signature
  signer_pk BLOB NOT NULL,       -- public key
  schema_version TEXT NOT NULL,
  validator_version TEXT NOT NULL,
  ts INTEGER NOT NULL,
  chain_tx TEXT                  -- SafeAICoin tx id (once anchored)
);

-- Constraints (declarative rules enforced at validation time)
CREATE TABLE constraints (
  target TEXT NOT NULL,          -- label or rel-type
  rule   TEXT NOT NULL,          -- JSON rule spec
  PRIMARY KEY(target)
);

-- Optional: FTS for text props
CREATE VIRTUAL TABLE fts_nodes USING fts5(id, text, content='');
```

### 2.2 Canonicalization & Hashing

* **Canonical JSON**: RFC 8785 (deterministic ordering, numbers, whitespace).
* **Hash**: `BLAKE3-256(record_json)` stored as 32‑byte blob.
* **IDs**: `ULID()` generation in Swift; may also derive from hash for pure content‑addressable objects.

### 2.3 Parquet/Arrow (optional)

* Cold columns for analytical scans; use for bulk import/export.
* Maintain **manifests** mapping Parquet shards to logical node/edge ranges.

---

## 3. Cypher Frontend (L1)

### 3.1 Supported Cypher (v1)

* **Read**: `MATCH`, `WHERE`, `WITH`, `RETURN`, `ORDER BY`, `LIMIT`, `UNWIND`, pattern comprehensions, basic aggregations (`count`, `avg`, `sum`).
* **Write**: `CREATE`, `MERGE`, `SET`, `DELETE` **only inside** `BEGIN WRITE ... COMMIT` envelope.
* **Constraints/Indexes**: `CREATE CONSTRAINT`, `CREATE INDEX` → persisted to `constraints` + SQLite indexes.

**Not in v1:** Procedures, APOC, multi‑db, triggers (can be added later).

### 3.2 Parser/Planner

* **ANTLR4 Cypher grammar** → Swift target → AST.
* Logical plan → **Translator**: Cypher patterns → SQL over `nodes/edges` with JSON1 ops.
* **Backend hint**: `/* backend:local|neo4j */` comment toggles execution target (default: local).

### 3.3 Examples

**Read**

```cypher
MATCH (p:Protein {uniprot:"P69905"})-[:INTERACTS_WITH]->(q:Protein)
WHERE q.props->>'go' LIKE 'oxygen%'
RETURN q.props->>'symbol' AS symbol, q.props->>'go' AS go
ORDER BY symbol LIMIT 25;
```

**Validated Write**

```cypher
BEGIN WRITE
CREATE (s:Simulation {case:"FSI-ANSYS-57k", ts:1729900000})
CREATE (m:Mode {idx:1, freq_hz:8.0648, echo_F:0.9993})
CREATE (s)-[:YIELDED]->(m)
COMMIT
```

---

## 4. Validator (L2)

### 4.1 Pipeline

1. **Extract** candidate mutations from the parsed batch.
2. **Schema checks**: label/rel types, required fields, uniqueness (e.g., `Protein.uniprot`), domain of numeric fields (`echo_F∈[0,1]`, `freq_hz≥0`).
3. **Domain rules** (kit‑opt‑in):

   * **Clinical**: PHI guard (encryption/hash), valid code systems (ICD‑10/LOINC), consent flags.
   * **ClinicalTrials**: ISO 14155 primary keys, randomization consistency, arm references.
   * **Protein Folding**: PDB/mmCIF sanity, chain/length bounds; **GO/CAFA** labels as **optional annotations** (not required for discovery).
   * **Chemistry**: SMILES valid, valence checks, InChIKey normalization.
   * **FEA/FSI**: rigid‑body deflation recorded, `echo_F ≥ threshold`, residual bound.
4. **Canonicalize** each record → **BLAKE3 leaf**.
5. Build **Merkle tree** (pairs → parent hash) → **root**.
6. **Sign** root with **Ed25519** (Secure Enclave key).
7. Insert **attestation** row; keep **proof shards** (leaf → branch) in `artifacts` or file store.
8. On success: execute SQL mutations; on failure: reject entire batch with reason set.

### 4.2 Rules Language (JSON)

```json
{
  "target": "Mode",
  "required": ["idx", "freq_hz", "echo_F"],
  "numeric": {"freq_hz": {"min": 0}, "echo_F": {"min": 0, "max": 1}},
  "unique": ["mesh", "idx"],
  "links": [{"rel": "YIELDED", "from": "Simulation", "to": "Mode"}]
}
```

### 4.3 Error Reporting (deterministic)

* Error code, message, offending record (canonical JSON), violated rule ID.

---

## 5. SafeAICoin Bridge (L3)

### 5.1 On‑Chain Anchor

* Payload (compact):

  * `attestation_id` (ULID)
  * `merkle_root` (32B)
  * `schema_version`, `validator_version`
  * `content_uri` (optional, off‑chain proof bundle)
  * `signer_pk`, `signature`

* Client: `submitAnchor(attestation)` ⇒ returns `chain_tx`.

* Retry/confirm policy with exponential backoff; store final `chain_tx`.

### 5.2 Proof Serving

* `GET /proof/{attestation_id}` → returns:

  * validator report (rules passed),
  * leaf records (canonical JSON),
  * Merkle branches,
  * chain_tx.

### 5.3 Read Receipts

* Every `/cypher` response includes receipt: `{query_hash, result_hash, ts, nonce, sig, covered_attestations:[…]}`
* Verifier can re‑compute result hash offline and match attestation coverage.

---

## 6. APIs & Endpoints

### 6.1 HTTP/JSON

**POST /cypher**

```json
{"query":"MATCH (s:Simulation)-[:YIELDED]->(m:Mode) RETURN m.idx,m.freq_hz LIMIT 5"}
```

Response: `rows`, `receipt`.

**POST /write**

```json
{"statements":[
  "CREATE (s:Simulation {case:'FSI-ANSYS-57k', ts:1729900000})",
  "CREATE (m:Mode {idx:1, freq_hz:8.0648, echo_F:0.9993})",
  "MATCH (s:Simulation {case:'FSI-ANSYS-57k'}) CREATE (s)-[:YIELDED]->(m)"
]}
```

Response: `attestation_id`, `merkle_root`, `sig`, `chain_tx`.

**GET /proof/{attestation_id}** → Merkle + records + report.

### 6.2 Bolt (Neo4j protocol)

* **Read‑only** support for standard drivers.
* Writes return error directing clients to `/write` envelope.

### 6.3 Local Swift API

```swift
let svc = try AKGService()
let rows = try svc.queryCypher("MATCH (p:Protein)-[:HAS_GO]->(g:GO) RETURN p.id, g.id LIMIT 10")
let att = try svc.writeBatch([
  "CREATE (m:Mode {idx:1, freq_hz:8.0648, echo_F:0.9993})"
])
```

---

## 7. Security & Privacy

* **Secure Enclave** Ed25519 keys; device‑bound with rotation & revocation list.
* **PHI/PII**: field‑level encryption (AES‑GCM); PHI never leaves device; anchors exclude PHI.
* **Access control**: per‑endpoint tokens, per‑label/rel policy (allow/deny), query‑time row filtering.
* **Audit**: all writes/reads logged (hashed), tamper‑evident via Merkle chaining of log entries.

---

## 8. Domain Kits (Rules & Mappers)

### 8.1 Clinical

* Validators: ICD‑10/LOINC sets, consent flags, PHI redaction/encryption.
* Labels: `ClinicalCase, Patient*, Observation, Code`.

### 8.2 Clinical Trials

* ISO 14155 conformance, arm/randomization, visit windows.
* Labels: `Trial, Arm, Subject*, Visit, Endpoint`.

### 8.3 Protein Folding

* PDB/mmCIF integrity, chain lengths, residue bounds.
* Optional **GO/CAFA** annotations post‑hoc.
* Labels: `Protein, Structure, GO, Fold`.

### 8.4 Chemistry

* SMILES validation, InChIKey hashing, valence checks.
* Labels: `Molecule, Reaction, Reagent`.

### 8.5 Q‑FoTEC FEA/FSI

* Rigid‑mode deflation recorded; `echo_F ≥ threshold`; residual bounds.
* Labels: `Simulation, Mode, Mesh, Boundary, Material, Run`.

---

## 9. Implementation Plan & Milestones

### Week 0–1 — Core Engine

*

### Week 2 — Domain & Anchoring

*

### Week 3 — Hardening & Passthrough

*

### Week 4+ — Optimizations

*

---

## 10. Testing Strategy

* **Unit tests**: canonicalization, hashing, Merkle, signature verification.
* **Validator tests**: rule suites per kit (pass/fail fixtures).
* **Cypher translation**: MATCH/WHERE/aggregations, path patterns, edge cases.
* **End‑to‑end**: write batch → attestation → anchor → proof → replay verification.
* **Performance**: QPS targets for reads; batch throughput for writes; proof retrieval latency.

---

## 11. Developer Contracts (Canonicalization & Proofs)

### 11.1 Canonical JSON rules (RFC 8785)

* Sort object keys, UTF‑8, numbers normalized, no trailing zeros; no insignificant whitespace.
* Store **exact** bytes used for hashing to guarantee reproducibility.

### 11.2 Merkle Tree

* Binary tree, left‑right concatenation order preserved; leaf = `0x00 || blake3(record)`; node = `0x01 || blake3(left||right)`.

### 11.3 Signatures

* Ed25519 over `domain_separation || merkle_root || attestation_id || ts`.
* Key storage: Secure Enclave; export public key only; rotation recorded as a special attestation.

---

## 12. Example Cypher Sessions

**Read with Receipt**

```http
POST /cypher
{"query":"MATCH (s:Simulation)-[:YIELDED]->(m:Mode) RETURN m.idx,m.freq_hz LIMIT 5"}
```

Response:

```json
{
  "rows": [[1,8.0648],[2,10.33],[3,12.91],[4,15.7],[5,18.2]],
  "receipt": {
    "query_hash":"b3:7f…",
    "result_hash":"b3:91…",
    "ts":1730001112,
    "nonce":"01JD…",
    "sig":"ed25519:…",
    "covered_attestations":["01JB…","01JC…"]
  }
}
```

**Validated Write (FEA/FSI)**

```http
POST /write
{"statements":[
 "CREATE (s:Simulation {case:'FSI-ANSYS-57k', ts:1729900000})",
 "CREATE (m:Mode {idx:1, freq_hz:8.0648, echo_F:0.9993})",
 "MATCH (s:Simulation {case:'FSI-ANSYS-57k'}) CREATE (s)-[:YIELDED]->(m)"
]}
```

Response:

```json
{
  "attestation_id":"01JDAB…",
  "merkle_root":"b3:3a…",
  "sig":"ed25519:…",
  "chain_tx":"0xabc…"
}
```

---

## 13. Performance Targets

* **Reads**: >2k QPS for simple MATCH on Apple Silicon (local), p95 < 40 ms.
* **Writes**: 1k records/s batch, attestation build < 200 ms, anchor post < 1 s (async).
* **Proof size**: < 2 MB for 1k‑record batch (compressed JSON + branches).

---

## 14. Packaging & Deployment

* **SwiftPM** library `AKGService` + `AKGValidator` + `AKGCypherSQL` + `AKGAnchor`.
* **CLI** tool: `akgctl` for admin (create constraints, rotate keys, export proofs).
* **macOS App** integration: embed as framework; expose UI for receipts/proofs.

---

## 15. Open Questions / Decisions

* Do we require **multi‑signature** (m‑of‑n) before anchoring? (recommended for regulated domains)
* Which SafeAICoin **chain parameters** (network id, gas, RPC) for prod/test?
* Data retention policy for **PHI artifacts** and redaction strategy for exported proofs.
* Extent of Cypher coverage in v1 vs v2 (procedures, APOC functions).

---

## 16. Next Steps (Action Items)

*

---

## 17. SwiftPM Scaffold (Code Skeleton)

### 17.1 Repository Layout

```
AKGService/
  Package.swift
  Sources/
    AKGService/
      AKGService.swift
      HTTPServer.swift
      CypherSQL/
        Parser.swift
        Planner.swift
        Translator.swift
      Storage/
        DB.swift
        Schema.sql
        UDFs.swift
      Validator/
        Validator.swift
        Rules.swift
        Canon.swift
        Merkle.swift
        Signer.swift
      Anchor/
        SafeAICoinClient.swift
      Bolt/
        BoltServer.swift   # read-only v1
    AKGServiceCLI/
      main.swift
  Tests/
    AKGServiceTests/
      CanonTests.swift
      MerkleTests.swift
      ValidatorTests.swift
      CypherTranslationTests.swift
```

### 17.2 `Package.swift`

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "AKGService",
  platforms: [.macOS(.v13)],
  products: [
    .library(name: "AKGService", targets: ["AKGService"]),
    .executable(name: "akgctl", targets: ["AKGServiceCLI"]) 
  ],
  dependencies: [
    // Minimal deps; you can swap SQLite3 C API if you prefer zero deps
    .package(url: "https://github.com/groue/GRDB.swift", from: "6.26.0"),
    .package(url: "https://github.com/apple/swift-nio", from: "2.60.0")
  ],
  targets: [
    .target(name: "AKGService", dependencies: [
      .product(name: "GRDB", package: "GRDB.swift"),
      .product(name: "NIO", package: "swift-nio"),
      .product(name: "NIOHTTP1", package: "swift-nio")
    ], resources: [.process("Storage/Schema.sql")]),
    .executableTarget(name: "AKGServiceCLI", dependencies: ["AKGService"]),
    .testTarget(name: "AKGServiceTests", dependencies: ["AKGService"]) 
  ]
)
```

### 17.3 Storage & UDFs

`Storage/Schema.sql` (load at startup):

```sql
PRAGMA foreign_keys=ON;
-- (schema from §2.1)
```

`Storage/UDFs.swift`:

```swift
import Foundation
import GRDB

public enum UDFs {
  public static func install(on db: DatabaseQueue) throws {
    try db.write { db in
      let ulid = DatabaseFunction("ULID", argumentCount: 0, pure: true) { _ in
        return ULID().string
      }
      DatabaseFunction.register(ulid)

      let canon = DatabaseFunction("CANONJSON", argumentCount: 1, pure: true) { dbValues in
        guard let s: String = dbValues[0]?.string else { return nil }
        return try CanonicalJSON.canonicalize(s)
      }
      DatabaseFunction.register(canon)

      let blake3 = DatabaseFunction("BLAKE3", argumentCount: 1, pure: true) { dbValues in
        guard let data = (dbValues[0]?.string)?.data(using: .utf8) else { return nil }
        return Blake3.hash(data).hex
      }
      DatabaseFunction.register(blake3)
    }
  }
}

// ULID generator (tiny impl)
public struct ULID { public let string: String; public init() { self.string = ULID.make() }
  static func make() -> String { /* monotonic ULID implementation */ return UUID().uuidString }
}

enum CanonicalJSON {
  static func canonicalize(_ s: String) throws -> String { /* RFC 8785 canonicalization */ return s }
}

enum Blake3 { static func hash(_ d: Data) -> Data { /* call out to C/Swift blake3 */ return Data(repeating: 0, count: 32) } }
extension Data { var hex: String { map { String(format: "%02x", $0) }.joined() } }
```

`Storage/DB.swift`:

```swift
import GRDB

public final class AKGDB {
  public let db: DatabaseQueue
  public init(path: String) throws {
    db = try DatabaseQueue(path: path)
    try migrator.migrate(db)
    try UDFs.install(on: db)
  }
  private var migrator: DatabaseMigrator {
    var m = DatabaseMigrator()
    m.registerMigration("schema_v1") { db in
      let sql = try String(contentsOf: Bundle.module.url(forResource: "Schema", withExtension: "sql")!)
      try db.execute(sql: sql)
    }
    return m
  }
}
```

### 17.4 HTTP Server (NIO) & Endpoints

`HTTPServer.swift`:

```swift
import NIO
import NIOHTTP1

final class HTTPServer {
  let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
  let service: AKGService
  init(service: AKGService) { self.service = service }

  func start(host: String = "127.0.0.1", port: Int = 8888) throws {
    let bootstrap = ServerBootstrap(group: group)
      .serverChannelOption(ChannelOptions.backlog, value: 256)
      .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
      .childChannelInitializer { channel in
        channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).flatMap {
          channel.pipeline.addHandler(HTTPHandler(service: self.service))
        }
      }
      .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)

    let ch = try bootstrap.bind(host: host, port: port).wait()
    print("AKGService HTTP listening on http://\(host):\(port)")
    try ch.closeFuture.wait()
  }
}

final class HTTPHandler: ChannelInboundHandler {
  typealias InboundIn = HTTPServerRequestPart
  private var buffer: ByteBuffer = .init()
  let service: AKGService
  init(service: AKGService) { self.service = service }

  func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let part = self.unwrapInboundIn(data)
    switch part {
    case .head: buffer.clear()
    case .body(let b): var b = b; buffer.writeBuffer(&b)
    case .end:
      guard let req = try? JSONDecoder().decode(Req.self, from: Data(buffer.readableBytesView)) else {
        return write(context, status: .badRequest, json: ["error":"bad json"]) }
      switch req.path {
      case "/cypher":
        let rows = (try? service.queryCypher(req.query ?? "", params: req.params ?? [:])) ?? []
        let resp = ["rows": rows, "receipt": service.lastReceipt()] as [String: Any]
        write(context, status: .ok, anyJSON: resp)
      case "/write":
        do {
          let att = try service.writeBatch(req.statements ?? [])
          write(context, status: .ok, anyJSON: att)
        } catch {
          write(context, status: .unprocessableEntity, json: ["error":"\(error)"]) }
      default:
        write(context, status: .notFound, json: ["error":"not found"]) }
    }
  }

  struct Req: Decodable { var path: String; var query: String?; var params: [String:String]?; var statements: [String]? }
  private func write(_ ctx: ChannelHandlerContext, status: HTTPResponseStatus, json: [String:String]) {
    write(ctx, status: status, anyJSON: json)
  }
  private func write(_ ctx: ChannelHandlerContext, status: HTTPResponseStatus, anyJSON: Any) {
    let data = try! JSONSerialization.data(withJSONObject: anyJSON, options: [])
    var head = HTTPResponseHead(version: .http1_1, status: status)
    head.headers.add(name: "Content-Type", value: "application/json")
    ctx.write(self.wrapOutboundOut(.head(head)), promise: nil)
    var buf = ctx.channel.allocator.buffer(capacity: data.count)
    buf.writeBytes(data)
    ctx.write(self.wrapOutboundOut(.body(.byteBuffer(buf))), promise: nil)
    ctx.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
  }
}
```

### 17.5 Service Shell

`AKGService.swift`:

```swift
import Foundation
import GRDB

public final class AKGService {
  let db: AKGDB
  let validator: Validator
  let anchor: SafeAICoinClient
  public init(dbPath: String = "akg.db") throws {
    self.db = try AKGDB(path: dbPath)
    self.validator = Validator(db: db.db)
    self.anchor = SafeAICoinClient()
  }

  public func queryCypher(_ cypher: String, params: [String:String]) throws -> [[Any]] {
    // TODO: Parser → Planner → Translator → SQL
    // For now, return empty and record a dummy receipt
    return []
  }

  public func lastReceipt() -> [String: Any] {
    // Dummy; replace with real receipt
    return ["query_hash":"b3:…","result_hash":"b3:…","ts":Int(Date().timeIntervalSince1970),"nonce":"…","sig":"ed25519:…"]
  }

  public func writeBatch(_ stmts: [String]) throws -> [String: Any] {
    // 1) Parse & collect mutations
    // 2) validator.validate(batch)
    // 3) Build Merkle, sign, insert attestation
    // 4) Execute SQL mutations in a tx
    // 5) anchor.submit(attestation)
    return ["attestation_id":"01JD…","merkle_root":"b3:…","sig":"ed25519:…","chain_tx":"0x…"]
  }
}
```

### 17.6 Validator Core

`Validator/Validator.swift`:

```swift
import GRDB

public final class Validator {
  let db: DatabaseQueue
  public init(db: DatabaseQueue) { self.db = db }

  public func validate(batch: [Mutation]) throws -> Attestation {
    // Load rules, check schema/domain, build canonical JSON, hashes, merkle
    return Attestation(id: ULID().string, merkleRoot: Data(), sig: Data(), ts: Int(Date().timeIntervalSince1970))
  }
}

public struct Mutation { public let kind: Kind; public let record: [String:Any]; public enum Kind { case createNode, createEdge, setProps, delete }
}
public struct Attestation { public let id: String; public let merkleRoot: Data; public let sig: Data; public let ts: Int }
```

### 17.7 SafeAICoin Client Stub

`Anchor/SafeAICoinClient.swift`:

```swift
public final class SafeAICoinClient {
  public init() {}
  public func submit(attestation: Attestation) throws -> String {
    // POST to RPC / sign & send tx; return tx id
    return "0xabc…"
  }
}
```

---

## 18. Cypher Parser & SQL Translator (Design Notes)

* Use **ANTLR4** Cypher grammar; generate Swift target.
* AST → logical plan nodes: `NodeScan(label)`, `Expand(src,label,rel)`, `Filter(expr)`, `Project(exprs)`, `Limit(n)`.
* Translator maps to SQL with JSON1:

  * Node scan: `SELECT * FROM nodes WHERE json_each(labels) = 'Protein'` (or virtual column).
  * Property access: `json_extract(props, '$.uniprot')`.
  * Expand: join `edges` on `src`/`dst`, then join target `nodes`.

**Example translation** Cypher:

```cypher
MATCH (p:Protein {uniprot:"P69905"})-[:HAS_GO]->(g:GO)
RETURN g.id, json_extract(g.props,'$.name') AS name LIMIT 10
```

SQL:

```sql
WITH P AS (
  SELECT id FROM nodes 
  WHERE json_array_contains(labels,'Protein')
    AND json_extract(props,'$.uniprot') = 'P69905'
)
SELECT g.id, json_extract(g.props,'$.name') AS name
FROM edges e
JOIN nodes g ON g.id = e.dst
WHERE e.src IN (SELECT id FROM P) AND e.type = 'HAS_GO'
LIMIT 10;
```

---

## 19. Rules Engine (Examples)

### 19.1 Constraint DDL → JSON rule

Cypher:

```cypher
CREATE CONSTRAINT protein_uniprot IF NOT EXISTS
ON (p:Protein) ASSERT p.uniprot IS UNIQUE;
```

Stored rule:

```json
{"target":"Protein","unique":["uniprot"]}
```

### 19.2 FEA/FSI Domain Check

```json
{
  "target":"Mode",
  "required":["idx","freq_hz","echo_F"],
  "numeric":{"freq_hz":{"min":0},"echo_F":{"min":0,"max":1}},
  "implications":[{"if":{"echo_F":{"lt":0.999}},"then":"REJECT: Echo below threshold"}]
}
```

---

## 20. SafeAICoin Anchor: Payload & Verification

**Payload**

```json
{
  "attestation_id":"01JD…",
  "merkle_root":"b3:…",
  "schema_version":"akg-1.4.2",
  "validator_version":"qfotec-val-0.7.0",
  "signer_pk":"ed25519:…",
  "signature":"ed25519:…"
}
```

**Verification steps**

1. Fetch proof bundle, verify branches to `merkle_root`.
2. Rebuild canonical JSON for each leaf; recompute BLAKE3 and root.
3. Verify signature (Ed25519) over domain‑separated message.
4. Confirm on‑chain `chain_tx` matches stored root.

---

## 21. CLI (akgctl) & Test Harness

**Build & run**

```bash
swift build -c release
.build/release/akgctl serve --db akg.db --port 8888
```

**Insert (validated write)**

```bash
curl -s localhost:8888 -H 'Content-Type: application/json' \
  -d '{"path":"/write","statements":[
    "CREATE (s:Simulation {case:\"FSI-ANSYS-57k\", ts:1729900000})",
    "CREATE (m:Mode {idx:1, freq_hz:8.0648, echo_F:0.9993})",
    "MATCH (s:Simulation {case:\"FSI-ANSYS-57k\"}) CREATE (s)-[:YIELDED]->(m)"
  ]}' | jq
```

**Query with receipt**

```bash
curl -s localhost:8888 -H 'Content-Type: application/json' \
  -d '{"path":"/cypher","query":"MATCH (s:Simulation)-[:YIELDED]->(m:Mode) RETURN m.idx,m.freq_hz LIMIT 5"}' | jq
```

**Fetch proof**

```bash
curl -s localhost:8888/proof/01JDAB… | jq
```

---

## 22. Hardening Checklist

*

---

## 23. Roadmap Enhancements

* **APOC‑like functions** (safe subset) implemented locally.
* **Streaming Bolt writes** with pre‑validation channel (future).
* **Materialized views** for hot subgraphs (Protein, FEA/FSI) with incremental refresh.
* **Columnar cache** (Arrow) for analytics; vectorized projection engine.
* **Cross‑device sync** with per‑record attestations & reconciliation.

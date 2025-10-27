-- FoT AKG Schema v1.0
-- SQLite database schema for Audit Knowledge Graph
-- Based on design document §2.1

PRAGMA foreign_keys=ON;
PRAGMA journal_mode=WAL;

-- Nodes table: vertices in the knowledge graph
CREATE TABLE IF NOT EXISTS nodes (
    id TEXT PRIMARY KEY,                -- ULID identifier
    labels TEXT NOT NULL,               -- JSON array of label strings
    props TEXT NOT NULL,                -- Canonical JSON (RFC 8785)
    hash BLOB NOT NULL,                 -- BLAKE3-256 hash (32 bytes)
    created_at INTEGER NOT NULL,        -- Unix timestamp (ms)
    updated_at INTEGER NOT NULL,        -- Unix timestamp (ms)
    CHECK(length(hash) = 32)
);

CREATE INDEX IF NOT EXISTS nodes_created_idx ON nodes(created_at);
CREATE INDEX IF NOT EXISTS nodes_hash_idx ON nodes(hash);

-- Edges table: relationships in the knowledge graph
CREATE TABLE IF NOT EXISTS edges (
    id TEXT PRIMARY KEY,                -- ULID identifier
    src TEXT NOT NULL,                  -- Source node ID
    dst TEXT NOT NULL,                  -- Destination node ID
    type TEXT NOT NULL,                 -- Relationship type
    props TEXT NOT NULL,                -- Canonical JSON properties
    hash BLOB NOT NULL,                 -- BLAKE3-256 hash
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY(src) REFERENCES nodes(id) ON DELETE CASCADE,
    FOREIGN KEY(dst) REFERENCES nodes(id) ON DELETE CASCADE,
    CHECK(length(hash) = 32)
);

CREATE INDEX IF NOT EXISTS edges_src_idx ON edges(src);
CREATE INDEX IF NOT EXISTS edges_dst_idx ON edges(dst);
CREATE INDEX IF NOT EXISTS edges_type_idx ON edges(type);
CREATE INDEX IF NOT EXISTS edges_created_idx ON edges(created_at);

-- Artifacts table: binary data and external URIs
CREATE TABLE IF NOT EXISTS artifacts (
    id TEXT PRIMARY KEY,                -- ULID identifier
    uri TEXT NOT NULL,                  -- URI or file path
    blake3 TEXT NOT NULL,               -- BLAKE3 hash (hex)
    mime TEXT,                          -- MIME type
    bytes INTEGER,                      -- Size in bytes
    created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS artifacts_blake3_idx ON artifacts(blake3);

-- Lineage table: immutable provenance relationships
CREATE TABLE IF NOT EXISTS lineage (
    parent_id TEXT NOT NULL,            -- Parent record ID
    child_id TEXT NOT NULL,             -- Child record ID
    op TEXT NOT NULL,                   -- Operation: YIELDED, DERIVES_FROM, etc.
    ts INTEGER NOT NULL,                -- Timestamp
    PRIMARY KEY(parent_id, child_id, op)
);

CREATE INDEX IF NOT EXISTS lineage_parent_idx ON lineage(parent_id);
CREATE INDEX IF NOT EXISTS lineage_child_idx ON lineage(child_id);
CREATE INDEX IF NOT EXISTS lineage_ts_idx ON lineage(ts);

-- Attestations table: cryptographic validation records
CREATE TABLE IF NOT EXISTS attestations (
    id TEXT PRIMARY KEY,                -- ULID identifier
    merkle_root BLOB NOT NULL,          -- Merkle tree root (32 bytes)
    sig BLOB NOT NULL,                  -- Ed25519 signature (64 bytes)
    signer_pk BLOB NOT NULL,            -- Public key (32 bytes)
    schema_version TEXT NOT NULL,       -- Schema version
    validator_version TEXT NOT NULL,    -- Validator version
    ts INTEGER NOT NULL,                -- Timestamp
    chain_tx TEXT,                      -- SafeAICoin transaction hash
    CHECK(length(merkle_root) = 32),
    CHECK(length(sig) = 64),
    CHECK(length(signer_pk) = 32)
);

CREATE INDEX IF NOT EXISTS attestations_ts_idx ON attestations(ts);
CREATE INDEX IF NOT EXISTS attestations_chain_tx_idx ON attestations(chain_tx);

-- Attestation coverage: which records are covered by which attestation
CREATE TABLE IF NOT EXISTS attestation_coverage (
    attestation_id TEXT NOT NULL,
    record_type TEXT NOT NULL,          -- 'node' or 'edge'
    record_id TEXT NOT NULL,
    FOREIGN KEY(attestation_id) REFERENCES attestations(id) ON DELETE CASCADE,
    PRIMARY KEY(attestation_id, record_type, record_id)
);

CREATE INDEX IF NOT EXISTS coverage_record_idx ON attestation_coverage(record_type, record_id);

-- Constraints table: declarative validation rules
CREATE TABLE IF NOT EXISTS constraints (
    target TEXT NOT NULL,               -- Label or relationship type
    rule TEXT NOT NULL,                 -- JSON rule specification
    active INTEGER NOT NULL DEFAULT 1,  -- Boolean: is rule active?
    PRIMARY KEY(target)
);

-- Merkle proofs table: branch proofs for verification
CREATE TABLE IF NOT EXISTS merkle_proofs (
    attestation_id TEXT NOT NULL,
    leaf_hash BLOB NOT NULL,
    branch_proof TEXT NOT NULL,         -- JSON array of hashes
    FOREIGN KEY(attestation_id) REFERENCES attestations(id) ON DELETE CASCADE,
    PRIMARY KEY(attestation_id, leaf_hash)
);

-- Full-text search for node properties (optional)
CREATE VIRTUAL TABLE IF NOT EXISTS fts_nodes USING fts5(
    id UNINDEXED,
    text,
    content=''
);

-- Triggers to maintain FTS index
CREATE TRIGGER IF NOT EXISTS nodes_ai AFTER INSERT ON nodes BEGIN
    INSERT INTO fts_nodes(id, text) VALUES (new.id, new.props);
END;

CREATE TRIGGER IF NOT EXISTS nodes_ad AFTER DELETE ON nodes BEGIN
    DELETE FROM fts_nodes WHERE id = old.id;
END;

CREATE TRIGGER IF NOT EXISTS nodes_au AFTER UPDATE ON nodes BEGIN
    UPDATE fts_nodes SET text = new.props WHERE id = new.id;
END;


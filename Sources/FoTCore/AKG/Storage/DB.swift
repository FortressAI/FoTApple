import Foundation
import GRDB

/// AKG Database manager
/// Handles SQLite connection, migrations, and custom SQL functions
public actor AKGDB {
    public let dbQueue: DatabaseQueue
    private let schemaVersion = "1.0.0"
    
    /// Initialize database at given path
    public init(path: String = ":memory:") throws {
        // Create database queue
        var configuration = Configuration()
        configuration.prepareDatabase { db in
            // Enable foreign keys
            try db.execute(sql: "PRAGMA foreign_keys = ON")
            // Enable WAL mode for better concurrency
            try db.execute(sql: "PRAGMA journal_mode = WAL")
        }
        
        self.dbQueue = try DatabaseQueue(path: path, configuration: configuration)
        
        // Run migrations  
        // Note: These need to be non-async for initialization
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1.0.0") { db in
            try AKGDB.executeSchemaInline(db)
        }
        try migrator.migrate(dbQueue)
        
        try dbQueue.write { db in
            try AKGDB.registerCustomFunctionsStatic(db)
        }
        
        print("✅ AKG Database initialized at: \(path)")
    }
    
    /// Fallback inline schema execution
    private static func executeSchemaInline(_ db: Database) throws {
        // Create tables directly (fallback if resource loading fails)
        try db.execute(sql: """
            PRAGMA foreign_keys=ON;
            
            CREATE TABLE IF NOT EXISTS nodes (
                id TEXT PRIMARY KEY,
                labels TEXT NOT NULL,
                props TEXT NOT NULL,
                hash BLOB NOT NULL,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            );
            
            CREATE TABLE IF NOT EXISTS edges (
                id TEXT PRIMARY KEY,
                src TEXT NOT NULL,
                dst TEXT NOT NULL,
                type TEXT NOT NULL,
                props TEXT NOT NULL,
                hash BLOB NOT NULL,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL,
                FOREIGN KEY(src) REFERENCES nodes(id),
                FOREIGN KEY(dst) REFERENCES nodes(id)
            );
            
            CREATE TABLE IF NOT EXISTS attestations (
                id TEXT PRIMARY KEY,
                merkle_root BLOB NOT NULL,
                sig BLOB NOT NULL,
                signer_pk BLOB NOT NULL,
                schema_version TEXT NOT NULL,
                validator_version TEXT NOT NULL,
                ts INTEGER NOT NULL,
                chain_tx TEXT
            );
            
            CREATE INDEX IF NOT EXISTS nodes_created_idx ON nodes(created_at);
            CREATE INDEX IF NOT EXISTS edges_src_idx ON edges(src);
            CREATE INDEX IF NOT EXISTS edges_dst_idx ON edges(dst);
            CREATE INDEX IF NOT EXISTS edges_type_idx ON edges(type);
        """)
    }
    
    /// Register custom SQL functions
    private static func registerCustomFunctionsStatic(_ db: Database) throws {
        // ULID() - Generate new ULID
        db.add(function: DatabaseFunction("ULID", argumentCount: 0, pure: false) { _ in
            return ULID().string
        })
        
        // BLAKE3(data) - Hash data with BLAKE3
        db.add(function: DatabaseFunction("BLAKE3", argumentCount: 1, pure: true) { dbValues in
            guard let string = String.fromDatabaseValue(dbValues[0]) else {
                return nil
            }
            guard let data = string.data(using: .utf8) else {
                return nil
            }
            return BLAKE3.hashHex(data)
        })
        
        // CANONJSON(json) - Canonicalize JSON string
        db.add(function: DatabaseFunction("CANONJSON", argumentCount: 1, pure: true) { dbValues in
            guard let string = String.fromDatabaseValue(dbValues[0]) else {
                return nil
            }
            
            do {
                let canonical = try CanonicalJSON.canonicalize(string)
                return String(data: canonical, encoding: .utf8)
            } catch {
                return nil
            }
        })
        
        // UNIX_MS() - Current Unix timestamp in milliseconds
        db.add(function: DatabaseFunction("UNIX_MS", argumentCount: 0, pure: false) { _ in
            return Int64(Date().timeIntervalSince1970 * 1000)
        })
        
        print("✅ Custom SQL functions registered")
    }
    
    /// Insert a node into the graph
    public func insertNode(
        id: String? = nil,
        labels: [String],
        properties: [String: Any]
    ) async throws -> String {
        let nodeId = id ?? ULID().string
        
        try await dbQueue.write { db in
            // Canonicalize properties
            let propsData = try CanonicalJSON.canonicalize(properties)
            let propsString = String(data: propsData, encoding: .utf8)!
            
            // Compute hash
            let hash = BLAKE3.hash(propsData)
            
            // Current timestamp
            let now = Int64(Date().timeIntervalSince1970 * 1000)
            
            // Convert labels to JSON array
            let labelsJSON = try JSONEncoder().encode(labels)
            let labelsString = String(data: labelsJSON, encoding: .utf8)!
            
            // Insert node
            try db.execute(
                sql: """
                INSERT INTO nodes (id, labels, props, hash, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                arguments: [nodeId, labelsString, propsString, hash, now, now]
            )
        }
        
        return nodeId
    }
    
    /// Insert an edge into the graph
    public func insertEdge(
        id: String? = nil,
        source: String,
        destination: String,
        type: String,
        properties: [String: Any] = [:]
    ) async throws -> String {
        let edgeId = id ?? ULID().string
        
        try await dbQueue.write { db in
            // Canonicalize properties
            let propsData = try CanonicalJSON.canonicalize(properties)
            let propsString = String(data: propsData, encoding: .utf8)!
            
            // Compute hash
            let hash = BLAKE3.hash(propsData)
            
            // Current timestamp
            let now = Int64(Date().timeIntervalSince1970 * 1000)
            
            // Insert edge
            try db.execute(
                sql: """
                INSERT INTO edges (id, src, dst, type, props, hash, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                arguments: [edgeId, source, destination, type, propsString, hash, now, now]
            )
        }
        
        return edgeId
    }
    
    /// Query nodes by label
    public func queryNodesByLabel(_ label: String, limit: Int = 100) async throws -> [[String: Any]] {
        return try await dbQueue.read { db in
            let rows = try Row.fetchAll(db, sql: """
                SELECT id, labels, props, hash, created_at, updated_at
                FROM nodes
                WHERE labels LIKE ?
                LIMIT ?
                """, arguments: ["%\"\(label)\"%", limit])
            
            return rows.map { row in
                [
                    "id": row["id"] as String,
                    "labels": row["labels"] as String,
                    "props": row["props"] as String,
                    "hash": (row["hash"] as Data).toHexString(),
                    "created_at": row["created_at"] as Int64,
                    "updated_at": row["updated_at"] as Int64
                ]
            }
        }
    }
    
    /// Get database statistics
    public func statistics() async throws -> [String: Any] {
        return try await dbQueue.read { db in
            let nodeCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM nodes") ?? 0
            let edgeCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM edges") ?? 0
            let attestationCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM attestations") ?? 0
            
            return [
                "nodes": nodeCount,
                "edges": edgeCount,
                "attestations": attestationCount,
                "schema_version": self.schemaVersion
            ]
        }
    }
}


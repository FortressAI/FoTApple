// ReceiptStore.swift
// GRDB-based storage for cryptographic receipts
// Provides tamper-evident audit trail for all VQbit operations

import Foundation
import GRDB

/// Receipt record for database storage
public struct ReceiptRecord: Codable, FetchableRecord, PersistableRecord {
    public var id: String
    public var timestamp: Date
    public var engineType: String
    public var deviceCapability: String
    public var dimension: Int
    public var operationType: String  // "step", "collapse", "solve"
    public var inputs: Data
    public var outputs: Data
    public var canonicalJSON: Data
    public var hash: Data
    public var signature: Data
    public var merkleRoot: Data
    public var deterministic: Bool
    public var verified: Bool
    public var blockchainTxID: String?
    
    public static let databaseTableName = "receipts"
    
    public init(
        id: String,
        timestamp: Date,
        engineType: String,
        deviceCapability: String,
        dimension: Int,
        operationType: String,
        inputs: Data,
        outputs: Data,
        canonicalJSON: Data,
        hash: Data,
        signature: Data,
        merkleRoot: Data,
        deterministic: Bool,
        verified: Bool = false,
        blockchainTxID: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.engineType = engineType
        self.deviceCapability = deviceCapability
        self.dimension = dimension
        self.operationType = operationType
        self.inputs = inputs
        self.outputs = outputs
        self.canonicalJSON = canonicalJSON
        self.hash = hash
        self.signature = signature
        self.merkleRoot = merkleRoot
        self.deterministic = deterministic
        self.verified = verified
        self.blockchainTxID = blockchainTxID
    }
    
    public init(from bundle: ReceiptBundle, operationType: String, dimension: Int) {
        self.id = bundle.id
        self.timestamp = bundle.timestamp
        self.engineType = bundle.engineType
        self.deviceCapability = bundle.deviceCapability
        self.dimension = dimension
        self.operationType = operationType
        self.inputs = bundle.inputs
        self.outputs = bundle.outputs
        self.canonicalJSON = bundle.canonicalJSON
        self.hash = bundle.hash
        self.signature = bundle.signature
        self.merkleRoot = bundle.merkleRoot
        self.deterministic = bundle.deterministic
        self.verified = false
        self.blockchainTxID = nil
    }
}

/// Receipt store for managing cryptographic receipts
public actor ReceiptStore {
    private let dbQueue: DatabaseQueue
    
    public init(path: String = ":memory:") throws {
        self.dbQueue = try DatabaseQueue(path: path)
        try self.createSchemaSync()
    }
    
    nonisolated private func createSchemaSync() throws {
        try dbQueue.write { db in
            try db.create(table: "receipts", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("timestamp", .datetime).notNull()
                t.column("engineType", .text).notNull()
                t.column("deviceCapability", .text).notNull()
                t.column("dimension", .integer).notNull()
                t.column("operationType", .text).notNull()
                t.column("inputs", .blob).notNull()
                t.column("outputs", .blob).notNull()
                t.column("canonicalJSON", .blob).notNull()
                t.column("hash", .blob).notNull()
                t.column("signature", .blob).notNull()
                t.column("merkleRoot", .blob).notNull()
                t.column("deterministic", .boolean).notNull()
                t.column("verified", .boolean).notNull().defaults(to: false)
                t.column("blockchainTxID", .text)
            }
            
            // Indices for common queries
            try db.create(index: "idx_receipts_timestamp", on: "receipts", columns: ["timestamp"])
            try db.create(index: "idx_receipts_engine", on: "receipts", columns: ["engineType"])
            try db.create(index: "idx_receipts_operation", on: "receipts", columns: ["operationType"])
            try db.create(index: "idx_receipts_verified", on: "receipts", columns: ["verified"])
        }
        
        print("✅ Receipt Store initialized")
    }
    
    /// Store a new receipt
    public func store(_ bundle: ReceiptBundle, operationType: String, dimension: Int) throws {
        let record = ReceiptRecord(from: bundle, operationType: operationType, dimension: dimension)
        try dbQueue.write { db in
            try record.insert(db)
        }
    }
    
    /// Get receipt by ID
    public func get(id: String) throws -> ReceiptRecord? {
        try dbQueue.read { db in
            try ReceiptRecord.fetchOne(db, key: id)
        }
    }
    
    /// Get all receipts for a time range
    public func getReceipts(from startDate: Date, to endDate: Date) throws -> [ReceiptRecord] {
        try dbQueue.read { db in
            try ReceiptRecord
                .filter(Column("timestamp") >= startDate && Column("timestamp") <= endDate)
                .order(Column("timestamp").desc)
                .fetchAll(db)
        }
    }
    
    /// Get unverified receipts
    public func getUnverified() throws -> [ReceiptRecord] {
        try dbQueue.read { db in
            try ReceiptRecord
                .filter(Column("verified") == false)
                .order(Column("timestamp"))
                .fetchAll(db)
        }
    }
    
    /// Mark receipt as verified
    public func markVerified(id: String, blockchainTxID: String? = nil) throws {
        try dbQueue.write { db in
            var record = try ReceiptRecord.fetchOne(db, key: id)
            record?.verified = true
            record?.blockchainTxID = blockchainTxID
            try record?.update(db)
        }
    }
    
    /// Get receipt count by engine type
    public func getStats() throws -> [String: Int] {
        try dbQueue.read { db in
            let rows = try Row.fetchAll(db, sql: """
                SELECT engineType, COUNT(*) as count
                FROM receipts
                GROUP BY engineType
            """)
            
            var stats: [String: Int] = [:]
            for row in rows {
                let engine: String = row["engineType"]
                let count: Int = row["count"]
                stats[engine] = count
            }
            return stats
        }
    }
    
    /// Verify receipt integrity
    public func verify(id: String) throws -> Bool {
        guard let record = try get(id: id) else {
            return false
        }
        
        // Recompute hash from canonical JSON
        let computedHash = BLAKE3.hash(String(data: record.canonicalJSON, encoding: .utf8) ?? "")
        
        // Compare with stored hash
        return computedHash == record.hash
    }
    
    /// Export receipt as proof bundle
    public func exportProof(id: String) throws -> ReceiptBundle {
        guard let record = try get(id: id) else {
            throw ReceiptStoreError.receiptNotFound(id)
        }
        
        return ReceiptBundle(
            id: record.id,
            timestamp: record.timestamp,
            inputs: record.inputs,
            outputs: record.outputs,
            canonicalJSON: record.canonicalJSON,
            hash: record.hash,
            signature: record.signature,
            merkleRoot: record.merkleRoot,
            engineType: record.engineType,
            deviceCapability: record.deviceCapability,
            deterministic: record.deterministic
        )
    }
}

/// Receipt store errors
public enum ReceiptStoreError: Error {
    case receiptNotFound(String)
    case verificationFailed(String)
    case exportFailed(String)
}


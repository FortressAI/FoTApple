// LegalDataStore.swift
// Real SQLite storage for legal evidence and incidents - NO MOCKS

import Foundation
import SQLite3

/// Real legal data storage with SQLite - NO SIMULATIONS
public actor LegalDataStore {
    public static let shared = LegalDataStore()
    
    private var db: OpaquePointer?
    private let dbPath: String
    
    private init() {
        // Get documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        dbPath = paths[0].appendingPathComponent("legal_data.sqlite").path
        
        Task {
            await initializeDatabase()
        }
    }
    
    private func initializeDatabase() {
        // Open/create database
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            FoTLogger.app.error("❌ Failed to open legal database")
            return
        }
        
        // Create tables
        let createEvidenceTable = """
        CREATE TABLE IF NOT EXISTS evidence (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            description TEXT,
            timestamp INTEGER NOT NULL,
            receipt_id TEXT NOT NULL,
            created_at INTEGER NOT NULL
        );
        """
        
        let createIncidentsTable = """
        CREATE TABLE IF NOT EXISTS incidents (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            description TEXT,
            location TEXT,
            timestamp INTEGER NOT NULL,
            receipt_id TEXT NOT NULL,
            created_at INTEGER NOT NULL
        );
        """
        
        let createResearchTable = """
        CREATE TABLE IF NOT EXISTS research_queries (
            id TEXT PRIMARY KEY,
            query TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            receipt_id TEXT NOT NULL,
            created_at INTEGER NOT NULL
        );
        """
        
        executeSQL(createEvidenceTable)
        executeSQL(createIncidentsTable)
        executeSQL(createResearchTable)
        
        FoTLogger.app.info("✅ Legal database initialized: \(dbPath)")
    }
    
    private func executeSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                FoTLogger.app.info("✅ SQL executed successfully")
            } else {
                FoTLogger.app.error("❌ SQL execution failed")
            }
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Real Storage Functions (NO MOCKS)
    
    public func saveEvidence(_ evidence: EvidenceRecord) throws {
        let sql = """
        INSERT INTO evidence (id, type, description, timestamp, receipt_id, created_at)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw NSError(domain: "LegalDataStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare evidence insert"])
        }
        
        let id = ULID.generate()
        let timestamp = Int(evidence.timestamp.timeIntervalSince1970)
        let createdAt = Int(Date().timeIntervalSince1970)
        
        sqlite3_bind_text(statement, 1, id, -1, nil)
        sqlite3_bind_text(statement, 2, evidence.type, -1, nil)
        sqlite3_bind_text(statement, 3, evidence.description, -1, nil)
        sqlite3_bind_int(statement, 4, Int32(timestamp))
        sqlite3_bind_text(statement, 5, evidence.receiptID, -1, nil)
        sqlite3_bind_int(statement, 6, Int32(createdAt))
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            sqlite3_finalize(statement)
            throw NSError(domain: "LegalDataStore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to insert evidence"])
        }
        
        sqlite3_finalize(statement)
        FoTLogger.app.info("✅ Evidence saved to database: \(id)")
    }
    
    public func saveIncident(_ incident: IncidentRecord) throws {
        let sql = """
        INSERT INTO incidents (id, type, description, location, timestamp, receipt_id, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw NSError(domain: "LegalDataStore", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare incident insert"])
        }
        
        let id = ULID.generate()
        let timestamp = Int(incident.timestamp.timeIntervalSince1970)
        let createdAt = Int(Date().timeIntervalSince1970)
        
        sqlite3_bind_text(statement, 1, id, -1, nil)
        sqlite3_bind_text(statement, 2, incident.type, -1, nil)
        sqlite3_bind_text(statement, 3, incident.description, -1, nil)
        sqlite3_bind_text(statement, 4, incident.location, -1, nil)
        sqlite3_bind_int(statement, 5, Int32(timestamp))
        sqlite3_bind_text(statement, 6, incident.receiptID, -1, nil)
        sqlite3_bind_int(statement, 7, Int32(createdAt))
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            sqlite3_finalize(statement)
            throw NSError(domain: "LegalDataStore", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to insert incident"])
        }
        
        sqlite3_finalize(statement)
        FoTLogger.app.info("✅ Incident saved to database: \(id)")
    }
    
    public func saveResearchQuery(_ research: LegalResearchRecord) throws {
        let sql = """
        INSERT INTO research_queries (id, query, timestamp, receipt_id, created_at)
        VALUES (?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw NSError(domain: "LegalDataStore", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare research insert"])
        }
        
        let id = ULID.generate()
        let timestamp = Int(research.timestamp.timeIntervalSince1970)
        let createdAt = Int(Date().timeIntervalSince1970)
        
        sqlite3_bind_text(statement, 1, id, -1, nil)
        sqlite3_bind_text(statement, 2, research.query, -1, nil)
        sqlite3_bind_int(statement, 3, Int32(timestamp))
        sqlite3_bind_text(statement, 4, research.receiptID, -1, nil)
        sqlite3_bind_int(statement, 5, Int32(createdAt))
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            sqlite3_finalize(statement)
            throw NSError(domain: "LegalDataStore", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to insert research query"])
        }
        
        sqlite3_finalize(statement)
        FoTLogger.app.info("✅ Research query saved to database: \(id)")
    }
    
    public func getLegalStats() throws -> LegalStats {
        var totalEvidence = 0
        var totalIncidents = 0
        var totalResearch = 0
        
        // Count evidence
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM evidence", -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                totalEvidence = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        
        // Count incidents
        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM incidents", -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                totalIncidents = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        
        // Count research queries
        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM research_queries", -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                totalResearch = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        
        return LegalStats(
            totalEvidence: totalEvidence,
            totalIncidents: totalIncidents,
            totalResearch: totalResearch
        )
    }
    
    deinit {
        if let db = db {
            sqlite3_close(db)
        }
    }
}

// MARK: - Data Models (REAL, not mocked)

public struct EvidenceRecord: Codable {
    public let type: String
    public let description: String
    public let timestamp: Date
    public let receiptID: String
    
    public init(type: String, description: String, timestamp: Date, receiptID: String) {
        self.type = type
        self.description = description
        self.timestamp = timestamp
        self.receiptID = receiptID
    }
}

public struct IncidentRecord: Codable {
    public let type: String
    public let description: String
    public let location: String
    public let timestamp: Date
    public let receiptID: String
    
    public init(type: String, description: String, location: String, timestamp: Date, receiptID: String) {
        self.type = type
        self.description = description
        self.location = location
        self.timestamp = timestamp
        self.receiptID = receiptID
    }
}

public struct LegalResearchRecord: Codable {
    public let query: String
    public let timestamp: Date
    public let receiptID: String
    
    public init(query: String, timestamp: Date, receiptID: String) {
        self.query = query
        self.timestamp = timestamp
        self.receiptID = receiptID
    }
}

public struct LegalStats: Codable {
    public let totalEvidence: Int
    public let totalIncidents: Int
    public let totalResearch: Int
    
    public init(totalEvidence: Int, totalIncidents: Int, totalResearch: Int) {
        self.totalEvidence = totalEvidence
        self.totalIncidents = totalIncidents
        self.totalResearch = totalResearch
    }
}


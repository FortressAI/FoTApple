// HealthDataStore.swift
// Real SQLite storage for health data - NO MOCKS

import Foundation
import SQLite3

/// Real health data storage with SQLite - NO SIMULATIONS
public actor HealthDataStore {
    public static let shared = HealthDataStore()
    
    private var db: OpaquePointer?
    private let dbPath: String
    
    private init() {
        // Get documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        dbPath = paths[0].appendingPathComponent("health_data.sqlite").path
        
        Task {
            await initializeDatabase()
        }
    }
    
    private func initializeDatabase() {
        // Open/create database
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            FoTLogger.app.error("❌ Failed to open health database")
            return
        }
        
        // Create tables
        let createVitalsTable = """
        CREATE TABLE IF NOT EXISTS vitals (
            id TEXT PRIMARY KEY,
            temperature REAL,
            heart_rate INTEGER,
            blood_pressure TEXT,
            weight REAL,
            timestamp INTEGER NOT NULL,
            receipt_id TEXT NOT NULL,
            created_at INTEGER NOT NULL
        );
        """
        
        let createSymptomsTable = """
        CREATE TABLE IF NOT EXISTS symptoms (
            id TEXT PRIMARY KEY,
            description TEXT NOT NULL,
            severity INTEGER,
            timestamp INTEGER NOT NULL,
            receipt_id TEXT NOT NULL,
            created_at INTEGER NOT NULL
        );
        """
        
        let createMoodsTable = """
        CREATE TABLE IF NOT EXISTS moods (
            id TEXT PRIMARY KEY,
            mood TEXT NOT NULL,
            notes TEXT,
            timestamp INTEGER NOT NULL,
            receipt_id TEXT NOT NULL,
            created_at INTEGER NOT NULL
        );
        """
        
        let createSharesTable = """
        CREATE TABLE IF NOT EXISTS health_shares (
            id TEXT PRIMARY KEY,
            clinician_code TEXT NOT NULL,
            share_date INTEGER NOT NULL,
            expiration_date INTEGER NOT NULL,
            receipt_id TEXT NOT NULL,
            encrypted INTEGER NOT NULL,
            created_at INTEGER NOT NULL
        );
        """
        
        executeSQL(createVitalsTable)
        executeSQL(createSymptomsTable)
        executeSQL(createMoodsTable)
        executeSQL(createSharesTable)
        
        FoTLogger.app.info("✅ Health database initialized: \(dbPath)")
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
    
    public func saveVitals(_ vitals: VitalsRecord) throws {
        let sql = """
        INSERT INTO vitals (id, temperature, heart_rate, blood_pressure, weight, timestamp, receipt_id, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw NSError(domain: "HealthDataStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare vitals insert"])
        }
        
        let id = ULID.generate()
        let timestamp = Int(vitals.timestamp.timeIntervalSince1970)
        let createdAt = Int(Date().timeIntervalSince1970)
        
        sqlite3_bind_text(statement, 1, id, -1, nil)
        sqlite3_bind_double(statement, 2, vitals.temperature)
        sqlite3_bind_int(statement, 3, Int32(vitals.heartRate))
        sqlite3_bind_text(statement, 4, vitals.bloodPressure, -1, nil)
        sqlite3_bind_double(statement, 5, vitals.weight)
        sqlite3_bind_int(statement, 6, Int32(timestamp))
        sqlite3_bind_text(statement, 7, vitals.receiptID, -1, nil)
        sqlite3_bind_int(statement, 8, Int32(createdAt))
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            sqlite3_finalize(statement)
            throw NSError(domain: "HealthDataStore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to insert vitals"])
        }
        
        sqlite3_finalize(statement)
        FoTLogger.app.info("✅ Vitals saved to database: \(id)")
    }
    
    public func saveSymptom(_ symptom: SymptomRecord) throws {
        let sql = """
        INSERT INTO symptoms (id, description, severity, timestamp, receipt_id, created_at)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw NSError(domain: "HealthDataStore", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare symptom insert"])
        }
        
        let id = ULID.generate()
        let timestamp = Int(symptom.timestamp.timeIntervalSince1970)
        let createdAt = Int(Date().timeIntervalSince1970)
        
        sqlite3_bind_text(statement, 1, id, -1, nil)
        sqlite3_bind_text(statement, 2, symptom.description, -1, nil)
        sqlite3_bind_int(statement, 3, Int32(symptom.severity))
        sqlite3_bind_int(statement, 4, Int32(timestamp))
        sqlite3_bind_text(statement, 5, symptom.receiptID, -1, nil)
        sqlite3_bind_int(statement, 6, Int32(createdAt))
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            sqlite3_finalize(statement)
            throw NSError(domain: "HealthDataStore", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to insert symptom"])
        }
        
        sqlite3_finalize(statement)
        FoTLogger.app.info("✅ Symptom saved to database: \(id)")
    }
    
    public func createShare(_ share: HealthShareRecord) throws {
        let sql = """
        INSERT INTO health_shares (id, clinician_code, share_date, expiration_date, receipt_id, encrypted, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw NSError(domain: "HealthDataStore", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare share insert"])
        }
        
        let id = ULID.generate()
        let shareDate = Int(share.shareDate.timeIntervalSince1970)
        let expirationDate = Int(share.expirationDate.timeIntervalSince1970)
        let createdAt = Int(Date().timeIntervalSince1970)
        
        sqlite3_bind_text(statement, 1, id, -1, nil)
        sqlite3_bind_text(statement, 2, share.clinicianCode, -1, nil)
        sqlite3_bind_int(statement, 3, Int32(shareDate))
        sqlite3_bind_int(statement, 4, Int32(expirationDate))
        sqlite3_bind_text(statement, 5, share.receiptID, -1, nil)
        sqlite3_bind_int(statement, 6, share.encrypted ? 1 : 0)
        sqlite3_bind_int(statement, 7, Int32(createdAt))
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            sqlite3_finalize(statement)
            throw NSError(domain: "HealthDataStore", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to insert share"])
        }
        
        sqlite3_finalize(statement)
        FoTLogger.app.info("✅ Health share created: \(id)")
    }
    
    public func saveMood(_ mood: MoodRecord) throws {
        let sql = """
        INSERT INTO moods (id, mood, notes, timestamp, receipt_id, created_at)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw NSError(domain: "HealthDataStore", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare mood insert"])
        }
        
        let id = ULID.generate()
        let timestamp = Int(mood.timestamp.timeIntervalSince1970)
        let createdAt = Int(Date().timeIntervalSince1970)
        
        sqlite3_bind_text(statement, 1, id, -1, nil)
        sqlite3_bind_text(statement, 2, mood.mood, -1, nil)
        sqlite3_bind_text(statement, 3, mood.notes, -1, nil)
        sqlite3_bind_int(statement, 4, Int32(timestamp))
        sqlite3_bind_text(statement, 5, mood.receiptID, -1, nil)
        sqlite3_bind_int(statement, 6, Int32(createdAt))
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            sqlite3_finalize(statement)
            throw NSError(domain: "HealthDataStore", code: 8, userInfo: [NSLocalizedDescriptionKey: "Failed to insert mood"])
        }
        
        sqlite3_finalize(statement)
        FoTLogger.app.info("✅ Mood saved to database: \(id)")
    }
    
    public func getHealthStats() throws -> HealthStats {
        var totalVitals = 0
        var totalSymptoms = 0
        var totalMoods = 0
        var totalShares = 0
        
        // Count vitals
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM vitals", -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                totalVitals = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        
        // Count symptoms
        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM symptoms", -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                totalSymptoms = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        
        // Count moods
        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM moods", -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                totalMoods = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        
        // Count active shares
        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM health_shares WHERE expiration_date > ?", -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(Date().timeIntervalSince1970))
            if sqlite3_step(statement) == SQLITE_ROW {
                totalShares = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        
        return HealthStats(
            totalVitals: totalVitals,
            totalSymptoms: totalSymptoms,
            totalMoods: totalMoods,
            totalShares: totalShares
        )
    }
    
    deinit {
        if let db = db {
            sqlite3_close(db)
        }
    }
}

// MARK: - Data Models (REAL, not mocked)

public struct VitalsRecord: Codable {
    public let temperature: Double
    public let heartRate: Int
    public let bloodPressure: String
    public let weight: Double
    public let timestamp: Date
    public let receiptID: String
    
    public init(temperature: Double, heartRate: Int, bloodPressure: String, weight: Double, timestamp: Date, receiptID: String) {
        self.temperature = temperature
        self.heartRate = heartRate
        self.bloodPressure = bloodPressure
        self.weight = weight
        self.timestamp = timestamp
        self.receiptID = receiptID
    }
}

public struct SymptomRecord: Codable {
    public let description: String
    public let severity: Int
    public let timestamp: Date
    public let receiptID: String
    
    public init(description: String, severity: Int, timestamp: Date, receiptID: String) {
        self.description = description
        self.severity = severity
        self.timestamp = timestamp
        self.receiptID = receiptID
    }
}

public struct HealthShareRecord: Codable {
    public let clinicianCode: String
    public let shareDate: Date
    public let expirationDate: Date
    public let receiptID: String
    public let encrypted: Bool
    
    public init(clinicianCode: String, shareDate: Date, expirationDate: Date, receiptID: String, encrypted: Bool) {
        self.clinicianCode = clinicianCode
        self.shareDate = shareDate
        self.expirationDate = expirationDate
        self.receiptID = receiptID
        self.encrypted = encrypted
    }
}

public struct MoodRecord: Codable {
    public let mood: String
    public let notes: String
    public let timestamp: Date
    public let receiptID: String
    
    public init(mood: String, notes: String, timestamp: Date, receiptID: String) {
        self.mood = mood
        self.notes = notes
        self.timestamp = timestamp
        self.receiptID = receiptID
    }
}

public struct HealthStats: Codable {
    public let totalVitals: Int
    public let totalSymptoms: Int
    public let totalMoods: Int
    public let totalShares: Int
    
    public init(totalVitals: Int, totalSymptoms: Int, totalMoods: Int, totalShares: Int) {
        self.totalVitals = totalVitals
        self.totalSymptoms = totalSymptoms
        self.totalMoods = totalMoods
        self.totalShares = totalShares
    }
}


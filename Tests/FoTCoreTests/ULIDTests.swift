import XCTest
@testable import FoTCore

final class ULIDTests: XCTestCase {
    func testULIDGeneration() {
        let ulid = ULID()
        
        XCTAssertEqual(ulid.string.count, 26, "ULID should be 26 characters")
        XCTAssertFalse(ulid.string.isEmpty)
    }
    
    func testULIDUniqueness() {
        let ulid1 = ULID()
        let ulid2 = ULID()
        
        XCTAssertNotEqual(ulid1.string, ulid2.string, "ULIDs should be unique")
    }
    
    func testULIDParsing() {
        let original = ULID()
        let parsed = ULID(original.string)
        
        XCTAssertNotNil(parsed, "Should parse valid ULID")
        XCTAssertEqual(parsed?.string, original.string, "Parsed ULID should match original")
    }
    
    func testInvalidULIDParsing() {
        let invalid = ULID("INVALID")
        XCTAssertNil(invalid, "Should reject invalid ULID")
        
        let tooShort = ULID("ABC")
        XCTAssertNil(tooShort, "Should reject too-short ULID")
        
        let tooLong = ULID("ABCDEFGHIJKLMNOPQRSTUVWXYZ123")
        XCTAssertNil(tooLong, "Should reject too-long ULID")
    }
    
    func testULIDTimestamp() {
        let ulid = ULID()
        let timestamp = ulid.timestamp
        let now = UInt64(Date().timeIntervalSince1970 * 1000)
        
        // Should be within a few seconds
        XCTAssertLessThan(abs(Int64(timestamp) - Int64(now)), 5000, "Timestamp should be close to now")
    }
    
    func testULIDSorting() {
        // Create ULIDs with small delay to ensure different timestamps
        let ulid1 = ULID()
        Thread.sleep(forTimeInterval: 0.01)
        let ulid2 = ULID()
        
        XCTAssertLessThan(ulid1, ulid2, "Earlier ULID should sort before later ULID")
    }
    
    func testULIDEquality() {
        let ulid1 = ULID()
        let ulid2 = ULID(ulid1.string)!
        
        XCTAssertEqual(ulid1, ulid2, "ULIDs with same string should be equal")
    }
    
    func testULIDHashable() {
        let ulid1 = ULID()
        let ulid2 = ULID(ulid1.string)!
        
        var set = Set<ULID>()
        set.insert(ulid1)
        
        XCTAssertTrue(set.contains(ulid2), "Should find ULID in set")
    }
    
    func testULIDCodable() throws {
        let ulid = ULID()
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(ulid)
        
        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ULID.self, from: data)
        
        XCTAssertEqual(ulid, decoded, "ULID should survive encode/decode")
    }
    
    func testBase32Characters() {
        let ulid = ULID()
        let validChars = Set("0123456789ABCDEFGHJKMNPQRSTVWXYZ")
        
        for char in ulid.string {
            XCTAssertTrue(validChars.contains(char), "ULID should only contain valid Base32 characters")
        }
    }
}


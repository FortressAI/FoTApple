import XCTest
@testable import FoTCore

final class CanonicalJSONTests: XCTestCase {
    func testBasicCanonicalization() throws {
        let input: [String: Any] = [
            "z": 3,
            "a": 1,
            "m": 2
        ]
        
        let canonical = try CanonicalJSON.canonicalize(input)
        let string = String(data: canonical, encoding: .utf8)!
        
        // Keys should be sorted: a, m, z
        XCTAssertTrue(string.contains("\"a\""), "Should contain key 'a'")
        XCTAssertTrue(string.contains("\"m\""), "Should contain key 'm'")
        XCTAssertTrue(string.contains("\"z\""), "Should contain key 'z'")
        
        // Check ordering
        if let aIndex = string.range(of: "\"a\""),
           let mIndex = string.range(of: "\"m\""),
           let zIndex = string.range(of: "\"z\"") {
            XCTAssertLessThan(aIndex.lowerBound, mIndex.lowerBound, "a should come before m")
            XCTAssertLessThan(mIndex.lowerBound, zIndex.lowerBound, "m should come before z")
        }
    }
    
    func testNestedObjectCanonicalization() throws {
        let input: [String: Any] = [
            "outer_z": ["inner_z": 1, "inner_a": 2],
            "outer_a": ["inner_z": 3, "inner_a": 4]
        ]
        
        let canonical = try CanonicalJSON.canonicalize(input)
        let string = String(data: canonical, encoding: .utf8)!
        
        // Outer keys should be sorted
        if let outerAIndex = string.range(of: "\"outer_a\""),
           let outerZIndex = string.range(of: "\"outer_z\"") {
            XCTAssertLessThan(outerAIndex.lowerBound, outerZIndex.lowerBound)
        }
    }
    
    func testArrayPreservesOrder() throws {
        let input: [String: Any] = [
            "array": [3, 1, 2]
        ]
        
        let canonical = try CanonicalJSON.canonicalize(input)
        let string = String(data: canonical, encoding: .utf8)!
        
        // Arrays should preserve order
        XCTAssertTrue(string.contains("[3,1,2]") || string.contains("[3, 1, 2]"))
    }
    
    func testDeterministicOutput() throws {
        let input: [String: Any] = [
            "b": 2,
            "a": 1,
            "c": 3
        ]
        
        let canonical1 = try CanonicalJSON.canonicalize(input)
        let canonical2 = try CanonicalJSON.canonicalize(input)
        
        XCTAssertEqual(canonical1, canonical2, "Canonicalization should be deterministic")
    }
    
    func testNumberNormalization() throws {
        let input: [String: Any] = [
            "int": 42,
            "double": 3.14159,
            "zero": 0
        ]
        
        let canonical = try CanonicalJSON.canonicalize(input)
        let string = String(data: canonical, encoding: .utf8)!
        
        // Numbers should be properly formatted
        XCTAssertTrue(string.contains("42"))
        XCTAssertTrue(string.contains("3.14159"))
        XCTAssertTrue(string.contains("0"))
    }
    
    func testHashConsistency() throws {
        // Same data should produce same hash
        let data1: [String: Any] = ["key": "value", "number": 123]
        let data2: [String: Any] = ["number": 123, "key": "value"]  // Different order
        
        let canonical1 = try CanonicalJSON.canonicalize(data1)
        let canonical2 = try CanonicalJSON.canonicalize(data2)
        
        let hash1 = BLAKE3.hash(canonical1)
        let hash2 = BLAKE3.hash(canonical2)
        
        XCTAssertEqual(hash1, hash2, "Canonical form should produce same hash regardless of input order")
    }
    
    func testComplexNestedStructure() throws {
        let input: [String: Any] = [
            "proteins": [
                ["name": "Hemoglobin", "sequence": "MVHLT", "mass": 64500],
                ["name": "Insulin", "sequence": "FVNQH", "mass": 5808]
            ],
            "metadata": [
                "version": "1.0",
                "timestamp": 1234567890
            ]
        ]
        
        let canonical = try CanonicalJSON.canonicalize(input)
        
        XCTAssertFalse(canonical.isEmpty)
        
        // Should be valid JSON
        let parsed = try JSONSerialization.jsonObject(with: canonical)
        XCTAssertNotNil(parsed)
    }
}


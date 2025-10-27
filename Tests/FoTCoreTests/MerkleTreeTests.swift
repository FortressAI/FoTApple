import XCTest
@testable import FoTCore

final class MerkleTreeTests: XCTestCase {
    func testMerkleTreeConstruction() throws {
        let leaves = [
            "Record 1".data(using: .utf8)!,
            "Record 2".data(using: .utf8)!,
            "Record 3".data(using: .utf8)!,
            "Record 4".data(using: .utf8)!
        ]
        
        let tree = MerkleTree(leaves: leaves)
        
        XCTAssertEqual(tree.leaves.count, 4)
        XCTAssertFalse(tree.root.isEmpty, "Root hash should not be empty")
    }
    
    func testProofGeneration() throws {
        let leaves = [
            "Leaf 0".data(using: .utf8)!,
            "Leaf 1".data(using: .utf8)!,
            "Leaf 2".data(using: .utf8)!,
            "Leaf 3".data(using: .utf8)!
        ]
        
        let tree = MerkleTree(leaves: leaves)
        
        // Generate proof for first leaf
        let proof = tree.generateProof(for: 0)
        XCTAssertNotNil(proof, "Should generate proof for valid index")
        
        // Verify proof
        if let proof = proof {
            XCTAssertTrue(tree.verify(proof), "Proof should verify against tree root")
        }
    }
    
    func testProofVerification() throws {
        let leaves = (0..<8).map { "Data \($0)".data(using: .utf8)! }
        let tree = MerkleTree(leaves: leaves)
        
        // Verify all leaf proofs
        for i in 0..<leaves.count {
            guard let proof = tree.generateProof(for: i) else {
                XCTFail("Failed to generate proof for leaf \(i)")
                continue
            }
            
            XCTAssertTrue(proof.verify(against: tree.root),
                "Proof for leaf \(i) should verify")
        }
    }
    
    func testSingleLeafTree() throws {
        let tree = MerkleTree(leaves: ["Single".data(using: .utf8)!])
        
        XCTAssertEqual(tree.leaves.count, 1)
        XCTAssertFalse(tree.root.isEmpty)
        
        let proof = tree.generateProof(for: 0)
        XCTAssertNotNil(proof)
        XCTAssertTrue(tree.verify(proof!))
    }
    
    func testEmptyTree() throws {
        let tree = MerkleTree(leaves: [])
        
        XCTAssertTrue(tree.root.isEmpty, "Empty tree should have empty root")
        XCTAssertNil(tree.generateProof(for: 0), "Empty tree should not generate proofs")
    }
    
    func testProofSerialization() throws {
        let leaves = ["A".data(using: .utf8)!, "B".data(using: .utf8)!]
        let tree = MerkleTree(leaves: leaves)
        
        guard let proof = tree.generateProof(for: 0) else {
            XCTFail("Failed to generate proof")
            return
        }
        
        // Serialize to JSON
        let jsonData = try proof.toJSON()
        XCTAssertFalse(jsonData.isEmpty, "JSON data should not be empty")
        
        // Should be valid JSON
        let json = try JSONSerialization.jsonObject(with: jsonData)
        XCTAssertNotNil(json)
    }
}


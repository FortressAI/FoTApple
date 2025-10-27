import XCTest
@testable import FoTCore

final class AKGServiceTests: XCTestCase {
    var akg: AKGService!
    
    override func setUp() async throws {
        // Use in-memory database for tests
        akg = try await AKGService(databasePath: ":memory:")
    }
    
    override func tearDown() async throws {
        akg = nil
    }
    
    func testServiceInitialization() async throws {
        let stats = try await akg.statistics()
        
        XCTAssertNotNil(stats["nodes"])
        XCTAssertNotNil(stats["edges"])
        XCTAssertNotNil(stats["attestations"])
        XCTAssertEqual(stats["nodes"] as? Int, 0, "Should start with no nodes")
    }
    
    func testCreateNode() async throws {
        let nodeId = try await akg.createNode(
            labels: ["Protein"],
            properties: [
                "sequence": "ACDEFGHIKLMN",
                "uniprot": "P12345",
                "name": "Test Protein"
            ]
        )
        
        XCTAssertFalse(nodeId.isEmpty, "Should return node ID")
        
        // Verify node was created
        let stats = try await akg.statistics()
        XCTAssertEqual(stats["nodes"] as? Int, 1, "Should have 1 node")
    }
    
    func testCreateEdge() async throws {
        // Create two nodes first
        let node1 = try await akg.createNode(
            labels: ["Protein"],
            properties: ["name": "Protein A"]
        )
        
        let node2 = try await akg.createNode(
            labels: ["Protein"],
            properties: ["name": "Protein B"]
        )
        
        // Create edge between them
        let edgeId = try await akg.createEdge(
            source: node1,
            destination: node2,
            type: "INTERACTS_WITH",
            properties: ["confidence": 0.95]
        )
        
        XCTAssertFalse(edgeId.isEmpty, "Should return edge ID")
        
        // Verify edge was created
        let stats = try await akg.statistics()
        XCTAssertEqual(stats["edges"] as? Int, 1, "Should have 1 edge")
    }
    
    func testValidatedBatchWrite() async throws {
        let mutations: [Mutation] = [
            .createNode(labels: ["Molecule"], properties: [
                "smiles": "CC(C)CC1=CC=C(C=C1)C(C)C(=O)O",
                "name": "Ibuprofen"
            ]),
            .createNode(labels: ["Target"], properties: [
                "name": "COX-2",
                "uniprot": "P35354"
            ])
        ]
        
        let attestation = try await akg.writeBatch(mutations)
        
        XCTAssertFalse(attestation.id.isEmpty, "Should have attestation ID")
        XCTAssertEqual(attestation.merkleRoot.count, 32, "Should have 32-byte Merkle root")
        XCTAssertEqual(attestation.signature.count, 64, "Should have 64-byte Ed25519 signature")
        XCTAssertEqual(attestation.records.count, 2, "Should have 2 records")
        
        // Verify nodes were created
        let stats = try await akg.statistics()
        XCTAssertEqual(stats["nodes"] as? Int, 2, "Should have 2 nodes")
        XCTAssertEqual(stats["attestations"] as? Int, 1, "Should have 1 attestation")
    }
    
    func testQueryNodesByLabel() async throws {
        // Create test nodes
        _ = try await akg.createNode(labels: ["Protein"], properties: ["name": "A"])
        _ = try await akg.createNode(labels: ["Protein"], properties: ["name": "B"])
        _ = try await akg.createNode(labels: ["Molecule"], properties: ["name": "C"])
        
        // Query proteins
        let proteins = try await akg.queryNodes(byLabel: "Protein", limit: 10)
        
        XCTAssertEqual(proteins.count, 2, "Should find 2 proteins")
    }
    
    func testMultipleLabels() async throws {
        let nodeId = try await akg.createNode(
            labels: ["Protein", "Enzyme", "Catalyst"],
            properties: ["name": "Multi-label test"]
        )
        
        XCTAssertFalse(nodeId.isEmpty)
        
        // Should be findable by any label
        let proteins = try await akg.queryNodes(byLabel: "Protein")
        XCTAssertEqual(proteins.count, 1)
        
        let enzymes = try await akg.queryNodes(byLabel: "Enzyme")
        XCTAssertEqual(enzymes.count, 1)
    }
    
    func testLargePropertyValues() async throws {
        // Test with large protein sequence
        let largeSequence = String(repeating: "ACDEFGHIKLMNPQRSTVWY", count: 100)
        
        let nodeId = try await akg.createNode(
            labels: ["Protein"],
            properties: [
                "sequence": largeSequence,
                "name": "Large protein"
            ]
        )
        
        XCTAssertFalse(nodeId.isEmpty)
    }
    
    func testConcurrentOperations() async throws {
        // Test concurrent node creation
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    do {
                        _ = try await self.akg.createNode(
                            labels: ["Test"],
                            properties: ["index": i]
                        )
                    } catch {
                        XCTFail("Concurrent operation failed: \(error)")
                    }
                }
            }
        }
        
        let stats = try await akg.statistics()
        XCTAssertEqual(stats["nodes"] as? Int, 10, "Should have 10 nodes from concurrent operations")
    }
}


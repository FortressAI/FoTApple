import XCTest
@testable import FoTCore
@testable import FoTProtein

final class ProteinDomainPackTests: XCTestCase {
    var pack: ProteinDomainPack!
    
    override func setUp() {
        pack = ProteinDomainPack()
    }
    
    func testValidProteinSequence() throws {
        let record = Record(
            type: .node,
            data: [
                "sequence": "ACDEFGHIKLMNPQRSTVWY",
                "name": "Test Protein"
            ],
            labels: ["Protein"]
        )
        
        let result = try pack.validate(record: record)
        
        XCTAssertTrue(result.isValid, "Valid protein sequence should pass")
        XCTAssertTrue(result.errors.isEmpty, "Should have no errors")
    }
    
    func testInvalidAminoAcid() throws {
        let record = Record(
            type: .node,
            data: [
                "sequence": "ACDEFGXYZ",  // X, Y, Z are not valid (X is ambiguous, Z is invalid)
                "name": "Invalid Protein"
            ],
            labels: ["Protein"]
        )
        
        let result = try pack.validate(record: record)
        
        XCTAssertFalse(result.isValid, "Invalid amino acids should fail validation")
        XCTAssertFalse(result.errors.isEmpty, "Should have errors")
    }
    
    func testProteinTooLong() throws {
        // Create sequence longer than 50,000 amino acids
        let longSequence = String(repeating: "A", count: 50_001)
        
        let record = Record(
            type: .node,
            data: [
                "sequence": longSequence,
                "name": "Too Long Protein"
            ],
            labels: ["Protein"]
        )
        
        let result = try pack.validate(record: record)
        
        XCTAssertFalse(result.isValid, "Protein exceeding length limit should fail")
    }
    
    func testValidUniProtID() throws {
        let record = Record(
            type: .node,
            data: [
                "sequence": "MVHLTPE",
                "uniprot": "P69905",  // Valid UniProt ID format
                "name": "Hemoglobin"
            ],
            labels: ["Protein"]
        )
        
        let result = try pack.validate(record: record)
        
        XCTAssertTrue(result.isValid)
    }
    
    func testHighProlineContent() throws {
        // Create sequence with >30% proline
        let sequence = "PPPPPPPPPPACDEFGHIKL"  // 50% proline
        
        let record = Record(
            type: .node,
            data: [
                "sequence": sequence,
                "name": "High Proline Protein"
            ],
            labels: ["Protein"]
        )
        
        let result = try pack.validate(record: record)
        
        // Should be valid but with warnings
        XCTAssertTrue(result.isValid, "Should still be valid")
        XCTAssertFalse(result.warnings.isEmpty, "Should have warnings about high proline")
    }
    
    func testMolecularMassValidation() throws {
        let record = Record(
            type: .node,
            data: [
                "sequence": "MVHLTPE",
                "mass_da": 64500.0,  // Valid mass for small protein
                "name": "Test Protein"
            ],
            labels: ["Protein"]
        )
        
        let result = try pack.validate(record: record)
        
        XCTAssertTrue(result.isValid)
    }
    
    func testNegativeMass() throws {
        let record = Record(
            type: .node,
            data: [
                "sequence": "MVHLTPE",
                "mass_da": -1000.0,  // Invalid negative mass
                "name": "Invalid Mass"
            ],
            labels: ["Protein"]
        )
        
        let result = try pack.validate(record: record)
        
        XCTAssertFalse(result.isValid, "Negative mass should fail validation")
    }
    
    func testNonProteinRecord() throws {
        // Test that non-protein records are ignored
        let record = Record(
            type: .node,
            data: [
                "smiles": "CC(C)O",
                "name": "Isopropanol"
            ],
            labels: ["Molecule"]
        )
        
        let result = try pack.validate(record: record)
        
        XCTAssertTrue(result.isValid, "Non-protein records should pass through")
    }
    
    func testMetrics() async throws {
        let metrics = try await pack.metrics()
        
        XCTAssertEqual(metrics["domain"] as? String, "Protein")
        XCTAssertNotNil(metrics["version"])
        XCTAssertNotNil(metrics["supported_features"])
    }
    
    func testValidationRuleCount() {
        XCTAssertGreaterThan(pack.validationRules.count, 0, "Should have validation rules")
    }
    
    func testCypherQueries() {
        XCTAssertFalse(pack.cypherQueries.isEmpty, "Should have Cypher queries")
        XCTAssertNotNil(pack.cypherQueries["find_by_uniprot"])
        XCTAssertNotNil(pack.cypherQueries["protein_interactions"])
    }
    
    func testOntologySchema() {
        XCTAssertFalse(pack.ontologySchema.isEmpty, "Should have ontology schema")
        XCTAssertTrue(pack.ontologySchema.contains("protein:Protein"), "Should define Protein class")
        XCTAssertTrue(pack.ontologySchema.contains("protein:hasSequence"), "Should define sequence property")
    }
}


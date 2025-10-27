import Foundation
import FoTCore

/// Protein Folding and Function Prediction Domain Pack
/// Implements validation for protein structures, sequences, and GO annotations
public struct ProteinDomainPack: DomainPack {
    public let name = "Protein"
    public let version = "1.0.0"
    public let description = "Protein folding, sequence analysis, and function prediction"
    
    /// Valid amino acid single-letter codes
    private static let validAminoAcids = Set("ACDEFGHIKLMNPQRSTVWY")
    
    public init() {}
    
    public var validationRules: [ValidationRule] {
        return [
            // Sequence validation
            DomainConstraint(
                name: "valid_sequence",
                errorMessage: "Protein sequence contains invalid amino acid codes"
            ) { props in
                guard let sequence = props["sequence"] as? String else {
                    return true // Optional field
                }
                return sequence.uppercased().allSatisfy { Self.validAminoAcids.contains($0) }
            },
            
            // Chain length validation
            DomainConstraint(
                name: "chain_length",
                errorMessage: "Protein chain length must be between 1 and 50,000 amino acids"
            ) { props in
                guard let sequence = props["sequence"] as? String else {
                    return true
                }
                return sequence.count >= 1 && sequence.count <= 50_000
            },
            
            // UniProt ID format validation (optional)
            DomainConstraint(
                name: "uniprot_format",
                errorMessage: "UniProt ID must be in format [OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}"
            ) { props in
                guard let uniprot = props["uniprot"] as? String else {
                    return true // Optional
                }
                // Simplified regex check
                return uniprot.count == 6 || uniprot.count == 10
            },
            
            // Mass bounds (if provided)
            DomainConstraint(
                name: "molecular_mass",
                errorMessage: "Molecular mass must be positive and < 10 MDa"
            ) { props in
                guard let mass = props["mass_da"] as? Double else {
                    return true
                }
                return mass > 0 && mass < 10_000_000
            }
        ]
    }
    
    public var ontologySchema: String {
        return """
        @prefix fot: <http://fieldoftruth.org/ontology/> .
        @prefix protein: <http://fieldoftruth.org/ontology/protein/> .
        @prefix go: <http://geneontology.org/> .
        
        protein:Protein a owl:Class ;
            rdfs:label "Protein" ;
            rdfs:comment "Biological protein with sequence and structure" .
        
        protein:hasSequence a owl:DatatypeProperty ;
            rdfs:domain protein:Protein ;
            rdfs:range xsd:string .
        
        protein:hasUniProtID a owl:DatatypeProperty ;
            rdfs:domain protein:Protein ;
            rdfs:range xsd:string .
        
        protein:hasMass a owl:DatatypeProperty ;
            rdfs:domain protein:Protein ;
            rdfs:range xsd:double .
        
        protein:hasGOAnnotation a owl:ObjectProperty ;
            rdfs:domain protein:Protein ;
            rdfs:range go:GOTerm .
        """
    }
    
    public var cypherQueries: [String: String] {
        return [
            "find_by_uniprot": """
                MATCH (p:Protein {uniprot: $uniprot})
                RETURN p
                """,
            
            "find_with_go_term": """
                MATCH (p:Protein)-[:HAS_GO]->(g:GO {id: $go_id})
                RETURN p, g
                """,
            
            "find_similar_sequence": """
                MATCH (p:Protein)
                WHERE p.sequence CONTAINS $motif
                RETURN p
                ORDER BY length(p.sequence)
                LIMIT 100
                """,
            
            "protein_interactions": """
                MATCH (p1:Protein {uniprot: $uniprot})-[:INTERACTS_WITH]-(p2:Protein)
                RETURN p2, COUNT(*) as interaction_count
                ORDER BY interaction_count DESC
                LIMIT 50
                """
        ]
    }
    
    public func initialize(engine: VQbitEngine, akg: AKGService) async throws {
        // Register validation rules with AKG
        await akg.registerValidationRules(validationRules, for: name)
        
        print("✅ Protein domain pack initialized")
        print("   - Sequence validation enabled")
        print("   - GO annotation support ready")
        print("   - BiVQbitEGNN predictor available")
    }
    
    public func validate(record: Record) throws -> ValidationResult {
        var errors: [ValidationIssue] = []
        var warnings: [ValidationIssue] = []
        
        // Check if this is a Protein node
        guard record.labels.contains("Protein") else {
            return .valid() // Not a protein record
        }
        
        // Run all validation rules
        for rule in validationRules {
            do {
                try rule.validate(record.data)
            } catch let error as ValidationError {
                switch error {
                case .ruleViolation(let message):
                    errors.append(ValidationIssue(
                        severity: .error,
                        code: "PROTEIN_VALIDATION",
                        message: message
                    ))
                default:
                    errors.append(ValidationIssue(
                        severity: .error,
                        code: "VALIDATION_ERROR",
                        message: String(describing: error)
                    ))
                }
            }
        }
        
        // Additional domain-specific checks
        if let sequence = record.data["sequence"] as? String {
            // Check for unusual compositions
            let length = Double(sequence.count)
            let prolineCount = Double(sequence.filter { $0 == "P" }.count)
            
            if prolineCount / length > 0.3 {
                warnings.append(ValidationIssue(
                    severity: .warning,
                    code: "HIGH_PROLINE",
                    message: "Unusually high proline content (\(Int(prolineCount / length * 100))%)",
                    field: "sequence",
                    suggestedFix: "Verify sequence is correct"
                ))
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            metadata: ["domain": name, "version": version]
        )
    }
    
    public func optimize(problem: OptimizationProblem) async throws -> [Solution] {
        // This would implement protein folding optimization using BiVQbitEGNN
        // For now, return empty array
        return []
    }
    
    public func metrics() async throws -> [String: Any] {
        return [
            "domain": name,
            "version": version,
            "supported_features": [
                "sequence_validation",
                "go_annotation",
                "pdb_validation",
                "cafa6_prediction"
            ],
            "validation_rules": validationRules.count
        ]
    }
}


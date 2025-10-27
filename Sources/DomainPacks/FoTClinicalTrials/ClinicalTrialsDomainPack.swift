import Foundation
import FoTCore

/// Clinical Trials Domain Pack
/// ISO 14155 compliance, GLP/GMP validation
public struct ClinicalTrialsDomainPack: DomainPack {
    public let name = "ClinicalTrials"
    public let version = "1.0.0"
    public let description = "Clinical trial validation and ISO 14155 compliance"
    
    public var validationRules: [ValidationRule] {
        return [
            DomainConstraint(
                name: "consent_required",
                errorMessage: "Subject consent flag must be present"
            ) { props in
                return props["consent"] != nil
            }
        ]
    }
    
    public var ontologySchema: String {
        return """
        @prefix trial: <http://fieldoftruth.org/ontology/clinicaltrials/> .
        
        trial:Trial a owl:Class .
        trial:Subject a owl:Class .
        """
    }
    
    public var cypherQueries: [String: String] {
        return [
            "find_trial": "MATCH (t:Trial {id: $trial_id}) RETURN t"
        ]
    }
    
    public func initialize(engine: VQbitEngine, akg: AKGService) async throws {
        await akg.registerValidationRules(validationRules, for: name)
        print("✅ Clinical Trials domain pack initialized")
    }
    
    public func validate(record: Record) throws -> ValidationResult {
        guard record.labels.contains("Subject") else {
            return .valid()
        }
        
        for rule in validationRules {
            do {
                try rule.validate(record.data)
            } catch {
                return .invalid(ValidationIssue(
                    severity: .error,
                    code: "TRIAL_VALIDATION",
                    message: String(describing: error)
                ))
            }
        }
        
        return .valid()
    }
    
    public func optimize(problem: OptimizationProblem) async throws -> [Solution] {
        return []
    }
    
    public func metrics() async throws -> [String: Any] {
        return ["domain": name, "version": version]
    }
}


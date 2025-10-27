import Foundation

/// Protocol for domain-specific validation and optimization packs
/// Each scientific domain implements this protocol to provide custom rules and capabilities
public protocol DomainPack: Sendable {
    /// Domain name (e.g., "Protein", "Chemistry", "FluidDynamics")
    var name: String { get }
    
    /// Version of this domain pack
    var version: String { get }
    
    /// Human-readable description
    var description: String { get }
    
    /// Validation rules specific to this domain
    var validationRules: [ValidationRule] { get }
    
    /// Ontology schema in Turtle/RDF format
    var ontologySchema: String { get }
    
    /// Pre-defined Cypher queries for common operations
    var cypherQueries: [String: String] { get }
    
    /// Initialize the domain pack with VQbit engine and AKG service
    func initialize(engine: VQbitEngine, akg: AKGService) async throws
    
    /// Validate a record according to domain-specific rules
    func validate(record: Record) throws -> ValidationResult
    
    /// Run domain-specific optimization
    func optimize(problem: OptimizationProblem) async throws -> [Solution]
    
    /// Get domain-specific metrics
    func metrics() async throws -> [String: Any]
}

/// Record to be validated
public struct Record: Sendable {
    public let type: RecordType
    public let data: [String: Any]
    public let labels: [String]
    
    public enum RecordType: String, Sendable {
        case node
        case edge
        case property
    }
    
    public init(type: RecordType, data: [String: Any], labels: [String] = []) {
        self.type = type
        self.data = data
        self.labels = labels
    }
}

/// Result of validation
public struct ValidationResult: Sendable {
    public let isValid: Bool
    public let errors: [ValidationIssue]
    public let warnings: [ValidationIssue]
    public let metadata: [String: Any]
    
    public init(
        isValid: Bool,
        errors: [ValidationIssue] = [],
        warnings: [ValidationIssue] = [],
        metadata: [String: Any] = [:]
    ) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
        self.metadata = metadata
    }
    
    public static func valid() -> ValidationResult {
        return ValidationResult(isValid: true)
    }
    
    public static func invalid(_ error: ValidationIssue) -> ValidationResult {
        return ValidationResult(isValid: false, errors: [error])
    }
}

/// Validation issue (error or warning)
public struct ValidationIssue: Sendable {
    public let severity: Severity
    public let code: String
    public let message: String
    public let field: String?
    public let suggestedFix: String?
    
    public enum Severity: String, Sendable {
        case error
        case warning
        case info
    }
    
    public init(
        severity: Severity,
        code: String,
        message: String,
        field: String? = nil,
        suggestedFix: String? = nil
    ) {
        self.severity = severity
        self.code = code
        self.message = message
        self.field = field
        self.suggestedFix = suggestedFix
    }
}

/// Domain-specific constraint
public struct DomainConstraint: ValidationRule, Sendable {
    public let name: String
    public let check: @Sendable ([String: Any]) throws -> Bool
    public let errorMessage: String
    
    public init(
        name: String,
        errorMessage: String,
        check: @escaping @Sendable ([String: Any]) throws -> Bool
    ) {
        self.name = name
        self.check = check
        self.errorMessage = errorMessage
    }
    
    public func validate(_ properties: [String: Any]) throws {
        let result = try check(properties)
        if !result {
            throw ValidationError.ruleViolation(errorMessage)
        }
    }
}

/// Registry for domain packs
public actor DomainPackRegistry {
    private var packs: [String: any DomainPack] = [:]
    
    public init() {}
    
    /// Register a domain pack
    public func register(_ pack: any DomainPack) {
        packs[pack.name] = pack
        print("✅ Registered domain pack: \(pack.name) v\(pack.version)")
    }
    
    /// Get a domain pack by name
    public func get(_ name: String) -> (any DomainPack)? {
        return packs[name]
    }
    
    /// List all registered packs
    public func list() -> [String] {
        return Array(packs.keys).sorted()
    }
    
    /// Get validation rules for a domain
    public func rules(for domain: String) -> [ValidationRule] {
        return packs[domain]?.validationRules ?? []
    }
}


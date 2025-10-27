import Foundation

/// AKG validation pipeline
/// Validates mutations, builds Merkle trees, and creates attestations
public actor Validator {
    private let db: AKGDB
    private var domainRules: [String: [ValidationRule]] = [:]
    public let version = "fot-0.1.0"
    
    public init(db: AKGDB) {
        self.db = db
    }
    
    /// Register domain-specific validation rules
    public func registerRules(_ rules: [ValidationRule], for domain: String) {
        domainRules[domain] = rules
    }
    
    /// Validate a batch of mutations and create attestation
    public func validateBatch(_ mutations: [Mutation]) async throws -> Attestation {
        // 1. Validate each mutation
        var validatedRecords: [ValidatedRecord] = []
        
        for mutation in mutations {
            let record = try await validateMutation(mutation)
            validatedRecords.append(record)
        }
        
        // 2. Canonicalize and hash each record
        var leafHashes: [Data] = []
        var canonicalRecords: [Data] = []
        
        for record in validatedRecords {
            let canonical = try CanonicalJSON.canonicalize(record.data)
            let hash = BLAKE3.hash(canonical)
            
            canonicalRecords.append(canonical)
            leafHashes.append(hash)
        }
        
        // 3. Build Merkle tree
        let merkleTree = MerkleTree(leaves: leafHashes)
        
        // 4. Create attestation
        let attestationId = ULID().string
        let timestamp = Date()
        
        // 5. Sign with Ed25519 (would use Secure Enclave in production)
        let keyPair = Ed25519Signer.generateKeyPair()
        let signatureMessage = AttestationSignature.createSignatureMessage(
            merkleRoot: merkleTree.root,
            attestationId: attestationId,
            timestamp: timestamp
        )
        let signature = try Ed25519Signer.sign(signatureMessage, with: keyPair.privateKey)
        
        // 6. Store attestation in database
        try await storeAttestation(
            id: attestationId,
            merkleRoot: merkleTree.root,
            signature: signature,
            publicKey: Ed25519Signer.exportPublicKey(keyPair.publicKey),
            timestamp: timestamp,
            validatedRecords: validatedRecords
        )
        
        return Attestation(
            id: attestationId,
            merkleRoot: merkleTree.root,
            signature: signature,
            publicKey: Ed25519Signer.exportPublicKey(keyPair.publicKey),
            schemaVersion: "akg-1.4.2",
            validatorVersion: version,
            timestamp: timestamp,
            records: validatedRecords,
            merkleTree: merkleTree
        )
    }
    
    /// Validate a single mutation
    private func validateMutation(_ mutation: Mutation) async throws -> ValidatedRecord {
        switch mutation {
        case .createNode(let labels, let properties):
            // Schema validation
            try validateLabels(labels)
            try validateProperties(properties)
            
            // Domain-specific validation
            for label in labels {
                if let rules = domainRules[label] {
                    for rule in rules {
                        try rule.validate(properties)
                    }
                }
            }
            
            return ValidatedRecord(
                type: .node,
                data: ["labels": labels, "props": properties],
                hash: Data(),  // Will be computed later
                validationStatus: .passed
            )
            
        case .createEdge(let source, let destination, let type, let properties):
            // Validate edge type
            try validateEdgeType(type)
            try validateProperties(properties)
            
            // Domain-specific validation
            if let rules = domainRules[type] {
                for rule in rules {
                    try rule.validate(properties)
                }
            }
            
            return ValidatedRecord(
                type: .edge,
                data: ["src": source, "dst": destination, "type": type, "props": properties],
                hash: Data(),
                validationStatus: .passed
            )
            
        case .updateNode(let id, let properties):
            try validateProperties(properties)
            
            return ValidatedRecord(
                type: .nodeUpdate,
                data: ["id": id, "props": properties],
                hash: Data(),
                validationStatus: .passed
            )
        }
    }
    
    /// Validate node labels
    private func validateLabels(_ labels: [String]) throws {
        guard !labels.isEmpty else {
            throw ValidationError.emptyLabels
        }
        
        for label in labels {
            guard label.count > 0 && label.count <= 128 else {
                throw ValidationError.invalidLabel(label)
            }
        }
    }
    
    /// Validate edge type
    private func validateEdgeType(_ type: String) throws {
        guard type.count > 0 && type.count <= 128 else {
            throw ValidationError.invalidEdgeType(type)
        }
    }
    
    /// Validate properties dictionary
    private func validateProperties(_ properties: [String: Any]) throws {
        // Properties should be JSON-serializable
        do {
            _ = try JSONSerialization.data(withJSONObject: properties)
        } catch {
            throw ValidationError.invalidProperties("Not JSON-serializable")
        }
    }
    
    /// Store attestation in database
    private func storeAttestation(
        id: String,
        merkleRoot: Data,
        signature: Data,
        publicKey: Data,
        timestamp: Date,
        validatedRecords: [ValidatedRecord]
    ) async throws {
        try await db.dbQueue.write { db in
            let ts = Int64(timestamp.timeIntervalSince1970 * 1000)
            
            // Insert attestation
            try db.execute(
                sql: """
                INSERT INTO attestations (id, merkle_root, sig, signer_pk, schema_version, validator_version, ts)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                arguments: [id, merkleRoot, signature, publicKey, "akg-1.4.2", self.version, ts]
            )
        }
    }
}

// MARK: - Supporting Types

public enum Mutation: Sendable {
    case createNode(labels: [String], properties: [String: Any])
    case createEdge(source: String, destination: String, type: String, properties: [String: Any])
    case updateNode(id: String, properties: [String: Any])
}

public struct ValidatedRecord: Sendable {
    public enum RecordType: String, Sendable {
        case node
        case edge
        case nodeUpdate
    }
    
    public enum ValidationStatus: String, Sendable {
        case passed
        case failed
        case warning
    }
    
    public let type: RecordType
    public let data: [String: Any]
    public let hash: Data
    public let validationStatus: ValidationStatus
}

public struct Attestation: Sendable {
    public let id: String
    public let merkleRoot: Data
    public let signature: Data
    public let publicKey: Data
    public let schemaVersion: String
    public let validatorVersion: String
    public let timestamp: Date
    public let records: [ValidatedRecord]
    public let merkleTree: MerkleTree
    public var chainTx: String?
    
    /// Serialize attestation for blockchain submission
    public func toJSON() throws -> Data {
        let dict: [String: Any] = [
            "attestation_id": id,
            "merkle_root": "b3:" + merkleRoot.toHexString(),
            "schema_version": schemaVersion,
            "validator_version": validatorVersion,
            "signer_pk": "ed25519:" + publicKey.toHexString(),
            "signature": "ed25519:" + signature.toHexString(),
            "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000)
        ]
        
        return try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
    }
}

public protocol ValidationRule: Sendable {
    func validate(_ properties: [String: Any]) throws
}

public enum ValidationError: Error {
    case emptyLabels
    case invalidLabel(String)
    case invalidEdgeType(String)
    case invalidProperties(String)
    case ruleViolation(String)
}


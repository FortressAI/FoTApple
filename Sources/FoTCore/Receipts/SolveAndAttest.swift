// SolveAndAttest.swift
// Wrapper that turns VQbit operations into attested, receipt-bearing results
// Every domain pack should use this for cryptographic validation

import Foundation

/// Result with cryptographic attestation
public struct AttestedResult<T: Codable> {
    public let result: T
    public let receipt: ReceiptBundle
    public let attestationID: String
    
    public init(result: T, receipt: ReceiptBundle, attestationID: String) {
        self.result = result
        self.receipt = receipt
        self.attestationID = attestationID
    }
}

/// Solve and attest wrapper for VQbit operations
public actor SolveAndAttest {
    private let engine: VQbitEngineProtocol
    private let receiptStore: ReceiptStore
    
    public init(engine: VQbitEngineProtocol, receiptStore: ReceiptStore) {
        self.engine = engine
        self.receiptStore = receiptStore
    }
    
    /// Perform evolution and generate receipt
    public func evolve<T: Codable>(
        unit: EvolutionUnit,
        extractResult: (Snapshot) -> T
    ) async throws -> AttestedResult<T> {
        // Perform evolution
        let snapshot = try await engine.step(unit)
        
        // Extract result
        let result = extractResult(snapshot)
        
        // Generate receipt
        let receipt = try await engine.receipt()
        
        // Store receipt
        let status = await engine.status()
        try await receiptStore.store(receipt, operationType: "evolve", dimension: status.dimension)
        
        return AttestedResult(
            result: result,
            receipt: receipt,
            attestationID: receipt.id
        )
    }
    
    /// Perform collapse and generate receipt
    public func collapse<T: Codable>(
        policy: CollapsePolicy,
        extractResult: (Snapshot) -> T
    ) async throws -> AttestedResult<T> {
        // Perform collapse
        let snapshot = try await engine.collapse(policy)
        
        // Extract result
        let result = extractResult(snapshot)
        
        // Generate receipt
        let receipt = try await engine.receipt()
        
        // Store receipt
        let status = await engine.status()
        try await receiptStore.store(receipt, operationType: "collapse", dimension: status.dimension)
        
        return AttestedResult(
            result: result,
            receipt: receipt,
            attestationID: receipt.id
        )
    }
    
    /// Generic solve with attestation
    /// Use this for domain-specific solvers (FSI, CFD, CDS, etc.)
    public func solve<Input: Codable, Output: Codable>(
        operationType: String,
        inputs: Input,
        solver: () async throws -> Output
    ) async throws -> AttestedResult<Output> {
        // Serialize inputs
        let inputData = try JSONEncoder().encode(inputs)
        
        // Run solver
        let output = try await solver()
        
        // Serialize outputs
        let outputData = try JSONEncoder().encode(output)
        
        // Create canonical representation
        let receiptData: [String: Any] = [
            "operation": operationType,
            "timestamp": Date().ISO8601Format(),
            "inputs_hash": BLAKE3.hashHex(String(data: inputData, encoding: .utf8) ?? ""),
            "outputs_hash": BLAKE3.hashHex(String(data: outputData, encoding: .utf8) ?? "")
        ]
        
        let canonicalJSON = try CanonicalJSON.canonicalize(receiptData)
        let hash = BLAKE3.hash(String(data: canonicalJSON, encoding: .utf8) ?? "")
        
        // Mock signature for now (TODO: Use Secure Enclave)
        let signature = Data(hash.prefix(64))
        
        // Create receipt
        let id = ULID().string
        let receipt = ReceiptBundle(
            id: id,
            timestamp: Date(),
            inputs: inputData,
            outputs: outputData,
            canonicalJSON: canonicalJSON,
            hash: hash,
            signature: signature,
            merkleRoot: hash,
            engineType: "Generic Solver",
            deviceCapability: VQbitEngineFactory.detectDevice().description,
            deterministic: false
        )
        
        // Store receipt
        let status = await engine.status()
        try await receiptStore.store(receipt, operationType: operationType, dimension: status.dimension)
        
        return AttestedResult(
            result: output,
            receipt: receipt,
            attestationID: receipt.id
        )
    }
}

/// Codable wrapper for JSON dictionaries
public struct JSONDict: Codable {
    public let data: [String: String]
    
    public init(_ data: [String: Any]) {
        // Convert to string representation
        var stringDict: [String: String] = [:]
        for (key, value) in data {
            stringDict[key] = "\(value)"
        }
        self.data = stringDict
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.data = try container.decode([String: String].self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
}

/// Convenience extensions for common operations
extension SolveAndAttest {
    
    /// Attest clinical decision support
    public func attestCDS(
        patientContext: JSONDict,
        recommendation: JSONDict
    ) async throws -> AttestedResult<JSONDict> {
        try await solve(
            operationType: "clinical_decision_support",
            inputs: patientContext,
            solver: { recommendation }
        )
    }
    
    /// Attest legal analysis
    public func attestLegalAnalysis(
        caseContext: JSONDict,
        analysis: JSONDict
    ) async throws -> AttestedResult<JSONDict> {
        try await solve(
            operationType: "legal_analysis",
            inputs: caseContext,
            solver: { analysis }
        )
    }
    
    /// Attest education assessment
    public func attestAssessment(
        studentResponse: JSONDict,
        score: JSONDict
    ) async throws -> AttestedResult<JSONDict> {
        try await solve(
            operationType: "education_assessment",
            inputs: studentResponse,
            solver: { score }
        )
    }
    
    /// Attest FSI eigensolve
    public func attestFSI(
        meshConfig: JSONDict,
        eigenvalues: [Double]
    ) async throws -> AttestedResult<[Double]> {
        try await solve(
            operationType: "fsi_eigensolve",
            inputs: meshConfig,
            solver: { eigenvalues }
        )
    }
}


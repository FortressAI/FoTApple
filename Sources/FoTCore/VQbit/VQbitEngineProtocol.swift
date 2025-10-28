// VQbitEngineProtocol.swift
// Stable contract for all VQbit implementations (Metal GPU, Accelerate CPU)
//
// This protocol defines the IMMUTABLE interface that all domain packs depend on.
// NEVER break this contract - extend via new methods only.

import Foundation

/// Device capability matrix for adaptive dimension scaling
public enum DeviceCapability {
    case watch(dimension: Int = 512)
    case iPhone(dimension: Int = 2048)
    case iPad(dimension: Int = 4096)
    case Mac(dimension: Int = 8096)
    case MacStudio(dimension: Int = 16384)
    
    public var dimension: Int {
        switch self {
        case .watch(let d): return d
        case .iPhone(let d): return d
        case .iPad(let d): return d
        case .Mac(let d): return d
        case .MacStudio(let d): return d
        }
    }
    
    public var description: String {
        switch self {
        case .watch: return "Apple Watch"
        case .iPhone: return "iPhone"
        case .iPad: return "iPad"
        case .Mac: return "Mac"
        case .MacStudio: return "Mac Studio"
        }
    }
}

/// Configuration for VQbit engine
public struct VQbitConfig {
    public let dimension: Int
    public let seed: UInt64?
    public let useGPU: Bool
    public let virtueWeights: VirtueWeights
    public let adaptiveDimension: Bool
    
    public init(
        dimension: Int = 8096,
        seed: UInt64? = nil,
        useGPU: Bool = true,
        virtueWeights: VirtueWeights = VirtueWeights(),
        adaptiveDimension: Bool = true
    ) {
        self.dimension = dimension
        self.seed = seed
        self.useGPU = useGPU
        self.virtueWeights = virtueWeights
        self.adaptiveDimension = adaptiveDimension
    }
}

/// Virtue weights for collapse policy
public struct VirtueWeights {
    public let justice: Double
    public let temperance: Double
    public let prudence: Double
    public let fortitude: Double
    
    public init(
        justice: Double = 1.0,
        temperance: Double = 1.0,
        prudence: Double = 1.0,
        fortitude: Double = 1.0
    ) {
        self.justice = justice
        self.temperance = temperance
        self.prudence = prudence
        self.fortitude = fortitude
    }
}

/// Evolution unit for step-by-step quantum evolution
public struct EvolutionUnit {
    public let hamiltonianTerms: [HamiltonianTerm]
    public let timeStep: Double
    public let iterations: Int
    
    public init(
        hamiltonianTerms: [HamiltonianTerm] = [],
        timeStep: Double = 0.01,
        iterations: Int = 100
    ) {
        self.hamiltonianTerms = hamiltonianTerms
        self.timeStep = timeStep
        self.iterations = iterations
    }
}

/// Hamiltonian term for evolution
public struct HamiltonianTerm {
    public let type: HamiltonianType
    public let coefficient: Double
    
    public init(type: HamiltonianType, coefficient: Double) {
        self.type = type
        self.coefficient = coefficient
        }
}

/// Types of Hamiltonian operators
public enum HamiltonianType {
    case justice
    case temperance
    case prudence
    case fortitude
    case laplacian
    case custom(String)
}

/// Collapse policy for measurement
public struct CollapsePolicy {
    public let virtueWeights: VirtueWeights
    public let deterministic: Bool
    public let threshold: Double
    
    public init(
        virtueWeights: VirtueWeights = VirtueWeights(),
        deterministic: Bool = false,
        threshold: Double = 0.01
    ) {
        self.virtueWeights = virtueWeights
        self.deterministic = deterministic
        self.threshold = threshold
    }
}

/// Snapshot of VQbit state
public struct Snapshot {
    public let state: VQbitState
    public let virtueScores: [VirtueType: Double]
    public let coherence: Double
    public let entanglement: Double
    public let timestamp: Date
    public let receiptID: String?
    
    public init(
        state: VQbitState,
        virtueScores: [VirtueType: Double],
        coherence: Double,
        entanglement: Double,
        timestamp: Date = Date(),
        receiptID: String? = nil
    ) {
        self.state = state
        self.virtueScores = virtueScores
        self.coherence = coherence
        self.entanglement = entanglement
        self.timestamp = timestamp
        self.receiptID = receiptID
    }
}

/// Receipt bundle for cryptographic validation
public struct ReceiptBundle {
    public let id: String
    public let timestamp: Date
    public let inputs: Data
    public let outputs: Data
    public let canonicalJSON: Data
    public let hash: Data
    public let signature: Data
    public let merkleRoot: Data
    public let engineType: String  // "Metal" or "Accelerate"
    public let deviceCapability: String
    public let deterministic: Bool
    
    public init(
        id: String,
        timestamp: Date = Date(),
        inputs: Data,
        outputs: Data,
        canonicalJSON: Data,
        hash: Data,
        signature: Data,
        merkleRoot: Data,
        engineType: String,
        deviceCapability: String,
        deterministic: Bool
    ) {
        self.id = id
        self.timestamp = timestamp
        self.inputs = inputs
        self.outputs = outputs
        self.canonicalJSON = canonicalJSON
        self.hash = hash
        self.signature = signature
        self.merkleRoot = merkleRoot
        self.engineType = engineType
        self.deviceCapability = deviceCapability
        self.deterministic = deterministic
    }
}

/// **STABLE CONTRACT** - Do NOT break this interface
public protocol VQbitEngineProtocol {
    /// Configure the engine
    func configure(_ config: VQbitConfig) throws
    
    /// Perform evolution step
    func step(_ unit: EvolutionUnit) async throws -> Snapshot
    
    /// Collapse quantum state
    func collapse(_ policy: CollapsePolicy) async throws -> Snapshot
    
    /// Get current receipt
    func receipt() async throws -> ReceiptBundle
    
    /// Get engine status
    func status() async -> EngineStatus
    
    /// Reset engine to initial state
    func reset() async throws
}

/// Engine status
public struct EngineStatus {
    public let engineType: String
    public let dimension: Int
    public let isConfigured: Bool
    public let currentState: VQbitState?
    public let device: String
    public let memoryUsage: UInt64
    
    public init(
        engineType: String,
        dimension: Int,
        isConfigured: Bool,
        currentState: VQbitState?,
        device: String,
        memoryUsage: UInt64
    ) {
        self.engineType = engineType
        self.dimension = dimension
        self.isConfigured = isConfigured
        self.currentState = currentState
        self.device = device
        self.memoryUsage = memoryUsage
    }
}

/// Error types for VQbit engines
public enum VQbitEngineError: Error {
    case notConfigured
    case gpuNotAvailable
    case outOfMemory
    case invalidDimension
    case evolutionFailed(String)
    case collapseFailed(String)
    case receiptGenerationFailed(String)
}


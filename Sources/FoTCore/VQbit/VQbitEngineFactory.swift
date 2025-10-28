// VQbitEngineFactory.swift
// Factory for selecting optimal VQbit implementation
// Metal GPU (when available) → Accelerate CPU (fallback)

import Foundation
#if canImport(Metal)
import Metal
#endif

public final class VQbitEngineFactory {
    
    /// Create the best available VQbit engine for this device
    public static func create(
        config: VQbitConfig? = nil,
        forceImplementation: EngineImplementation? = nil
    ) async throws -> VQbitEngineProtocol {
        
        let implementation = forceImplementation ?? selectOptimalImplementation()
        let finalConfig = config ?? defaultConfig(for: implementation)
        
        let engine: VQbitEngineProtocol
        
        switch implementation {
        case .metal:
            #if canImport(Metal)
            // TODO: Implement MetalVQbitEngine when Metal implementation is ready
            print("⚠️ Metal implementation not yet available, falling back to Accelerate")
            engine = AccelerateVQbitEngine(dimension: finalConfig.dimension)
            #else
            print("⚠️ Metal not available on this platform, using Accelerate")
            engine = AccelerateVQbitEngine(dimension: finalConfig.dimension)
            #endif
            
        case .accelerate:
            engine = AccelerateVQbitEngine(dimension: finalConfig.dimension)
        }
        
        try engine.configure(finalConfig)
        
        print("✅ VQbit Engine initialized")
        print("   Implementation: \(implementation.description)")
        print("   Dimension: \(finalConfig.dimension)")
        print("   Device: \(detectDevice().description)")
        print("   Deterministic: \(finalConfig.seed != nil)")
        
        return engine
    }
    
    /// Select optimal implementation based on device capabilities
    private static func selectOptimalImplementation() -> EngineImplementation {
        #if canImport(Metal)
        if let _ = MTLCreateSystemDefaultDevice() {
            // Metal available - check if we should use it
            let device = detectDevice()
            switch device {
            case .watch:
                // Watch: Use Accelerate (better battery life)
                return .accelerate
            case .iPhone, .iPad, .Mac, .MacStudio:
                // TODO: Enable Metal once implemented
                // return .metal
                return .accelerate
            }
        }
        #endif
        
        return .accelerate
    }
    
    /// Detect device type
    public static func detectDevice() -> DeviceCapability {
        #if os(watchOS)
        return .watch()
        #elseif os(iOS)
        // Simple heuristic - check memory
        let memory = ProcessInfo.processInfo.physicalMemory
        if memory > 6 * 1024 * 1024 * 1024 {  // > 6GB = Pro models
            return .iPhone(dimension: 4096)
        }
        return .iPhone()
        #elseif os(macOS)
        // Check if Mac Studio (M1 Ultra/Max) or regular Mac
        let memory = ProcessInfo.processInfo.physicalMemory
        if memory > 64 * 1024 * 1024 * 1024 {  // > 64GB = Studio
            return .MacStudio()
        }
        return .Mac()
        #else
        return .Mac()
        #endif
    }
    
    /// Create default config for device
    private static func defaultConfig(for implementation: EngineImplementation) -> VQbitConfig {
        let device = detectDevice()
        return VQbitConfig(
            dimension: device.dimension,
            seed: nil,
            useGPU: implementation == .metal,
            virtueWeights: VirtueWeights(),
            adaptiveDimension: true
        )
    }
}

/// Available engine implementations
public enum EngineImplementation {
    case metal      // GPU-accelerated (MPSGraph)
    case accelerate // CPU-accelerated (Accelerate framework)
    
    public var description: String {
        switch self {
        case .metal: return "Metal GPU"
        case .accelerate: return "Accelerate CPU"
        }
    }
}

/// Adapter to make existing VQbitEngine conform to protocol
public final class AccelerateVQbitEngine: VQbitEngineProtocol {
    private let engine: VQbitEngine
    private var config: VQbitConfig?
    private var lastSnapshot: Snapshot?
    
    public init(dimension: Int) {
        self.engine = VQbitEngine(dimension: dimension)
    }
    
    public func configure(_ config: VQbitConfig) throws {
        self.config = config
        // Engine is already initialized with dimension
    }
    
    public func step(_ unit: EvolutionUnit) async throws -> Snapshot {
        guard config != nil else {
            throw VQbitEngineError.notConfigured
        }
        
        // Use existing engine's evolution
        let state = await engine.createVQbitState()
        
        // Calculate scalar entanglement measure (average of entanglement matrix sizes)
        let entanglementScalar = state.entanglement.isEmpty ? 0.0 : Double(state.entanglement.count) / 10.0
        
        let snapshot = Snapshot(
            state: state,
            virtueScores: state.virtueScores,
            coherence: state.coherence,
            entanglement: entanglementScalar,
            timestamp: Date()
        )
        
        self.lastSnapshot = snapshot
        return snapshot
    }
    
    public func collapse(_ policy: CollapsePolicy) async throws -> Snapshot {
        guard config != nil else {
            throw VQbitEngineError.notConfigured
        }
        
        // Use existing engine's collapse
        let state = await engine.createVQbitState()
        
        // Apply virtue collapse
        let collapsedState = await engine.applyVirtueCollapse(
            state: state,
            targetVirtues: [
                .justice: policy.virtueWeights.justice,
                .temperance: policy.virtueWeights.temperance,
                .prudence: policy.virtueWeights.prudence,
                .fortitude: policy.virtueWeights.fortitude
            ],
            strength: 0.1
        )
        
        // Calculate scalar entanglement measure
        let entanglementScalar = collapsedState.entanglement.isEmpty ? 0.0 : Double(collapsedState.entanglement.count) / 10.0
        
        let snapshot = Snapshot(
            state: collapsedState,
            virtueScores: collapsedState.virtueScores,
            coherence: collapsedState.coherence,
            entanglement: entanglementScalar,
            timestamp: Date()
        )
        
        self.lastSnapshot = snapshot
        return snapshot
    }
    
    public func receipt() async throws -> ReceiptBundle {
        guard let config = self.config else {
            throw VQbitEngineError.notConfigured
        }
        
        guard let snapshot = self.lastSnapshot else {
            throw VQbitEngineError.receiptGenerationFailed("No operations performed yet")
        }
        
        // Create receipt
        let id = ULID().string
        let inputs = try JSONEncoder().encode(["dimension": config.dimension])
        let outputs = try JSONEncoder().encode(["coherence": snapshot.coherence])
        
        // Canonical JSON
        let receiptData: [String: Any] = [
            "id": id,
            "timestamp": snapshot.timestamp.ISO8601Format(),
            "dimension": config.dimension,
            "coherence": snapshot.coherence,
            "engine": "Accelerate"
        ]
        let canonicalJSON = try CanonicalJSON.canonicalize(receiptData)
        let hash = BLAKE3.hash(String(data: canonicalJSON, encoding: .utf8) ?? "")
        
        // Mock signature and Merkle root for now
        let signature = Data(hash.prefix(64))
        let merkleRoot = hash
        
        return ReceiptBundle(
            id: id,
            timestamp: snapshot.timestamp,
            inputs: inputs,
            outputs: outputs,
            canonicalJSON: canonicalJSON,
            hash: hash,
            signature: signature,
            merkleRoot: merkleRoot,
            engineType: "Accelerate",
            deviceCapability: VQbitEngineFactory.detectDevice().description,
            deterministic: config.seed != nil
        )
    }
    
    public func status() async -> EngineStatus {
        let device = VQbitEngineFactory.detectDevice()
        return EngineStatus(
            engineType: "Accelerate",
            dimension: await engine.dimension,
            isConfigured: config != nil,
            currentState: lastSnapshot?.state,
            device: device.description,
            memoryUsage: 0  // TODO: Calculate actual memory usage
        )
    }
    
    public func reset() async throws {
        self.lastSnapshot = nil
        // Engine keeps its dimension, just clear state
    }
}


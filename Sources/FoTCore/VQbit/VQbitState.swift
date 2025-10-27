import Foundation
import Accelerate
import Numerics

/// Quantum state representation for virtual quantum bits (vQbits)
/// Implements 8096-dimensional complex amplitude space with entanglement tracking
public struct VQbitState: Sendable {
    /// Complex amplitudes in 8096-dimensional Hilbert space
    /// Stored as interleaved real/imaginary components for BLAS compatibility
    public let amplitudes: [DSPComplex]
    
    /// Quantum coherence measure [0, 1]
    /// Based on off-diagonal density matrix elements
    public let coherence: Double
    
    /// Entanglement map with other vQbits
    /// Keys are vQbit identifiers, values are entanglement matrices
    public let entanglement: [String: [[DSPComplex]]]
    
    /// Virtue scores for each cardinal virtue [0, 1]
    public let virtueScores: [VirtueType: Double]
    
    /// Metadata about the quantum state
    public let metadata: [String: Any]
    
    /// Default dimension for vQbit systems
    public static let standardDimension = 8096
    
    /// Initialize a vQbit state
    public init(
        amplitudes: [DSPComplex],
        coherence: Double,
        entanglement: [String: [[DSPComplex]]] = [:],
        virtueScores: [VirtueType: Double],
        metadata: [String: Any] = [:]
    ) {
        self.amplitudes = amplitudes
        self.coherence = coherence
        self.entanglement = entanglement
        self.virtueScores = virtueScores
        self.metadata = metadata
    }
    
    /// Create a uniform superposition state
    public static func uniformSuperposition(dimension: Int = standardDimension) -> VQbitState {
        // |ψ⟩ = 1/√N ∑|i⟩ - equal superposition of all basis states
        let amplitude = 1.0 / sqrt(Double(dimension))
        let amplitudes = Array(repeating: DSPComplex(real: Float(amplitude), imag: 0), count: dimension)
        
        return VQbitState(
            amplitudes: amplitudes,
            coherence: 1.0, // Maximum coherence for pure state
            virtueScores: VirtueType.defaultWeights,
            metadata: ["type": "uniform_superposition"]
        )
    }
    
    /// Create a random superposition state with proper normalization
    public static func randomSuperposition(
        dimension: Int = standardDimension,
        seed: UInt64? = nil
    ) -> VQbitState {
        var generator: any RandomNumberGenerator = seed.map { SeededRandomNumberGenerator(seed: $0) as any RandomNumberGenerator } ?? SystemRandomNumberGenerator()
        
        // Generate random complex amplitudes
        var amplitudes = [DSPComplex]()
        var normSquared: Double = 0.0
        
        for _ in 0..<dimension {
            let real = Float.random(in: -1...1, using: &generator) * 0.1
            let imag = Float.random(in: -1...1, using: &generator) * 0.1
            amplitudes.append(DSPComplex(real: real, imag: imag))
            normSquared += Double(real * real + imag * imag)
        }
        
        // Normalize: ∑|ψᵢ|² = 1
        let normFactor = Float(1.0 / sqrt(normSquared))
        for i in 0..<dimension {
            amplitudes[i].real *= normFactor
            amplitudes[i].imag *= normFactor
        }
        
        // Calculate coherence and virtue scores
        let coherence = Self.calculateCoherence(amplitudes)
        let virtueScores = VirtueType.defaultWeights // Will be updated by virtue operators
        
        return VQbitState(
            amplitudes: amplitudes,
            coherence: coherence,
            virtueScores: virtueScores,
            metadata: ["type": "random_superposition"]
        )
    }
    
    /// Calculate quantum coherence from density matrix off-diagonal elements
    internal static func calculateCoherence(_ amplitudes: [DSPComplex]) -> Double {
        // Coherence = ∑ᵢ≠ⱼ |ρᵢⱼ| / (N(N-1)/2)
        // For pure state: ρᵢⱼ = ψᵢ ψⱼ*
        
        let n = amplitudes.count
        guard n > 1 else { return 0.0 }
        
        var coherenceSum: Double = 0.0
        let maxSamples = min(n, 1000) // Sample for large matrices
        
        for i in 0..<maxSamples {
            for j in (i+1)..<maxSamples {
                // ρᵢⱼ = ψᵢ ψⱼ* = (aᵢ + ibᵢ)(aⱼ - ibⱼ)
                let psi_i = amplitudes[i]
                let psi_j = amplitudes[j]
                
                let real = psi_i.real * psi_j.real + psi_i.imag * psi_j.imag
                let imag = psi_i.imag * psi_j.real - psi_i.real * psi_j.imag
                
                coherenceSum += sqrt(Double(real * real + imag * imag))
            }
        }
        
        let maxCoherence = Double(maxSamples * (maxSamples - 1)) / 2.0
        return maxCoherence > 0 ? coherenceSum / maxCoherence : 0.0
    }
    
    /// Check if state is properly normalized
    public var isNormalized: Bool {
        var normSquared: Double = 0.0
        for amplitude in amplitudes {
            normSquared += Double(amplitude.real * amplitude.real + amplitude.imag * amplitude.imag)
        }
        return abs(normSquared - 1.0) < 1e-6
    }
    
    /// Get dimension of the Hilbert space
    public var dimension: Int {
        return amplitudes.count
    }
}

/// Seeded random number generator for reproducibility
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        // Simple LCG for deterministic randomness
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}


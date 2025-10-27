import Foundation
import Accelerate

/// Hermitian operators for cardinal virtues
/// Each virtue operator acts on the 8096-dimensional Hilbert space
public struct VirtueOperators: Sendable {
    /// Justice operator - promotes balanced distribution
    public let justice: VirtueOperator
    
    /// Temperance operator - promotes moderation
    public let temperance: VirtueOperator
    
    /// Prudence operator - promotes stability and long-term thinking
    public let prudence: VirtueOperator
    
    /// Fortitude operator - promotes robustness
    public let fortitude: VirtueOperator
    
    /// Initialize all virtue operators for given dimension
    public init(dimension: Int = VQbitState.standardDimension, seed: UInt64? = nil) {
        self.justice = VirtueOperator.createJusticeOperator(dimension: dimension, seed: seed)
        self.temperance = VirtueOperator.createTemperanceOperator(dimension: dimension, seed: seed)
        self.prudence = VirtueOperator.createPrudenceOperator(dimension: dimension, seed: seed)
        self.fortitude = VirtueOperator.createFortitudeOperator(dimension: dimension, seed: seed)
    }
    
    /// Get operator for specific virtue type
    public func operatorFor(_ virtue: VirtueType) -> VirtueOperator {
        switch virtue {
        case .justice: return justice
        case .temperance: return temperance
        case .prudence: return prudence
        case .fortitude: return fortitude
        }
    }
}

/// Single Hermitian operator for a cardinal virtue
public struct VirtueOperator: Sendable {
    /// Dimension of the operator
    public let dimension: Int
    
    /// Diagonal elements (real-valued for Hermitian)
    public let diagonal: [Float]
    
    /// Off-diagonal elements (sparse representation)
    /// For efficiency, only store non-zero off-diagonal elements
    public let offDiagonal: [(row: Int, col: Int, value: DSPComplex)]
    
    /// Virtue type this operator represents
    public let virtueType: VirtueType
    
    private init(dimension: Int, diagonal: [Float], offDiagonal: [(Int, Int, DSPComplex)], virtueType: VirtueType) {
        self.dimension = dimension
        self.diagonal = diagonal
        self.offDiagonal = offDiagonal
        self.virtueType = virtueType
    }
    
    /// Create Justice operator: Identity-like with small perturbations
    /// Promotes balanced, fair solutions across all objectives
    static func createJusticeOperator(dimension: Int, seed: UInt64?) -> VirtueOperator {
        var generator: any RandomNumberGenerator = seed.map { SeededRandomNumberGenerator(seed: $0) as any RandomNumberGenerator } ?? SystemRandomNumberGenerator()
        
        // Diagonal: 1.0 with small random perturbations
        var diagonal = [Float](repeating: 1.0, count: dimension)
        for i in 0..<dimension {
            diagonal[i] += Float.random(in: -0.01...0.01, using: &generator)
        }
        
        return VirtueOperator(
            dimension: dimension,
            diagonal: diagonal,
            offDiagonal: [], // Sparse - mostly identity
            virtueType: .justice
        )
    }
    
    /// Create Temperance operator: Diagonal with normal distribution
    /// Promotes moderation and efficiency
    static func createTemperanceOperator(dimension: Int, seed: UInt64?) -> VirtueOperator {
        var generator: any RandomNumberGenerator = seed.map { SeededRandomNumberGenerator(seed: $0) as any RandomNumberGenerator } ?? SystemRandomNumberGenerator()
        
        // Diagonal: Normal distribution with small variance
        var diagonal = [Float](repeating: 0.0, count: dimension)
        for i in 0..<dimension {
            // Box-Muller transform for normal distribution
            let u1 = Float.random(in: 0..<1, using: &generator)
            let u2 = Float.random(in: 0..<1, using: &generator)
            let z = sqrt(-2.0 * log(u1)) * cos(2.0 * Float.pi * u2)
            diagonal[i] = z * 0.1 // Small variance
        }
        
        return VirtueOperator(
            dimension: dimension,
            diagonal: diagonal,
            offDiagonal: [],
            virtueType: .temperance
        )
    }
    
    /// Create Prudence operator: Positive definite diagonal
    /// Promotes stability and wisdom
    static func createPrudenceOperator(dimension: Int, seed: UInt64?) -> VirtueOperator {
        var generator: any RandomNumberGenerator = seed.map { SeededRandomNumberGenerator(seed: $0) as any RandomNumberGenerator } ?? SystemRandomNumberGenerator()
        
        // Diagonal: Positive values for stability
        var diagonal = [Float](repeating: 0.0, count: dimension)
        for i in 0..<dimension {
            diagonal[i] = 0.1 + 0.1 * abs(Float.random(in: -1...1, using: &generator))
        }
        
        return VirtueOperator(
            dimension: dimension,
            diagonal: diagonal,
            offDiagonal: [],
            virtueType: .prudence
        )
    }
    
    /// Create Fortitude operator: Tridiagonal for robustness
    /// Promotes resilience through local coupling
    static func createFortitudeOperator(dimension: Int, seed: UInt64?) -> VirtueOperator {
        // Main diagonal: 0.5
        let diagonal = [Float](repeating: 0.5, count: dimension)
        
        // Super and sub diagonals: 0.1
        var offDiagonal = [(Int, Int, DSPComplex)]()
        for i in 0..<(dimension - 1) {
            // Super diagonal
            offDiagonal.append((i, i+1, DSPComplex(real: 0.1, imag: 0)))
            // Sub diagonal (Hermitian symmetry)
            offDiagonal.append((i+1, i, DSPComplex(real: 0.1, imag: 0)))
        }
        
        return VirtueOperator(
            dimension: dimension,
            diagonal: diagonal,
            offDiagonal: offDiagonal,
            virtueType: .fortitude
        )
    }
    
    /// Apply operator to a vQbit state: |ψ'⟩ = V|ψ⟩
    public func apply(to state: VQbitState) -> [DSPComplex] {
        guard state.dimension == dimension else {
            fatalError("Dimension mismatch: operator=\(dimension), state=\(state.dimension)")
        }
        
        var result = [DSPComplex](repeating: DSPComplex(real: 0, imag: 0), count: dimension)
        
        // Apply diagonal part
        for i in 0..<dimension {
            result[i].real = diagonal[i] * state.amplitudes[i].real
            result[i].imag = diagonal[i] * state.amplitudes[i].imag
        }
        
        // Apply off-diagonal part
        for (row, col, value) in offDiagonal {
            // Complex multiplication: (a + ib)(c + id) = (ac - bd) + i(ad + bc)
            let psi = state.amplitudes[col]
            result[row].real += value.real * psi.real - value.imag * psi.imag
            result[row].imag += value.real * psi.imag + value.imag * psi.real
        }
        
        return result
    }
    
    /// Measure expectation value: ⟨ψ|V|ψ⟩
    public func expectationValue(for state: VQbitState) -> Double {
        let vPsi = apply(to: state)
        
        // ⟨ψ|V|ψ⟩ = ∑ᵢ ψᵢ* (V|ψ⟩)ᵢ
        var expectation: Double = 0.0
        for i in 0..<dimension {
            // Complex conjugate multiplication: (a - ib)(c + id) = (ac + bd) + i(ad - bc)
            let psi = state.amplitudes[i]
            let vp = vPsi[i]
            expectation += Double(psi.real * vp.real + psi.imag * vp.imag)
        }
        
        return expectation
    }
}


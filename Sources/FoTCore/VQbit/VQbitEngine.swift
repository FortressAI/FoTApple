import Foundation
import Accelerate

/// Core vQbit optimization engine
/// Implements Field of Truth quantum-inspired multi-objective optimization
public actor VQbitEngine {
    /// Dimension of vQbit Hilbert space (adaptive to platform)
    public let dimension: Int
    
    /// Virtue operators for all cardinal virtues
    public let virtueOperators: VirtueOperators
    
    /// Current optimization problems being tracked
    private var activeProblems: [String: OptimizationProblem] = [:]
    
    /// Solution archive for Pareto fronts
    private var solutionArchive: [String: [Solution]] = [:]
    
    /// Initialization state
    public private(set) var isInitialized: Bool = false
    
    /// Initialize vQbit engine with platform-specific dimension
    public init(dimension: Int? = nil, seed: UInt64? = nil) {
        // Detect platform and set appropriate dimension
        #if os(macOS) || os(visionOS)
        self.dimension = dimension ?? VQbitState.standardDimension // 8096 on Mac/Vision
        #elseif os(iOS)
        #if targetEnvironment(macCatalyst)
        self.dimension = dimension ?? VQbitState.standardDimension
        #else
        self.dimension = dimension ?? 4096 // Reduced for iPhone
        #endif
        #elseif os(watchOS)
        self.dimension = dimension ?? 512 // Minimal for Watch
        #else
        self.dimension = dimension ?? VQbitState.standardDimension
        #endif
        
        // Initialize virtue operators
        self.virtueOperators = VirtueOperators(dimension: self.dimension, seed: seed)
        self.isInitialized = true
        
        print("✅ VQbit Engine initialized with \(self.dimension) dimensions")
    }
    
    /// Create a new vQbit state in superposition
    public func createVQbitState(
        initialValues: [String: Double]? = nil,
        context: [String: Any] = [:]
    ) -> VQbitState {
        if let values = initialValues {
            return encodeClassicalValues(values, context: context)
        } else {
            return VQbitState.randomSuperposition(dimension: dimension)
        }
    }
    
    /// Encode classical optimization variables into quantum state
    private func encodeClassicalValues(
        _ values: [String: Double],
        context: [String: Any]
    ) -> VQbitState {
        var amplitudes = [DSPComplex](repeating: DSPComplex(real: 0, imag: 0), count: dimension)
        
        // Use hash of variable names to determine amplitude positions
        for (name, value) in values {
            let idx = abs(name.hashValue) % dimension
            let phase = Float(value) * Float.pi
            amplitudes[idx].real = Float(value)
            amplitudes[idx].imag = sin(phase)
        }
        
        // Normalize
        var normSquared: Double = 0.0
        for amplitude in amplitudes {
            normSquared += Double(amplitude.real * amplitude.real + amplitude.imag * amplitude.imag)
        }
        
        if normSquared > 0 {
            let normFactor = Float(1.0 / sqrt(normSquared))
            for i in 0..<dimension {
                amplitudes[i].real *= normFactor
                amplitudes[i].imag *= normFactor
            }
        } else {
            // Fallback to uniform superposition
            return VQbitState.uniformSuperposition(dimension: dimension)
        }
        
        // Measure initial virtue scores
        let virtueScores = measureVirtues(amplitudes: amplitudes)
        
        return VQbitState(
            amplitudes: amplitudes,
            coherence: VQbitState.calculateCoherence(amplitudes),
            virtueScores: virtueScores,
            metadata: context
        )
    }
    
    /// Measure virtue scores from quantum state
    private func measureVirtues(amplitudes: [DSPComplex]) -> [VirtueType: Double] {
        var scores: [VirtueType: Double] = [:]
        
        let tempState = VQbitState(
            amplitudes: amplitudes,
            coherence: 0,
            virtueScores: [:],
            metadata: [:]
        )
        
        for virtue in VirtueType.allCases {
            let op = virtueOperators.operatorFor(virtue)
            let expectation = op.expectationValue(for: tempState)
            // Normalize to [0, 1] range
            scores[virtue] = (expectation + 1.0) / 2.0
        }
        
        return scores
    }
    
    /// Apply virtue-guided collapse to quantum state
    public func applyVirtueCollapse(
        state: VQbitState,
        targetVirtues: [VirtueType: Double],
        strength: Double = 0.1
    ) -> VQbitState {
        var amplitudes = state.amplitudes
        
        // Apply each virtue operator based on target values
        for (virtue, targetValue) in targetVirtues {
            let currentValue = state.virtueScores[virtue] ?? 0.5
            let correction = targetValue - currentValue
            
            // Apply weighted operator: |ψ'⟩ = |ψ⟩ + α·correction·V|ψ⟩
            let op = virtueOperators.operatorFor(virtue)
            let vPsi = op.apply(to: state)
            
            let weight = Float(strength * correction)
            for i in 0..<dimension {
                amplitudes[i].real += weight * vPsi[i].real
                amplitudes[i].imag += weight * vPsi[i].imag
            }
        }
        
        // Renormalize
        var normSquared: Double = 0.0
        for amplitude in amplitudes {
            normSquared += Double(amplitude.real * amplitude.real + amplitude.imag * amplitude.imag)
        }
        
        let normFactor = Float(1.0 / sqrt(normSquared))
        for i in 0..<dimension {
            amplitudes[i].real *= normFactor
            amplitudes[i].imag *= normFactor
        }
        
        // Measure new virtue scores
        let newVirtueScores = measureVirtues(amplitudes: amplitudes)
        let newCoherence = VQbitState.calculateCoherence(amplitudes)
        
        return VQbitState(
            amplitudes: amplitudes,
            coherence: newCoherence,
            entanglement: state.entanglement,
            virtueScores: newVirtueScores,
            metadata: state.metadata
        )
    }
    
    /// Evolve multiple entangled vQbit states together
    public func evolveEntangledStates(
        _ states: [VQbitState],
        timeStep: Double = 0.1
    ) -> [VQbitState] {
        guard states.count >= 2 else { return states }
        
        // For large systems, use simplified coupling
        // Full entanglement evolution would be computationally intensive
        return states.map { state in
            // Apply small random phase rotation to simulate evolution
            var amplitudes = state.amplitudes
            let phase = Float(timeStep * 0.1)
            
            for i in 0..<amplitudes.count {
                let cosPhase = cos(phase)
                let sinPhase = sin(phase)
                let real = amplitudes[i].real
                let imag = amplitudes[i].imag
                amplitudes[i].real = real * cosPhase - imag * sinPhase
                amplitudes[i].imag = real * sinPhase + imag * cosPhase
            }
            
            return VQbitState(
                amplitudes: amplitudes,
                coherence: VQbitState.calculateCoherence(amplitudes),
                entanglement: state.entanglement,
                virtueScores: measureVirtues(amplitudes: amplitudes),
                metadata: state.metadata
            )
        }
    }
    
    /// Register an optimization problem
    public func registerProblem(_ problem: OptimizationProblem) {
        activeProblems[problem.id] = problem
    }
    
    /// Retrieve solutions for a problem
    public func getSolutions(for problemId: String) -> [Solution] {
        return solutionArchive[problemId] ?? []
    }
    
    /// Get engine status
    public func status() -> [String: Any] {
        return [
            "dimension": dimension,
            "initialized": isInitialized,
            "active_problems": activeProblems.count,
            "total_solutions": solutionArchive.values.reduce(0) { $0 + $1.count }
        ]
    }
}

// MARK: - Supporting Types

/// Multi-objective optimization problem definition
public struct OptimizationProblem: Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let objectives: [Objective]
    public let constraints: [Constraint]
    public let variables: [Variable]
    public let virtueWeights: [VirtueType: Double]
    
    public init(
        id: String,
        name: String,
        description: String,
        objectives: [Objective],
        constraints: [Constraint],
        variables: [Variable],
        virtueWeights: [VirtueType: Double] = VirtueType.defaultWeights
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.objectives = objectives
        self.constraints = constraints
        self.variables = variables
        self.virtueWeights = virtueWeights
    }
}

public struct Objective: Sendable {
    public let name: String
    public let direction: OptimizationDirection
    public let weight: Double
    
    public init(name: String, direction: OptimizationDirection, weight: Double = 1.0) {
        self.name = name
        self.direction = direction
        self.weight = weight
    }
}

public enum OptimizationDirection: String, Sendable {
    case minimize
    case maximize
}

public struct Constraint: Sendable {
    public let name: String
    public let type: ConstraintType
    public let bound: Double
    
    public init(name: String, type: ConstraintType, bound: Double) {
        self.name = name
        self.type = type
        self.bound = bound
    }
}

public enum ConstraintType: String, Sendable {
    case lessEqual = "<="
    case greaterEqual = ">="
    case equal = "="
}

public struct Variable: Sendable {
    public let name: String
    public let lowerBound: Double
    public let upperBound: Double
    
    public init(name: String, lowerBound: Double, upperBound: Double) {
        self.name = name
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }
}

public struct Solution: Sendable {
    public let id: String
    public let variables: [String: Double]
    public let objectives: [String: Double]
    public let constraints: [String: Double]
    public let virtueScores: [VirtueType: Double]
    public let vqbitState: VQbitState
    public let metadata: [String: Any]
    
    public init(
        id: String,
        variables: [String: Double],
        objectives: [String: Double],
        constraints: [String: Double],
        virtueScores: [VirtueType: Double],
        vqbitState: VQbitState,
        metadata: [String: Any] = [:]
    ) {
        self.id = id
        self.variables = variables
        self.objectives = objectives
        self.constraints = constraints
        self.virtueScores = virtueScores
        self.vqbitState = vqbitState
        self.metadata = metadata
    }
}


import Foundation

/// Cardinal virtues for quantum-inspired optimization
/// Based on classical virtue ethics adapted for multi-objective optimization
public enum VirtueType: String, CaseIterable, Codable, Sendable {
    case justice = "justice"
    case temperance = "temperance"
    case prudence = "prudence"
    case fortitude = "fortitude"
    
    /// Human-readable description of the virtue
    public var description: String {
        switch self {
        case .justice:
            return "Promotes fairness and balanced distribution in solutions"
        case .temperance:
            return "Promotes moderation and efficiency"
        case .prudence:
            return "Promotes wisdom and long-term thinking"
        case .fortitude:
            return "Promotes resilience and robustness"
        }
    }
    
    /// Default weight for balanced optimization
    public static let defaultWeights: [VirtueType: Double] = [
        .justice: 0.25,
        .temperance: 0.25,
        .prudence: 0.25,
        .fortitude: 0.25
    ]
}


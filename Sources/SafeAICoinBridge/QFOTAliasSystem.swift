import Foundation
import CryptoKit

/// QFOT Alias System - PayPal-like Human-Readable Names
/// All users must opt-in with NO IDENTITY disclosure
/// Wallet Address + Human-Readable Alias for privacy-first transactions
public actor QFOTAliasSystem {
    
    /// Alias registry (stored on-chain)
    private var aliases: [String: QFOTAlias] = [:]
    
    /// Reverse lookup (wallet address to alias)
    private var addressToAlias: [String: String] = [:]
    
    public init() {}
    
    /// Create a new alias for a wallet address
    /// NO IDENTITY REQUIRED - fully anonymous
    public func createAlias(
        walletAddress: String,
        desiredAlias: String,
        category: AliasCategory
    ) async throws -> QFOTAlias {
        // Validate alias format
        try validateAliasFormat(desiredAlias)
        
        // Check if alias is available
        guard !aliases.keys.contains(desiredAlias) else {
            throw QFOTAliasError.aliasAlreadyTaken
        }
        
        // Ensure wallet doesn't already have an alias
        if let existingAlias = addressToAlias[walletAddress] {
            throw QFOTAliasError.walletAlreadyHasAlias(existingAlias)
        }
        
        // Create alias
        let alias = QFOTAlias(
            alias: desiredAlias,
            walletAddress: walletAddress,
            category: category,
            createdAt: Date(),
            reputationScore: 100, // Start at 100
            claimsSubmitted: 0,
            claimsValidated: 0,
            tokensEarned: 0.0,
            verified: false
        )
        
        // Store alias
        aliases[desiredAlias] = alias
        addressToAlias[walletAddress] = desiredAlias
        
        print("✅ Alias created: \(desiredAlias) → \(walletAddress)")
        
        return alias
    }
    
    /// Look up wallet address by alias
    public func resolveAlias(_ alias: String) async -> String? {
        return aliases[alias]?.walletAddress
    }
    
    /// Look up alias by wallet address
    public func getAlias(for walletAddress: String) async -> QFOTAlias? {
        guard let aliasString = addressToAlias[walletAddress] else {
            return nil
        }
        return aliases[aliasString]
    }
    
    /// Update reputation score (called by ethics validators)
    public func updateReputation(
        alias: String,
        adjustment: Int,
        reason: String
    ) async throws {
        guard var aliasInfo = aliases[alias] else {
            throw QFOTAliasError.aliasNotFound
        }
        
        let newScore = max(0, min(1000, aliasInfo.reputationScore + adjustment))
        aliasInfo.reputationScore = newScore
        aliasInfo.lastReputationUpdate = Date()
        
        aliases[alias] = aliasInfo
        
        print("📊 Reputation updated: \(alias) → \(newScore) (\(reason))")
    }
    
    /// Record a truth claim submission
    public func recordClaimSubmission(alias: String) async throws {
        guard var aliasInfo = aliases[alias] else {
            throw QFOTAliasError.aliasNotFound
        }
        
        aliasInfo.claimsSubmitted += 1
        aliases[alias] = aliasInfo
    }
    
    /// Record a truth claim validation
    public func recordClaimValidation(
        alias: String,
        tokensEarned: Double
    ) async throws {
        guard var aliasInfo = aliases[alias] else {
            throw QFOTAliasError.aliasNotFound
        }
        
        aliasInfo.claimsValidated += 1
        aliasInfo.tokensEarned += tokensEarned
        aliases[alias] = aliasInfo
    }
    
    /// Get leaderboard (top contributors by reputation)
    public func getLeaderboard(limit: Int = 100) async -> [QFOTAlias] {
        return Array(aliases.values)
            .sorted { $0.reputationScore > $1.reputationScore }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Validate alias format
    private func validateAliasFormat(_ alias: String) throws {
        // Rules:
        // - 3-30 characters
        // - Alphanumeric + underscore + dash
        // - No spaces
        // - Must start with letter
        
        guard alias.count >= 3 && alias.count <= 30 else {
            throw QFOTAliasError.invalidAliasLength
        }
        
        guard alias.first?.isLetter ?? false else {
            throw QFOTAliasError.mustStartWithLetter
        }
        
        let allowedChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        guard alias.unicodeScalars.allSatisfy({ allowedChars.contains($0) }) else {
            throw QFOTAliasError.invalidCharacters
        }
        
        // Reserved aliases (prevent impersonation)
        let reserved = [
            "admin", "administrator", "root", "system", "qfot", "fieldoftruth",
            "moderator", "validator", "eth", "ethereum", "bitcoin", "btc"
        ]
        
        guard !reserved.contains(alias.lowercased()) else {
            throw QFOTAliasError.reservedAlias
        }
    }
}

/// Alias information stored on-chain
public struct QFOTAlias: Codable, Sendable {
    public let alias: String
    public let walletAddress: String
    public let category: AliasCategory
    public let createdAt: Date
    public var reputationScore: Int // 0-1000
    public var claimsSubmitted: Int
    public var claimsValidated: Int
    public var tokensEarned: Double
    public var verified: Bool // Blue checkmark for verified contributors
    public var lastReputationUpdate: Date?
    
    /// Display name (alias + category badge)
    public var displayName: String {
        return "\(alias) [\(category.badge)]"
    }
    
    /// Reputation tier
    public var tier: ReputationTier {
        switch reputationScore {
        case 0..<100: return .novice
        case 100..<300: return .contributor
        case 300..<600: return .expert
        case 600..<900: return .master
        default: return .legend
        }
    }
}

/// Alias category (what type of contributor)
public enum AliasCategory: String, Codable, Sendable {
    case doctor = "doctor"
    case lawyer = "lawyer"
    case teacher = "teacher"
    case researcher = "researcher"
    case parent = "parent"
    case student = "student"
    case citizen = "citizen"
    
    var badge: String {
        switch self {
        case .doctor: return "🩺"
        case .lawyer: return "⚖️"
        case .teacher: return "📚"
        case .researcher: return "🔬"
        case .parent: return "👨‍👩‍👧"
        case .student: return "🎓"
        case .citizen: return "🌍"
        }
    }
}

/// Reputation tiers
public enum ReputationTier: String, Codable, Sendable {
    case novice = "Novice"
    case contributor = "Contributor"
    case expert = "Expert"
    case master = "Master"
    case legend = "Legend"
    
    var badge: String {
        switch self {
        case .novice: return "🔹"
        case .contributor: return "🔷"
        case .expert: return "⭐"
        case .master: return "🏆"
        case .legend: return "👑"
        }
    }
}

/// Alias system errors
public enum QFOTAliasError: Error, LocalizedError {
    case aliasAlreadyTaken
    case walletAlreadyHasAlias(String)
    case aliasNotFound
    case invalidAliasLength
    case mustStartWithLetter
    case invalidCharacters
    case reservedAlias
    
    public var errorDescription: String? {
        switch self {
        case .aliasAlreadyTaken:
            return "This alias is already taken. Please choose another."
        case .walletAlreadyHasAlias(let alias):
            return "This wallet already has an alias: \(alias)"
        case .aliasNotFound:
            return "Alias not found"
        case .invalidAliasLength:
            return "Alias must be 3-30 characters long"
        case .mustStartWithLetter:
            return "Alias must start with a letter"
        case .invalidCharacters:
            return "Alias can only contain letters, numbers, underscores, and dashes"
        case .reservedAlias:
            return "This alias is reserved"
        }
    }
}

/// No-Identity Opt-In Manager
/// ALL users must explicitly opt-in with NO identity disclosure
public class QFOTNoIdentityOptIn: ObservableObject {
    @Published public var hasOptedIn: Bool = false
    @Published public var alias: String?
    @Published public var walletAddress: String?
    
    public static let shared = QFOTNoIdentityOptIn()
    
    private let userDefaultsKey = "qfot.no_identity_opt_in"
    private let aliasKey = "qfot.alias"
    private let walletKey = "qfot.wallet_address"
    
    private init() {
        // Load opt-in status from UserDefaults
        hasOptedIn = UserDefaults.standard.bool(forKey: userDefaultsKey)
        alias = UserDefaults.standard.string(forKey: aliasKey)
        walletAddress = UserDefaults.standard.string(forKey: walletKey)
    }
    
    /// User opts in with NO IDENTITY (only alias + wallet)
    public func optIn(alias: String, walletAddress: String) {
        self.hasOptedIn = true
        self.alias = alias
        self.walletAddress = walletAddress
        
        // Save to UserDefaults
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
        UserDefaults.standard.set(alias, forKey: aliasKey)
        UserDefaults.standard.set(walletAddress, forKey: walletKey)
        
        print("✅ User opted in with NO IDENTITY:")
        print("   Alias: \(alias)")
        print("   Wallet: \(walletAddress)")
        print("   ⚠️ NO personal information stored")
    }
    
    /// User opts out (clears all data)
    public func optOut() {
        self.hasOptedIn = false
        self.alias = nil
        self.walletAddress = nil
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: aliasKey)
        UserDefaults.standard.removeObject(forKey: walletKey)
        
        print("✅ User opted out - all data cleared")
    }
    
    /// Check if user can submit truth claims
    public func canSubmitClaims() -> Bool {
        return hasOptedIn && alias != nil && walletAddress != nil
    }
}


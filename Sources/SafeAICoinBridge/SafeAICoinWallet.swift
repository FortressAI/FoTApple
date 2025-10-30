import Foundation
import CryptoKit
import FoTCore

/// SafeAICoin Wallet - Manages user token balance and transactions
/// LIVE MAINNET - NO SIMULATION
public actor SafeAICoinWallet {
    private let userId: String
    private let keychain: KeychainManager
    private let client: SafeAICoinClient
    
    /// Wallet address on SafeAICoin blockchain
    public let address: String
    
    /// Initialize wallet for user
    public init(userId: String, client: SafeAICoinClient) async throws {
        self.userId = userId
        self.client = client
        self.keychain = KeychainManager(service: "org.fieldoftruth.safeaicoin")
        
        // Generate or retrieve wallet address
        if let existingAddress = try? keychain.get(key: "wallet_address_\(userId)") {
            self.address = existingAddress
            print("✅ Loaded existing SafeAICoin wallet: \(address)")
        } else {
            // Generate new wallet address using cryptographic derivation
            let privateKey = P256.Signing.PrivateKey()
            let publicKey = privateKey.publicKey
            let publicKeyData = publicKey.rawRepresentation
            let addressHash = SHA256.hash(data: publicKeyData)
            let address = "SAFE" + addressHash.compactMap { String(format: "%02x", $0) }.joined().prefix(40)
            
            // Store private key securely in keychain
            try keychain.set(key: "wallet_privkey_\(userId)", value: privateKey.rawRepresentation.base64EncodedString())
            try keychain.set(key: "wallet_address_\(userId)", value: address)
            
            self.address = address
            
            // Register wallet on-chain
            try await registerWalletOnChain()
            
            print("✅ Created new SafeAICoin wallet: \(address)")
        }
    }
    
    /// Register wallet on blockchain (REAL on-chain transaction)
    private func registerWalletOnChain() async throws {
        let rpcRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": UUID().uuidString,
            "method": "fot.registerWallet",
            "params": [
                "address": address,
                "user_id": userId,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: rpcRequest)
        
        // Submit to actual blockchain
        _ = try await submitToBlockchain(requestData)
        
        print("✅ Wallet registered on-chain: \(address)")
    }
    
    /// Get current token balance (REAL on-chain query)
    public func getBalance() async throws -> TokenBalance {
        let balance = try await client.getBalance(address: address)
        
        return TokenBalance(
            safe: balance,
            usdValue: balance * await getCurrentSAFEPrice(),
            lastUpdated: Date()
        )
    }
    
    /// Get transaction history (REAL on-chain query)
    public func getTransactionHistory(limit: Int = 50) async throws -> [TokenTransaction] {
        let rpcRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": UUID().uuidString,
            "method": "fot.getTransactionHistory",
            "params": [
                "address": address,
                "limit": limit
            ]
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: rpcRequest)
        let response = try await submitToBlockchain(requestData)
        
        guard let transactions = response["transactions"] as? [[String: Any]] else {
            return []
        }
        
        return transactions.compactMap { tx in
            guard let txHash = tx["hash"] as? String,
                  let amount = tx["amount"] as? Double,
                  let type = tx["type"] as? String,
                  let timestampStr = tx["timestamp"] as? String,
                  let timestamp = ISO8601DateFormatter().date(from: timestampStr) else {
                return nil
            }
            
            return TokenTransaction(
                hash: txHash,
                type: TransactionType(rawValue: type) ?? .other,
                amount: amount,
                timestamp: timestamp,
                from: tx["from"] as? String,
                to: tx["to"] as? String,
                description: tx["description"] as? String ?? ""
            )
        }
    }
    
    /// Earn tokens for knowledge contribution (70% goes to creator)
    public func earnTokensForContribution(
        contributionId: String,
        contributionType: ContributionType,
        confidence: Double,
        usageCount: Int = 1
    ) async throws -> TokenEarning {
        let baseReward = contributionType.baseReward
        let confidenceMultiplier = confidence
        let usageMultiplier = Double(usageCount)
        
        // Calculate earnings based on 70/15/10/5 split
        let totalFee = baseReward * confidenceMultiplier * usageMultiplier
        let creatorShare = totalFee * 0.70  // 70% to knowledge creator
        
        let rpcRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": UUID().uuidString,
            "method": "fot.creditReward",
            "params": [
                "wallet_address": address,
                "contribution_id": contributionId,
                "contribution_type": contributionType.rawValue,
                "amount": creatorShare,
                "confidence": confidence,
                "usage_count": usageCount,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: rpcRequest)
        let response = try await submitToBlockchain(requestData)
        
        guard let txHash = response["tx_hash"] as? String else {
            throw SafeAICoinError.invalidResponse
        }
        
        print("✅ Earned \(creatorShare) SAFE for contribution: \(contributionId)")
        
        return TokenEarning(
            transactionHash: txHash,
            amount: creatorShare,
            contributionType: contributionType,
            confidence: confidence,
            timestamp: Date()
        )
    }
    
    /// Transfer tokens to another wallet (REAL on-chain transaction)
    public func transfer(
        to recipientAddress: String,
        amount: Double,
        note: String? = nil
    ) async throws -> String {
        // Get private key for signing
        guard let privKeyBase64 = try? keychain.get(key: "wallet_privkey_\(userId)"),
              let privKeyData = Data(base64Encoded: privKeyBase64) else {
            throw SafeAICoinError.rpcError("Private key not found")
        }
        
        let privateKey = try P256.Signing.PrivateKey(rawRepresentation: privKeyData)
        
        // Create transaction
        let txData: [String: Any] = [
            "from": address,
            "to": recipientAddress,
            "amount": amount,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "note": note ?? ""
        ]
        
        let txDataJson = try JSONSerialization.data(withJSONObject: txData)
        let signature = try privateKey.signature(for: txDataJson)
        
        let rpcRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": UUID().uuidString,
            "method": "fot.transfer",
            "params": [
                "transaction": txData,
                "signature": signature.rawRepresentation.base64EncodedString()
            ]
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: rpcRequest)
        let response = try await submitToBlockchain(requestData)
        
        guard let txHash = response["tx_hash"] as? String else {
            throw SafeAICoinError.invalidResponse
        }
        
        print("✅ Transferred \(amount) SAFE to \(recipientAddress): \(txHash)")
        
        return txHash
    }
    
    /// Get reward summary for period
    public func getRewardSummary(
        startDate: Date,
        endDate: Date
    ) async throws -> RewardSummary {
        let rpcRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": UUID().uuidString,
            "method": "fot.getRewardSummary",
            "params": [
                "address": address,
                "start_date": ISO8601DateFormatter().string(from: startDate),
                "end_date": ISO8601DateFormatter().string(from: endDate)
            ]
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: rpcRequest)
        let response = try await submitToBlockchain(requestData)
        
        return RewardSummary(
            totalEarned: response["total_earned"] as? Double ?? 0,
            contributionCount: response["contribution_count"] as? Int ?? 0,
            averageConfidence: response["average_confidence"] as? Double ?? 0,
            topContributions: [], // Parse from response
            period: DateInterval(start: startDate, end: endDate)
        )
    }
    
    /// Submit request to actual blockchain
    private func submitToBlockchain(_ requestData: Data) async throws -> [String: Any] {
        guard let config = try? SafeAICoinConfig.loadNetworkConfig() else {
            throw SafeAICoinError.rpcError("Network not configured. Deploy SafeAICoin first.")
        }
        
        guard let rpcURL = URL(string: config.primaryRPC) else {
            throw SafeAICoinError.rpcError("Invalid RPC URL")
        }
        
        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication if required
        if let credentials = config.rpcCredentials.user.data(using: .utf8) {
            let auth = "\(config.rpcCredentials.user):\(config.rpcCredentials.password)"
            let authData = auth.data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = requestData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SafeAICoinError.rpcError("HTTP error: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SafeAICoinError.invalidResponse
        }
        
        if let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            throw SafeAICoinError.rpcError(message)
        }
        
        guard let result = json["result"] as? [String: Any] else {
            throw SafeAICoinError.invalidResponse
        }
        
        return result
    }
    
    /// Get current SAFE token price in USD (from oracle)
    /// NOTE: Price is speculative and may be zero - no guaranteed market value
    private func getCurrentSAFEPrice() async -> Double {
        // TODO: Query price oracle on-chain when exchanges list SAFE
        // For now, return 0 (no established market value yet)
        return 0.00  // No market value established - tokens are utility only
    }
}

// MARK: - Supporting Types

public struct TokenBalance {
    public let safe: Double
    public let usdValue: Double
    public let lastUpdated: Date
    
    public var formatted: String {
        String(format: "%.4f SAFE (~$%.2f)", safe, usdValue)
    }
}

public struct TokenTransaction {
    public let hash: String
    public let type: TransactionType
    public let amount: Double
    public let timestamp: Date
    public let from: String?
    public let to: String?
    public let description: String
}

public enum TransactionType: String, Codable {
    case earned = "earned"
    case sent = "sent"
    case received = "received"
    case staked = "staked"
    case unstaked = "unstaked"
    case governance = "governance"
    case other = "other"
}

public enum ContributionType: String, Codable {
    case medicalDiagnosis = "medical_diagnosis"
    case legalResearch = "legal_research"
    case educationalContent = "educational_content"
    case healthGuidance = "health_guidance"
    case parentingAdvice = "parenting_advice"
    case knowledgeValidation = "knowledge_validation"
    
    /// Base reward in SAFE tokens
    var baseReward: Double {
        switch self {
        case .medicalDiagnosis: return 10.0      // High value medical insights
        case .legalResearch: return 8.0           // Legal analysis
        case .educationalContent: return 5.0      // Educational materials
        case .healthGuidance: return 6.0          // Health recommendations
        case .parentingAdvice: return 4.0         // Parenting insights
        case .knowledgeValidation: return 2.0     // Validation work
        }
    }
}

public struct TokenEarning {
    public let transactionHash: String
    public let amount: Double
    public let contributionType: ContributionType
    public let confidence: Double
    public let timestamp: Date
}

public struct RewardSummary {
    public let totalEarned: Double
    public let contributionCount: Int
    public let averageConfidence: Double
    public let topContributions: [TokenEarning]
    public let period: DateInterval
}

// MARK: - Keychain Manager

private class KeychainManager {
    private let service: String
    
    init(service: String) {
        self.service = service
    }
    
    func set(key: String, value: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SafeAICoinError.rpcError("Keychain write failed: \(status)")
        }
    }
    
    func get(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw SafeAICoinError.rpcError("Keychain read failed: \(status)")
        }
        
        return value
    }
}


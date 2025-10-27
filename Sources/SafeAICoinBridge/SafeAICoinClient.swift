import Foundation
import FoTCore
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// SafeAICoin blockchain client for attestation anchoring
/// Handles RPC communication, transaction submission, and proof retrieval
public actor SafeAICoinClient {
    private let rpcURL: URL
    private let networkID: String
    private let session: URLSession
    public let version = "safeaicoin-bridge-0.1.0"
    
    /// Initialize client with RPC endpoint
    public init(
        rpcURL: String = "https://rpc.safeaicoin.org",
        networkID: String = "mainnet"
    ) {
        self.rpcURL = URL(string: rpcURL)!
        self.networkID = networkID
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        
        print("✅ SafeAICoin client initialized")
        print("   RPC: \(rpcURL)")
        print("   Network: \(networkID)")
    }
    
    /// Submit an attestation to the blockchain
    public func submitAttestation(_ attestation: Attestation) async throws -> String {
        // Prepare transaction payload
        let payload = try attestation.toJSON()
        
        // Submit to blockchain
        let txHash = try await submitTransaction(
            method: "fot.submitAttestation",
            params: payload
        )
        
        // Wait for confirmation
        let confirmed = try await waitForConfirmation(txHash, maxAttempts: 10)
        
        guard confirmed else {
            throw SafeAICoinError.confirmationTimeout
        }
        
        print("✅ Attestation anchored on-chain: \(txHash)")
        return txHash
    }
    
    /// Submit a transaction via RPC
    private func submitTransaction(method: String, params: Data) async throws -> String {
        let rpcRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": UUID().uuidString,
            "method": method,
            "params": [
                "data": String(data: params, encoding: .utf8) ?? ""
            ]
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: rpcRequest)
        
        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SafeAICoinError.rpcError("HTTP error: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        }
        
        let rpcResponse = try JSONDecoder().decode(RPCResponse.self, from: data)
        
        if let error = rpcResponse.error {
            throw SafeAICoinError.rpcError(error.message)
        }
        
        guard let txHash = rpcResponse.result?["tx_hash"] as? String else {
            throw SafeAICoinError.invalidResponse
        }
        
        return txHash
    }
    
    /// Wait for transaction confirmation
    private func waitForConfirmation(_ txHash: String, maxAttempts: Int) async throws -> Bool {
        for attempt in 1...maxAttempts {
            let confirmed = try await checkTransaction(txHash)
            if confirmed {
                return true
            }
            
            // Exponential backoff: 1s, 2s, 4s, 8s, etc.
            let delay = UInt64(pow(2.0, Double(attempt - 1)) * 1_000_000_000)
            try await Task.sleep(nanoseconds: min(delay, 30_000_000_000))
        }
        
        return false
    }
    
    /// Check transaction status
    private func checkTransaction(_ txHash: String) async throws -> Bool {
        let rpcRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": UUID().uuidString,
            "method": "fot.getTransaction",
            "params": ["tx_hash": txHash]
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: rpcRequest)
        
        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        let (data, _) = try await session.data(for: request)
        let rpcResponse = try JSONDecoder().decode(RPCResponse.self, from: data)
        
        if let status = rpcResponse.result?["status"] as? String {
            return status == "confirmed"
        }
        
        return false
    }
    
    /// Retrieve a proof from the blockchain
    public func retrieveProof(attestationId: String) async throws -> Data {
        let rpcRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": UUID().uuidString,
            "method": "fot.getProof",
            "params": ["attestation_id": attestationId]
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: rpcRequest)
        
        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        let (data, _) = try await session.data(for: request)
        let rpcResponse = try JSONDecoder().decode(RPCResponse.self, from: data)
        
        guard let proofData = rpcResponse.result?["proof"] as? String else {
            throw SafeAICoinError.proofNotFound
        }
        
        guard let proof = Data(base64Encoded: proofData) else {
            throw SafeAICoinError.invalidProof
        }
        
        return proof
    }
    
    /// Get account balance
    public func getBalance(address: String) async throws -> Double {
        let rpcRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": UUID().uuidString,
            "method": "fot.getBalance",
            "params": ["address": address]
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: rpcRequest)
        
        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        let (data, _) = try await session.data(for: request)
        let rpcResponse = try JSONDecoder().decode(RPCResponse.self, from: data)
        
        guard let balance = rpcResponse.result?["balance"] as? Double else {
            throw SafeAICoinError.invalidResponse
        }
        
        return balance
    }
    
    /// Estimate gas cost for attestation
    public func estimateGas(attestationSize: Int) async throws -> Double {
        // Simplified gas estimation
        // In production, this would query the network
        let baseGas = 21000.0
        let dataGas = Double(attestationSize) * 16.0
        return baseGas + dataGas
    }
}

// MARK: - Supporting Types

struct RPCResponse: Codable {
    let jsonrpc: String
    let id: String
    let result: [String: Any]?
    let error: RPCError?
    
    struct RPCError: Codable {
        let code: Int
        let message: String
    }
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc, id, result, error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        id = try container.decode(String.self, forKey: .id)
        error = try container.decodeIfPresent(RPCError.self, forKey: .error)
        
        // Decode result as [String: Any]
        if let resultData = try? container.decode([String: AnyCodable].self, forKey: .result) {
            result = resultData.mapValues { $0.value }
        } else {
            result = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(error, forKey: .error)
    }
}

// Helper for decoding Any
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unsupported type"))
        }
    }
}

public enum SafeAICoinError: Error {
    case rpcError(String)
    case invalidResponse
    case confirmationTimeout
    case proofNotFound
    case invalidProof
}


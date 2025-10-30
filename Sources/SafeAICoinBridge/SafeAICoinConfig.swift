import Foundation

/// Configuration for SafeAICoin blockchain network
/// Deployed on Hetzner Cloud - 3 node mainnet
public struct SafeAICoinConfig {
    
    /// Load network configuration from deployment
    /// Location: ~/.safeaicoin/network_config.json
    public static func loadNetworkConfig() throws -> NetworkConfig {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configPath = homeDir.appendingPathComponent(".safeaicoin/network_config.json")
        
        guard FileManager.default.fileExists(atPath: configPath.path) else {
            throw SafeAICoinError.rpcError("Network config not found. Deploy network first.")
        }
        
        let data = try Data(contentsOf: configPath)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(NetworkConfig.self, from: data)
    }
    
    /// Mainnet configuration (default)
    public static let mainnet = NetworkEndpoint(
        name: "SafeAICoin Mainnet",
        rpcNodes: [
            // These will be populated from network_config.json after deployment
            // Or set manually here after running deploy_safeaicoin_hetzner.sh
        ],
        networkID: "mainnet"
    )
    
    /// Testnet configuration
    public static let testnet = NetworkEndpoint(
        name: "SafeAICoin Testnet",
        rpcNodes: [
            // Testnet nodes (if deployed)
        ],
        networkID: "testnet"
    )
}

// MARK: - Configuration Types

public struct NetworkConfig: Codable {
    public let network: String
    public let deploymentDate: Date
    public let nodes: [NodeInfo]
    public let rpcCredentials: RPCCredentials
    public let costPerMonth: String
    
    enum CodingKeys: String, CodingKey {
        case network
        case deploymentDate = "deployment_date"
        case nodes
        case rpcCredentials = "rpc_credentials"
        case costPerMonth = "cost_per_month"
    }
    
    /// Get primary RPC URL (first node)
    public var primaryRPC: String {
        nodes.first?.rpcUrl ?? ""
    }
    
    /// Get all RPC URLs
    public var allRPCs: [String] {
        nodes.map { $0.rpcUrl }
    }
}

public struct NodeInfo: Codable {
    public let name: String
    public let ip: String
    public let location: String
    public let rpcUrl: String
    
    enum CodingKeys: String, CodingKey {
        case name, ip, location
        case rpcUrl = "rpc_url"
    }
}

public struct RPCCredentials: Codable {
    public let user: String
    public let password: String
}

public struct NetworkEndpoint {
    public let name: String
    public let rpcNodes: [String]
    public let networkID: String
}

// MARK: - SafeAICoinClient Extension

extension SafeAICoinClient {
    /// Initialize client from deployed network configuration
    public static func fromDeployedNetwork() async throws -> SafeAICoinClient {
        let config = try SafeAICoinConfig.loadNetworkConfig()
        
        guard let primaryRPC = config.nodes.first?.rpcUrl else {
            throw SafeAICoinError.rpcError("No RPC nodes found in configuration")
        }
        
        print("✅ Loading SafeAICoin network configuration")
        print("   Network: \(config.network)")
        print("   Nodes: \(config.nodes.count)")
        print("   Primary RPC: \(primaryRPC)")
        print("   Deployed: \(config.deploymentDate)")
        
        return SafeAICoinClient(
            rpcURL: primaryRPC,
            networkID: config.network
        )
    }
    
    /// Initialize client with specific node
    public static func withNode(_ nodeIndex: Int = 0) async throws -> SafeAICoinClient {
        let config = try SafeAICoinConfig.loadNetworkConfig()
        
        guard nodeIndex < config.nodes.count else {
            throw SafeAICoinError.rpcError("Node index out of range")
        }
        
        let node = config.nodes[nodeIndex]
        
        return SafeAICoinClient(
            rpcURL: node.rpcUrl,
            networkID: config.network
        )
    }
}


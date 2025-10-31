// ArangoDBClient.swift
// Swift client for QFOT ArangoDB API
// Connects iOS/Mac apps to mainnet knowledge graph

import Foundation

/// ArangoDB client for querying mainnet knowledge graph
/// Connects to real ArangoDB via REST API - NO SIMULATIONS
public actor ArangoDBClient {
    private let baseURL: String
    private let session: URLSession
    
    public init(baseURL: String = "https://safeaicoin.org/api") {
        self.baseURL = baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Models
    
    public struct Fact: Codable, Identifiable {
        public let id: String
        public let content: String
        public let domain: String
        public let creator: String
        public let stake: Double
        public let queryCount: Int
        public let createdAt: String
        public let simulation: Bool
        
        enum CodingKeys: String, CodingKey {
            case id = "_key"
            case content, domain, creator, stake
            case queryCount = "query_count"
            case createdAt = "created_at"
            case simulation
        }
    }
    
    public struct RelatedFact: Codable {
        public let vertex: Fact
        public let relationshipType: String?
        public let pathLength: Int
        
        enum CodingKeys: String, CodingKey {
            case vertex
            case relationshipType = "relationship_type"
            case pathLength = "path_length"
        }
    }
    
    public struct DomainStats: Codable {
        public let domain: String
        public let factCount: Int
        
        enum CodingKeys: String, CodingKey {
            case domain
            case factCount = "fact_count"
        }
    }
    
    public struct Entity: Codable, Identifiable {
        public let id: String
        public let name: String
        public let entityType: String?
        public let linkedFacts: [Fact]?
        
        enum CodingKeys: String, CodingKey {
            case id = "_key"
            case name
            case entityType = "entity_type"
            case linkedFacts = "linked_facts"
        }
    }
    
    // MARK: - Search Facts
    
    /// Search facts by content (free endpoint)
    public func searchFacts(
        query: String = "",
        domain: String = "all",
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> [Fact] {
        var components = URLComponents(string: "\(baseURL)/facts/search")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "domain", value: domain),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        
        guard let url = components.url else {
            throw AKGError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AKGError.serverError
        }
        
        let result = try JSONDecoder().decode(SearchResponse.self, from: data)
        
        // Verify this is NOT a simulation
        guard result.simulation == false else {
            throw AKGError.simulationDetected
        }
        
        return result.results
    }
    
    private struct SearchResponse: Codable {
        let query: String
        let domain: String
        let count: Int
        let results: [Fact]
        let simulation: Bool
    }
    
    // MARK: - Get Single Fact
    
    /// Get single fact by ID
    public func getFact(id: String) async throws -> Fact {
        let url = URL(string: "\(baseURL)/facts/\(id)")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AKGError.serverError
        }
        
        let result = try JSONDecoder().decode(FactResponse.self, from: data)
        
        guard result.simulation == false else {
            throw AKGError.simulationDetected
        }
        
        return result.fact
    }
    
    private struct FactResponse: Codable {
        let fact: Fact
        let simulation: Bool
    }
    
    // MARK: - Graph Traversal
    
    /// Traverse graph relationships from a fact
    /// Find all connected facts (supports, contradicts, implies, derived)
    public func traverseRelationships(
        fromFact factId: String,
        relationshipType: String? = nil,
        maxDepth: Int = 3,
        limit: Int = 50
    ) async throws -> [RelatedFact] {
        let url = URL(string: "\(baseURL)/graph/traverse")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "fact_id": factId,
            "relationship_type": relationshipType as Any,
            "max_depth": maxDepth,
            "limit": limit
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AKGError.serverError
        }
        
        let result = try JSONDecoder().decode(TraversalResponse.self, from: data)
        
        guard result.simulation == false else {
            throw AKGError.simulationDetected
        }
        
        return result.relatedFacts
    }
    
    private struct TraversalResponse: Codable {
        let factId: String
        let relationshipType: String?
        let maxDepth: Int
        let count: Int
        let relatedFacts: [RelatedFact]
        let simulation: Bool
        
        enum CodingKeys: String, CodingKey {
            case factId = "fact_id"
            case relationshipType = "relationship_type"
            case maxDepth = "max_depth"
            case count
            case relatedFacts = "related_facts"
            case simulation
        }
    }
    
    // MARK: - Find Contradictions
    
    /// Find facts that contradict this fact
    public func findContradictions(factId: String) async throws -> [Fact] {
        let url = URL(string: "\(baseURL)/graph/contradictions/\(factId)")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AKGError.serverError
        }
        
        let result = try JSONDecoder().decode(ContradictionsResponse.self, from: data)
        
        guard result.simulation == false else {
            throw AKGError.simulationDetected
        }
        
        // Extract facts from contradictions
        return result.contradictions.map { $0.contradictingFact }
    }
    
    private struct ContradictionsResponse: Codable {
        let factId: String
        let contradictionsFound: Int
        let contradictions: [Contradiction]
        let simulation: Bool
        
        enum CodingKeys: String, CodingKey {
            case factId = "fact_id"
            case contradictionsFound = "contradictions_found"
            case contradictions
            case simulation
        }
        
        struct Contradiction: Codable {
            let contradictingFact: Fact
            
            enum CodingKeys: String, CodingKey {
                case contradictingFact = "contradicting_fact"
            }
        }
    }
    
    // MARK: - Domain Queries
    
    /// Query facts for a specific domain (medical, legal, education)
    public func queryDomain(
        domain: String,
        query: String? = nil,
        limit: Int = 100,
        offset: Int = 0
    ) async throws -> [Fact] {
        let url = URL(string: "\(baseURL)/domains/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "domain": domain,
            "limit": limit,
            "offset": offset
        ]
        
        if let query = query {
            body["query"] = query
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AKGError.serverError
        }
        
        let result = try JSONDecoder().decode(DomainQueryResponse.self, from: data)
        
        guard result.simulation == false else {
            throw AKGError.simulationDetected
        }
        
        return result.facts
    }
    
    private struct DomainQueryResponse: Codable {
        let domain: String
        let query: String?
        let count: Int
        let facts: [Fact]
        let simulation: Bool
    }
    
    // MARK: - Domain Statistics
    
    /// Get statistics for all domains
    public func getDomainStats() async throws -> [DomainStats] {
        let url = URL(string: "\(baseURL)/domains/stats")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AKGError.serverError
        }
        
        let result = try JSONDecoder().decode(DomainStatsResponse.self, from: data)
        
        guard result.simulation == false else {
            throw AKGError.simulationDetected
        }
        
        return result.domains
    }
    
    private struct DomainStatsResponse: Codable {
        let domains: [DomainStats]
        let simulation: Bool
    }
    
    // MARK: - Entity Queries
    
    /// Search for entities (drugs, ICD codes, case law, etc.)
    public func searchEntities(
        name: String,
        type: String? = nil,
        includeFacts: Bool = true
    ) async throws -> [Entity] {
        let url = URL(string: "\(baseURL)/entities/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "entity_name": name,
            "include_facts": includeFacts
        ]
        
        if let type = type {
            body["entity_type"] = type
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AKGError.serverError
        }
        
        let result = try JSONDecoder().decode(EntityQueryResponse.self, from: data)
        
        guard result.simulation == false else {
            throw AKGError.simulationDetected
        }
        
        return result.entities
    }
    
    private struct EntityQueryResponse: Codable {
        let entityName: String
        let entityType: String?
        let count: Int
        let entities: [Entity]
        let simulation: Bool
        
        enum CodingKeys: String, CodingKey {
            case entityName = "entity_name"
            case entityType = "entity_type"
            case count
            case entities
            case simulation
        }
    }
    
    // MARK: - Submit Fact
    
    /// Submit new fact to knowledge graph
    public func submitFact(
        content: String,
        domain: String,
        creator: String,
        stake: Double = 1.0,
        metadata: [String: Any]? = nil
    ) async throws -> String {
        let url = URL(string: "\(baseURL)/facts/submit")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "content": content,
            "domain": domain,
            "creator": creator,
            "stake": stake
        ]
        
        if let metadata = metadata {
            body["metadata"] = metadata
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AKGError.serverError
        }
        
        let result = try JSONDecoder().decode(SubmitResponse.self, from: data)
        
        guard result.simulation == false else {
            throw AKGError.simulationDetected
        }
        
        return result.factId
    }
    
    private struct SubmitResponse: Codable {
        let success: Bool
        let factId: String
        let documentKey: String
        let simulation: Bool
        
        enum CodingKeys: String, CodingKey {
            case success
            case factId = "fact_id"
            case documentKey = "document_key"
            case simulation
        }
    }
    
    // MARK: - Health Check
    
    /// Check API health and verify no simulations
    public func healthCheck() async throws -> Bool {
        let url = URL(string: "\(baseURL)/health")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        
        let result = try JSONDecoder().decode(HealthResponse.self, from: data)
        
        // Verify NOT a simulation
        return result.status == "healthy" && result.simulation == false
    }
    
    private struct HealthResponse: Codable {
        let status: String
        let database: String
        let facts: Int
        let simulation: Bool
    }
}

// MARK: - Errors

public enum AKGError: Error, LocalizedError {
    case invalidURL
    case serverError
    case simulationDetected
    case noData
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .serverError:
            return "Server error"
        case .simulationDetected:
            return "SIMULATION DETECTED - This violates mainnet rules!"
        case .noData:
            return "No data received"
        }
    }
}


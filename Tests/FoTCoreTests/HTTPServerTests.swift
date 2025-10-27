import XCTest
@testable import FoTCore

final class HTTPServerTests: XCTestCase {
    var akg: AKGService!
    var server: HTTPServer!
    
    override func setUp() async throws {
        akg = try await AKGService(databasePath: ":memory:")
        server = await HTTPServer(akg: akg, host: "127.0.0.1", port: 8899)
    }
    
    override func tearDown() async throws {
        try? await server.stop()
        akg = nil
        server = nil
    }
    
    func testServerStartStop() async throws {
        try await server.start()
        
        // Give server time to start
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
        
        // Server should be listening
        // In a real test, you'd make an HTTP request here
        
        try await server.stop()
    }
    
    func testStatusEndpoint() async throws {
        try await server.start()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Test status endpoint
        let url = URL(string: "http://127.0.0.1:8899/status")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let httpResponse = response as! HTTPURLResponse
        XCTAssertEqual(httpResponse.statusCode, 200)
        
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["service"] as? String, "FoT Apple AKG")
        XCTAssertNotNil(json["statistics"])
        
        try await server.stop()
    }
    
    func testCypherEndpoint() async throws {
        try await server.start()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let url = URL(string: "http://127.0.0.1:8899/cypher")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["query": "MATCH (n) RETURN n LIMIT 10"]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let httpResponse = response as! HTTPURLResponse
        XCTAssertEqual(httpResponse.statusCode, 200)
        
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertNotNil(json["query"])
        XCTAssertNotNil(json["receipt"])
        
        try await server.stop()
    }
    
    func testWriteEndpoint() async throws {
        try await server.start()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let url = URL(string: "http://127.0.0.1:8899/write")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "mutations": [
                [
                    "type": "createNode",
                    "labels": ["Test"],
                    "properties": ["name": "Test Node"]
                ]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let httpResponse = response as! HTTPURLResponse
        XCTAssertEqual(httpResponse.statusCode, 200)
        
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertNotNil(json["attestation_id"])
        XCTAssertNotNil(json["merkle_root"])
        XCTAssertNotNil(json["signature"])
        
        try await server.stop()
    }
    
    func testRootEndpoint() async throws {
        try await server.start()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let url = URL(string: "http://127.0.0.1:8899/")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let httpResponse = response as! HTTPURLResponse
        XCTAssertEqual(httpResponse.statusCode, 200)
        
        let html = String(data: data, encoding: .utf8)!
        XCTAssertTrue(html.contains("FoT Apple"), "Root should return HTML documentation")
        
        try await server.stop()
    }
    
    func testNotFoundEndpoint() async throws {
        try await server.start()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let url = URL(string: "http://127.0.0.1:8899/nonexistent")!
        let (_, response) = try await URLSession.shared.data(from: url)
        
        let httpResponse = response as! HTTPURLResponse
        XCTAssertEqual(httpResponse.statusCode, 404)
        
        try await server.stop()
    }
}


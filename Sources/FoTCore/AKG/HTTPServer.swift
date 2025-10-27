import Foundation
import NIO
import NIOHTTP1

/// HTTP server for AKG service
/// Provides REST API for Cypher queries, validated writes, and proof retrieval
public actor HTTPServer {
    private let akg: AKGService
    private let host: String
    private let port: Int
    private var channel: Channel?
    private let group: MultiThreadedEventLoopGroup
    
    public init(akg: AKGService, host: String = "127.0.0.1", port: Int = 8888) {
        self.akg = akg
        self.host = host
        self.port = port
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    }
    
    /// Start the HTTP server
    public func start() async throws {
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).flatMap {
                    channel.pipeline.addHandler(HTTPHandler(akg: self.akg))
                }
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
        
        self.channel = try await bootstrap.bind(host: host, port: port).get()
        print("✅ HTTP server listening on http://\(host):\(port)")
    }
    
    /// Stop the HTTP server
    public func stop() async throws {
        try await channel?.close()
        try await group.shutdownGracefully()
        print("🛑 HTTP server stopped")
    }
}

/// HTTP request handler
final class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    
    private let akg: AKGService
    private var requestBuffer: ByteBuffer?
    private var requestHead: HTTPRequestHead?
    
    init(akg: AKGService) {
        self.akg = akg
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let part = self.unwrapInboundIn(data)
        
        switch part {
        case .head(let head):
            self.requestHead = head
            self.requestBuffer = context.channel.allocator.buffer(capacity: 0)
            
        case .body(var buffer):
            if self.requestBuffer != nil {
                self.requestBuffer!.writeBuffer(&buffer)
            }
            
        case .end:
            guard let head = self.requestHead else { return }
            
            Task {
                await self.handleRequest(head: head, body: self.requestBuffer, context: context)
            }
            
            self.requestHead = nil
            self.requestBuffer = nil
        }
    }
    
    private func handleRequest(head: HTTPRequestHead, body: ByteBuffer?, context: ChannelHandlerContext) async {
        let path = head.uri
        let method = head.method
        
        // Route handling
        switch (method, path) {
        case (.GET, "/"):
            await handleRoot(context: context)
            
        case (.GET, "/status"):
            await handleStatus(context: context)
            
        case (.POST, "/cypher"):
            await handleCypherQuery(body: body, context: context)
            
        case (.POST, "/write"):
            await handleWrite(body: body, context: context)
            
        case (.GET, _) where path.starts(with: "/proof/"):
            let attestationId = String(path.dropFirst("/proof/".count))
            await handleGetProof(attestationId: attestationId, context: context)
            
        default:
            await handleNotFound(context: context)
        }
    }
    
    private func handleRoot(context: ChannelHandlerContext) async {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>FoT Apple - AKG Service</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto; padding: 2rem; }
                h1 { color: #007AFF; }
                .endpoint { background: #f5f5f5; padding: 1rem; margin: 1rem 0; border-radius: 8px; }
                code { background: #e5e5e5; padding: 0.2rem 0.5rem; border-radius: 4px; }
            </style>
        </head>
        <body>
            <h1>🌟 FoT Apple - AKG Service</h1>
            <p>Audit Knowledge Graph with cryptographic validation</p>
            
            <h2>Endpoints</h2>
            
            <div class="endpoint">
                <strong>GET /status</strong>
                <p>Get service status and statistics</p>
            </div>
            
            <div class="endpoint">
                <strong>POST /cypher</strong>
                <p>Execute Cypher query</p>
                <code>{"query": "MATCH (n:Protein) RETURN n LIMIT 10"}</code>
            </div>
            
            <div class="endpoint">
                <strong>POST /write</strong>
                <p>Execute validated write batch</p>
                <code>{"mutations": [...]}</code>
            </div>
            
            <div class="endpoint">
                <strong>GET /proof/{attestation_id}</strong>
                <p>Retrieve Merkle proof for attestation</p>
            </div>
            
            <footer style="margin-top: 2rem; color: #666;">
                <p>Quantum for all. Verified forever.</p>
            </footer>
        </body>
        </html>
        """
        
        await sendResponse(context: context, status: .ok, contentType: "text/html", body: html)
    }
    
    private func handleStatus(context: ChannelHandlerContext) async {
        do {
            let stats = try await akg.statistics()
            let response: [String: Any] = [
                "service": "FoT Apple AKG",
                "version": "1.0.0",
                "status": "operational",
                "statistics": stats
            ]
            
            await sendJSON(context: context, status: .ok, json: response)
        } catch {
            await sendError(context: context, error: error)
        }
    }
    
    private func handleCypherQuery(body: ByteBuffer?, context: ChannelHandlerContext) async {
        guard let body = body else {
            await sendError(context: context, message: "No request body")
            return
        }
        
        let bodyBytes = body.getBytes(at: 0, length: body.readableBytes) ?? []
        guard let data = Data(bodyBytes).count > 0 ? Data(bodyBytes) : nil,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let query = json["query"] as? String else {
            await sendError(context: context, message: "Invalid request body")
            return
        }
        
        do {
            // For now, return a placeholder response
            // Full Cypher implementation would go here
            let response: [String: Any] = [
                "query": query,
                "rows": [],
                "receipt": [
                    "query_hash": BLAKE3.hashHex(query),
                    "ts": Int64(Date().timeIntervalSince1970 * 1000),
                    "nonce": ULID().string
                ]
            ]
            
            await sendJSON(context: context, status: .ok, json: response)
        } catch {
            await sendError(context: context, error: error)
        }
    }
    
    private func handleWrite(body: ByteBuffer?, context: ChannelHandlerContext) async {
        guard let body = body else {
            await sendError(context: context, message: "No request body")
            return
        }
        
        let bodyBytes = body.getBytes(at: 0, length: body.readableBytes) ?? []
        guard let data = Data(bodyBytes).count > 0 ? Data(bodyBytes) : nil,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            await sendError(context: context, message: "Invalid request body")
            return
        }
        
        do {
            // Parse mutations from request
            var mutations: [Mutation] = []
            
            if let mutationsArray = json["mutations"] as? [[String: Any]] {
                for mutationDict in mutationsArray {
                    if let type = mutationDict["type"] as? String,
                       type == "createNode",
                       let labels = mutationDict["labels"] as? [String],
                       let properties = mutationDict["properties"] as? [String: Any] {
                        mutations.append(.createNode(labels: labels, properties: properties))
                    }
                }
            }
            
            // Execute validated batch
            let attestation = try await akg.writeBatch(mutations)
            
            let response: [String: Any] = [
                "attestation_id": attestation.id,
                "merkle_root": attestation.merkleRoot.toHexString(),
                "signature": attestation.signature.toHexString(),
                "timestamp": Int64(attestation.timestamp.timeIntervalSince1970 * 1000),
                "records_count": mutations.count
            ]
            
            await sendJSON(context: context, status: .ok, json: response)
        } catch {
            await sendError(context: context, error: error)
        }
    }
    
    private func handleGetProof(attestationId: String, context: ChannelHandlerContext) async {
        do {
            // Retrieve proof from AKG
            guard let proof = try await akg.generateProof(for: attestationId, recordIndex: 0) else {
                await sendError(context: context, message: "Proof not found", status: .notFound)
                return
            }
            
            let proofJSON = try proof.toJSON()
            let proofString = String(data: proofJSON, encoding: .utf8) ?? "{}"
            
            await sendResponse(context: context, status: .ok, contentType: "application/json", body: proofString)
        } catch {
            await sendError(context: context, error: error)
        }
    }
    
    private func handleNotFound(context: ChannelHandlerContext) async {
        await sendError(context: context, message: "Endpoint not found", status: .notFound)
    }
    
    // MARK: - Response Helpers
    
    private func sendJSON(context: ChannelHandlerContext, status: HTTPResponseStatus, json: [String: Any]) async {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
            let body = String(data: data, encoding: .utf8) ?? "{}"
            await sendResponse(context: context, status: status, contentType: "application/json", body: body)
        } catch {
            await sendError(context: context, error: error)
        }
    }
    
    private func sendResponse(context: ChannelHandlerContext, status: HTTPResponseStatus, contentType: String, body: String) async {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: contentType)
        headers.add(name: "Content-Length", value: String(body.utf8.count))
        headers.add(name: "Access-Control-Allow-Origin", value: "*")
        
        let responseHead = HTTPResponseHead(version: .http1_1, status: status, headers: headers)
        context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
        
        var buffer = context.channel.allocator.buffer(capacity: body.utf8.count)
        buffer.writeString(body)
        context.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
        
        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
    }
    
    private func sendError(context: ChannelHandlerContext, message: String, status: HTTPResponseStatus = .badRequest) async {
        let response: [String: Any] = [
            "error": message,
            "status": status.code
        ]
        await sendJSON(context: context, status: status, json: response)
    }
    
    private func sendError(context: ChannelHandlerContext, error: Error) async {
        let response: [String: Any] = [
            "error": String(describing: error),
            "status": 500
        ]
        await sendJSON(context: context, status: .internalServerError, json: response)
    }
}


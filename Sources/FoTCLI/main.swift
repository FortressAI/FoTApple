import Foundation
import FoTCore
import FoTProtein
import SafeAICoinBridge

/// FoT CLI Tool - Command-line interface for Field of Truth platform
@main
struct FoTCLI {
    static func main() async {
        print("🌟 FoT Apple - Field of Truth Platform")
        print("   Quantum for all. Verified forever.\n")
        
        let args = CommandLine.arguments
        
        guard args.count > 1 else {
            printUsage()
            return
        }
        
        let command = args[1]
        
        do {
            switch command {
            case "init":
                try await initializeSystem()
                
            case "create-node":
                guard args.count >= 4 else {
                    print("❌ Usage: fotctl create-node <label> <properties-json>")
                    return
                }
                try await createNode(label: args[2], propertiesJSON: args[3])
                
            case "query":
                guard args.count >= 3 else {
                    print("❌ Usage: fotctl query <cypher-query>")
                    return
                }
                try await runQuery(args[2])
                
            case "optimize":
                try await runOptimization()
                
            case "status":
                try await showStatus()
                
            case "version":
                print("FoT Apple v1.0.0")
                print("VQbit Engine: Platform-adaptive dimensions")
                print("AKG Service: Local SQLite + validation")
                print("SafeAICoin: Blockchain attestation")
                
            case "help":
                printUsage()
                
            default:
                print("❌ Unknown command: \(command)")
                printUsage()
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    static func printUsage() {
        print("""
        Usage: fotctl <command> [arguments]
        
        Commands:
          init              Initialize FoT system
          create-node       Create a node in the knowledge graph
          query             Execute a Cypher query
          optimize          Run vQbit optimization
          status            Show system status
          version           Show version information
          help              Show this help message
        
        Examples:
          fotctl init
          fotctl create-node Protein '{"sequence":"ACDEFGHIKLMN","uniprot":"P12345"}'
          fotctl query 'MATCH (p:Protein) RETURN p LIMIT 10'
          fotctl optimize
          fotctl status
        """)
    }
    
    static func initializeSystem() async throws {
        print("🚀 Initializing Field of Truth system...")
        
        // Initialize VQbit Engine
        let engine = await VQbitEngine()
        let status = await engine.status()
        print("✅ VQbit Engine: \(status["dimension"] as! Int) dimensions")
        
        // Initialize AKG Service
        let akg = try await AKGService(databasePath: "./fot.db")
        let stats = try await akg.statistics()
        print("✅ AKG Service: \(stats["nodes"] as! Int) nodes, \(stats["edges"] as! Int) edges")
        
        // Register domain packs
        let proteinPack = ProteinDomainPack()
        try await proteinPack.initialize(engine: engine, akg: akg)
        
        // Initialize SafeAICoin bridge
        let blockchain = await SafeAICoinClient()
        print("✅ SafeAICoin bridge ready")
        
        print("\n✨ System initialized successfully!")
    }
    
    static func createNode(label: String, propertiesJSON: String) async throws {
        print("📝 Creating node with label: \(label)")
        
        // Parse properties JSON
        guard let propsData = propertiesJSON.data(using: .utf8),
              let props = try JSONSerialization.jsonObject(with: propsData) as? [String: Any] else {
            throw CLIError.invalidJSON
        }
        
        // Initialize AKG
        let akg = try await AKGService(databasePath: "./fot.db")
        
        // Create node
        let nodeId = try await akg.createNode(labels: [label], properties: props)
        
        print("✅ Node created: \(nodeId)")
    }
    
    static func runQuery(_ query: String) async throws {
        print("🔍 Executing query: \(query)")
        
        let akg = try await AKGService(databasePath: "./fot.db")
        
        // For now, just show stats (full Cypher implementation would go here)
        let stats = try await akg.statistics()
        print("\n📊 Database Statistics:")
        print("   Nodes: \(stats["nodes"] as! Int)")
        print("   Edges: \(stats["edges"] as! Int)")
        print("   Attestations: \(stats["attestations"] as! Int)")
    }
    
    static func runOptimization() async throws {
        print("🧮 Running vQbit optimization...")
        
        let engine = await VQbitEngine()
        
        // Create test problem
        let problem = OptimizationProblem(
            id: ULID().string,
            name: "Test Optimization",
            description: "Multi-objective test problem",
            objectives: [
                Objective(name: "minimize_energy", direction: .minimize),
                Objective(name: "maximize_stability", direction: .maximize)
            ],
            constraints: [
                Constraint(name: "bounds", type: .lessEqual, bound: 1.0)
            ],
            variables: [
                Variable(name: "x1", lowerBound: 0, upperBound: 1),
                Variable(name: "x2", lowerBound: 0, upperBound: 1)
            ]
        )
        
        await engine.registerProblem(problem)
        
        // Create initial population
        let state1 = await engine.createVQbitState()
        let state2 = await engine.createVQbitState()
        
        print("✅ Initial states created")
        print("   State 1 coherence: \(state1.coherence)")
        print("   State 2 coherence: \(state2.coherence)")
        
        // Apply virtue collapse
        let targetVirtues: [VirtueType: Double] = [
            .justice: 0.8,
            .prudence: 0.7
        ]
        
        let collapsed = await engine.applyVirtueCollapse(
            state: state1,
            targetVirtues: targetVirtues
        )
        
        print("\n✅ Virtue-guided collapse complete")
        print("   New coherence: \(collapsed.coherence)")
        print("   Virtue scores:")
        for (virtue, score) in collapsed.virtueScores {
            print("     \(virtue.rawValue): \(String(format: "%.3f", score))")
        }
    }
    
    static func showStatus() async throws {
        print("📊 System Status\n")
        
        // VQbit Engine
        let engine = await VQbitEngine()
        let engineStatus = await engine.status()
        print("VQbit Engine:")
        print("  Dimension: \(engineStatus["dimension"] as! Int)")
        print("  Active problems: \(engineStatus["active_problems"] as! Int)")
        print("  Total solutions: \(engineStatus["total_solutions"] as! Int)")
        
        // AKG Service
        let akg = try await AKGService(databasePath: "./fot.db")
        let akgStats = try await akg.statistics()
        print("\nAKG Service:")
        print("  Nodes: \(akgStats["nodes"] as! Int)")
        print("  Edges: \(akgStats["edges"] as! Int)")
        print("  Attestations: \(akgStats["attestations"] as! Int)")
        print("  Version: \(akgStats["schema_version"] as! String)")
        
        print("\n✨ System operational")
    }
}

enum CLIError: Error {
    case invalidJSON
    case missingArgument
}


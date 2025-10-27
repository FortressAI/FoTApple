import XCTest
@testable import FoTCore

final class VQbitEngineTests: XCTestCase {
    func testEngineInitialization() async throws {
        let engine = await VQbitEngine(dimension: 1024)
        let status = await engine.status()
        
        XCTAssertEqual(status["dimension"] as? Int, 1024)
        XCTAssertEqual(status["initialized"] as? Bool, true)
    }
    
    func testCreateVQbitState() async throws {
        let engine = await VQbitEngine(dimension: 512)
        let state = await engine.createVQbitState()
        
        XCTAssertEqual(state.dimension, 512)
        XCTAssertTrue(state.isNormalized, "State should be normalized")
        XCTAssertGreaterThanOrEqual(state.coherence, 0.0)
        XCTAssertLessThanOrEqual(state.coherence, 1.0)
    }
    
    func testVirtueCollapse() async throws {
        let engine = await VQbitEngine(dimension: 256)
        let initialState = await engine.createVQbitState()
        
        let targetVirtues: [VirtueType: Double] = [
            .justice: 0.8,
            .temperance: 0.6,
            .prudence: 0.7,
            .fortitude: 0.5
        ]
        
        let collapsedState = await engine.applyVirtueCollapse(
            state: initialState,
            targetVirtues: targetVirtues,
            strength: 0.1
        )
        
        XCTAssertTrue(collapsedState.isNormalized, "Collapsed state should be normalized")
        XCTAssertEqual(collapsedState.dimension, 256)
        
        // Virtue scores should move toward targets
        for (virtue, targetScore) in targetVirtues {
            let initialScore = initialState.virtueScores[virtue] ?? 0.5
            let finalScore = collapsedState.virtueScores[virtue] ?? 0.5
            
            // Check that we moved in the right direction
            if targetScore > initialScore {
                XCTAssertGreaterThanOrEqual(finalScore, initialScore,
                    "Virtue \(virtue) should increase toward target")
            } else if targetScore < initialScore {
                XCTAssertLessThanOrEqual(finalScore, initialScore,
                    "Virtue \(virtue) should decrease toward target")
            }
        }
    }
    
    func testEntangledEvolution() async throws {
        let engine = await VQbitEngine(dimension: 128)
        let state1 = await engine.createVQbitState()
        let state2 = await engine.createVQbitState()
        
        let evolvedStates = await engine.evolveEntangledStates([state1, state2], timeStep: 0.1)
        
        XCTAssertEqual(evolvedStates.count, 2)
        for state in evolvedStates {
            XCTAssertTrue(state.isNormalized, "Evolved state should be normalized")
        }
    }
    
    func testOptimizationProblem() async throws {
        let engine = await VQbitEngine(dimension: 256)
        
        let problem = OptimizationProblem(
            id: "test-problem",
            name: "Test Optimization",
            description: "Test multi-objective problem",
            objectives: [
                Objective(name: "minimize_cost", direction: .minimize),
                Objective(name: "maximize_quality", direction: .maximize)
            ],
            constraints: [
                Constraint(name: "budget", type: .lessEqual, bound: 100.0)
            ],
            variables: [
                Variable(name: "x1", lowerBound: 0, upperBound: 10),
                Variable(name: "x2", lowerBound: 0, upperBound: 10)
            ]
        )
        
        await engine.registerProblem(problem)
        let solutions = await engine.getSolutions(for: "test-problem")
        
        XCTAssertNotNil(solutions)
    }
}


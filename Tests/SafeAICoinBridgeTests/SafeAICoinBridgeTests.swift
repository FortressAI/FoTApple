import XCTest
@testable import SafeAICoinBridge
@testable import FoTCore

final class SafeAICoinBridgeTests: XCTestCase {
    func testClientInitialization() async {
        let client = await SafeAICoinClient(
            rpcURL: "https://testnet.safeaicoin.org",
            networkID: "testnet"
        )
        
        XCTAssertNotNil(client)
    }
    
    func testGasEstimation() async throws {
        let client = await SafeAICoinClient()
        let gas = try await client.estimateGas(attestationSize: 1000)
        
        XCTAssertGreaterThan(gas, 0, "Gas estimate should be positive")
    }
    
    // Note: Actual blockchain tests would require a running testnet
    // These are placeholder tests for the bridge functionality
}


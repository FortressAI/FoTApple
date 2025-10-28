// StepLogger.swift
// Captures UI test steps with precise timestamps for video narration alignment
// Used for Functional Acceptance Testing and User Guide generation

import Foundation
import XCTest

/// Step logger for UI test recording with narration alignment
public final class StepLogger {
    private var steps: [[String: Any]] = []
    private let outURL: URL
    private var currentStepIndex = 0
    
    public init(outputPath: String = "/tmp/steps.json") {
        self.outURL = URL(fileURLWithPath: outputPath)
    }
    
    /// Add a completed step
    public func add(name: String, start: Date, end: Date, metadata: [String: Any] = [:]) {
        currentStepIndex += 1
        var step: [String: Any] = [
            "index": currentStepIndex,
            "name": name,
            "start": start.timeIntervalSince1970,
            "end": end.timeIntervalSince1970,
            "duration": end.timeIntervalSince(start)
        ]
        
        // Merge metadata
        for (key, value) in metadata {
            step[key] = value
        }
        
        steps.append(step)
        print("✅ Step \(currentStepIndex): \(name) (\(String(format: "%.2f", end.timeIntervalSince(start)))s)")
    }
    
    /// Write steps to JSON file
    public func flush() {
        do {
            let data = try JSONSerialization.data(withJSONObject: steps, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: outURL)
            print("📝 Logged \(steps.count) steps to \(outURL.path)")
        } catch {
            XCTFail("Failed to write steps: \(error)")
        }
    }
    
    /// Get step count
    public var count: Int {
        return steps.count
    }
}

/// XCTest extension for step-based testing
extension XCTestCase {
    
    /// Execute a test step with automatic timing and logging
    public func step(_ name: String, logger: StepLogger, file: StaticString = #file, line: UInt = #line, _ block: () throws -> Void) rethrows {
        let start = Date()
        print("\n▶️  Starting: \(name)")
        
        do {
            try block()
            let end = Date()
            logger.add(name: name, start: start, end: end)
        } catch {
            let end = Date()
            logger.add(name: name, start: start, end: end, metadata: ["error": "\(error)"])
            XCTFail("Step '\(name)' failed: \(error)", file: file, line: line)
            throw error
        }
    }
    
    /// Execute an async test step
    @available(iOS 13.0, macOS 10.15, *)
    public func asyncStep(_ name: String, logger: StepLogger, file: StaticString = #file, line: UInt = #line, _ block: () async throws -> Void) async rethrows {
        let start = Date()
        print("\n▶️  Starting: \(name)")
        
        do {
            try await block()
            let end = Date()
            logger.add(name: name, start: start, end: end)
        } catch {
            let end = Date()
            logger.add(name: name, start: start, end: end, metadata: ["error": "\(error)"])
            XCTFail("Step '\(name)' failed: \(error)", file: file, line: line)
            throw error
        }
    }
}


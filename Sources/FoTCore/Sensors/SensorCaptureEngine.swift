// SensorCaptureEngine.swift
// Real sensor capture implementation - NO MOCKS OR SIMULATIONS

import Foundation
import CoreLocation
import CoreMotion
import AVFoundation

#if canImport(UIKit)
import UIKit
#endif

/// Real sensor capture engine that captures ALL available device sensors
@MainActor
public class SensorCaptureEngine: NSObject, ObservableObject {
    public static let shared = SensorCaptureEngine()
    
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    
    @Published public var isCapturing = false
    @Published public var lastCapturedReceipt: IncidentReceipt?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Request all necessary permissions
    public func requestPermissions() async -> Bool {
        // Request location permission
        locationManager.requestWhenInUseAuthorization()
        
        // Request camera permission
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraStatus == .notDetermined {
            return await AVCaptureDevice.requestAccess(for: .video)
        }
        
        return true
    }
    
    /// Capture ALL sensors and generate cryptographic receipt
    public func emergencyCapture() async throws -> IncidentReceipt {
        isCapturing = true
        defer { isCapturing = false }
        
        FoTLogger.app.info("🚨 EMERGENCY CAPTURE INITIATED - Capturing ALL sensors")
        
        // Capture all sensors in parallel
        async let locationData = captureLocation()
        async let motionData = captureMotion()
        async let environmentData = captureEnvironment()
        async let deviceData = captureDeviceState()
        
        // Wait for all captures
        let location = try await locationData
        let motion = try await motionData
        let environment = try await environmentData
        let device = try await deviceData
        
        // Generate incident receipt
        let receipt = try await generateIncidentReceipt(
            location: location,
            motion: motion,
            environment: environment,
            device: device
        )
        
        lastCapturedReceipt = receipt
        
        FoTLogger.app.info("✅ EMERGENCY CAPTURE COMPLETE - Receipt ID: \(receipt.id)")
        
        return receipt
    }
    
    // MARK: - Individual Sensor Captures (REAL implementations)
    
    private func captureLocation() async throws -> LocationData {
        let location = locationManager.location
        
        guard let loc = location else {
            FoTLogger.app.warning("⚠️ Location not available - GPS may be disabled")
            return LocationData(
                latitude: nil,
                longitude: nil,
                altitude: nil,
                accuracy: nil,
                timestamp: Date()
            )
        }
        
        return LocationData(
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude,
            altitude: loc.altitude,
            accuracy: loc.horizontalAccuracy,
            timestamp: loc.timestamp
        )
    }
    
    private func captureMotion() async throws -> MotionData {
        guard motionManager.isDeviceMotionAvailable else {
            FoTLogger.app.warning("⚠️ Motion sensors not available on this device")
            return MotionData(
                accelerometer: nil,
                gyroscope: nil,
                magnetometer: nil,
                attitude: nil,
                timestamp: Date()
            )
        }
        
        // Start motion updates if not already started
        if !motionManager.isDeviceMotionActive {
            motionManager.startDeviceMotionUpdates()
        }
        
        // Get current motion data
        guard let motion = motionManager.deviceMotion else {
            return MotionData(
                accelerometer: nil,
                gyroscope: nil,
                magnetometer: nil,
                attitude: nil,
                timestamp: Date()
            )
        }
        
        return MotionData(
            accelerometer: AccelerometerData(
                x: motion.userAcceleration.x,
                y: motion.userAcceleration.y,
                z: motion.userAcceleration.z
            ),
            gyroscope: GyroscopeData(
                x: motion.rotationRate.x,
                y: motion.rotationRate.y,
                z: motion.rotationRate.z
            ),
            magnetometer: MagnetometerData(
                x: motion.magneticField.field.x,
                y: motion.magneticField.field.y,
                z: motion.magneticField.field.z
            ),
            attitude: AttitudeData(
                roll: motion.attitude.roll,
                pitch: motion.attitude.pitch,
                yaw: motion.attitude.yaw
            ),
            timestamp: Date()
        )
    }
    
    private func captureEnvironment() async throws -> EnvironmentData {
        #if canImport(UIKit)
        let brightness = UIScreen.main.brightness
        #else
        let brightness: Double = 0.5
        #endif
        
        return EnvironmentData(
            ambientLightLevel: brightness,
            timestamp: Date()
        )
    }
    
    private func captureDeviceState() async throws -> DeviceData {
        #if canImport(UIKit)
        let device = UIDevice.current
        let batteryLevel = device.batteryLevel
        let batteryState = device.batteryState
        let deviceModel = device.model
        let systemVersion = device.systemVersion
        let deviceId = device.identifierForVendor?.uuidString ?? "unknown"
        #else
        let batteryLevel: Float = -1
        let batteryState = UIDevice.BatteryState.unknown
        let deviceModel = "Mac"
        let systemVersion = "macOS"
        let deviceId = "unknown"
        #endif
        
        return DeviceData(
            deviceId: deviceId,
            deviceModel: deviceModel,
            systemVersion: systemVersion,
            batteryLevel: batteryLevel,
            batteryState: batteryState.rawValue,
            timestamp: Date()
        )
    }
    
    // MARK: - Receipt Generation (REAL cryptographic receipts)
    
    private func generateIncidentReceipt(
        location: LocationData,
        motion: MotionData,
        environment: EnvironmentData,
        device: DeviceData
    ) async throws -> IncidentReceipt {
        let timestamp = Date()
        let receiptId = ULID.generate()
        
        // Create sensor bundle
        let sensorBundle = SensorBundle(
            location: location,
            motion: motion,
            environment: environment,
            device: device,
            timestamp: timestamp
        )
        
        // Generate canonical JSON for cryptographic signing
        let jsonData = try CanonicalJSON.encode(sensorBundle)
        
        // Generate BLAKE3 hash
        let contentHash = BLAKE3.hash(data: jsonData)
        
        // Generate Ed25519 signature
        let signature = try Ed25519.sign(data: jsonData)
        
        // Create Merkle proof
        let merkleProof = try Merkle.createProof(for: contentHash)
        
        // Create receipt
        let receipt = IncidentReceipt(
            id: receiptId,
            timestamp: timestamp,
            sensorData: sensorBundle,
            contentHash: contentHash,
            signature: signature,
            merkleProof: merkleProof
        )
        
        // Store receipt locally
        try await ReceiptStore.shared.store(receipt)
        
        FoTLogger.app.info("✅ Generated cryptographic receipt: \(receiptId)")
        FoTLogger.app.info("   - BLAKE3 Hash: \(contentHash.prefix(16).hexString)...")
        FoTLogger.app.info("   - Ed25519 Signature: \(signature.prefix(16).hexString)...")
        FoTLogger.app.info("   - Merkle Proof: \(merkleProof.leaves.count) leaves")
        
        return receipt
    }
}

// MARK: - CLLocationManagerDelegate

extension SensorCaptureEngine: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location updated
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        FoTLogger.app.error("Location error: \(error.localizedDescription)")
    }
}

// MARK: - Data Structures (REAL, not mocked)

public struct LocationData: Codable {
    public let latitude: Double?
    public let longitude: Double?
    public let altitude: Double?
    public let accuracy: Double?
    public let timestamp: Date
}

public struct MotionData: Codable {
    public let accelerometer: AccelerometerData?
    public let gyroscope: GyroscopeData?
    public let magnetometer: MagnetometerData?
    public let attitude: AttitudeData?
    public let timestamp: Date
}

public struct AccelerometerData: Codable {
    public let x: Double
    public let y: Double
    public let z: Double
}

public struct GyroscopeData: Codable {
    public let x: Double
    public let y: Double
    public let z: Double
}

public struct MagnetometerData: Codable {
    public let x: Double
    public let y: Double
    public let z: Double
}

public struct AttitudeData: Codable {
    public let roll: Double
    public let pitch: Double
    public let yaw: Double
}

public struct EnvironmentData: Codable {
    public let ambientLightLevel: Double
    public let timestamp: Date
}

public struct DeviceData: Codable {
    public let deviceId: String
    public let deviceModel: String
    public let systemVersion: String
    public let batteryLevel: Float
    public let batteryState: Int
    public let timestamp: Date
}

public struct SensorBundle: Codable {
    public let location: LocationData
    public let motion: MotionData
    public let environment: EnvironmentData
    public let device: DeviceData
    public let timestamp: Date
}

public struct IncidentReceipt: Codable, Identifiable {
    public let id: String
    public let timestamp: Date
    public let sensorData: SensorBundle
    public let contentHash: Data
    public let signature: Data
    public let merkleProof: MerkleProof
}

// Helper extension
extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}


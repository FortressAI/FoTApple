// PersonalHealthMacApp.swift
// macOS version of Personal Health Monitor

import SwiftUI
import FoTCore
import FoTUI

@main
struct PersonalHealthMacApp: App {
    @StateObject private var healthState = HealthStateMac()
    
    var body: some Scene {
        WindowGroup {
            PersonalHealthMacContentView()
                .environmentObject(healthState)
                .frame(minWidth: 1000, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}

class HealthStateMac: ObservableObject {
    @Published var healthRecords: [HealthRecord] = []
    @Published var currentDate = Date()
    
    init() {
        // Load sample health data
        loadSampleData()
    }
    
    func loadSampleData() {
        healthRecords = [
            HealthRecord(
                date: Date().addingTimeInterval(-86400 * 7),
                type: .vitals,
                temperature: 98.6,
                heartRate: 72,
                bloodPressure: "120/80",
                notes: "Weekly checkup - feeling great"
            ),
            HealthRecord(
                date: Date().addingTimeInterval(-86400 * 3),
                type: .symptom,
                temperature: 99.1,
                heartRate: 82,
                bloodPressure: nil,
                notes: "Mild headache, took ibuprofen"
            ),
            HealthRecord(
                date: Date(),
                type: .vitals,
                temperature: 98.4,
                heartRate: 68,
                bloodPressure: "118/76",
                notes: "Morning vitals - all normal"
            )
        ]
    }
    
    func captureHealthMoment() {
        FoTLogger.app.info("Capturing health moment with camera and sensors...")
    }
}

struct HealthRecord: Identifiable {
    let id = UUID()
    let date: Date
    let type: RecordType
    var temperature: Double?
    var heartRate: Int?
    var bloodPressure: String?
    var weight: Double?
    var notes: String
    var receiptID: String?
    
    enum RecordType: String {
        case vitals = "Vitals"
        case symptom = "Symptom"
        case medication = "Medication"
        case injury = "Injury"
    }
}


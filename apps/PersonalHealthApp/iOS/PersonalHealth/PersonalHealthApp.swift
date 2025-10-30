// PersonalHealthApp.swift
// Personal Health Monitor - For INDIVIDUALS to track their own health

import SwiftUI
import FoTCore
import FoTUI

@main
struct PersonalHealthApp: App {
    @StateObject private var healthState = HealthState()
    @StateObject private var voiceAssistant = SiriVoiceAssistant.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    init() {
        FoTLogger.app.info("My Health starting - Personal health monitor for individuals")
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasCompletedOnboarding {
                    PersonalHealthOnboardingFlow {
                        hasCompletedOnboarding = true
                    }
                } else {
                    PersonalHealthContentView()
                        .environmentObject(healthState)
                        .interactiveHelp(.personalHealthDashboard)
                        .voiceContext(.healthTracking, message: "Welcome to My Health. Your personal health companion.")
                        .onAppear {
                            // Greet user every time app opens
                            voiceAssistant.greetUser(appName: "My Health")
                        }
                }
                
                // Floating voice assistant indicator
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VoiceAssistantIndicator()
                            .padding()
                    }
                }
            }
        }
    }
}

/// Health state for individual user
class HealthState: ObservableObject {
    @Published var healthRecords: [HealthRecord] = []
    @Published var currentSymptoms: [Symptom] = []
    @Published var medications: [MedicationLog] = []
    @Published var sharedWithClinicians: [String] = [] // Clinician IDs who have access
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        // Load user's own health data
        healthRecords = [
            HealthRecord(
                date: Date(),
                type: .vitals,
                temperature: 37.1,
                heartRate: 72,
                bloodPressure: "120/80",
                notes: "Feeling good today"
            )
        ]
    }
    
    func captureHealthIncident() {
        // This will capture ALL sensors and generate receipt
        FoTLogger.app.info("Capturing health incident with sensors...")
    }
    
    func shareWithClinician(_ clinicianID: String, duration: TimeInterval) {
        // Grant temporary access to health data
        sharedWithClinicians.append(clinicianID)
        FoTLogger.app.info("Shared health data with clinician: \(clinicianID)")
    }
}

/// Individual health record
struct HealthRecord: Identifiable {
    let id = UUID()
    let date: Date
    let type: RecordType
    var temperature: Double?
    var heartRate: Int?
    var bloodPressure: String?
    var weight: Double?
    var notes: String
    var photos: [Data] = []
    var location: String?
    var receiptID: String?
    
    enum RecordType: String {
        case vitals = "Vitals"
        case symptom = "Symptom"
        case medication = "Medication"
        case injury = "Injury"
        case fallDetected = "Fall Detected"
    }
}

/// Symptom tracking
struct Symptom: Identifiable {
    let id = UUID()
    let date: Date
    let description: String
    let severity: Int // 1-10
    let bodyPart: String?
    let photo: Data?
}

/// Medication log
struct MedicationLog: Identifiable {
    let id = UUID()
    let date: Date
    let medicationName: String
    let dose: String
    let photo: Data? // Photo of pill bottle
    let taken: Bool
}


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
                    PersonalHealthOnboardingView {
                        hasCompletedOnboarding = true
                    }
                } else {
                    PersonalHealthContentView()
                        .environmentObject(healthState)
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
        // Load sample data only in training mode
        if AppConfig.shared.features.dataMode == .training {
            loadSampleData()
        }
    }
    
    func loadSampleData() {
        // Load user's own health data (TRAINING MODE ONLY)
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
    
    func captureHealthIncident() async {
        // REAL sensor capture - NO MOCKS
        FoTLogger.app.info("🚨 EMERGENCY: Capturing ALL sensors...")
        
        do {
            let receipt = try await SensorCaptureEngine.shared.emergencyCapture()
            
            // Store receipt with health record
            let healthRecord = HealthRecord(
                date: Date(),
                type: .injury,
                notes: "Emergency capture",
                receiptID: receipt.id
            )
            healthRecords.append(healthRecord)
            
            FoTLogger.app.info("✅ Health incident captured successfully - Receipt: \(receipt.id)")
            
        } catch {
            FoTLogger.app.error("❌ Failed to capture incident: \(error.localizedDescription)")
        }
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


// Temporary inline onboarding view until Xcode project updated
struct PersonalHealthOnboardingView: View {
    let onComplete: () -> Void
    @State private var showingSplash = true
    @State private var showingOnboarding = false
    
    var body: some View {
        ZStack {
            if showingSplash {
                AnimatedSplashScreen(
                    appName: "My Health",
                    appIcon: "heart.fill",
                    primaryColor: .pink,
                    secondaryColor: .purple,
                    onComplete: {
                        withAnimation {
                            showingSplash = false
                            showingOnboarding = true
                        }
                    }
                )
            } else if showingOnboarding {
                SiriGuidedOnboarding(
                    appName: "My Health",
                    features: [
                        OnboardingFeature(
                            icon: "heart.fill",
                            title: "Track Your Health",
                            description: "Monitor your mental and physical wellbeing with daily check-ins",
                            siriCommand: "Log my mood in My Health"
                        ),
                        OnboardingFeature(
                            icon: "phone.fill",
                            title: "Crisis Support",
                            description: "Access immediate help when you need it most",
                            siriCommand: "Get crisis support in My Health"
                        ),
                        OnboardingFeature(
                            icon: "questionmark.circle",
                            title: "Health Guidance",
                            description: "Get AI-powered guidance on whether you should seek professional care",
                            siriCommand: "Should I see a doctor in My Health"
                        )
                    ],
                    primaryColor: .pink,
                    onComplete: onComplete
                )
            }
        }
    }
}

// FoTLegalApp.swift
// Field of Truth Legal US App

import SwiftUI
import FoTCore
import FoTLegalUS
import FoTUI

@main
struct FoTLegalApp: App {
    @StateObject private var appState = LegalAppState()
    @StateObject private var voiceAssistant = SiriVoiceAssistant.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    init() {
        AppConfig.shared.features.useLocalLLM = false
        AppConfig.shared.features.vqbitSuggestions = true
        FoTLogger.app.info("FoT Legal US starting - version \(AppConfig.shared.version)")
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasCompletedOnboarding {
                    LegalOnboardingView {
                        hasCompletedOnboarding = true
                    }
                } else {
                    LegalContentView()
                        .environmentObject(appState)
                        .voiceContext(.dashboard, message: "Welcome to Field of Truth Legal. Your case management dashboard.")
                        .onAppear {
                            // Greet user every time app opens
                            voiceAssistant.greetUser(appName: "Field of Truth Legal")
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

class LegalAppState: ObservableObject {
    @Published var cases: [LegalCase] = []
    @Published var currentCase: LegalCase?
    
    init() {
        // Load sample data only in training mode
        if AppConfig.shared.features.dataMode == .training {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        // Sample legal cases for demonstration (TRAINING MODE ONLY)
        cases = [
            LegalCase(
                id: UUID(),
                caseNumber: "2025-CV-001234",
                title: "Johnson v. Acme Corporation",
                caseType: .employment,
                status: .active,
                filingDate: Date().addingTimeInterval(-86400 * 60),
                description: "Wrongful termination and discrimination claim",
                timeline: [
                    TimelineEvent(date: Date().addingTimeInterval(-86400 * 60), description: "Case filed", eventType: .filing),
                    TimelineEvent(date: Date().addingTimeInterval(-86400 * 45), description: "Discovery period begins", eventType: .discovery),
                    TimelineEvent(date: Date().addingTimeInterval(-86400 * 30), description: "Depositions scheduled", eventType: .deposition)
                ],
                evidence: [],
                notes: "Client claims discriminatory remarks and hostile work environment."
            ),
            LegalCase(
                id: UUID(),
                caseNumber: "2025-PI-005678",
                title: "Smith Personal Injury Claim",
                caseType: .personalInjury,
                status: .active,
                filingDate: Date().addingTimeInterval(-86400 * 90),
                description: "Motor vehicle accident with significant injuries",
                timeline: [
                    TimelineEvent(date: Date().addingTimeInterval(-86400 * 90), description: "Accident occurred", eventType: .incident),
                    TimelineEvent(date: Date().addingTimeInterval(-86400 * 85), description: "Demand letter sent", eventType: .correspondence),
                    TimelineEvent(date: Date().addingTimeInterval(-86400 * 60), description: "Settlement negotiations begin", eventType: .negotiation)
                ],
                evidence: [],
                notes: "Client suffered back injuries. Medical bills exceed $50,000."
            ),
            LegalCase(
                id: UUID(),
                caseNumber: "2025-FAM-002345",
                title: "Rodriguez Family Matter",
                caseType: .family,
                status: .pending,
                filingDate: Date().addingTimeInterval(-86400 * 30),
                description: "Child custody modification",
                timeline: [
                    TimelineEvent(date: Date().addingTimeInterval(-86400 * 30), description: "Petition filed", eventType: .filing),
                    TimelineEvent(date: Date().addingTimeInterval(-86400 * 15), description: "Mediation scheduled", eventType: .hearing)
                ],
                evidence: [],
                notes: "Client seeking increased custody due to changed circumstances."
            )
        ]
    }
    
    func selectCase(_ legalCase: LegalCase) {
        currentCase = legalCase
    }
}

struct LegalCase: Identifiable {
    let id: UUID
    let caseNumber: String
    let title: String
    let caseType: CaseType
    var status: CaseStatus
    let filingDate: Date
    let description: String
    var timeline: [TimelineEvent]
    var evidence: [Evidence]
    var notes: String
    
    enum CaseType: String, CaseIterable {
        case employment = "Employment"
        case personalInjury = "Personal Injury"
        case family = "Family Law"
        case criminal = "Criminal"
        case civilRights = "Civil Rights"
        case contract = "Contract"
        case other = "Other"
    }
    
    enum CaseStatus: String {
        case pending = "Pending"
        case active = "Active"
        case settled = "Settled"
        case closed = "Closed"
        case appealed = "Appealed"
    }
}

struct TimelineEvent: Identifiable {
    let id = UUID()
    let date: Date
    let description: String
    let eventType: EventType
    
    enum EventType: String {
        case filing = "Filing"
        case hearing = "Hearing"
        case deposition = "Deposition"
        case discovery = "Discovery"
        case negotiation = "Negotiation"
        case correspondence = "Correspondence"
        case incident = "Incident"
        case evidence = "Evidence"
    }
}

struct Evidence: Identifiable {
    let id = UUID()
    let title: String
    let type: EvidenceType
    let dateCollected: Date
    let description: String
    var receiptID: String?
    
    enum EvidenceType: String {
        case document = "Document"
        case photo = "Photo"
        case video = "Video"
        case audio = "Audio"
        case testimony = "Testimony"
        case physical = "Physical"
    }
}


// Inline onboarding view
struct LegalOnboardingView: View {
    let onComplete: () -> Void
    @State private var showingSplash = true
    @State private var showingOnboarding = false
    
    var body: some View {
        ZStack {
            if showingSplash {
                AnimatedSplashScreen(
                    appName: "FoT Legal",
                    appIcon: "scale.3d",
                    primaryColor: .blue,
                    secondaryColor: .cyan,
                    onComplete: {
                        withAnimation {
                            showingSplash = false
                            showingOnboarding = true
                        }
                    }
                )
            } else if showingOnboarding {
                SiriGuidedOnboarding(
                    appName: "FoT Legal",
                    features: [
                        OnboardingFeature(
                            icon: "folder.badge.plus",
                            title: "Case Management",
                            description: "Create and manage legal cases with AI-powered assistance",
                            siriCommand: "Create new case in FoT Legal"
                        ),
                        OnboardingFeature(
                            icon: "magnifyingglass",
                            title: "Legal Research",
                            description: "Search case law and legal precedents instantly",
                            siriCommand: "Search case law in FoT Legal"
                        ),
                        OnboardingFeature(
                            icon: "calendar.badge.clock",
                            title: "Deadline Tracking",
                            description: "Never miss a filing deadline with smart reminders",
                            siriCommand: "Show my deadlines in FoT Legal"
                        )
                    ],
                    primaryColor: .blue,
                    onComplete: onComplete
                )
            }
        }
    }
}

// FoTEducationApp.swift
// Field of Truth Education K-18 App

import SwiftUI
import FoTCore
import FoTEducationK18
import FoTUI

@main
struct FoTEducationApp: App {
    @StateObject private var appState = EducationAppState()
    @StateObject private var voiceAssistant = SiriVoiceAssistant.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    init() {
        AppConfig.shared.features.useLocalLLM = false
        AppConfig.shared.features.vqbitSuggestions = true
        FoTLogger.app.info("FoT Education K-18 starting - version \(AppConfig.shared.version)")
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasCompletedOnboarding {
                    EducationOnboardingFlow {
                        hasCompletedOnboarding = true
                    }
                } else {
                    EducationContentView()
                        .environmentObject(appState)
                        .interactiveHelp(.educationDashboard)
                        .voiceContext(.education, message: "Welcome to FoT Education. Your personal learning assistant.")
                        .onAppear {
                            // Greet user every time app opens
                            voiceAssistant.greetUser(appName: "FoT Education")
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

class EducationAppState: ObservableObject {
    @Published var students: [Student] = []
    @Published var currentStudent: Student?
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample students for demonstration
        students = [
            Student(
                studentId: "STU001",
                firstName: "Emma",
                lastName: "Johnson",
                gradeLevel: .grade5,
                dateOfBirth: Date().addingTimeInterval(-365 * 24 * 3600 * 11),
                guardianConsent: true,
                learningProfile: LearningProfile(
                    strengths: ["Math", "Science", "Visual Learning"],
                    challenges: ["Reading Comprehension", "Written Expression"],
                    learningStyle: .visual,
                    accommodations: ["Extra time on tests", "Read-aloud support", "IEP accommodations"]
                ),
                virtueScores: VirtueScores(justice: 0.8, temperance: 0.7, prudence: 0.75, fortitude: 0.8)
            ),
            Student(
                studentId: "STU002",
                firstName: "Michael",
                lastName: "Chen",
                gradeLevel: .grade8,
                dateOfBirth: Date().addingTimeInterval(-365 * 24 * 3600 * 14),
                guardianConsent: true,
                learningProfile: LearningProfile(
                    strengths: ["Writing", "Critical Thinking", "Leadership"],
                    challenges: ["Organization", "Time Management"],
                    learningStyle: .balanced,
                    accommodations: ["Planner assistance", "Check-ins"]
                ),
                virtueScores: VirtueScores(justice: 0.85, temperance: 0.6, prudence: 0.65, fortitude: 0.9)
            ),
            Student(
                studentId: "STU003",
                firstName: "Sofia",
                lastName: "Rodriguez",
                gradeLevel: .kindergarten,
                dateOfBirth: Date().addingTimeInterval(-365 * 24 * 3600 * 5),
                guardianConsent: true,
                learningProfile: LearningProfile(
                    strengths: ["Creative Play", "Social Skills", "Art"],
                    challenges: ["Sitting Still", "Following Multi-Step Directions"],
                    learningStyle: .kinesthetic,
                    accommodations: ["Movement breaks", "Visual schedules"]
                ),
                virtueScores: VirtueScores(justice: 0.7, temperance: 0.5, prudence: 0.55, fortitude: 0.75)
            )
        ]
    }
    
    func selectStudent(_ student: Student) {
        currentStudent = student
    }
}


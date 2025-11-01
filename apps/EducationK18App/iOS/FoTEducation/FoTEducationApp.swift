// FoTEducationApp.swift
// Main app entry point for FoT Education K-18 iOS

import SwiftUI
import FoTCore
import FoTEducationK18

@main
struct FoTEducationApp: App {
    @StateObject private var appState = EducationAppState()
    
    init() {
        FoTLogger.app.info("FoT Education K-18 starting - version \(AppConfig.shared.version)")
    }
    
    var body: some Scene {
        WindowGroup {
            EducationContentView()
                .environmentObject(appState)
        }
    }
}

/// Global app state for Education K-18
class EducationAppState: ObservableObject {
    @Published var currentStudent: Student?
    @Published var students: [Student] = []
    
    init() {
        // Load sample data only in training mode
        if AppConfig.shared.features.dataMode == .training {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        // Sample students for demonstration (TRAINING MODE ONLY)
        let student1 = Student(
            studentId: "STU001",
            firstName: "Alice",
            lastName: "Johnson",
            gradeLevel: .grade5,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -10, to: Date())!,
            guardianConsent: true,
            learningProfile: LearningProfile(
                strengths: ["Mathematics", "Science"],
                challenges: ["Reading comprehension"],
                learningStyle: .visual,
                accommodations: ["Extended time on tests"]
            ),
            assignments: [
                Assignment(
                    title: "Math Worksheet - Fractions",
                    subject: .mathematics,
                    dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                    status: .inProgress
                ),
                Assignment(
                    title: "Science Project - Solar System",
                    subject: .science,
                    dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                    status: .assigned
                )
            ],
            assessments: [
                Assessment(
                    title: "Math Quiz - Chapter 5",
                    subject: .mathematics,
                    date: Date(),
                    score: 45,
                    maxScore: 50,
                    masteryLevel: .proficient
                )
            ],
            virtueScores: VirtueScores(justice: 0.8, temperance: 0.7, prudence: 0.9, fortitude: 0.85)
        )
        
        let student2 = Student(
            studentId: "STU002",
            firstName: "Bob",
            lastName: "Smith",
            gradeLevel: .grade8,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -13, to: Date())!,
            guardianConsent: true,
            learningProfile: LearningProfile(
                strengths: ["English", "History"],
                challenges: ["Mathematics"],
                learningStyle: .auditory
            ),
            assignments: [
                Assignment(
                    title: "Essay - American Revolution",
                    subject: .socialStudies,
                    dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
                    status: .inProgress
                )
            ],
            virtueScores: VirtueScores(justice: 0.9, temperance: 0.8, prudence: 0.7, fortitude: 0.75)
        )
        
        students = [student1, student2]
    }
    
    func selectStudent(_ student: Student) {
        currentStudent = student
    }
}


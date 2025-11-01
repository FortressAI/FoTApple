// FoTEducationWatchApp.swift
// watchOS companion app for FoT Education K-18

import SwiftUI
import FoTCore
import FoTEducationK18

@main
struct FoTEducationWatchApp: App {
    @StateObject private var appState = EducationWatchAppState()
    
    var body: some Scene {
        WindowGroup {
            EducationWatchContentView()
                .environmentObject(appState)
        }
    }
}

/// Watch app state for Education
class EducationWatchAppState: ObservableObject {
    @Published var todayAssignments: [Assignment] = []
    @Published var currentStudent: Student?
    
    init() {
        // Load sample data only in training mode
        if AppConfig.shared.features.dataMode == .training {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        // Sample student and assignments (TRAINING MODE ONLY)
        let student = Student(
            studentId: "STU001",
            firstName: "Alice",
            lastName: "Johnson",
            gradeLevel: .grade5,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -10, to: Date())!,
            guardianConsent: true,
            virtueScores: VirtueScores(justice: 0.8, temperance: 0.7, prudence: 0.9, fortitude: 0.85)
        )
        
        currentStudent = student
        
        todayAssignments = [
            Assignment(
                title: "Math Worksheet - Fractions",
                subject: .mathematics,
                dueDate: Date(),
                status: .inProgress
            ),
            Assignment(
                title: "Reading Comprehension",
                subject: .english,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                status: .assigned
            )
        ]
    }
}


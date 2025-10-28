// FoTEducationMacApp.swift
// macOS app for FoT Education K-18

import SwiftUI
import FoTCore
import FoTEducationK18

@main
struct FoTEducationMacApp: App {
    @StateObject private var appState = EducationMacAppState()
    
    var body: some Scene {
        // Main Window
        WindowGroup {
            EducationMacContentView()
                .environmentObject(appState)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .commands {
            EducationCommands()
        }
        
        // Student Detail Window
        WindowGroup("Student Detail", for: UUID.self) { $studentID in
            if let studentID = studentID,
               let student = appState.students.first(where: { $0.id == studentID }) {
                StudentDetailWindow(student: student)
                    .environmentObject(appState)
            }
        }
        
        // Settings Window
        Settings {
            EducationSettingsView()
        }
    }
}

/// macOS app state for Education K-18
class EducationMacAppState: ObservableObject {
    @Published var students: [Student] = []
    @Published var selectedStudent: Student?
    @Published var searchText = ""
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
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
                Assignment(title: "Math Worksheet - Fractions", subject: .mathematics, dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, status: .inProgress),
                Assignment(title: "Science Project - Solar System", subject: .science, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, status: .assigned)
            ],
            assessments: [
                Assessment(title: "Math Quiz - Chapter 5", subject: .mathematics, date: Date(), score: 45, maxScore: 50, masteryLevel: .proficient)
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
                Assignment(title: "Essay - American Revolution", subject: .socialStudies, dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, status: .inProgress)
            ],
            virtueScores: VirtueScores(justice: 0.9, temperance: 0.8, prudence: 0.7, fortitude: 0.75)
        )
        
        students = [student1, student2]
    }
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return students
        }
        return students.filter { student in
            student.fullName.localizedCaseInsensitiveContains(searchText) ||
            student.studentId.localizedCaseInsensitiveContains(searchText)
        }
    }
}

/// Menu commands
struct EducationCommands: Commands {
    var body: some Commands {
        CommandMenu("Student") {
            Button("New Student...") {}
                .keyboardShortcut("n", modifiers: [.command])
            
            Divider()
            
            Button("Generate Report Card...") {}
                .keyboardShortcut("r", modifiers: [.command])
            
            Button("Export Grades...") {}
                .keyboardShortcut("e", modifiers: [.command])
        }
        
        CommandMenu("View") {
            Button("Show Grade Book") {}
                .keyboardShortcut("g", modifiers: [.command, .option])
        }
    }
}


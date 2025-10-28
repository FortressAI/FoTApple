// FoTParentApp.swift
// Field of Truth Parent/Guardian App

import SwiftUI
import FoTCore
import FoTEducationK18
import FoTUI

@main
struct FoTParentApp: App {
    @StateObject private var appState = ParentAppState()
    
    init() {
        AppConfig.shared.features.useLocalLLM = false
        AppConfig.shared.features.vqbitSuggestions = true
        FoTLogger.app.info("FoT Parent starting - version \(AppConfig.shared.version)")
    }
    
    var body: some Scene {
        WindowGroup {
            ParentContentView()
                .environmentObject(appState)
        }
    }
}

class ParentAppState: ObservableObject {
    @Published var children: [StudentInfo] = []
    @Published var selectedChild: StudentInfo?
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample children for demonstration
        children = [
            StudentInfo(
                name: "Emma Smith",
                gradeLevel: .ninth,
                gpa: 3.65,
                attendance: 96.0,
                behaviorRating: .excellent
            ),
            StudentInfo(
                name: "Liam Smith",
                gradeLevel: .sixth,
                gpa: 3.45,
                attendance: 94.0,
                behaviorRating: .good
            )
        ]
        selectedChild = children.first
    }
}

struct StudentInfo: Identifiable {
    let id = UUID()
    let name: String
    let gradeLevel: GradeLevel
    let gpa: Double
    let attendance: Double
    let behaviorRating: BehaviorRating
    
    enum BehaviorRating: String {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case needsImprovement = "Needs Improvement"
    }
}


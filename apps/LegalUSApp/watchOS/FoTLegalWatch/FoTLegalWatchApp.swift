// FoTLegalWatchApp.swift
// watchOS companion app for FoT Legal US

import SwiftUI
import FoTCore
import FoTLegalUS

@main
struct FoTLegalWatchApp: App {
    @StateObject private var appState = LegalWatchAppState()
    
    var body: some Scene {
        WindowGroup {
            LegalWatchContentView()
                .environmentObject(appState)
        }
    }
}

/// Watch app state for Legal
class LegalWatchAppState: ObservableObject {
    @Published var upcomingDeadlines: [Deadline] = []
    @Published var recentCases: [LegalCase] = []
    
    init() {
        // Load sample data only in training mode
        if AppConfig.shared.features.dataMode == .training {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        // Sample cases and deadlines (TRAINING MODE ONLY)
        let case1 = LegalCase(
            caseNumber: "CV-2024-001",
            title: "Smith v. Johnson",
            clientName: "John Smith",
            caseType: .civil,
            jurisdiction: Jurisdiction(court: "U.S. District Court", district: "Northern District of California", state: "CA"),
            filingDate: Date()
        )
        
        recentCases = [case1]
        
        upcomingDeadlines = [
            Deadline(
                title: "Answer Due",
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                ruleReference: "FRCP 12(a)",
                description: "Defendant must file answer"
            ),
            Deadline(
                title: "Discovery Meeting",
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                ruleReference: "FRCP 26(f)",
                description: "Initial discovery conference"
            )
        ]
    }
}


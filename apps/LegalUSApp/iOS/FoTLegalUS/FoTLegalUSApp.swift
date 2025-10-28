// FoTLegalUSApp.swift
// Main app entry point for FoT Legal US iOS

import SwiftUI
import FoTCore
import FoTLegalUS

@main
struct FoTLegalUSApp: App {
    @StateObject private var appState = LegalAppState()
    
    init() {
        AppConfig.shared.features.strictCitationMode = true
        FoTLogger.app.info("FoT Legal US starting - version \(AppConfig.shared.version)")
    }
    
    var body: some Scene {
        WindowGroup {
            LegalContentView()
                .environmentObject(appState)
        }
    }
}

/// Global app state for Legal US
class LegalAppState: ObservableObject {
    @Published var currentCase: LegalCase?
    @Published var cases: [LegalCase] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample cases for demonstration
        let case1 = LegalCase(
            caseNumber: "CV-2024-001",
            title: "Smith v. Johnson",
            clientName: "John Smith",
            caseType: .civil,
            jurisdiction: Jurisdiction(court: "U.S. District Court", district: "Northern District of California", state: "CA"),
            filingDate: Date(),
            deadlines: [
                Deadline(title: "Answer Due", dueDate: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, ruleReference: "FRCP 12(a)", description: "Defendant must file answer"),
                Deadline(title: "Discovery Conference", dueDate: Calendar.current.date(byAdding: .day, value: 90, to: Date())!, ruleReference: "FRCP 26(f)", description: "Initial discovery conference")
            ],
            citations: [
                Citation(citationText: "550 U.S. 544", caseTitle: "Bell Atlantic Corp. v. Twombly", reporter: "550 U.S. 544", year: 2007, court: "Supreme Court", relevance: "Pleading standards")
            ]
        )
        
        let case2 = LegalCase(
            caseNumber: "CR-2024-002",
            title: "United States v. Doe",
            clientName: "Jane Doe",
            caseType: .criminal,
            jurisdiction: Jurisdiction(court: "U.S. District Court", district: "Southern District of New York", state: "NY"),
            filingDate: Date(),
            status: .pending,
            deadlines: [
                Deadline(title: "Arraignment", dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, ruleReference: "Fed. R. Crim. P. 10", description: "Defendant arraignment")
            ]
        )
        
        cases = [case1, case2]
    }
    
    func selectCase(_ legalCase: LegalCase) {
        currentCase = legalCase
    }
}


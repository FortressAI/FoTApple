// FoTLegalMacApp.swift
// macOS app for FoT Legal US

import SwiftUI
import FoTCore
import FoTLegalUS

@main
struct FoTLegalMacApp: App {
    @StateObject private var appState = LegalMacAppState()
    
    var body: some Scene {
        // Main Window
        WindowGroup {
            LegalMacContentView()
                .environmentObject(appState)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .commands {
            LegalCommands()
        }
        
        // Case Detail Window
        WindowGroup("Case Detail", for: UUID.self) { $caseID in
            if let caseID = caseID,
               let legalCase = appState.cases.first(where: { $0.id == caseID }) {
                CaseDetailWindow(legalCase: legalCase)
                    .environmentObject(appState)
            }
        }
        
        // Settings Window
        Settings {
            LegalSettingsView()
        }
    }
}

/// macOS app state for Legal US
class LegalMacAppState: ObservableObject {
    @Published var cases: [LegalCase] = []
    @Published var selectedCase: LegalCase?
    @Published var searchText = ""
    
    init() {
        // Load sample data only in training mode
        if AppConfig.shared.features.dataMode == .training {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        // Sample cases (TRAINING MODE ONLY)
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
    
    var filteredCases: [LegalCase] {
        if searchText.isEmpty {
            return cases
        }
        return cases.filter { legalCase in
            legalCase.title.localizedCaseInsensitiveContains(searchText) ||
            legalCase.caseNumber.localizedCaseInsensitiveContains(searchText) ||
            legalCase.clientName.localizedCaseInsensitiveContains(searchText)
        }
    }
}

/// Menu commands
struct LegalCommands: Commands {
    var body: some Commands {
        CommandMenu("Case") {
            Button("New Case...") {}
                .keyboardShortcut("n", modifiers: [.command])
            
            Divider()
            
            Button("Calculate Deadlines...") {}
                .keyboardShortcut("d", modifiers: [.command])
            
            Button("Export Case Brief...") {}
                .keyboardShortcut("e", modifiers: [.command])
        }
        
        CommandMenu("View") {
            Button("Show Calendar") {}
                .keyboardShortcut("c", modifiers: [.command, .option])
        }
    }
}


// FoTLegalMacApp.swift
// FoT Legal US - macOS Version

import SwiftUI
import FoTCore
import FoTLegalUS
import FoTUI

@main
struct FoTLegalMacApp: App {
    @StateObject private var appState = LegalAppState()
    
    init() {
        AppConfig.shared.features.useLocalLLM = false
        AppConfig.shared.features.vqbitSuggestions = true
        FoTLogger.app.info("FoT Legal US (macOS) starting - version \(AppConfig.shared.version)")
    }
    
    var body: some Scene {
        WindowGroup {
            LegalMacContentView()
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
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
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                caseNumber: "2024-CV-12345",
                title: "Employment Dispute - Smith v. TechCorp",
                clientName: "Jane Smith",
                caseType: .employment,
                jurisdiction: Jurisdiction(court: "Superior Court", district: "Northern", state: "CA"),
                status: .active,
                filingDate: Date().addingTimeInterval(-30 * 24 * 3600),
                notes: "Wrongful termination and discrimination claim"
            ),
            LegalCase(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                caseNumber: "2024-RE-00789",
                title: "Contract Review - Real Estate Purchase",
                clientName: "John Doe",
                caseType: .corporate,
                jurisdiction: Jurisdiction(court: "District Court", district: "Central", state: "NY"),
                status: .active,
                filingDate: Date().addingTimeInterval(-7 * 24 * 3600),
                notes: "Commercial property purchase agreement review"
            )
        ]
    }
}


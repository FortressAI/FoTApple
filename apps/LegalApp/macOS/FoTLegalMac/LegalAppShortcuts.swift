// LegalAppShortcuts.swift
// App Shortcuts for Legal Mac App

import Foundation
import AppIntents
import FoTCore
import FoTAppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct LegalAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Shortcuts temporarily disabled for macOS build
        // TODO: Implement FoTAppIntents for macOS
        return []
        /*return [
            // Personal Legal shortcuts
            AppShortcut(
                intent: DocumentIncidentIntent(),
                phrases: [
                    "Document incident in \(.applicationName)",
                    "Record incident in \(.applicationName)",
                    "Log incident in \(.applicationName)"
                ],
                shortTitle: "Document Incident",
                systemImageName: "exclamationmark.triangle"
            ),
            
            AppShortcut(
                intent: CaptureEvidenceIntent(),
                phrases: [
                    "Record evidence in \(.applicationName)",
                    "Document evidence in \(.applicationName)",
                    "Save evidence in \(.applicationName)"
                ],
                shortTitle: "Record Evidence",
                systemImageName: "camera"
            ),
            
            AppShortcut(
                intent: FindLegalAidIntent(),
                phrases: [
                    "Find legal help in \(.applicationName)",
                    "Get legal assistance in \(.applicationName)",
                    "Find a lawyer in \(.applicationName)"
                ],
                shortTitle: "Find Help",
                systemImageName: "magnifyingglass"
            ),
            
            // Attorney shortcuts
            AppShortcut(
                intent: CreateCaseIntent(),
                phrases: [
                    "Create new case in \(.applicationName)",
                    "Open new case in \(.applicationName)",
                    "Start case in \(.applicationName)"
                ],
                shortTitle: "New Case",
                systemImageName: "folder.badge.plus"
            ),
            
            AppShortcut(
                intent: GenerateContractIntent(),
                phrases: [
                    "Generate contract in \(.applicationName)",
                    "Create contract in \(.applicationName)",
                    "Draft agreement in \(.applicationName)"
                ],
                shortTitle: "Generate Contract",
                systemImageName: "doc.text"
            ),
            
            AppShortcut(
                intent: AnalyzeConstitutionalityIntent(),
                phrases: [
                    "Analyze constitutionality in \(.applicationName)",
                    "Check constitutional law in \(.applicationName)",
                    "Review constitutionality in \(.applicationName)"
                ],
                shortTitle: "Constitutional Analysis",
                systemImageName: "building.columns"
            )
        ]*/
    }
}


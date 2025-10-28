// LegalAppShortcuts.swift
// App Shortcuts for Legal App (Personal & Attorney modes)

import Foundation
import AppIntents
import FoTCore

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct LegalAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
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
                intent: RecordEvidenceIntent(),
                phrases: [
                    "Record evidence in \(.applicationName)",
                    "Document evidence in \(.applicationName)",
                    "Save evidence in \(.applicationName)"
                ],
                shortTitle: "Record Evidence",
                systemImageName: "camera"
            ),
            
            AppShortcut(
                intent: FindLegalHelpIntent(),
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
                intent: CreateClientCaseIntent(),
                phrases: [
                    "Create client case in \(.applicationName)",
                    "New case in \(.applicationName)",
                    "Start case in \(.applicationName)"
                ],
                shortTitle: "New Case",
                systemImageName: "folder.badge.plus"
            ),
            
            AppShortcut(
                intent: RecordBillableTimeIntent(),
                phrases: [
                    "Record billable time in \(.applicationName)",
                    "Log time in \(.applicationName)",
                    "Track hours in \(.applicationName)"
                ],
                shortTitle: "Log Time",
                systemImageName: "clock"
            ),
            
            AppShortcut(
                intent: SearchCaseLawIntent(),
                phrases: [
                    "Search case law in \(.applicationName)",
                    "Find legal precedent in \(.applicationName)",
                    "Research cases in \(.applicationName)"
                ],
                shortTitle: "Search Cases",
                systemImageName: "books.vertical"
            )
        ]
    }
}


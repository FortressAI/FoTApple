// LegalAppShortcuts.swift
// App Shortcuts for Legal App (Personal & Attorney modes)

import Foundation
import AppIntents
import FoTCore
import FoTAppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct LegalAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: CreateCaseIntent(),
                phrases: [
                    "Create new case in \(.applicationName)",
                    "New case in \(.applicationName)",
                    "Start case in \(.applicationName)"
                ],
                shortTitle: "New Case",
                systemImageName: "folder.badge.plus"
            ),
            
            AppShortcut(
                intent: SearchCaseLawIntent(),
                phrases: [
                    "Search case law in \(.applicationName)",
                    "Research legal precedent in \(.applicationName)",
                    "Find statute in \(.applicationName)"
                ],
                shortTitle: "Legal Research",
                systemImageName: "magnifyingglass"
            ),
            
            AppShortcut(
                intent: ShowDeadlinesIntent(),
                phrases: [
                    "Show my deadlines in \(.applicationName)",
                    "Check filing deadlines in \(.applicationName)",
                    "Upcoming deadlines in \(.applicationName)"
                ],
                shortTitle: "Deadlines",
                systemImageName: "calendar.badge.clock"
            ),
            
            AppShortcut(
                intent: MessageClientIntent(),
                phrases: [
                    "Message client in \(.applicationName)",
                    "Contact client in \(.applicationName)",
                    "Send client message in \(.applicationName)"
                ],
                shortTitle: "Message Client",
                systemImageName: "envelope.fill"
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


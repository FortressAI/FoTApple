// HealthAppShortcuts.swift
// App Shortcuts for Personal Health App

import Foundation
import AppIntents
import FoTCore

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct HealthAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: LogVitalsIntent(),
                phrases: [
                    "Log my vitals in \(.applicationName)",
                    "Record health data in \(.applicationName)",
                    "Track my health in \(.applicationName)"
                ],
                shortTitle: "Log Vitals",
                systemImageName: "heart.fill"
            ),
            
            AppShortcut(
                intent: LogMoodIntent(),
                phrases: [
                    "Log my mood in \(.applicationName)",
                    "Record how I'm feeling in \(.applicationName)",
                    "Track my emotions in \(.applicationName)"
                ],
                shortTitle: "Log Mood",
                systemImageName: "face.smiling"
            ),
            
            AppShortcut(
                intent: SummarizeHealthIntent(),
                phrases: [
                    "Summarize my health in \(.applicationName)",
                    "Show health summary in \(.applicationName)",
                    "Health overview in \(.applicationName)"
                ],
                shortTitle: "Health Summary",
                systemImageName: "chart.bar.doc.horizontal"
            ),
            
            AppShortcut(
                intent: ContactCrisisSupportIntent(),
                phrases: [
                    "Contact crisis support in \(.applicationName)",
                    "Get emergency help in \(.applicationName)",
                    "Crisis hotline in \(.applicationName)"
                ],
                shortTitle: "Crisis Support",
                systemImageName: "phone.fill"
            ),
            
            AppShortcut(
                intent: RequestGuidanceIntent(),
                phrases: [
                    "Request guidance in \(.applicationName)",
                    "Get health advice in \(.applicationName)",
                    "Ask for help in \(.applicationName)"
                ],
                shortTitle: "Get Guidance",
                systemImageName: "questionmark.circle"
            ),
            
            AppShortcut(
                intent: SeekMedicalHelpIntent(),
                phrases: [
                    "Seek medical help in \(.applicationName)",
                    "Find a doctor in \(.applicationName)",
                    "Get medical care in \(.applicationName)"
                ],
                shortTitle: "Medical Help",
                systemImageName: "stethoscope"
            )
        ]
    }
}


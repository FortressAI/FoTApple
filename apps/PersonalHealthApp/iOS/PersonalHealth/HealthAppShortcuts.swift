// HealthAppShortcuts.swift
// App Shortcuts for Personal Health App

import Foundation
import AppIntents
import FoTCore
import FoTAppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct HealthAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: RecordHealthCheckInIntent(),
                phrases: [
                    "Record health check-in in \(.applicationName)",
                    "Log my health in \(.applicationName)",
                    "Track how I'm feeling in \(.applicationName)"
                ],
                shortTitle: "Health Check-In",
                systemImageName: "heart.fill"
            ),
            
            AppShortcut(
                intent: AccessCrisisSupportIntent(),
                phrases: [
                    "Get crisis support in \(.applicationName)",
                    "Contact crisis hotline in \(.applicationName)",
                    "Emergency mental health help in \(.applicationName)"
                ],
                shortTitle: "Crisis Support",
                systemImageName: "phone.fill"
            ),
            
            AppShortcut(
                intent: StartGuidanceNavigatorIntent(),
                phrases: [
                    "Get health guidance in \(.applicationName)",
                    "Should I see a doctor in \(.applicationName)",
                    "Get medical advice in \(.applicationName)"
                ],
                shortTitle: "Get Guidance",
                systemImageName: "questionmark.circle"
            ),
            
            AppShortcut(
                intent: RecordVitalsIntent(),
                phrases: [
                    "Record my vitals in \(.applicationName)",
                    "Log vital signs in \(.applicationName)",
                    "Track blood pressure in \(.applicationName)"
                ],
                shortTitle: "Record Vitals",
                systemImageName: "waveform.path.ecg"
            ),
            
            AppShortcut(
                intent: SummarizeHealthIntent(),
                phrases: [
                    "Summarize my health in \(.applicationName)",
                    "Show health summary in \(.applicationName)",
                    "Health trends in \(.applicationName)"
                ],
                shortTitle: "Health Summary",
                systemImageName: "chart.bar.doc.horizontal"
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
            
            // NEW: Proactive Health Guidance (Ask Questions & Guide Users Using AKG GNN)
            AppShortcut(
                intent: AskHealthQuestionsIntent(),
                phrases: [
                    "Ask me health questions in \(.applicationName)",
                    "Check my health with questions in \(.applicationName)",
                    "Assess my wellbeing in \(.applicationName)"
                ],
                shortTitle: "Health Questions",
                systemImageName: "questionmark.circle.fill"
            ),
            
            AppShortcut(
                intent: GuideToMentalHealthIntent(),
                phrases: [
                    "Guide me to mental health in \(.applicationName)",
                    "Help with mental health in \(.applicationName)",
                    "Mental health guidance in \(.applicationName)"
                ],
                shortTitle: "Mental Health Guide",
                systemImageName: "brain.head.profile"
            ),
            
            AppShortcut(
                intent: GuideToPhysicalHealthIntent(),
                phrases: [
                    "Guide me to physical health in \(.applicationName)",
                    "Help with physical health in \(.applicationName)",
                    "Physical health guidance in \(.applicationName)"
                ],
                shortTitle: "Physical Health Guide",
                systemImageName: "heart.circle.fill"
            ),
            
            AppShortcut(
                intent: ProactiveHealthCheckIntent(),
                phrases: [
                    "Do a health check in \(.applicationName)",
                    "Check my overall health in \(.applicationName)",
                    "Assess my health in \(.applicationName)"
                ],
                shortTitle: "Health Check",
                systemImageName: "checkmark.shield.fill"
            )
        ]
    }
}


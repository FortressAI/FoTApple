// EducationAppShortcuts.swift
// App Shortcuts for Education App (Teacher & Student modes)

import Foundation
import AppIntents
import FoTCore
import FoTAppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct EducationAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            // Teacher shortcuts
            AppShortcut(
                intent: RecordAttendanceIntent(),
                phrases: [
                    "Record attendance in \(.applicationName)",
                    "Take attendance in \(.applicationName)",
                    "Mark attendance in \(.applicationName)"
                ],
                shortTitle: "Attendance",
                systemImageName: "checklist"
            ),
            
            AppShortcut(
                intent: GradeAssignmentIntent(),
                phrases: [
                    "Grade assignment in \(.applicationName)",
                    "Score student work in \(.applicationName)",
                    "Enter grades in \(.applicationName)"
                ],
                shortTitle: "Grade Work",
                systemImageName: "pencil"
            ),
            
            // Student shortcuts
            AppShortcut(
                intent: LogAssignmentStatusIntent(),
                phrases: [
                    "Log assignment status in \(.applicationName)",
                    "Update homework progress in \(.applicationName)",
                    "Mark assignment complete in \(.applicationName)"
                ],
                shortTitle: "Assignment Status",
                systemImageName: "checkmark.circle"
            ),
            
            AppShortcut(
                intent: ViewGradesIntent(),
                phrases: [
                    "View my grades in \(.applicationName)",
                    "Check my scores in \(.applicationName)",
                    "Show my grades in \(.applicationName)"
                ],
                shortTitle: "My Grades",
                systemImageName: "chart.bar"
            ),
            
            AppShortcut(
                intent: LogStudySessionIntent(),
                phrases: [
                    "Log study session in \(.applicationName)",
                    "Record study time in \(.applicationName)",
                    "Track studying in \(.applicationName)"
                ],
                shortTitle: "Study Session",
                systemImageName: "book.closed"
            ),
            
            AppShortcut(
                intent: CheckScheduleIntent(),
                phrases: [
                    "Check my schedule in \(.applicationName)",
                    "Show my classes in \(.applicationName)",
                    "View my timetable in \(.applicationName)"
                ],
                shortTitle: "My Schedule",
                systemImageName: "calendar"
            ),
            
            // NEW: Intelligent Helper Shortcuts (Transform from Record-Keeper to Learning Partner)
            AppShortcut(
                intent: ExplainConceptIntent(),
                phrases: [
                    "Explain \(\.conceptName) in \(.applicationName)",
                    "Help me understand \(\.conceptName) in \(.applicationName)",
                    "What is \(\.conceptName) in \(.applicationName)"
                ],
                shortTitle: "Explain Concept",
                systemImageName: "brain.head.profile"
            ),
            
            AppShortcut(
                intent: AnswerQuestionIntent(),
                phrases: [
                    "Answer my question in \(.applicationName)",
                    "Help me with \(\.question) in \(.applicationName)",
                    "Explain \(\.question) in \(.applicationName)"
                ],
                shortTitle: "Ask Question",
                systemImageName: "questionmark.circle.fill"
            ),
            
            AppShortcut(
                intent: GenerateLearningPathIntent(),
                phrases: [
                    "Create learning path for \(\.topic) in \(.applicationName)",
                    "Help me learn \(\.topic) in \(.applicationName)",
                    "Generate study plan for \(\.topic) in \(.applicationName)"
                ],
                shortTitle: "Learning Path",
                systemImageName: "map.fill"
            ),
            
            AppShortcut(
                intent: GetTutoringHelpIntent(),
                phrases: [
                    "Tutor me on \(\.topic) in \(.applicationName)",
                    "Help me with \(\.topic) in \(.applicationName)",
                    "I'm struggling with \(\.topic) in \(.applicationName)"
                ],
                shortTitle: "Get Tutoring",
                systemImageName: "person.2.fill"
            ),
            
            AppShortcut(
                intent: ExploreTopicConnectionsIntent(),
                phrases: [
                    "How does \(\.topic1) relate to \(\.topic2) in \(.applicationName)",
                    "Connect \(\.topic1) and \(\.topic2) in \(.applicationName)",
                    "Show connections between topics in \(.applicationName)"
                ],
                shortTitle: "Topic Connections",
                systemImageName: "network"
            )
        ]
    }
}


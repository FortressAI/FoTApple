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
            )
        ]
    }
}


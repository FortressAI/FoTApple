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
            AppShortcut(
                intent: ShowStudentsIntent(),
                phrases: [
                    "Show my students in \(.applicationName)",
                    "View student roster in \(.applicationName)",
                    "List my class in \(.applicationName)"
                ],
                shortTitle: "Show Students",
                systemImageName: "person.3.fill"
            ),
            
            AppShortcut(
                intent: AddStudentIntent(),
                phrases: [
                    "Add student in \(.applicationName)",
                    "Enroll new student in \(.applicationName)",
                    "Register student in \(.applicationName)"
                ],
                shortTitle: "Add Student",
                systemImageName: "person.badge.plus"
            ),
            
            AppShortcut(
                intent: CreateAssignmentIntent(),
                phrases: [
                    "Create assignment in \(.applicationName)",
                    "Make new homework in \(.applicationName)",
                    "Add assignment in \(.applicationName)"
                ],
                shortTitle: "Create Assignment",
                systemImageName: "doc.badge.plus"
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
            
            AppShortcut(
                intent: ShowLearningInsightsIntent(),
                phrases: [
                    "Show learning insights in \(.applicationName)",
                    "View student progress in \(.applicationName)",
                    "Check learning analytics in \(.applicationName)"
                ],
                shortTitle: "Learning Insights",
                systemImageName: "chart.bar.xaxis"
            ),
            
            AppShortcut(
                intent: ShowIEPsIntent(),
                phrases: [
                    "Show IEPs in \(.applicationName)",
                    "View IEP plans in \(.applicationName)",
                    "Check special education plans in \(.applicationName)"
                ],
                shortTitle: "IEPs",
                systemImageName: "doc.text.magnifyingglass"
            ),
            
            AppShortcut(
                intent: MessageParentsIntent(),
                phrases: [
                    "Message parents in \(.applicationName)",
                    "Send parent communication in \(.applicationName)",
                    "Contact parents in \(.applicationName)"
                ],
                shortTitle: "Message Parents",
                systemImageName: "envelope.fill"
            )
        ]
    }
}


// ParentAppShortcuts.swift
// App Shortcuts for Parent App

import Foundation
import AppIntents
import FoTCore
import FoTAppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct ParentAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: ViewStudentProgressIntent(),
                phrases: [
                    "How is my child doing in school in \(.applicationName)",
                    "Check my child's grades in \(.applicationName)",
                    "Show student progress in \(.applicationName)"
                ],
                shortTitle: "Student Progress",
                systemImageName: "chart.bar.fill"
            ),
            
            AppShortcut(
                intent: CheckAssignmentsDueIntent(),
                phrases: [
                    "What homework does my child have in \(.applicationName)",
                    "Check assignments due in \(.applicationName)",
                    "Show upcoming homework in \(.applicationName)"
                ],
                shortTitle: "Assignments Due",
                systemImageName: "book.fill"
            ),
            
            AppShortcut(
                intent: ParentScheduleTeacherMeetingIntent(),
                phrases: [
                    "Schedule parent teacher meeting in \(.applicationName)",
                    "Request teacher conference in \(.applicationName)",
                    "Meet with teacher in \(.applicationName)"
                ],
                shortTitle: "Teacher Meeting",
                systemImageName: "person.2.fill"
            ),
            
            AppShortcut(
                intent: ViewBehaviorReportsIntent(),
                phrases: [
                    "Check my child's behavior in \(.applicationName)",
                    "Show behavior reports in \(.applicationName)",
                    "Any behavior incidents in \(.applicationName)"
                ],
                shortTitle: "Behavior Reports",
                systemImageName: "hand.raised.fill"
            ),
            
            AppShortcut(
                intent: UpdateEmergencyContactIntent(),
                phrases: [
                    "Update emergency contact in \(.applicationName)",
                    "Change emergency phone number in \(.applicationName)",
                    "Modify emergency info in \(.applicationName)"
                ],
                shortTitle: "Emergency Contact",
                systemImageName: "phone.circle.fill"
            ),
            
            AppShortcut(
                intent: ViewAttendanceIntent(),
                phrases: [
                    "Check my child's attendance in \(.applicationName)",
                    "Show attendance record in \(.applicationName)",
                    "Any absences in \(.applicationName)"
                ],
                shortTitle: "Attendance",
                systemImageName: "calendar.badge.checkmark"
            ),
            
            AppShortcut(
                intent: ApproveFieldTripIntent(),
                phrases: [
                    "Approve field trip in \(.applicationName)",
                    "Grant field trip permission in \(.applicationName)",
                    "Sign permission slip in \(.applicationName)"
                ],
                shortTitle: "Field Trip",
                systemImageName: "bus.fill"
            ),
            
            AppShortcut(
                intent: ViewIEPPlanIntent(),
                phrases: [
                    "Show my child's IEP in \(.applicationName)",
                    "View IEP plan in \(.applicationName)",
                    "Check IEP progress in \(.applicationName)"
                ],
                shortTitle: "View IEP",
                systemImageName: "doc.text.fill"
            )
        ]
    }
}


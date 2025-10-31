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
                intent: LogMilestoneIntent(),
                phrases: [
                    "Log milestone in \(.applicationName)",
                    "Record child milestone in \(.applicationName)",
                    "Track development in \(.applicationName)"
                ],
                shortTitle: "Log Milestone",
                systemImageName: "star.fill"
            ),
            
            AppShortcut(
                intent: ShowHealthRecordsIntent(),
                phrases: [
                    "Show health records in \(.applicationName)",
                    "View medical history in \(.applicationName)",
                    "Check health info in \(.applicationName)"
                ],
                shortTitle: "Health Records",
                systemImageName: "heart.text.square.fill"
            ),
            
            AppShortcut(
                intent: LogVaccinationIntent(),
                phrases: [
                    "Log vaccination in \(.applicationName)",
                    "Record immunization in \(.applicationName)",
                    "Add vaccine record in \(.applicationName)"
                ],
                shortTitle: "Log Vaccination",
                systemImageName: "cross.case.fill"
            ),
            
            AppShortcut(
                intent: ShowFamilyCalendarIntent(),
                phrases: [
                    "Show family calendar in \(.applicationName)",
                    "View family schedule in \(.applicationName)",
                    "Check family events in \(.applicationName)"
                ],
                shortTitle: "Family Calendar",
                systemImageName: "calendar"
            ),
            
            AppShortcut(
                intent: AddFamilyEventIntent(),
                phrases: [
                    "Add family event in \(.applicationName)",
                    "Schedule family activity in \(.applicationName)",
                    "Create family event in \(.applicationName)"
                ],
                shortTitle: "Add Event",
                systemImageName: "calendar.badge.plus"
            ),
            
            AppShortcut(
                intent: GetParentingAdviceIntent(),
                phrases: [
                    "Get parenting advice in \(.applicationName)",
                    "Ask parenting question in \(.applicationName)",
                    "Help with parenting in \(.applicationName)"
                ],
                shortTitle: "Parenting Advice",
                systemImageName: "lightbulb.fill"
            ),
            
            AppShortcut(
                intent: ShowSchoolUpdatesIntent(),
                phrases: [
                    "Show school updates in \(.applicationName)",
                    "Check school news in \(.applicationName)",
                    "View school announcements in \(.applicationName)"
                ],
                shortTitle: "School Updates",
                systemImageName: "building.2.fill"
            )
        ]
    }
}


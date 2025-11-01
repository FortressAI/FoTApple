// ClinicianAppShortcuts.swift
// App Shortcuts for Clinician Mac App

import Foundation
import AppIntents
import FoTCore
import FoTAppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct ClinicianAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Shortcuts temporarily disabled for macOS build
        // TODO: Implement FoTAppIntents for macOS
        return []
        /*return [
            AppShortcut(
                intent: StartEncounterIntent(),
                phrases: [
                    "Start patient encounter in \(.applicationName)",
                    "Begin consultation in \(.applicationName)",
                    "New patient visit in \(.applicationName)"
                ],
                shortTitle: "Start Encounter",
                systemImageName: "person.fill"
            ),
            
            AppShortcut(
                intent: AddPatientVitalsIntent(),
                phrases: [
                    "Add patient vitals in \(.applicationName)",
                    "Record vital signs in \(.applicationName)",
                    "Log patient vitals in \(.applicationName)"
                ],
                shortTitle: "Add Vitals",
                systemImageName: "heart.text.square"
            ),
            
            AppShortcut(
                intent: RecordDiagnosisIntent(),
                phrases: [
                    "Record diagnosis in \(.applicationName)",
                    "Document diagnosis in \(.applicationName)",
                    "Add diagnosis in \(.applicationName)"
                ],
                shortTitle: "Record Diagnosis",
                systemImageName: "note.text"
            ),
            
            AppShortcut(
                intent: RecordMedicationIntent(),
                phrases: [
                    "Prescribe medication in \(.applicationName)",
                    "Record prescription in \(.applicationName)",
                    "Add medication in \(.applicationName)"
                ],
                shortTitle: "Prescribe",
                systemImageName: "pills"
            ),
            
            AppShortcut(
                intent: SummarizePatientIntent(),
                phrases: [
                    "Summarize patient in \(.applicationName)",
                    "Patient summary in \(.applicationName)",
                    "Show patient overview in \(.applicationName)"
                ],
                shortTitle: "Patient Summary",
                systemImageName: "doc.text"
            ),
            
            AppShortcut(
                intent: EndEncounterIntent(),
                phrases: [
                    "End encounter in \(.applicationName)",
                    "Finish consultation in \(.applicationName)",
                    "Complete visit in \(.applicationName)"
                ],
                shortTitle: "End Encounter",
                systemImageName: "checkmark.circle"
            )
        ]*/
    }
}

// ClinicianAppShortcuts.swift
// App Shortcuts for Clinician App

import Foundation
import AppIntents
import FoTCore
import FoTAppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct ClinicianAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
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
                intent: CreatePatientIntent(),
                phrases: [
                    "Create new patient in \(.applicationName)",
                    "Add new patient in \(.applicationName)",
                    "Register patient in \(.applicationName)"
                ],
                shortTitle: "Create Patient",
                systemImageName: "person.crop.circle.badge.plus"
            ),
            
            AppShortcut(
                intent: GenerateDiagnosisIntent(),
                phrases: [
                    "Generate diagnosis in \(.applicationName)",
                    "Get diagnostic suggestions in \(.applicationName)",
                    "Analyze symptoms in \(.applicationName)"
                ],
                shortTitle: "Generate Diagnosis",
                systemImageName: "stethoscope"
            ),
            
            AppShortcut(
                intent: GenerateSOAPNoteIntent(),
                phrases: [
                    "Generate SOAP note in \(.applicationName)",
                    "Create clinical note in \(.applicationName)",
                    "Document encounter in \(.applicationName)"
                ],
                shortTitle: "SOAP Note",
                systemImageName: "doc.text"
            ),
            
            AppShortcut(
                intent: CheckDrugInteractionsIntent(),
                phrases: [
                    "Check drug interactions in \(.applicationName)",
                    "Verify medication safety in \(.applicationName)",
                    "Check prescription interactions in \(.applicationName)"
                ],
                shortTitle: "Check Interactions",
                systemImageName: "pills.circle"
            ),
            
            AppShortcut(
                intent: ShowAuditTrailIntent(),
                phrases: [
                    "Show audit trail in \(.applicationName)",
                    "View medical history in \(.applicationName)",
                    "Show patient record history in \(.applicationName)"
                ],
                shortTitle: "Audit Trail",
                systemImageName: "clock.arrow.circlepath"
            )
        ]
    }
}


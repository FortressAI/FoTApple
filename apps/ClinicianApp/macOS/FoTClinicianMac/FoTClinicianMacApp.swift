// FoTClinicianMacApp.swift
// macOS app for FoT Clinician

import SwiftUI
import FoTCore
import FoTClinician

@main
struct FoTClinicianMacApp: App {
    @StateObject private var appState = MacAppState()
    
    var body: some Scene {
        // Main Window
        WindowGroup {
            MacContentView()
                .environmentObject(appState)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .commands {
            ClinicianCommands()
        }
        
        // Patient Detail Window
        WindowGroup("Patient Detail", for: UUID.self) { $patientID in
            if let patientID = patientID,
               let patient = appState.patients.first(where: { $0.id == patientID }) {
                PatientDetailWindow(patient: patient)
                    .environmentObject(appState)
            }
        }
        
        // Settings Window
        Settings {
            SettingsView()
        }
    }
}

/// macOS app state
class MacAppState: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var selectedPatient: Patient?
    @Published var searchText = ""
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample patients
        let patient1 = Patient(
            mrn: "MRN001",
            firstName: "John",
            lastName: "Doe",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -45, to: Date())!,
            sex: .male,
            allergies: [
                Allergy(allergen: "Penicillin", reaction: "Anaphylaxis", severity: .lifeThreatening)
            ],
            activeProblems: [],
            medications: [
                Medication(name: "Aspirin", rxcui: "1191", dose: "81mg", route: "Oral", frequency: "Once daily")
            ]
        )
        
        let patient2 = Patient(
            mrn: "MRN002",
            firstName: "Jane",
            lastName: "Smith",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -62, to: Date())!,
            sex: .female,
            allergies: [],
            activeProblems: [],
            medications: [
                Medication(name: "Metformin", rxcui: "6809", dose: "500mg", route: "Oral", frequency: "Twice daily")
            ]
        )
        
        patients = [patient1, patient2]
    }
    
    var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patients
        }
        return patients.filter { patient in
            patient.fullName.localizedCaseInsensitiveContains(searchText) ||
            patient.mrn.localizedCaseInsensitiveContains(searchText)
        }
    }
}

/// Menu commands
struct ClinicianCommands: Commands {
    var body: some Commands {
        CommandMenu("Patient") {
            Button("New Patient...") {
                // New patient action
            }
            .keyboardShortcut("n", modifiers: [.command])
            
            Divider()
            
            Button("Export SOAP Note...") {
                // Export action
            }
            .keyboardShortcut("e", modifiers: [.command])
        }
        
        CommandMenu("View") {
            Button("Show Sidebar") {
                // Toggle sidebar
            }
            .keyboardShortcut("s", modifiers: [.command, .option])
        }
    }
}


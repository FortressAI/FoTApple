// FoTClinicianWatchApp.swift
// watchOS companion app for FoT Clinician

import SwiftUI
import FoTCore
import FoTClinician

@main
struct FoTClinicianWatchApp: App {
    @StateObject private var appState = WatchAppState()
    
    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(appState)
        }
    }
}

/// Watch app state
class WatchAppState: ObservableObject {
    @Published var recentPatients: [Patient] = []
    @Published var upcomingAlerts: [PatientAlert] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample data for watch
        let patient1 = Patient(
            id: UUID(),
            mrn: "MRN001",
            firstName: "John",
            lastName: "Doe",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -45, to: Date())!,
            sex: .male,
            allergies: [],
            activeProblems: [],
            medications: []
        )
        
        recentPatients = [patient1]
        
        upcomingAlerts = [
            PatientAlert(patientName: "John Doe", message: "BP check due", time: Date()),
            PatientAlert(patientName: "Jane Smith", message: "Medication reminder", time: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!)
        ]
    }
}

struct PatientAlert: Identifiable {
    let id = UUID()
    let patientName: String
    let message: String
    let time: Date
}


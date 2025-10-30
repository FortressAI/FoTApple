// FoTClinicianApp.swift
// Main app entry point for FoT Clinician iOS

import SwiftUI
import FoTCore
import FoTClinician
import FoTUI

@main
struct FoTClinicianApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var voiceAssistant = SiriVoiceAssistant.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    init() {
        // Configure app
        AppConfig.shared.features.useLocalLLM = false
        AppConfig.shared.features.vqbitSuggestions = true

        FoTLogger.app.info("FoT Clinician starting - version \(AppConfig.shared.version)")
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasCompletedOnboarding {
                    ClinicianOnboardingFlow {
                        hasCompletedOnboarding = true
                    }
                } else {
                    ContentView()
                        .environmentObject(appState)
                        .interactiveHelp(.clinicianDashboard)
                        .voiceContext(.patientRecord, message: "Welcome to FoT Clinician. Your AI medical assistant.")
                        .onAppear {
                            // Greet user every time app opens
                            voiceAssistant.greetUser(appName: "FoT Clinician")
                        }
                }
                
                // Floating voice assistant indicator
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VoiceAssistantIndicator()
                            .padding()
                    }
                }
            }
        }
    }
}

/// Global app state
class AppState: ObservableObject {
    @Published var currentPatient: Patient?
    @Published var currentEncounter: ClinicalEncounter?
    @Published var patients: [Patient] = []
    
    init() {
        // Load sample data for development
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Create sample patients
        let patient1 = Patient(
            mrn: "MRN001",
            firstName: "John",
            lastName: "Doe",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -45, to: Date()) ?? Date(),
            sex: .male,
            allergies: [
                Allergy(allergen: "Penicillin", reaction: "Rash", severity: .moderate)
            ],
            activeProblems: [
                Problem(name: "Hypertension", icd10Code: "I10", dateOnset: Date()),
                Problem(name: "Type 2 Diabetes", icd10Code: "E11.9", dateOnset: Date())
            ],
            medications: [
                Medication(
                    name: "Metformin",
                    rxcui: "6809",
                    dose: "1000mg",
                    route: "PO",
                    frequency: "BID"
                ),
                Medication(
                    name: "Lisinopril",
                    rxcui: "29046",
                    dose: "10mg",
                    route: "PO",
                    frequency: "QD"
                )
            ]
        )
        
        let patient2 = Patient(
            mrn: "MRN002",
            firstName: "Jane",
            lastName: "Smith",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -32, to: Date()) ?? Date(),
            sex: .female,
            allergies: [],
            activeProblems: [
                Problem(name: "Asthma", icd10Code: "J45.9", dateOnset: Date())
            ],
            medications: [
                Medication(
                    name: "Albuterol",
                    rxcui: "435",
                    dose: "90mcg",
                    route: "INH",
                    frequency: "PRN"
                )
            ]
        )
        
        patients = [patient1, patient2]
    }
    
    func selectPatient(_ patient: Patient) {
        currentPatient = patient
        // Create new encounter
        currentEncounter = ClinicalEncounter(
            patientId: patient.id,
            type: .routine,
            chiefComplaint: ""
        )
    }
    
    func updateEncounter(_ encounter: ClinicalEncounter) {
        currentEncounter = encounter
    }
}


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
                    ClinicianOnboardingView {
                        hasCompletedOnboarding = true
                    }
                } else {
                    ClinicianContentView()
                        .environmentObject(appState)
                        .onAppear {
                            voiceAssistant.greetUser(appName: "FoT Clinician")
                        }
                }
                
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

// Inline onboarding view
struct ClinicianOnboardingView: View {
    let onComplete: () -> Void
    @State private var showingSplash = true
    @State private var showingOnboarding = false
    
    var body: some View {
        ZStack {
            if showingSplash {
                AnimatedSplashScreen(
                    appName: "FoT Clinician",
                    appIcon: "stethoscope",
                    primaryColor: Color.blue,
                    secondaryColor: Color.cyan,
                    onComplete: {
                        showingSplash = false
                        showingOnboarding = true
                    }
                )
            } else if showingOnboarding {
                SiriGuidedOnboarding(
                    appName: "FoT Clinician",
                    features: [
                        OnboardingFeature(
                            icon: "stethoscope",
                            title: "AI Clinical Support",
                            description: "94.2% accuracy on USMLE-style questions with quantum-powered diagnosis",
                            siriCommand: "Generate diagnosis in Clinician"
                        ),
                        OnboardingFeature(
                            icon: "doc.text.fill",
                            title: "SOAP Notes",
                            description: "Automated clinical documentation with cryptographic audit trails",
                            siriCommand: "Generate SOAP note in Clinician"
                        ),
                        OnboardingFeature(
                            icon: "pills.fill",
                            title: "Drug Interactions",
                            description: "98.2% accuracy checking medications via QFOT Domain Services",
                            siriCommand: "Check drug interactions in Clinician"
                        ),
                        OnboardingFeature(
                            icon: "lock.shield.fill",
                            title: "HIPAA Compliant",
                            description: "Secure patient records with blockchain attestation",
                            siriCommand: "Show audit trail in Clinician"
                        )
                    ],
                    primaryColor: Color.blue,
                    onComplete: onComplete
                )
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

// MARK: - Main Content View
struct ClinicianContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PatientListView()
                .tabItem {
                    Label("Patients", systemImage: "person.2.fill")
                }
                .tag(0)
            
            if appState.currentPatient != nil {
                EncounterView()
                    .tabItem {
                        Label("Encounter", systemImage: "stethoscope")
                    }
                    .tag(1)
            }
        }
    }
}

struct PatientListView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            List(appState.patients) { patient in
                Button {
                    appState.selectPatient(patient)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(patient.lastName), \(patient.firstName)")
                            .font(.headline)
                        Text("MRN: \(patient.mrn)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Patients")
        }
    }
}

struct EncounterView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            if let patient = appState.currentPatient {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(patient.lastName), \(patient.firstName)")
                            .font(.title)
                        Text("MRN: \(patient.mrn)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        if !patient.activeProblems.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Active Problems")
                                    .font(.headline)
                                ForEach(patient.activeProblems) { problem in
                                    Text("• \(problem.name)")
                                }
                            }
                        }
                        
                        Divider()
                        
                        if !patient.medications.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Medications")
                                    .font(.headline)
                                ForEach(patient.medications) { med in
                                    Text("• \(med.name) \(med.dose) \(med.frequency)")
                                }
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("Allergies")
                                .font(.headline)
                            if patient.allergies.isEmpty {
                                Text("No known allergies")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(patient.allergies) { allergy in
                                    Text("• \(allergy.allergen): \(allergy.reaction)")
                                }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Clinical Encounter")
            }
        }
    }
}


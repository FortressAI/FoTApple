// WatchContentView.swift
// Main watch interface for Clinician app

import SwiftUI
import FoTClinician

struct WatchContentView: View {
    @EnvironmentObject var appState: WatchAppState
    
    var body: some View {
        NavigationStack {
            List {
                // Quick Actions
                Section("Quick Actions") {
                    NavigationLink(destination: QuickVitalsView()) {
                        Label("Record Vitals", systemImage: "heart.fill")
                            .foregroundColor(.red)
                    }
                    
                    NavigationLink(destination: AlertsView()) {
                        Label("Alerts", systemImage: "bell.fill")
                            .foregroundColor(.orange)
                            .badge(appState.upcomingAlerts.count)
                    }
                }
                
                // Recent Patients
                Section("Recent Patients") {
                    ForEach(appState.recentPatients) { patient in
                        NavigationLink(destination: PatientDetailWatch(patient: patient)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(patient.fullName)
                                    .font(.headline)
                                Text("MRN: \(patient.mrn)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Clinician")
        }
    }
}

struct QuickVitalsView: View {
    @State private var heartRate: String = ""
    @State private var bloodPressureSystolic: String = ""
    @State private var bloodPressureDiastolic: String = ""
    @State private var temperature: String = ""
    @State private var showingSaved = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Heart Rate
                VStack(alignment: .leading, spacing: 4) {
                    Label("Heart Rate", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    TextField("bpm", text: $heartRate)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Blood Pressure
                VStack(alignment: .leading, spacing: 4) {
                    Label("Blood Pressure", systemImage: "drop.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    HStack {
                        TextField("Sys", text: $bloodPressureSystolic)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        Text("/")
                        TextField("Dia", text: $bloodPressureDiastolic)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Temperature
                VStack(alignment: .leading, spacing: 4) {
                    Label("Temperature", systemImage: "thermometer")
                        .font(.caption)
                        .foregroundColor(.orange)
                    TextField("°F", text: $temperature)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button(action: saveVitals) {
                    Label("Save", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding()
        }
        .navigationTitle("Quick Vitals")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Vitals Saved", isPresented: $showingSaved) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func saveVitals() {
        // Save vitals
        showingSaved = true
    }
}

struct AlertsView: View {
    @EnvironmentObject var appState: WatchAppState
    
    var body: some View {
        List(appState.upcomingAlerts) { alert in
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.patientName)
                    .font(.headline)
                Text(alert.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(formatTime(alert.time))
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .navigationTitle("Alerts")
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct PatientDetailWatch: View {
    let patient: Patient
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Patient Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.fullName)
                        .font(.headline)
                    Text("MRN: \(patient.mrn)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Age: \(patient.age)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Blood Type
                if let bloodType = patient.bloodType {
                    Label(bloodType, systemImage: "drop.fill")
                        .foregroundColor(.red)
                }
                
                // Allergies
                if !patient.allergies.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Allergies", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        ForEach(patient.allergies) { allergy in
                            Text("• \(allergy.allergen)")
                                .font(.caption)
                        }
                    }
                }
                
                // Medications
                if !patient.currentMedications.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Medications", systemImage: "pills.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        ForEach(patient.currentMedications) { med in
                            Text("• \(med.name)")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Patient")
        .navigationBarTitleDisplayMode(.inline)
    }
}


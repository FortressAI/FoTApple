// ContentView.swift
// Main content view with navigation

import SwiftUI
import FoTClinician

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ShowcaseView()
                .tabItem {
                    Label("Showcase", systemImage: "sparkles")
                }
                .tag(0)
            
            PatientListView()
                .tabItem {
                    Label("Patients", systemImage: "person.2.fill")
                }
                .tag(1)
            
            if appState.currentPatient != nil {
                EncounterView()
                    .tabItem {
                        Label("Encounter", systemImage: "stethoscope")
                    }
                    .tag(2)
            }
        }
    }
}

struct PatientListView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    
    var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return appState.patients
        }
        return appState.patients.filter { patient in
            patient.fullName.localizedCaseInsensitiveContains(searchText) ||
            patient.mrn.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredPatients) { patient in
                PatientRowView(patient: patient)
                    .onTapGesture {
                        appState.selectPatient(patient)
                    }
            }
            .searchable(text: $searchText, prompt: "Search by name or MRN")
            .navigationTitle("Patients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct PatientRowView: View {
    let patient: Patient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(patient.fullName)
                    .font(.headline)
                Spacer()
                Text(patient.ageDisplay)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("MRN: \(patient.mrn)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(patient.sex.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !patient.activeProblems.isEmpty {
                Text(patient.activeProblems.map { $0.name }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.orange)
                    .lineLimit(1)
            }
            
            if !patient.allergies.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("Allergies: \(patient.allergies.map { $0.allergen }.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.red)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}


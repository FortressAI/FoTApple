// MacContentView.swift
// Main macOS interface for Clinician app

import SwiftUI
import FoTClinician

struct MacContentView: View {
    @EnvironmentObject var appState: MacAppState
    @State private var selectedTab: SidebarItem = .patients
    
    enum SidebarItem: String, CaseIterable {
        case patients = "Patients"
        case encounters = "Encounters"
        case medications = "Medications"
        case reports = "Reports"
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, id: \.self, selection: $selectedTab) { item in
                Label(item.rawValue, systemImage: icon(for: item))
            }
            .navigationTitle("Clinician")
        } content: {
            // Middle panel - Patient list
            PatientListMac()
        } detail: {
            // Detail panel - Patient details
            if let patient = appState.selectedPatient {
                PatientDetailMac(patient: patient)
            } else {
                Text("Select a patient")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private func icon(for item: SidebarItem) -> String {
        switch item {
        case .patients: return "person.2.fill"
        case .encounters: return "stethoscope"
        case .medications: return "pills.fill"
        case .reports: return "doc.text.fill"
        }
    }
}

struct PatientListMac: View {
    @EnvironmentObject var appState: MacAppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search patients", text: $appState.searchText)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color(.textBackgroundColor))
            
            Divider()
            
            // Patient list
            List(appState.filteredPatients, selection: $appState.selectedPatient) { patient in
                PatientRowMac(patient: patient)
                    .tag(patient)
            }
            .listStyle(.sidebar)
        }
        .frame(minWidth: 300)
        .navigationTitle("Patients")
    }
}

struct PatientRowMac: View {
    let patient: Patient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(patient.fullName)
                .font(.headline)
            
            HStack {
                Text("MRN: \(patient.mrn)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(patient.age) yo")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Alerts
            if !patient.allergies.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("\(patient.allergies.count) allergies")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct PatientDetailMac: View {
    let patient: Patient
    @State private var selectedDetailTab: DetailTab = .overview
    
    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case vitals = "Vitals"
        case medications = "Medications"
        case encounters = "Encounters"
        case documents = "Documents"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Patient header
            PatientHeaderMac(patient: patient)
            
            Divider()
            
            // Tab picker
            Picker("Section", selection: $selectedDetailTab) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            ScrollView {
                switch selectedDetailTab {
                case .overview:
                    OverviewSectionMac(patient: patient)
                case .vitals:
                    VitalsSectionMac()
                case .medications:
                    MedicationsSectionMac(medications: patient.medications)
                case .encounters:
                    EncountersSectionMac()
                case .documents:
                    DocumentsSectionMac()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: {}) {
                    Label("New Encounter", systemImage: "plus")
                }
                Button(action: {}) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

struct PatientHeaderMac: View {
    let patient: Patient
    
    var body: some View {
        HStack(spacing: 20) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 80, height: 80)
                Text(patient.initials)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(patient.fullName)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 16) {
                    Label("MRN: \(patient.mrn)", systemImage: "number")
                    Label("\(patient.age) years old", systemImage: "calendar")
                    Label(patient.sex.rawValue, systemImage: "person")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Alerts
            if !patient.allergies.isEmpty {
                VStack(alignment: .trailing, spacing: 4) {
                    Label("\(patient.allergies.count) Allergies", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                    ForEach(patient.allergies.prefix(2)) { allergy in
                        Text(allergy.allergen)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
}

struct OverviewSectionMac: View {
    let patient: Patient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox("Demographics") {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                    GridRow {
                        Text("Date of Birth:")
                            .foregroundColor(.secondary)
                        Text(formatDate(patient.dateOfBirth))
                    }
                    GridRow {
                        Text("Sex:")
                            .foregroundColor(.secondary)
                        Text(patient.sex.rawValue)
                    }
                }
                .padding()
            }
            
            if !patient.allergies.isEmpty {
                GroupBox("Allergies") {
                    ForEach(patient.allergies) { allergy in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            VStack(alignment: .leading) {
                                Text(allergy.allergen)
                                    .fontWeight(.semibold)
                                Text(allergy.reaction)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(allergy.severity.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(severityColor(allergy.severity).opacity(0.2))
                                .foregroundColor(severityColor(allergy.severity))
                                .cornerRadius(4)
                        }
                        .padding()
                    }
                }
            }
            
            if !patient.medications.isEmpty {
                GroupBox("Current Medications") {
                    ForEach(patient.medications) { medication in
                        HStack {
                            Image(systemName: "pills.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(medication.name)
                                    .fontWeight(.semibold)
                                Text("\(medication.dose) \(medication.route) - \(medication.frequency)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
        }
        .padding()
    }
    
    private func severityColor(_ severity: AllergySeverity) -> Color {
        switch severity {
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        case .lifeThreatening: return .red
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct VitalsSectionMac: View {
    var body: some View {
        VStack(spacing: 20) {
            GroupBox("Recent Vitals") {
                Text("No recent vital signs recorded")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Button(action: {}) {
                Label("Record New Vitals", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct MedicationsSectionMac: View {
    let medications: [Medication]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(medications) { medication in
                GroupBox {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(medication.name)
                                .font(.headline)
                            Text("\(medication.dose) (\(medication.route))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(medication.frequency)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {}) {
                            Label("Check Interactions", systemImage: "exclamationmark.triangle")
                        }
                    }
                    .padding()
                }
            }
            
            Button(action: {}) {
                Label("Add Medication", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct EncountersSectionMac: View {
    var body: some View {
        VStack(spacing: 20) {
            GroupBox("Recent Encounters") {
                Text("No encounters recorded")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Button(action: {}) {
                Label("New Encounter", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct DocumentsSectionMac: View {
    var body: some View {
        VStack(spacing: 20) {
            GroupBox("Documents") {
                Text("No documents available")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Button(action: {}) {
                Label("Upload Document", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct PatientDetailWindow: View {
    let patient: Patient
    
    var body: some View {
        PatientDetailMac(patient: patient)
            .frame(minWidth: 800, minHeight: 600)
    }
}

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            PrivacySettings()
                .tabItem {
                    Label("Privacy", systemImage: "lock.shield")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettings: View {
    @State private var autoSave = true
    
    var body: some View {
        Form {
            Toggle("Auto-save changes", isOn: $autoSave)
            Divider()
            Button("Reset to Defaults") {}
        }
        .padding()
    }
}

struct PrivacySettings: View {
    var body: some View {
        Form {
            Text("PHI Encryption: Enabled")
                .foregroundColor(.green)
            Text("Data stored locally only")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

extension Patient {
    var initials: String {
        let first = String(firstName.prefix(1))
        let last = String(lastName.prefix(1))
        return "\(first)\(last)"
    }
}


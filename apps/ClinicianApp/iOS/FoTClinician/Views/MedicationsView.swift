// MedicationsView.swift
// Medication management with real-time interaction checking

import SwiftUI
import FoTClinician
import DataAdapters

struct MedicationsView: View {
    let patient: Patient
    @Binding var encounter: ClinicalEncounter
    @StateObject private var viewModel: MedicationsViewModel
    
    init(patient: Patient, encounter: Binding<ClinicalEncounter>) {
        self.patient = patient
        self._encounter = encounter
        self._viewModel = StateObject(wrappedValue: MedicationsViewModel(patient: patient))
        
        if encounter.wrappedValue.plan == nil {
            encounter.wrappedValue.plan = Plan()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Medications")
                .font(.headline)
            
            if patient.medications.isEmpty {
                Text("No current medications")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(patient.medications) { medication in
                    CurrentMedicationRow(medication: medication)
                }
            }
            
            Divider()
                .padding(.vertical)
            
            Text("New Medications")
                .font(.headline)
            
            // Drug search
            VStack(alignment: .leading, spacing: 8) {
                Text("Search Medication")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                TextField("Search drug name...", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.searchQuery) { _, newValue in
                        viewModel.searchDrugs(query: newValue)
                    }
                
                if viewModel.isSearching {
                    ProgressView()
                        .padding()
                }
                
                if !viewModel.searchResults.isEmpty {
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(viewModel.searchResults.prefix(10)) { drug in
                                Button(action: {
                                    viewModel.selectDrug(drug)
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(drug.name)
                                                .font(.subheadline)
                                            if let tty = drug.tty {
                                                Text(tty)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
            
            // Selected drug details
            if let selectedDrug = viewModel.selectedDrug {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Selected: \(selectedDrug.name)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextField("Dose", text: $viewModel.dose)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Route (e.g., PO, IV)", text: $viewModel.route)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Frequency (e.g., QD, BID)", text: $viewModel.frequency)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Duration (e.g., 7 days)", text: $viewModel.duration)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Indication", text: $viewModel.indication)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        viewModel.checkInteractions(for: patient, encounter: encounter)
                    }) {
                        if viewModel.isCheckingInteractions {
                            ProgressView()
                        } else {
                            Text("Check Interactions")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isCheckingInteractions)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Interaction warnings
            if !viewModel.interactions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚠️ Interaction Warnings")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    ForEach(viewModel.interactions) { interaction in
                        InteractionWarningCard(interaction: interaction)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Add medication button
            if viewModel.selectedDrug != nil && !viewModel.dose.isEmpty {
                Button(action: {
                    viewModel.addMedicationToEncounter(encounter: encounter)
                }) {
                    Text(viewModel.hasCriticalInteractions ? "Override and Add Medication" : "Add Medication")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.hasCriticalInteractions ? .red : .blue)
                .disabled(viewModel.hasCriticalInteractions && !viewModel.acknowledgedCriticalWarning)
                
                if viewModel.hasCriticalInteractions {
                    Toggle("I acknowledge the critical interaction warning", isOn: $viewModel.acknowledgedCriticalWarning)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Medications in plan
            if let plan = encounter.plan, !plan.medications.isEmpty {
                Divider()
                    .padding(.vertical)
                
                Text("Medications in Plan")
                    .font(.headline)
                
                ForEach(plan.medications) { medication in
                    NewMedicationRow(medication: medication)
                }
            }
        }
        .padding()
    }
}

struct CurrentMedicationRow: View {
    let medication: Medication
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(medication.fullDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let indication = medication.indication {
                    Text("For: \(indication)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct NewMedicationRow: View {
    let medication: MedicationOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(medication.fullDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            if !medication.interactions.isEmpty {
                ForEach(medication.interactions) { interaction in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(interaction.isCritical ? .red : .orange)
                            .font(.caption)
                        Text(interaction.description)
                            .font(.caption)
                            .foregroundColor(interaction.isCritical ? .red : .orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct InteractionWarningCard: View {
    let interaction: InteractionWarning
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(interaction.isCritical ? .red : .orange)
                Text(interaction.severity)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(interaction.isCritical ? .red : .orange)
                Spacer()
            }
            
            Text(interaction.description)
                .font(.subheadline)
            
            Text("Drugs: \(interaction.drugNames.joined(separator: " + "))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Source: \(interaction.source)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(4)
    }
}

// MARK: - View Model

@MainActor
class MedicationsViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [Drug] = []
    @Published var isSearching = false
    @Published var selectedDrug: Drug?
    @Published var dose = ""
    @Published var route = ""
    @Published var frequency = ""
    @Published var duration = ""
    @Published var indication = ""
    @Published var interactions: [InteractionWarning] = []
    @Published var isCheckingInteractions = false
    @Published var acknowledgedCriticalWarning = false
    
    private let medicationService: MedicationService
    private let patient: Patient
    private var searchTask: Task<Void, Never>?
    
    init(patient: Patient) {
        self.patient = patient
        self.medicationService = MedicationService()
    }
    
    var hasCriticalInteractions: Bool {
        interactions.contains { $0.isCritical }
    }
    
    func searchDrugs(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty, query.count >= 2 else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            isSearching = true
            defer { isSearching = false }
            
            do {
                let results = try await medicationService.searchMedications(query: query)
                if !Task.isCancelled {
                    searchResults = results
                }
            } catch {
                print("Search error: \(error)")
            }
        }
    }
    
    func selectDrug(_ drug: Drug) {
        selectedDrug = drug
        searchResults = []
        searchQuery = drug.name
        interactions = []
        acknowledgedCriticalWarning = false
    }
    
    func checkInteractions(for patient: Patient, encounter: ClinicalEncounter) {
        guard let drug = selectedDrug, !dose.isEmpty else { return }
        
        let order = MedicationOrder(
            name: drug.name,
            rxcui: drug.rxcui,
            dose: dose,
            route: route,
            frequency: frequency,
            duration: duration,
            indication: indication
        )
        
        Task {
            isCheckingInteractions = true
            defer { isCheckingInteractions = false }
            
            do {
                let warnings = try await medicationService.checkInteractions(
                    medications: patient.medications,
                    newMedication: order
                )
                interactions = warnings
            } catch {
                print("Interaction check error: \(error)")
            }
        }
    }
    
    func addMedicationToEncounter(encounter: ClinicalEncounter) {
        guard let drug = selectedDrug, !dose.isEmpty else { return }
        
        let order = MedicationOrder(
            name: drug.name,
            rxcui: drug.rxcui,
            dose: dose,
            route: route,
            frequency: frequency,
            duration: duration,
            indication: indication,
            interactions: interactions
        )
        
        var updatedEncounter = encounter
        if updatedEncounter.plan == nil {
            updatedEncounter.plan = Plan()
        }
        updatedEncounter.plan?.medications.append(order)
        
        // Reset form
        selectedDrug = nil
        searchQuery = ""
        dose = ""
        route = ""
        frequency = ""
        duration = ""
        indication = ""
        interactions = []
        acknowledgedCriticalWarning = false
    }
}


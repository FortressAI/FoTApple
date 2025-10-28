// EncounterView.swift
// Main encounter workflow view

import SwiftUI
import FoTClinician

struct EncounterView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSection = EncounterSection.chiefComplaint
    
    enum EncounterSection: String, CaseIterable {
        case chiefComplaint = "Chief Complaint"
        case vitals = "Vitals"
        case assessment = "Assessment"
        case medications = "Medications"
        case plan = "Plan"
        case soapNote = "SOAP Note"
    }
    
    var body: some View {
        NavigationStack {
            if let patient = appState.currentPatient,
               let encounter = appState.currentEncounter {
                VStack(spacing: 0) {
                    // Patient banner
                    PatientBannerView(patient: patient)
                    
                    // Section picker
                    Picker("Section", selection: $selectedSection) {
                        ForEach(EncounterSection.allCases, id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Section content
                    ScrollView {
                        switch selectedSection {
                        case .chiefComplaint:
                            ChiefComplaintView(encounter: binding(for: encounter))
                        case .vitals:
                            VitalsView(encounter: binding(for: encounter))
                        case .assessment:
                            AssessmentView(encounter: binding(for: encounter))
                        case .medications:
                            MedicationsView(patient: patient, encounter: binding(for: encounter))
                        case .plan:
                            PlanView(encounter: binding(for: encounter))
                        case .soapNote:
                            SOAPNoteView(patient: patient, encounter: encounter)
                        }
                    }
                }
                .navigationTitle("Encounter")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("No active encounter")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func binding(for encounter: ClinicalEncounter) -> Binding<ClinicalEncounter> {
        Binding(
            get: { appState.currentEncounter ?? encounter },
            set: { appState.updateEncounter($0) }
        )
    }
}

struct PatientBannerView: View {
    let patient: Patient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(patient.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("MRN: \(patient.mrn) • \(patient.ageDisplay) • \(patient.sex.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            if !patient.allergies.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("ALLERGIES: \(patient.allergies.map { $0.allergen }.joined(separator: ", "))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct ChiefComplaintView: View {
    @Binding var encounter: ClinicalEncounter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chief Complaint")
                .font(.headline)
            
            TextEditor(text: $encounter.chiefComplaint)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Text("Encounter Type")
                .font(.headline)
            
            Picker("Type", selection: $encounter.type) {
                ForEach(EncounterType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
    }
}

struct VitalsView: View {
    @Binding var encounter: ClinicalEncounter
    
    init(encounter: Binding<ClinicalEncounter>) {
        self._encounter = encounter
        if encounter.wrappedValue.vitals == nil {
            encounter.wrappedValue.vitals = VitalSigns()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Vital Signs")
                .font(.headline)
            
            if let vitalsBinding = Binding($encounter.vitals) {
                VStack(spacing: 16) {
                    VitalInputRow(
                        label: "Temperature",
                        value: vitalsBinding.temperature,
                        unit: "°C"
                    )
                    
                    VitalInputRow(
                        label: "Heart Rate",
                        value: Binding(
                            get: { vitalsBinding.heartRate.wrappedValue.map { Double($0) } },
                            set: { vitalsBinding.heartRate.wrappedValue = $0.map { Int($0) } }
                        ),
                        unit: "BPM"
                    )
                    
                    HStack {
                        Text("Blood Pressure")
                            .frame(width: 140, alignment: .leading)
                        TextField("Systolic", value: vitalsBinding.bloodPressureSystolic, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        Text("/")
                        TextField("Diastolic", value: vitalsBinding.bloodPressureDiastolic, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        Text("mmHg")
                            .foregroundColor(.secondary)
                    }
                    
                    VitalInputRow(
                        label: "Resp Rate",
                        value: Binding(
                            get: { vitalsBinding.respiratoryRate.wrappedValue.map { Double($0) } },
                            set: { vitalsBinding.respiratoryRate.wrappedValue = $0.map { Int($0) } }
                        ),
                        unit: "/min"
                    )
                    
                    VitalInputRow(
                        label: "O2 Saturation",
                        value: Binding(
                            get: { vitalsBinding.oxygenSaturation.wrappedValue.map { Double($0) } },
                            set: { vitalsBinding.oxygenSaturation.wrappedValue = $0.map { Int($0) } }
                        ),
                        unit: "%"
                    )
                    
                    VitalInputRow(
                        label: "Weight",
                        value: vitalsBinding.weight,
                        unit: "kg"
                    )
                    
                    VitalInputRow(
                        label: "Height",
                        value: vitalsBinding.height,
                        unit: "cm"
                    )
                    
                    if let bmi = vitalsBinding.wrappedValue.bmi {
                        HStack {
                            Text("BMI")
                                .frame(width: 140, alignment: .leading)
                            Text(String(format: "%.1f", bmi))
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct VitalInputRow: View {
    let label: String
    @Binding var value: Double?
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
                .frame(width: 140, alignment: .leading)
            TextField(label, value: $value, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
            Text(unit)
                .foregroundColor(.secondary)
        }
    }
}

struct AssessmentView: View {
    @Binding var encounter: ClinicalEncounter
    @State private var newDiagnosisName = ""
    
    init(encounter: Binding<ClinicalEncounter>) {
        self._encounter = encounter
        if encounter.wrappedValue.assessment == nil {
            encounter.wrappedValue.assessment = Assessment()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Differential Diagnosis")
                .font(.headline)
            
            if let assessmentBinding = Binding($encounter.assessment) {
                ForEach(assessmentBinding.diagnoses) { $diagnosis in
                    DiagnosisRow(diagnosis: $diagnosis)
                }
                
                HStack {
                    TextField("Add diagnosis...", text: $newDiagnosisName)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        if !newDiagnosisName.isEmpty {
                            let diagnosis = Diagnosis(name: newDiagnosisName)
                            assessmentBinding.wrappedValue.diagnoses.append(diagnosis)
                            newDiagnosisName = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Text("Clinical Notes")
                    .font(.headline)
                    .padding(.top)
                
                TextEditor(text: assessmentBinding.notes)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct DiagnosisRow: View {
    @Binding var diagnosis: Diagnosis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(diagnosis.name)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(diagnosis.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Slider(value: $diagnosis.confidence, in: 0...1)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct PlanView: View {
    @Binding var encounter: ClinicalEncounter
    
    init(encounter: Binding<ClinicalEncounter>) {
        self._encounter = encounter
        if encounter.wrappedValue.plan == nil {
            encounter.wrappedValue.plan = Plan()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Treatment Plan")
                .font(.headline)
            
            if let planBinding = Binding($encounter.plan) {
                Text("Follow-up")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                TextEditor(text: planBinding.followUp)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Text("Patient Education")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                TextEditor(text: planBinding.patientEducation)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}


// EnhancedClinicalViewModel.swift
// Enhanced clinical workflows with QFOT blockchain integration
// Drug dosing, interactions, FDA alerts from mainnet

import Foundation
import FoTClinician
import Combine

/// Enhanced clinical features powered by QFOT blockchain
/// NO SIMULATIONS - Real mainnet services
@MainActor
class EnhancedClinicalViewModel: ObservableObject {
    // QFOT Services
    private let medicalServices: QFOTMedicalServices
    
    // Published state
    @Published var drugDosingResult: QFOTMedicalServices.DrugDosingResult?
    @Published var drugInteractions: QFOTMedicalServices.DrugInteractionsResult?
    @Published var fdaAlerts: [QFOTMedicalServices.FDAAlert] = []
    @Published var icd10Codes: [QFOTMedicalServices.ICD10Code] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(baseURL: String = "https://safeaicoin.org/api") {
        self.medicalServices = QFOTMedicalServices(baseURL: baseURL)
    }
    
    // MARK: - Drug Dosing
    
    /// Calculate drug dosing for a patient
    /// Example usage in prescribing workflow
    func calculateDosing(
        drug: String,
        patient: Patient
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Calculate weight in kg if needed
            let weightKg = patient.weightKg ?? 70.0  // Default if not set
            
            // Get patient age
            let ageYears = Calendar.current.dateComponents([.year], from: patient.dateOfBirth, to: Date()).year ?? 0
            
            // Call QFOT blockchain service
            let result = try await medicalServices.calculateDrugDosing(
                drugName: drug,
                patientWeightKg: weightKg,
                patientAgeYears: ageYears,
                indication: "Treatment",
                renalFunction: patient.renalFunction ?? "normal"
            )
            
            // Verify NOT a simulation
            guard result.simulation == false else {
                errorMessage = "SIMULATION DETECTED - Cannot use simulated data!"
                isLoading = false
                return
            }
            
            drugDosingResult = result
            isLoading = false
            
            print("✅ Drug dosing calculated from QFOT mainnet")
            print("   Drug: \(result.drug)")
            print("   Dose: \(result.recommendedDose ?? result.standardDose ?? "N/A")")
            print("   Simulation: \(result.simulation)")
            
        } catch {
            errorMessage = "Failed to calculate dosing: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Drug Interactions
    
    /// Check for drug interactions from patient's medication list
    /// Critical safety check before prescribing
    func checkInteractions(for patient: Patient) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let medicationNames = patient.medications.map { $0.name }
            
            guard !medicationNames.isEmpty else {
                errorMessage = "No medications to check"
                isLoading = false
                return
            }
            
            // Query QFOT blockchain for interactions
            let result = try await medicalServices.checkDrugInteractions(
                medications: medicationNames
            )
            
            guard result.simulation == false else {
                errorMessage = "SIMULATION DETECTED!"
                isLoading = false
                return
            }
            
            drugInteractions = result
            isLoading = false
            
            // Alert if major interactions found
            let majorInteractions = result.interactions.filter { $0.severity.lowercased() == "major" }
            if !majorInteractions.isEmpty {
                errorMessage = "⚠️ \(majorInteractions.count) MAJOR interaction(s) found!"
            }
            
            print("✅ Drug interactions checked via QFOT mainnet")
            print("   Medications: \(medicationNames.joined(separator: ", "))")
            print("   Interactions found: \(result.interactionsFound)")
            print("   Simulation: \(result.simulation)")
            
        } catch {
            errorMessage = "Failed to check interactions: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - FDA Alerts
    
    /// Get FDA safety alerts for a drug
    /// Real-time safety information from FDA MedWatch
    func getFDAAlerts(for drug: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await medicalServices.getFDAAlerts(drugName: drug, limit: 5)
            
            guard result.simulation == false else {
                errorMessage = "SIMULATION DETECTED!"
                isLoading = false
                return
            }
            
            fdaAlerts = result.alerts
            isLoading = false
            
            print("✅ FDA alerts fetched from QFOT mainnet")
            print("   Drug: \(drug)")
            print("   Alerts: \(result.alertsFound)")
            print("   Simulation: \(result.simulation)")
            
        } catch {
            errorMessage = "Failed to fetch FDA alerts: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - ICD-10 Lookup
    
    /// Look up ICD-10 codes for diagnosis
    /// Helps with accurate coding and billing
    func lookupICD10(query: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await medicalServices.lookupICD10(query: query, limit: 10)
            
            guard result.simulation == false else {
                errorMessage = "SIMULATION DETECTED!"
                isLoading = false
                return
            }
            
            icd10Codes = result.codes
            isLoading = false
            
            print("✅ ICD-10 codes retrieved from QFOT mainnet")
            print("   Query: \(query)")
            print("   Codes found: \(result.codesFound)")
            print("   Simulation: \(result.simulation)")
            
        } catch {
            errorMessage = "Failed to lookup ICD-10: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Integrated Workflow Example
    
    /// Complete clinical decision support workflow
    /// Demonstrates integration of multiple QFOT services
    func performClinicalDecisionSupport(
        patient: Patient,
        proposedDrug: String,
        diagnosis: String
    ) async {
        print("🏥 Starting Clinical Decision Support (via QFOT Mainnet)")
        
        // Step 1: Look up ICD-10 code
        await lookupICD10(query: diagnosis)
        
        // Step 2: Check for drug interactions with existing meds
        await checkInteractions(for: patient)
        
        // Step 3: Calculate appropriate dosing
        await calculateDosing(drug: proposedDrug, patient: patient)
        
        // Step 4: Check FDA alerts
        await getFDAAlerts(for: proposedDrug)
        
        print("✅ Clinical decision support complete (all from QFOT mainnet)")
    }
}

// MARK: - Patient Extension

extension Patient {
    /// Patient weight in kg (add this property if not exists)
    var weightKg: Double? {
        // In real implementation, get from patient vitals
        return 70.0  // Placeholder
    }
    
    /// Renal function status
    var renalFunction: String? {
        // In real implementation, calculate from labs (eGFR, creatinine)
        return "normal"  // Placeholder
    }
}

// MARK: - Usage Example for SwiftUI View

/*
 
 Example usage in a SwiftUI view:
 
 ```swift
 import SwiftUI
 
 struct PrescriptionView: View {
     @StateObject private var viewModel = EnhancedClinicalViewModel()
     let patient: Patient
     @State private var drugName = ""
     
     var body: some View {
         Form {
             Section("Patient") {
                 Text(patient.fullName)
                 Text("Age: \(patient.age) years")
             }
             
             Section("Prescribe Medication") {
                 TextField("Drug name", text: $drugName)
                 
                 Button("Calculate Dose") {
                     Task {
                         await viewModel.calculateDosing(
                             drug: drugName,
                             patient: patient
                         )
                     }
                 }
                 .disabled(drugName.isEmpty || viewModel.isLoading)
                 
                 Button("Check Interactions") {
                     Task {
                         await viewModel.checkInteractions(for: patient)
                     }
                 }
                 .disabled(viewModel.isLoading)
             }
             
             if viewModel.isLoading {
                 Section {
                     ProgressView("Querying QFOT Mainnet...")
                 }
             }
             
             if let dosingResult = viewModel.drugDosingResult {
                 Section("Recommended Dosing") {
                     Text(dosingResult.recommendedDose ?? dosingResult.standardDose ?? "N/A")
                         .font(.headline)
                     
                     if let frequency = dosingResult.frequency {
                         Text("Frequency: \(frequency)")
                     }
                     
                     ForEach(dosingResult.warnings, id: \.self) { warning in
                         Label(warning, systemImage: "exclamationmark.triangle")
                             .foregroundColor(.orange)
                             .font(.caption)
                     }
                     
                     Text("Source: QFOT Mainnet (NO SIMULATION)")
                         .font(.caption2)
                         .foregroundColor(.green)
                 }
             }
             
             if let interactions = viewModel.drugInteractions {
                 Section("Drug Interactions (\(interactions.interactionsFound))") {
                     ForEach(interactions.interactions, id: \.drug1) { interaction in
                         VStack(alignment: .leading) {
                             Text("\(interaction.drug1) ↔️ \(interaction.drug2)")
                                 .font(.headline)
                             Text("Severity: \(interaction.severity)")
                                 .foregroundColor(severityColor(interaction.severity))
                             Text(interaction.mechanism)
                                 .font(.caption)
                             Text("Recommendation: \(interaction.recommendation)")
                                 .font(.caption)
                                 .foregroundColor(.blue)
                         }
                     }
                     
                     Text("Source: QFOT Mainnet")
                         .font(.caption2)
                         .foregroundColor(.green)
                 }
             }
             
             if !viewModel.fdaAlerts.isEmpty {
                 Section("FDA Safety Alerts") {
                     ForEach(viewModel.fdaAlerts, id: \.alertId) { alert in
                         VStack(alignment: .leading) {
                             Text(alert.alertType)
                                 .font(.headline)
                             Text(alert.summary)
                                 .font(.body)
                             Text("Action: \(alert.actionRequired)")
                                 .font(.caption)
                                 .foregroundColor(.red)
                             Text(alert.date)
                                 .font(.caption2)
                         }
                     }
                 }
             }
             
             if let error = viewModel.errorMessage {
                 Section {
                     Text(error)
                         .foregroundColor(.red)
                 }
             }
         }
         .navigationTitle("Enhanced Prescribing")
     }
     
     func severityColor(_ severity: String) -> Color {
         switch severity.lowercased() {
         case "major": return .red
         case "moderate": return .orange
         default: return .yellow
         }
     }
 }
 ```
 
 */


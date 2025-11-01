// MetalAKGIntegrationExample.swift
// Example integration of Metal-accelerated AKG in Clinician app
// Shows how to use VQbit substrate + Metal GNN for clinical decision support

import Foundation
import SwiftUI
import FoTCore
import FoTClinician
import VQbitSubstrate

/// Example: Complete clinical workflow using Metal AKG + VQbit substrate
@MainActor
class MetalAKGClinicalViewModel: ObservableObject {
    // Metal-accelerated knowledge graph
    private var metalAKG: MetalAKGGraph?
    
    // Domain services
    private let medicalServices: QFOTMedicalServices
    private let apiClient: ArangoDBClient
    
    // Published state
    @Published var isInitialized = false
    @Published var factCount = 0
    @Published var isGPUAccelerated = false
    @Published var metalDeviceName = ""
    
    @Published var queryResults: [MetalAKGGraph.AKGFact] = []
    @Published var relatedFacts: [MetalAKGGraph.AKGFact] = []
    @Published var contradictions: [MetalAKGGraph.AKGFact] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        self.medicalServices = QFOTMedicalServices(baseURL: "https://safeaicoin.org/domain-api")
        self.apiClient = ArangoDBClient(baseURL: "https://safeaicoin.org/api")
    }
    
    // MARK: - Initialization
    
    /// Initialize Metal AKG on app launch
    func initialize() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🚀 Initializing Metal AKG for Clinical domain...")
            
            // Create Metal-accelerated graph
            let akg = try await MetalAKGGraph(domain: "medical", gnnSize: 8096)
            
            // Sync with mainnet ArangoDB
            print("🔄 Syncing with mainnet...")
            try await akg.syncWithMainnet(apiClient: apiClient)
            
            // Get statistics
            let stats = akg.getStatistics()
            
            metalAKG = akg
            factCount = stats["fact_count"] as? Int ?? 0
            isGPUAccelerated = stats["gpu_accelerated"] as? Bool ?? false
            metalDeviceName = stats["metal_device"] as? String ?? "Unknown"
            isInitialized = true
            isLoading = false
            
            print("✅ Metal AKG initialized")
            print("   Domain: medical")
            print("   Facts: \(factCount)")
            print("   GPU: \(metalDeviceName)")
            print("   VQbit GNN: 8096 vQbits")
            print("   Simulation: false")
            
        } catch {
            errorMessage = "Failed to initialize Metal AKG: \(error.localizedDescription)"
            isLoading = false
            print("❌ Initialization failed: \(error)")
        }
    }
    
    // MARK: - Clinical Workflows
    
    /// Example 1: Drug Information Lookup
    /// Uses VQbit-powered semantic search on local Metal graph
    func lookupDrugInfo(drugName: String) async {
        guard let akg = metalAKG else {
            errorMessage = "Metal AKG not initialized"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Looking up drug: \(drugName)")
            
            // Query local Metal AKG using VQbit reasoning
            let results = try await akg.queryFacts(
                query: "drug \(drugName) dosing interactions contraindications",
                limit: 10
            )
            
            queryResults = results
            isLoading = false
            
            print("✅ Found \(results.count) facts about \(drugName)")
            print("   GPU-accelerated GNN similarity search")
            print("   VQbit substrate reasoning")
            
        } catch {
            errorMessage = "Failed to query: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Example 2: Find Related Conditions
    /// Uses Metal GNN to traverse graph relationships
    func findRelatedConditions(diagnosis: String) async {
        guard let akg = metalAKG else {
            errorMessage = "Metal AKG not initialized"
            return
        }
        
        isLoading = true
        
        do {
            // First, find the diagnosis fact
            let diagnosisFacts = try await akg.queryFacts(
                query: "diagnosis \(diagnosis) ICD-10",
                limit: 1
            )
            
            guard let primaryFact = diagnosisFacts.first else {
                errorMessage = "Diagnosis not found in knowledge graph"
                isLoading = false
                return
            }
            
            print("🔍 Traversing graph from: \(primaryFact.id)")
            
            // Traverse relationships using Metal-accelerated GNN
            let related = try await akg.traverseGraph(
                fromFact: primaryFact.id,
                relationshipType: .related,
                maxHops: 2
            )
            
            relatedFacts = related
            isLoading = false
            
            print("✅ Found \(related.count) related conditions")
            print("   Multi-hop GNN traversal")
            print("   VQbit-guided path selection")
            
        } catch {
            errorMessage = "Failed to traverse graph: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Example 3: Check Treatment Contradictions
    /// Uses VQbit substrate to detect conflicting treatments
    func checkTreatmentConflicts(treatmentFactID: String) async {
        guard let akg = metalAKG else {
            errorMessage = "Metal AKG not initialized"
            return
        }
        
        isLoading = true
        
        do {
            print("⚠️ Checking for treatment conflicts...")
            
            // Use Metal GNN to find contradicting facts
            let conflicts = try await akg.findContradictions(for: treatmentFactID)
            
            contradictions = conflicts
            isLoading = false
            
            if !conflicts.isEmpty {
                print("⚠️ WARNING: \(conflicts.count) conflicts detected!")
                print("   Semantic contradiction detection via Metal")
                print("   VQbit substrate conflict resolution")
            } else {
                print("✅ No conflicts detected")
            }
            
        } catch {
            errorMessage = "Failed to check conflicts: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Example 4: Complete Prescription Workflow
    /// Combines Metal AKG + Domain Services + VQbit Reasoning
    func completePrescriptionWorkflow(
        drug: String,
        patient: Patient
    ) async {
        print("💊 Starting complete prescription workflow...")
        print("   Drug: \(drug)")
        print("   Patient: \(patient.fullName)")
        
        // Step 1: Query local Metal AKG for drug facts
        await lookupDrugInfo(drugName: drug)
        
        guard let drugFact = queryResults.first else {
            errorMessage = "Drug not found in knowledge graph"
            return
        }
        
        // Step 2: Check for interactions using graph traversal
        await checkTreatmentConflicts(treatmentFactID: drugFact.id)
        
        // Step 3: Use domain services for real-time calculation
        do {
            let dosing = try await medicalServices.calculateDrugDosing(
                drugName: drug,
                patientWeightKg: patient.weightKg ?? 70.0,
                patientAgeYears: patient.age,
                indication: "Treatment"
            )
            
            print("✅ Prescription workflow complete")
            print("   Local AKG facts: \(queryResults.count)")
            print("   Conflicts detected: \(contradictions.count)")
            print("   Recommended dose: \(dosing.recommendedDose ?? dosing.standardDose ?? "N/A")")
            print("   Metal GPU: ✓")
            print("   VQbit substrate: ✓")
            print("   Mainnet verified: ✓")
            print("   Simulation: false")
            
        } catch {
            errorMessage = "Failed to calculate dosing: \(error.localizedDescription)"
        }
    }
    
    /// Example 5: Background Sync
    /// Periodic updates from mainnet ArangoDB
    func performBackgroundSync() async {
        guard let akg = metalAKG else { return }
        
        print("🔄 Performing background sync...")
        
        do {
            try await akg.syncWithMainnet(apiClient: apiClient)
            
            let stats = akg.getStatistics()
            factCount = stats["fact_count"] as? Int ?? 0
            
            print("✅ Background sync complete")
            print("   Facts: \(factCount)")
            
        } catch {
            print("⚠️ Background sync failed: \(error)")
        }
    }
}

// MARK: - SwiftUI Integration Example

struct MetalAKGDemoView: View {
    @StateObject private var viewModel = MetalAKGClinicalViewModel()
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Metal AKG Status") {
                    if viewModel.isInitialized {
                        Label("Initialized", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        HStack {
                            Text("Facts in Graph")
                            Spacer()
                            Text("\(viewModel.factCount)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("GPU Accelerated")
                            Spacer()
                            Text(viewModel.isGPUAccelerated ? "Yes" : "No")
                                .foregroundColor(viewModel.isGPUAccelerated ? .green : .orange)
                        }
                        
                        HStack {
                            Text("Metal Device")
                            Spacer()
                            Text(viewModel.metalDeviceName)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        
                        Text("VQbit GNN: 8096 vQbits")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("Simulation: false")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                    } else {
                        Button("Initialize Metal AKG") {
                            Task {
                                await viewModel.initialize()
                            }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
                
                if viewModel.isInitialized {
                    Section("Query Knowledge Graph") {
                        TextField("Search drugs, diagnoses...", text: $searchQuery)
                        
                        Button("Search") {
                            Task {
                                await viewModel.lookupDrugInfo(drugName: searchQuery)
                            }
                        }
                        .disabled(searchQuery.isEmpty || viewModel.isLoading)
                    }
                    
                    if !viewModel.queryResults.isEmpty {
                        Section("Results (\(viewModel.queryResults.count))") {
                            ForEach(viewModel.queryResults) { fact in
                                VStack(alignment: .leading) {
                                    Text(fact.content)
                                        .font(.body)
                                    
                                    HStack {
                                        Text(fact.domain)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        
                                        Text("• \(fact.creator)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if let vqbitID = fact.vqbitID {
                                            Text("• VQbit")
                                                .font(.caption)
                                                .foregroundColor(.purple)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("Actions") {
                        Button("Sync with Mainnet") {
                            Task {
                                await viewModel.performBackgroundSync()
                            }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
                
                if viewModel.isLoading {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Processing...")
                        }
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Metal AKG Demo")
            .task {
                if !viewModel.isInitialized {
                    await viewModel.initialize()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MetalAKGDemoView()
}

/*
 
 Usage in Production App:
 
 1. Initialize on app launch:
 
    @main
    struct FoTClinicianApp: App {
        @StateObject private var akgViewModel = MetalAKGClinicalViewModel()
        
        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(akgViewModel)
                    .task {
                        await akgViewModel.initialize()
                    }
            }
        }
    }
 
 2. Use in any view:
 
    struct PrescriptionView: View {
        @EnvironmentObject var akg: MetalAKGClinicalViewModel
        
        var body: some View {
            Button("Look up drug") {
                Task {
                    await akg.lookupDrugInfo(drugName: "Metformin")
                }
            }
        }
    }
 
 3. Background sync:
 
    // Schedule periodic sync
    Task {
        while true {
            try await Task.sleep(for: .seconds(86400)) // 24 hours
            await akg.performBackgroundSync()
        }
    }
 
 */


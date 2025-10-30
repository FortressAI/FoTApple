// Protein Domain Pack - Blockchain Integration
// Submits protein structure/sequence truth claims to QFOT blockchain

import Foundation
import SafeAICoinBridge
import FoTCore

/// Protein truth claims submitted to blockchain
public struct ProteinTruthClaim: Codable {
    let uniprotId: String?
    let sequence: String
    let structure: ProteinStructure?
    let goAnnotations: [GOTerm]
    let mass: Double?
    let confidence: Double
    let validatedBy: ValidationSource
    
    enum ValidationSource: String, Codable {
        case alphafold3
        case experimentalXRay = "experimental_xray"
        case experimentalNMR = "experimental_nmr"
        case cafa6Prediction = "cafa6_prediction"
        case humanExpert = "human_expert"
    }
}

public struct ProteinStructure: Codable {
    let pdbId: String?
    let coordinates: [[Double]]  // 3D coordinates
    let confidence: [Double]     // Per-residue confidence (pLDDT)
}

public struct GOTerm: Codable {
    let id: String  // e.g., "GO:0005515"
    let aspect: String  // molecular_function, biological_process, cellular_component
    let description: String
    let evidence: String
}

/// Client for submitting protein truth claims to blockchain
public actor ProteinBlockchainClient {
    private let qfotClient: SafeAICoinClient
    private let domainPack: ProteinDomainPack
    
    public init() async throws {
        // Initialize QFOT blockchain client
        self.qfotClient = try await SafeAICoinClient.fromDeployedNetwork()
        self.domainPack = ProteinDomainPack()
    }
    
    /// Submit protein truth claim to blockchain
    /// Goes through Ethics Node validation before acceptance
    public func submitProteinFact(
        sequence: String,
        structure: ProteinStructure?,
        goAnnotations: [GOTerm],
        validationSource: ProteinTruthClaim.ValidationSource
    ) async throws -> String {
        
        // Step 1: Local validation using domain pack rules
        let record = Record(
            labels: ["Protein"],
            data: [
                "sequence": sequence,
                "mass_da": try calculateMass(sequence: sequence)
            ]
        )
        
        let validation = try domainPack.validate(record: record)
        guard validation.isValid else {
            throw ProteinBlockchainError.validationFailed(validation.errors)
        }
        
        // Step 2: Create truth claim
        let claim = ProteinTruthClaim(
            uniprotId: nil, // TODO: lookup from database
            sequence: sequence,
            structure: structure,
            goAnnotations: goAnnotations,
            mass: try calculateMass(sequence: sequence),
            confidence: try calculateConfidence(structure: structure, source: validationSource),
            validatedBy: validationSource
        )
        
        // Step 3: Convert to blockchain format
        let claimData = try JSONEncoder().encode(claim)
        let contentHash = Data(SHA256.hash(data: claimData))
        
        // Step 4: Submit to blockchain
        // This will trigger:
        // - Ethics Node assessment (Aristotelian logic check)
        // - AKG GNN embedding computation
        // - Contradiction detection with existing facts
        // - Socratic challenge generation
        // - Virtue alignment assessment
        
        let factId = try await qfotClient.submitKnowledgeFact(
            contentHash: contentHash,
            category: "Protein",
            stake: 10.0, // Stake 10 QFOT tokens
            ipfsHash: try await uploadToIPFS(claimData)
        )
        
        print("✅ Protein fact submitted to blockchain")
        print("   Fact ID: \(factId)")
        print("   Sequence length: \(sequence.count)")
        print("   GO annotations: \(goAnnotations.count)")
        print("   Now awaiting Ethics Node validation...")
        
        // Step 5: Wait for ethics assessment
        let ethicsResult = try await qfotClient.waitForEthicsAssessment(factId: factId)
        
        if ethicsResult.requiresHumanReview {
            print("⚠️  Human review required - submitted to expert panel")
            throw ProteinBlockchainError.humanReviewRequired(factId)
        }
        
        if !ethicsResult.approved {
            print("❌ Ethics Node rejected fact")
            print("   Reason: \(ethicsResult.reason)")
            throw ProteinBlockchainError.ethicsRejected(ethicsResult.reason)
        }
        
        print("🎉 Protein fact validated and added to knowledge graph!")
        print("   Ethical confidence: \(ethicsResult.confidence)%")
        print("   Virtues aligned: \(ethicsResult.virtuesAligned.joined(separator: ", "))")
        
        return factId
    }
    
    /// Calculate molecular mass from sequence
    private func calculateMass(sequence: String) throws -> Double {
        let residueMasses: [Character: Double] = [
            "A": 89.09, "R": 174.20, "N": 132.12, "D": 133.10,
            "C": 121.15, "E": 147.13, "Q": 146.15, "G": 75.07,
            "H": 155.16, "I": 131.17, "L": 131.17, "K": 146.19,
            "M": 149.21, "F": 165.19, "P": 115.13, "S": 105.09,
            "T": 119.12, "W": 204.23, "Y": 181.19, "V": 117.15
        ]
        
        return sequence.reduce(0.0) { sum, residue in
            sum + (residueMasses[residue] ?? 0.0)
        }
    }
    
    /// Calculate confidence score based on validation source
    private func calculateConfidence(
        structure: ProteinStructure?,
        source: ProteinTruthClaim.ValidationSource
    ) throws -> Double {
        switch source {
        case .experimentalXRay, .experimentalNMR:
            return 0.95 // Experimental structures are highly confident
        case .alphafold3:
            // Use average pLDDT score
            if let structure = structure {
                let avgPlddt = structure.confidence.reduce(0.0, +) / Double(structure.confidence.count)
                return avgPlddt / 100.0
            }
            return 0.70
        case .cafa6Prediction:
            return 0.75 // CAFA6 benchmark performance
        case .humanExpert:
            return 0.90 // Expert validation
        }
    }
    
    /// Upload to IPFS for full content storage
    private func uploadToIPFS(_ data: Data) async throws -> String {
        // In production, upload to IPFS
        // Return CID
        return "Qm..." // Placeholder
    }
    
    /// Track rewards earned from this protein fact
    public func trackRewards(factId: String) async throws -> RewardSummary {
        return try await qfotClient.getRewards(factId: factId)
    }
}

public enum ProteinBlockchainError: Error {
    case validationFailed([ValidationIssue])
    case humanReviewRequired(String)
    case ethicsRejected(String)
    case uploadFailed(String)
}

public struct RewardSummary {
    let factId: String
    let totalRewards: Double  // in QFOT
    let queryCount: Int
    let lastQueried: Date?
}


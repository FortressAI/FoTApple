import Foundation
import SwiftUI

/// SafeAICoin Opt-In Manager - Users CHOOSE to participate
/// This is a SHARING TOOL - not required for app functionality
public class SafeAICoinOptIn: ObservableObject {
    @AppStorage("safeaicoin.opted_in") public var isOptedIn: Bool = false
    @AppStorage("safeaicoin.share_anonymous") public var shareAnonymously: Bool = true
    @AppStorage("safeaicoin.auto_share") public var autoShare: Bool = false
    
    public static let shared = SafeAICoinOptIn()
    
    private init() {}
    
    /// Check if user has opted in to knowledge sharing
    public func canShareKnowledge() -> Bool {
        return isOptedIn
    }
    
    /// Opt-in to SafeAICoin knowledge sharing and earning
    public func optIn(shareAnonymously: Bool = true) {
        self.isOptedIn = true
        self.shareAnonymously = shareAnonymously
        print("✅ User opted in to SafeAICoin knowledge sharing")
    }
    
    /// Opt-out of SafeAICoin (can re-enable anytime)
    public func optOut() {
        self.isOptedIn = false
        self.autoShare = false
        print("✅ User opted out of SafeAICoin knowledge sharing")
    }
}

/// Opt-In Welcome Sheet - Explains the value proposition
public struct SafeAICoinOptInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var optIn = SafeAICoinOptIn.shared
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "network")
                            .font(.system(size: 60))
                            .foregroundStyle(.linearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        
                        Text("Share Knowledge. Earn Rewards.")
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                        
                        Text("Optional Feature")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
                    // How it works
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How It Works")
                            .font(.headline)
                        
                        FeatureRow(
                            icon: "checkmark.seal.fill",
                            color: .green,
                            title: "You Share Knowledge",
                            description: "Choose to contribute validated insights to help others"
                        )
                        
                        FeatureRow(
                            icon: "bitcoinsign.circle.fill",
                            color: .orange,
                            title: "You Earn SAFE Tokens",
                            description: "Get rewarded when others find your contributions useful"
                        )
                        
                        FeatureRow(
                            icon: "lock.shield.fill",
                            color: .blue,
                            title: "Your Privacy Protected",
                            description: "Share anonymously - no personal data on blockchain"
                        )
                        
                        FeatureRow(
                            icon: "hand.raised.fill",
                            color: .purple,
                            title: "You Control Everything",
                            description: "Choose what to share, when to share, opt-out anytime"
                        )
                    }
                    
                    Divider()
                    
                    // Value proposition
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What You Get")
                            .font(.headline)
                        
                        BenefitRow(text: "70% of fees when others use your knowledge")
                        BenefitRow(text: "Build reputation as trusted contributor")
                        BenefitRow(text: "Help advance collective intelligence")
                        BenefitRow(text: "Convert tokens to real value")
                    }
                    
                    Divider()
                    
                    // Important notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Important")
                            .font(.headline)
                        
                        InfoRow(icon: "info.circle.fill", text: "This is completely optional")
                        InfoRow(icon: "info.circle.fill", text: "App works fully without this")
                        InfoRow(icon: "info.circle.fill", text: "You decide what to share")
                        InfoRow(icon: "info.circle.fill", text: "Opt-out anytime in Settings")
                    }
                    
                    // Privacy options
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy Settings")
                            .font(.headline)
                        
                        Toggle(isOn: .constant(true)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Share Anonymously")
                                    .font(.subheadline)
                                Text("Your identity is not revealed on blockchain")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .disabled(true)
                        .tint(.blue)
                        
                        Toggle(isOn: $optIn.autoShare) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Auto-Share High-Confidence Insights")
                                    .font(.subheadline)
                                Text("Automatically share when confidence > 90%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tint(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            optIn.optIn(shareAnonymously: true)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Enable Knowledge Sharing")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Maybe Later")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("SafeAICoin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct BenefitRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Share Sheet - User decides what to share

public struct ShareKnowledgeSheet: View {
    let contribution: KnowledgeContribution
    @Environment(\.dismiss) private var dismiss
    @State private var shareAnonymously = true
    @State private var isSharing = false
    @State private var shareResult: ShareResult?
    
    public init(contribution: KnowledgeContribution) {
        self.contribution = contribution
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Contribution preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Contribution")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label(contribution.type.displayName, systemImage: contribution.type.icon)
                            .font(.subheadline)
                        
                        Text("Confidence: \(Int(contribution.confidence * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Estimated reward: \(String(format: "%.2f", contribution.estimatedReward)) SAFE")
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                // Privacy toggle
                Toggle(isOn: $shareAnonymously) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Share Anonymously")
                            .font(.subheadline)
                        Text("Your identity will not be revealed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .tint(.blue)
                
                Spacer()
                
                // Share result
                if let result = shareResult {
                    resultView(result)
                }
                
                // Share button
                if shareResult == nil {
                    Button(action: shareKnowledge) {
                        HStack {
                            if isSharing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                Text("Share & Earn")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isSharing)
                }
            }
            .padding()
            .navigationTitle("Share Knowledge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareKnowledge() {
        isSharing = true
        
        Task {
            do {
                // Get user's wallet
                let client = try await SafeAICoinClient.fromDeployedNetwork()
                let wallet = try await SafeAICoinWallet(
                    userId: contribution.userId,
                    client: client
                )
                
                // Submit contribution to blockchain
                let earning = try await wallet.earnTokensForContribution(
                    contributionId: contribution.id,
                    contributionType: contribution.type,
                    confidence: contribution.confidence,
                    usageCount: 1
                )
                
                await MainActor.run {
                    shareResult = .success(earning)
                    isSharing = false
                }
                
            } catch {
                await MainActor.run {
                    shareResult = .failure(error.localizedDescription)
                    isSharing = false
                }
            }
        }
    }
    
    @ViewBuilder
    private func resultView(_ result: ShareResult) -> some View {
        switch result {
        case .success(let earning):
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Shared Successfully!")
                    .font(.title2.bold())
                
                Text("You earned \(String(format: "%.4f", earning.amount)) SAFE")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
        case .failure(let error):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Sharing Failed")
                    .font(.title2.bold())
                
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Try Again") {
                    shareResult = nil
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

enum ShareResult {
    case success(TokenEarning)
    case failure(String)
}

// MARK: - Knowledge Contribution Model

public struct KnowledgeContribution {
    public let id: String
    public let userId: String
    public let type: ContributionType
    public let confidence: Double
    public let data: Data
    
    public var estimatedReward: Double {
        type.baseReward * confidence
    }
    
    public init(
        id: String,
        userId: String,
        type: ContributionType,
        confidence: Double,
        data: Data
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.confidence = confidence
        self.data = data
    }
}

extension ContributionType {
    var displayName: String {
        switch self {
        case .medicalDiagnosis: return "Medical Diagnosis"
        case .legalResearch: return "Legal Research"
        case .educationalContent: return "Educational Content"
        case .healthGuidance: return "Health Guidance"
        case .parentingAdvice: return "Parenting Advice"
        case .knowledgeValidation: return "Knowledge Validation"
        }
    }
    
    var icon: String {
        switch self {
        case .medicalDiagnosis: return "heart.text.square.fill"
        case .legalResearch: return "scale.3d"
        case .educationalContent: return "book.fill"
        case .healthGuidance: return "heart.fill"
        case .parentingAdvice: return "person.3.fill"
        case .knowledgeValidation: return "checkmark.seal.fill"
        }
    }
}

// MARK: - Preview

#Preview("Opt-In Sheet") {
    SafeAICoinOptInSheet()
}

#Preview("Share Sheet") {
    ShareKnowledgeSheet(
        contribution: KnowledgeContribution(
            id: "test-123",
            userId: "user-456",
            type: .medicalDiagnosis,
            confidence: 0.95,
            data: Data()
        )
    )
}


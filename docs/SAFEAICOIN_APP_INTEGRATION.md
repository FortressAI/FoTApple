# SafeAICoin App Integration Guide

## 🎯 **IMPORTANT: This is an OPTIONAL Sharing Tool**

SafeAICoin is **NOT REQUIRED** for app functionality. It's an **opt-in feature** that allows users to:
- **Share** their validated knowledge contributions
- **Earn** SAFE tokens when others find their contributions useful
- **Control** exactly what they share and when

## ✅ Integration Principles

1. **OPT-IN ONLY** - No blockchain interaction unless user explicitly enables it
2. **CLEAR VALUE PROPOSITION** - Explain what users get (70% of fees)
3. **PRIVACY FIRST** - All sharing is anonymous by default
4. **USER CONTROL** - Users can disable at any time
5. **NON-INTRUSIVE** - Don't interrupt app flow

## 📱 How to Integrate in Your App

### 1. Add SafeAICoin Settings to App Settings

```swift
import SwiftUI
import FoTUI

struct AppSettingsView: View {
    var body: some View {
        List {
            // Your existing settings sections...
            
            // Add SafeAICoin section
            Section {
                NavigationLink(destination: SafeAICoinSettingsView()) {
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(.blue)
                        Text("Knowledge Sharing")
                        Spacer()
                        if SafeAICoinOptIn.shared.isOptedIn {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            } header: {
                Text("Optional Features")
            } footer: {
                Text("Share your validated insights and earn SAFE tokens")
            }
        }
        .navigationTitle("Settings")
    }
}
```

### 2. Add Share Button After Generating Insights

When your app generates valuable insights (diagnosis, legal research, education content, etc.), offer users the option to share:

#### Example: Personal Health App

```swift
import SwiftUI
import FoTCore

struct HealthGuidanceResultView: View {
    let guidance: HealthGuidance
    let userId: String
    @StateObject private var optIn = SafeAICoinOptIn.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Show the guidance result
            Text(guidance.recommendation)
                .padding()
            
            // OPTIONAL: Show share button if opted in
            if optIn.isOptedIn && guidance.confidence >= 0.80 {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Share this guidance?")
                        .font(.headline)
                    
                    Text("Help others with similar questions. Estimated reward: \(String(format: "%.2f", estimatedReward)) SAFE")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SafeAICoinShareButton(
                        contribution: KnowledgeContribution(
                            id: UUID().uuidString,
                            userId: userId,
                            type: .healthGuidance,
                            confidence: guidance.confidence,
                            data: try! JSONEncoder().encode(guidance)
                        )
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }
    
    private var estimatedReward: Double {
        ContributionType.healthGuidance.baseReward * guidance.confidence
    }
}
```

#### Example: Clinician App - Medical Diagnosis

```swift
import SwiftUI
import FoTCore

struct DiagnosisResultView: View {
    let diagnosis: MedicalDiagnosis
    let userId: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Show diagnosis
            DiagnosisCard(diagnosis: diagnosis)
            
            // OPTIONAL: Share to help other clinicians
            if SafeAICoinOptIn.shared.isOptedIn {
                ShareDiagnosisSection(diagnosis: diagnosis, userId: userId)
            }
        }
    }
}

struct ShareDiagnosisSection: View {
    let diagnosis: MedicalDiagnosis
    let userId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "network")
                    .foregroundColor(.blue)
                Text("Share with Medical Community")
                    .font(.headline)
            }
            
            Text("De-identified diagnosis can help other clinicians. You earn \(String(format: "%.2f", estimatedReward)) SAFE when used.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            SafeAICoinShareButton(
                contribution: KnowledgeContribution(
                    id: diagnosis.id,
                    userId: userId,
                    type: .medicalDiagnosis,
                    confidence: diagnosis.confidence,
                    data: try! JSONEncoder().encode(diagnosis)
                )
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
        )
    }
    
    private var estimatedReward: Double {
        ContributionType.medicalDiagnosis.baseReward * diagnosis.confidence
    }
}
```

#### Example: Education App - Learning Content

```swift
import SwiftUI
import FoTCore

struct LearningContentView: View {
    let content: EducationalContent
    let userId: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Show educational content
                Text(content.explanation)
                    .padding()
                
                // OPTIONAL: Share to help other learners
                if SafeAICoinOptIn.shared.isOptedIn && content.wasHelpful {
                    ShareContentCard(content: content, userId: userId)
                }
            }
        }
    }
}

struct ShareContentCard: View {
    let content: EducationalContent
    let userId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("This helped you? Share to help others!", systemImage: "person.3.fill")
                .font(.subheadline.bold())
            
            Text("Earn tokens when other students find this useful")
                .font(.caption)
                .foregroundColor(.secondary)
            
            SafeAICoinShareButton(
                contribution: KnowledgeContribution(
                    id: content.id,
                    userId: userId,
                    type: .educationalContent,
                    confidence: content.quality,
                    data: try! JSONEncoder().encode(content)
                )
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.green, lineWidth: 2)
                .background(Color.green.opacity(0.05))
        )
    }
}
```

### 3. Auto-Share for Power Users (Optional)

For users who enable "auto-share", contributions are shared automatically when confidence is high:

```swift
// After generating high-confidence guidance
if guidance.confidence >= 0.90 {
    Task {
        await SafeAICoinIntegration.offerToShare(
            contribution: KnowledgeContribution(
                id: guidance.id,
                userId: userId,
                type: .healthGuidance,
                confidence: guidance.confidence,
                data: try! JSONEncoder().encode(guidance)
            ),
            autoShare: true  // Will auto-share if user enabled it
        )
    }
}
```

## 💰 Token Economics for Apps

### Contribution Types and Base Rewards

| Contribution Type | Base Reward (SAFE) | Use Case |
|-------------------|-------------------|----------|
| Medical Diagnosis | 10.0 | Clinician App validated diagnoses |
| Legal Research | 8.0 | Legal App case analysis |
| Educational Content | 5.0 | Education App learning materials |
| Health Guidance | 6.0 | Personal Health App recommendations |
| Parenting Advice | 4.0 | Parent App guidance |
| Knowledge Validation | 2.0 | General fact validation |

### Actual Earnings Formula

```
Earnings = Base Reward × Confidence Score × Usage Count × 0.70
```

**Example:**
- Medical diagnosis with 95% confidence
- Base reward: 10.0 SAFE
- Used by 50 other clinicians
- Earnings: 10.0 × 0.95 × 50 × 0.70 = **332.5 SAFE**

**Note:** SAFE token value is not established. Tokens may have no market value.

### Fee Distribution (Automated by Blockchain)

When someone uses a shared contribution:
- **70%** → Knowledge Creator (the user who shared)
- **15%** → Platform Maintenance (FoT development)
- **10%** → Governance Participants (token stakers)
- **5%** → Ethics Validators (quality control)

## 🎨 UI/UX Guidelines

### ✅ DO:
- Use subtle, non-intrusive share buttons
- Explain what users get ("Earn X SAFE tokens")
- Show estimated rewards before sharing
- Make opt-out easy to find
- Respect user's choice

### ❌ DON'T:
- Force users to opt-in
- Show blockchain jargon
- Interrupt critical app workflows
- Hide the disable option
- Make users feel guilty for not sharing

### Color & Icon Guidance
- Use **blue/purple gradient** for SafeAICoin branding
- Icon: `network` or `bitcoinsign.circle.fill`
- Success: **Green** with `checkmark.circle.fill`
- Optional tag: **Gray** with `hand.raised` icon

## 🔐 Privacy Guarantees

### What IS Shared (on blockchain):
- De-identified knowledge content
- Confidence score
- Timestamp
- Contribution type

### What is NOT Shared:
- User's real identity
- Personal health information
- Location data
- Device information
- Any PII/PHI

### Technical Implementation:
```swift
// All sharing is anonymous
let contribution = KnowledgeContribution(
    id: UUID().uuidString,  // Random ID, not linked to user
    userId: hashedUserId,    // Hashed, not reversible
    type: .healthGuidance,
    confidence: 0.95,
    data: sanitized(guidance)  // PHI/PII stripped
)
```

## 📊 Testing SafeAICoin Integration

### 1. Check Opt-In Flow
```swift
// In your UI tests
func testSafeAICoinOptIn() {
    // User should see opt-in sheet when clicking share button
    XCTAssertFalse(SafeAICoinOptIn.shared.isOptedIn)
    
    // After opting in
    SafeAICoinOptIn.shared.optIn()
    XCTAssertTrue(SafeAICoinOptIn.shared.isOptedIn)
}
```

### 2. Verify No Forced Interaction
```swift
func testNoForcedBlockchainCalls() {
    // Ensure no blockchain calls if not opted in
    SafeAICoinOptIn.shared.optOut()
    
    let shared = await SafeAICoinIntegration.offerToShare(
        contribution: testContribution,
        autoShare: true
    )
    
    XCTAssertFalse(shared)  // Should NOT share if opted out
}
```

### 3. Test Settings Integration
- Navigate to Settings → Knowledge Sharing
- Should show "Disabled" status
- Enable sharing
- Should show "Enabled" status
- Should show "View Wallet" button
- Disable sharing
- Should return to "Disabled" status

## 🚀 Deployment Checklist

- [ ] Add SafeAICoinSettingsView to app settings
- [ ] Add share buttons to appropriate result views
- [ ] Test opt-in flow
- [ ] Verify no blockchain calls when opted out
- [ ] Test wallet view (if opted in)
- [ ] Update App Store description mentioning optional earning feature
- [ ] Add privacy policy section about blockchain sharing

## 📚 Additional Resources

- [SafeAICoin Architecture](../blockchain/SAFEAICOIN_ARCHITECTURE.md)
- [Token Economics Whitepaper](https://safeaicoin.org/tokenomics)
- [Privacy Policy](https://safeaicoin.org/privacy)
- [Developer API Docs](https://docs.safeaicoin.org)

## ❓ FAQ

**Q: Is SafeAICoin required to use the app?**
A: No, it's completely optional. The app works fully without it.

**Q: What if users don't want to share?**
A: That's totally fine! The share buttons are subtle and non-intrusive.

**Q: How do I deploy SafeAICoin nodes?**
A: Run `./scripts/deploy_safeaicoin_hetzner.sh` to deploy to Hetzner Cloud.

**Q: How do users cash out SAFE tokens?**
A: They can transfer to exchanges or use in-app to access premium features.

**Q: What about HIPAA/GDPR compliance?**
A: All sharing is de-identified and anonymous. No PHI/PII on blockchain.

---

**Remember: SafeAICoin is a SHARING TOOL, not a requirement. Make it optional, valuable, and respectful of user choice.**


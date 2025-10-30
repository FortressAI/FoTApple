import SwiftUI
import FoTUI

/// Legal App - Complete Onboarding Experience
struct LegalOnboardingFlow: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingSplash: Bool = true
    @State private var showingOnboarding: Bool = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            if showingSplash {
                AnimatedSplashScreen(
                    appName: "Field of Truth Legal",
                    appIcon: "scale.3d",
                    primaryColor: .indigo,
                    secondaryColor: .blue,
                    onComplete: {
                        withAnimation {
                            showingSplash = false
                            showingOnboarding = true
                        }
                    }
                )
            } else if showingOnboarding {
                SiriGuidedOnboarding(
                    appName: "Field of Truth Legal",
                    features: legalFeatures,
                    primaryColor: .indigo,
                    onComplete: {
                        hasCompletedOnboarding = true
                        onComplete()
                    }
                )
            }
        }
    }
    
    private var legalFeatures: [OnboardingFeature] {
        [
            OnboardingFeature(
                icon: "folder.fill",
                title: "Case Management",
                description: "Track cases with automatic FRCP deadline calculation (100% accuracy). Never miss a filing deadline.",
                siriCommand: "Create new case in Legal"
            ),
            OnboardingFeature(
                icon: "magnifyingglass",
                title: "AI Legal Research",
                description: "Search case law and statutes with AI-powered analysis. Get Bluebook citations automatically.",
                siriCommand: "Search case law in Legal"
            ),
            OnboardingFeature(
                icon: "calendar.badge.clock",
                title: "Deadline Tracking",
                description: "Automated deadline calculation for all 50 states and federal courts. Get alerts before key dates.",
                siriCommand: "Show my deadlines in Legal"
            ),
            OnboardingFeature(
                icon: "doc.richtext.fill",
                title: "Document Management",
                description: "Organize pleadings, discovery, and correspondence. Full-text search and version control.",
                siriCommand: "Show case documents in Legal"
            ),
            OnboardingFeature(
                icon: "person.2.fill",
                title: "Client Communication",
                description: "Secure client portal with billing, document sharing, and case updates. ABA Model Rules compliant.",
                siriCommand: "Message client in Legal"
            )
        ]
    }
}

/// Help Context for Legal App
extension HelpContext {
    static let legalDashboard = HelpContext(
        id: "legal_dashboard",
        tooltipTitle: "Legal Practice Dashboard",
        tooltipMessage: "Manage cases, research law, and track deadlines all in one place.",
        siriCommand: "Show my cases in Legal",
        quickActions: [
            QuickAction(
                icon: "folder.badge.plus",
                title: "New Case",
                description: "Create a new case file"
            ) {},
            QuickAction(
                icon: "magnifyingglass",
                title: "Legal Research",
                description: "Search case law and statutes"
            ) {},
            QuickAction(
                icon: "calendar",
                title: "View Deadlines",
                description: "Check upcoming filing deadlines"
            ) {}
        ],
        helpTopics: [
            HelpTopic(
                icon: "folder.fill",
                title: "Creating a New Case",
                content: "Set up comprehensive case files with automatic deadline tracking and document management.",
                steps: [
                    "Tap 'New Case' on the dashboard",
                    "Enter case name and number",
                    "Select jurisdiction and court",
                    "Choose case type (civil, criminal, family, etc.)",
                    "Add parties (plaintiff, defendant, attorneys)",
                    "Enter key dates (filing, service, trial)",
                    "System calculates all FRCP deadlines automatically"
                ],
                relatedSiriCommand: "Create new case in Legal"
            ),
            HelpTopic(
                icon: "calendar.badge.clock",
                title: "Understanding Deadline Calculations",
                content: "The app automatically calculates procedural deadlines based on FRCP, state rules, and local rules.",
                steps: [
                    "Deadlines are calculated when you enter key dates",
                    "System accounts for court holidays and weekends",
                    "Alerts sent 7 days, 3 days, and 1 day before deadline",
                    "View all deadlines in the Calendar tab",
                    "Mark deadlines as completed or extended",
                    "Export deadlines to your calendar app"
                ],
                relatedSiriCommand: "Show my deadlines in Legal"
            ),
            HelpTopic(
                icon: "magnifyingglass",
                title: "AI Legal Research",
                content: "Search case law, statutes, and regulations with natural language queries and AI analysis.",
                steps: [
                    "Tap 'Legal Research' from any case",
                    "Enter your legal question in plain English",
                    "Select jurisdiction (federal, state, or all)",
                    "Review AI-generated research summary",
                    "Read relevant case excerpts with citations",
                    "Copy Bluebook citations to your documents",
                    "Save research to case file"
                ],
                relatedSiriCommand: "Search case law in Legal"
            ),
            HelpTopic(
                icon: "checkmark.shield.fill",
                title: "QFOT Knowledge Sharing (Optional)",
                content: "Opt-in to share de-identified legal research on the QFOT blockchain and earn tokens.",
                steps: [
                    "Review ABA Model Rules compliance in Settings",
                    "Enable 'Share Research' option",
                    "System automatically de-identifies all research",
                    "Never shares client names, case details, or work product",
                    "Earn QFOT tokens when others use your research",
                    "View earnings in QFOT Wallet"
                ],
                relatedSiriCommand: "Check QFOT settings in Legal"
            )
        ],
        siriCommands: [
            SiriCommandHelp(
                command: "Create new case in Legal",
                description: "Start a new case file"
            ),
            SiriCommandHelp(
                command: "Show my cases in Legal",
                description: "View all active cases"
            ),
            SiriCommandHelp(
                command: "Search case law in Legal",
                description: "Research legal precedent"
            ),
            SiriCommandHelp(
                command: "Show my deadlines in Legal",
                description: "View upcoming filing deadlines"
            ),
            SiriCommandHelp(
                command: "Message client in Legal",
                description: "Send secure client communication"
            )
        ],
        videoTutorials: [
            VideoTutorial(
                title: "Getting Started with FoT Legal",
                duration: "4:30",
                thumbnailURL: "",
                videoURL: ""
            ),
            VideoTutorial(
                title: "AI Legal Research Tutorial",
                duration: "5:45",
                thumbnailURL: "",
                videoURL: ""
            ),
            VideoTutorial(
                title: "Deadline Management Best Practices",
                duration: "3:15",
                thumbnailURL: "",
                videoURL: ""
            )
        ]
    )
}

#Preview {
    LegalOnboardingFlow {
        print("Onboarding complete")
    }
}


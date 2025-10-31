import SwiftUI
import FoTUI

/// Personal Health App - Complete Onboarding Experience
struct PersonalHealthOnboardingFlow: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingSplash: Bool = true
    @State private var showingOnboarding: Bool = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            if showingSplash {
                AnimatedSplashScreen(
                    appName: "Personal Health",
                    appIcon: "heart.fill",
                    primaryColor: .pink,
                    secondaryColor: .purple,
                    onComplete: {
                        withAnimation {
                            showingSplash = false
                            showingOnboarding = true
                        }
                    }
                )
            } else if showingOnboarding {
                SiriGuidedOnboarding(
                    appName: "Personal Health",
                    features: personalHealthFeatures,
                    primaryColor: .pink,
                    onComplete: {
                        hasCompletedOnboarding = true
                        onComplete()
                    }
                )
            }
        }
    }
    
    private var personalHealthFeatures: [OnboardingFeature] {
        [
            OnboardingFeature(
                icon: "heart.fill",
                title: "Track Your Health",
                description: "Monitor your mental and physical wellbeing with daily check-ins. Track mood, sleep, stress, and vital signs.",
                siriCommand: "Log my mood in Personal Health"
            ),
            OnboardingFeature(
                icon: "phone.fill",
                title: "24/7 Crisis Support",
                description: "Access immediate mental health resources anytime you need them. Connect with trained counselors instantly.",
                siriCommand: "Get crisis support in Personal Health"
            ),
            OnboardingFeature(
                icon: "stethoscope",
                title: "Health Guidance",
                description: "Get AI-powered recommendations about when and where to seek care based on your symptoms.",
                siriCommand: "Should I see a doctor in Personal Health"
            ),
            OnboardingFeature(
                icon: "chart.line.uptrend.xyaxis",
                title: "Health Insights",
                description: "Understand your health patterns with AI analysis. Identify trends and receive personalized guidance.",
                siriCommand: "Summarize my health in Personal Health"
            ),
            OnboardingFeature(
                icon: "lock.shield.fill",
                title: "Private & Secure",
                description: "Your health data is encrypted and stored locally. Only you control who sees your information.",
                siriCommand: "Check privacy settings in Personal Health"
            )
        ]
    }
}

/// Help Context for Personal Health Main Screen
extension HelpContext {
    static let personalHealthDashboard = HelpContext(
        id: "personal_health_dashboard",
        tooltipTitle: "Welcome to Your Health Dashboard",
        tooltipMessage: "Track your wellbeing here. Tap any card to log data or view trends.",
        siriCommand: "Log my mood in Personal Health",
        quickActions: [
            QuickAction(
                icon: "plus.circle.fill",
                title: "Quick Check-In",
                description: "Record how you're feeling right now"
            ) {
                // Action handled by app
            },
            QuickAction(
                icon: "phone.fill",
                title: "Crisis Support",
                description: "Get immediate help if you're in crisis"
            ) {
                // Action handled by app
            },
            QuickAction(
                icon: "chart.bar.fill",
                title: "View Trends",
                description: "See your health patterns over time"
            ) {
                // Action handled by app
            }
        ],
        helpTopics: [
            HelpTopic(
                icon: "heart.fill",
                title: "How to Log Your Mood",
                content: "Regular mood tracking helps you understand your mental health patterns and identify triggers.",
                steps: [
                    "Tap the 'Log Mood' button on your dashboard",
                    "Select how you're feeling using the mood scale",
                    "Optionally add notes about what's affecting your mood",
                    "Tap 'Save' to record your entry",
                    "View your mood trends in the Insights tab"
                ],
                relatedSiriCommand: "Log my mood in Personal Health"
            ),
            HelpTopic(
                icon: "moon.zzz.fill",
                title: "Tracking Sleep",
                content: "Good sleep is essential for both mental and physical health. Track your sleep patterns to identify issues.",
                steps: [
                    "Tap 'Log Sleep' each morning",
                    "Enter when you went to bed and woke up",
                    "Rate your sleep quality",
                    "Note any factors that affected your sleep",
                    "Review patterns in your sleep chart"
                ],
                relatedSiriCommand: "Log my sleep in Personal Health"
            ),
            HelpTopic(
                icon: "cross.case.fill",
                title: "Recording Vital Signs",
                content: "Track blood pressure, heart rate, weight, and other vitals to monitor your physical health.",
                steps: [
                    "Tap 'Record Vitals'",
                    "Enter measurements from your devices",
                    "System will alert you to concerning values",
                    "Share vital trends with your doctor",
                    "Set reminders for regular monitoring"
                ],
                relatedSiriCommand: "Record my vitals in Personal Health"
            ),
            HelpTopic(
                icon: "questionmark.circle.fill",
                title: "When to Use Health Guidance",
                content: "The Health Guidance Navigator helps you decide if and when to seek medical care.",
                steps: [
                    "Describe your symptoms or concerns",
                    "Answer guided questions about severity and duration",
                    "Receive an urgency assessment",
                    "Get recommendations for appropriate care level",
                    "Access provider directories if needed"
                ],
                relatedSiriCommand: "Should I see a doctor in Personal Health"
            ),
            HelpTopic(
                icon: "exclamationmark.triangle.fill",
                title: "Crisis Support Resources",
                content: "If you're experiencing a mental health emergency, we provide immediate access to help.",
                steps: [
                    "Tap the 'Crisis Support' button anytime",
                    "Choose your preferred contact method",
                    "988 Suicide & Crisis Lifeline (call or text)",
                    "Crisis Text Line (text HOME to 741741)",
                    "Local emergency services (911)"
                ],
                relatedSiriCommand: "Get crisis support in Personal Health"
            )
        ],
        siriCommands: [
            SiriCommandHelp(
                command: "Log my mood in Personal Health",
                description: "Start a new mood check-in"
            ),
            SiriCommandHelp(
                command: "Record my vitals in Personal Health",
                description: "Log blood pressure, heart rate, or other vitals"
            ),
            SiriCommandHelp(
                command: "Should I see a doctor in Personal Health",
                description: "Get health guidance about seeking care"
            ),
            SiriCommandHelp(
                command: "Get crisis support in Personal Health",
                description: "Access emergency mental health resources"
            ),
            SiriCommandHelp(
                command: "Summarize my health in Personal Health",
                description: "View your health trends and insights"
            ),
            SiriCommandHelp(
                command: "Log my sleep in Personal Health",
                description: "Record your sleep from last night"
            ),
            SiriCommandHelp(
                command: "Track my stress in Personal Health",
                description: "Log your current stress level"
            )
        ],
        videoTutorials: [
            VideoTutorial(
                title: "Getting Started with Personal Health",
                duration: "3:45",
                thumbnailURL: "",
                videoURL: ""
            ),
            VideoTutorial(
                title: "Understanding Your Health Insights",
                duration: "2:30",
                thumbnailURL: "",
                videoURL: ""
            ),
            VideoTutorial(
                title: "Using Crisis Support Features",
                duration: "2:15",
                thumbnailURL: "",
                videoURL: ""
            )
        ]
    )
    
    static let personalHealthCheckIn = HelpContext(
        id: "personal_health_checkin",
        tooltipTitle: "Health Check-In",
        tooltipMessage: "Answer these questions honestly. Your responses help us provide better health insights.",
        siriCommand: "Log my mood in Personal Health"
    )
    
    static let personalHealthGuidance = HelpContext(
        id: "personal_health_guidance",
        tooltipTitle: "Health Guidance Navigator",
        tooltipMessage: "Describe your symptoms and I'll help you determine what level of care you might need.",
        siriCommand: "Should I see a doctor in Personal Health"
    )
}

#Preview {
    PersonalHealthOnboardingFlow {
        print("Onboarding complete")
    }
}


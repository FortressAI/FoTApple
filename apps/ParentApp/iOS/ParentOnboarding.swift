import SwiftUI
import FoTUI

/// Parent App - Complete Onboarding Experience
struct ParentOnboardingFlow: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingSplash: Bool = true
    @State private var showingOnboarding: Bool = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            if showingSplash {
                AnimatedSplashScreen(
                    appName: "Field of Truth Parent",
                    appIcon: "figure.2.and.child.holdinghands",
                    primaryColor: .orange,
                    secondaryColor: .yellow,
                    onComplete: {
                        withAnimation {
                            showingSplash = false
                            showingOnboarding = true
                        }
                    }
                )
            } else if showingOnboarding {
                SiriGuidedOnboarding(
                    appName: "Field of Truth Parent",
                    features: parentFeatures,
                    primaryColor: .orange,
                    onComplete: {
                        hasCompletedOnboarding = true
                        onComplete()
                    }
                )
            }
        }
    }
    
    private var parentFeatures: [OnboardingFeature] {
        [
            OnboardingFeature(
                icon: "figure.and.child.holdinghands",
                title: "Child Development Tracking",
                description: "Monitor milestones from birth through adolescence. Get age-appropriate parenting guidance.",
                siriCommand: "Log milestone in Parent"
            ),
            OnboardingFeature(
                icon: "heart.text.square.fill",
                title: "Health Records",
                description: "Track vaccinations, doctor visits, medications, and growth charts for all your children.",
                siriCommand: "Show health records in Parent"
            ),
            OnboardingFeature(
                icon: "calendar.badge.checkmark",
                title: "Family Organization",
                description: "Shared family calendar, chore tracking, and meal planning. Keep everyone on the same page.",
                siriCommand: "Show family calendar in Parent"
            ),
            OnboardingFeature(
                icon: "bubble.left.and.bubble.right.fill",
                title: "Parenting Advice",
                description: "Get AI-powered guidance for behavior challenges, developmental concerns, and parenting questions.",
                siriCommand: "Get parenting advice in Parent"
            ),
            OnboardingFeature(
                icon: "person.2.badge.gearshape.fill",
                title: "School Connection",
                description: "Connect with your child's teachers, view grades and assignments, and stay informed.",
                siriCommand: "Show school updates in Parent"
            )
        ]
    }
}

/// Help Context for Parent App
extension HelpContext {
    static let parentDashboard = HelpContext(
        id: "parent_dashboard",
        tooltipTitle: "Parent Dashboard",
        tooltipMessage: "Track your children's development, health, and activities all in one place.",
        siriCommand: "Show family dashboard in Parent",
        helpTopics: [
            HelpTopic(
                icon: "figure.and.child.holdinghands",
                title: "Tracking Development Milestones",
                content: "Monitor your child's physical, cognitive, social, and emotional development milestones.",
                steps: [
                    "Tap 'Log Milestone' for your child",
                    "Choose milestone category (physical, cognitive, etc.)",
                    "Select the milestone from age-appropriate list",
                    "Add photos or notes about the achievement",
                    "System tracks progress against typical development",
                    "Get alerts if milestones are significantly delayed"
                ],
                relatedSiriCommand: "Log milestone in Parent"
            ),
            HelpTopic(
                icon: "heart.text.square.fill",
                title: "Managing Health Records",
                content: "Keep all your children's health information organized and accessible.",
                steps: [
                    "Add each child's profile",
                    "Record vaccinations and immunizations",
                    "Log doctor visits and diagnoses",
                    "Track medications and dosages",
                    "Monitor growth (height, weight, BMI)",
                    "Share records with healthcare providers"
                ],
                relatedSiriCommand: "Show health records in Parent"
            ),
            HelpTopic(
                icon: "bubble.left.and.bubble.right.fill",
                title: "Getting Parenting Advice",
                content: "Access evidence-based parenting guidance for any situation or developmental stage.",
                steps: [
                    "Tap 'Get Advice' or ask Siri",
                    "Describe your parenting question or concern",
                    "Specify child's age for developmentally appropriate advice",
                    "Review AI-generated recommendations",
                    "Access related articles and resources",
                    "Get professional referrals if needed"
                ],
                relatedSiriCommand: "Get parenting advice in Parent"
            )
        ],
        siriCommands: [
            SiriCommandHelp(
                command: "Log milestone in Parent",
                description: "Record a child development milestone"
            ),
            SiriCommandHelp(
                command: "Show health records in Parent",
                description: "View vaccination and medical history"
            ),
            SiriCommandHelp(
                command: "Get parenting advice in Parent",
                description: "Ask for parenting guidance"
            ),
            SiriCommandHelp(
                command: "Show family calendar in Parent",
                description: "View family schedule and events"
            )
        ],
        videoTutorials: []
    )
}

#Preview {
    ParentOnboardingFlow {
        print("Onboarding complete")
    }
}


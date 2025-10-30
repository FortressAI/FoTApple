import SwiftUI
import FoTUI

/// Education App - Complete Onboarding Experience
struct EducationOnboardingFlow: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingSplash: Bool = true
    @State private var showingOnboarding: Bool = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            if showingSplash {
                AnimatedSplashScreen(
                    appName: "Field of Truth Education",
                    appIcon: "book.fill",
                    primaryColor: .green,
                    secondaryColor: .teal,
                    onComplete: {
                        withAnimation {
                            showingSplash = false
                            showingOnboarding = true
                        }
                    }
                )
            } else if showingOnboarding {
                SiriGuidedOnboarding(
                    appName: "Field of Truth Education",
                    features: educationFeatures,
                    primaryColor: .green,
                    onComplete: {
                        hasCompletedOnboarding = true
                        onComplete()
                    }
                )
            }
        }
    }
    
    private var educationFeatures: [OnboardingFeature] {
        [
            OnboardingFeature(
                icon: "person.3.fill",
                title: "Student Management",
                description: "Track student progress, attendance, and achievements. FERPA-compliant data protection.",
                siriCommand: "Show my students in Education"
            ),
            OnboardingFeature(
                icon: "list.clipboard.fill",
                title: "Assignment Tracking",
                description: "Create, assign, and grade work with AI-powered feedback. Mastery-based grading support.",
                siriCommand: "Create assignment in Education"
            ),
            OnboardingFeature(
                icon: "chart.bar.fill",
                title: "Learning Analytics",
                description: "Identify struggling students early with predictive analytics. Get intervention recommendations.",
                siriCommand: "Show learning insights in Education"
            ),
            OnboardingFeature(
                icon: "doc.text.fill",
                title: "IEP & 504 Support",
                description: "Manage individualized education plans with accommodation tracking and progress monitoring.",
                siriCommand: "Show IEPs in Education"
            ),
            OnboardingFeature(
                icon: "person.2.badge.gearshape.fill",
                title: "Parent Communication",
                description: "Secure parent portal for grades, assignments, and progress reports. Two-way messaging.",
                siriCommand: "Message parents in Education"
            )
        ]
    }
}

/// Help Context for Education App
extension HelpContext {
    static let educationDashboard = HelpContext(
        id: "education_dashboard",
        tooltipTitle: "Education Dashboard",
        tooltipMessage: "Manage students, assignments, and track learning progress all in one place.",
        siriCommand: "Show my students in Education",
        helpTopics: [
            HelpTopic(
                icon: "person.badge.plus",
                title: "Adding Students",
                content: "Create student profiles with demographics, learning preferences, and accommodation needs.",
                steps: [
                    "Tap 'Add Student' on the dashboard",
                    "Enter student name and ID number",
                    "Add grade level and homeroom",
                    "Record learning preferences and interests",
                    "Note any IEP or 504 accommodations",
                    "Invite parents to connect via parent portal"
                ],
                relatedSiriCommand: "Add new student in Education"
            ),
            HelpTopic(
                icon: "list.clipboard.fill",
                title: "Creating Assignments",
                content: "Design engaging assignments with AI-powered suggestions and automatic grading support.",
                steps: [
                    "Tap 'New Assignment'",
                    "Enter title, description, and learning objectives",
                    "Set due date and point value",
                    "Choose assignment type (homework, quiz, project)",
                    "Add rubric or grading criteria",
                    "Assign to students or groups",
                    "Enable AI feedback for student work"
                ],
                relatedSiriCommand: "Create assignment in Education"
            )
        ],
        siriCommands: [
            SiriCommandHelp(
                command: "Show my students in Education",
                description: "View student roster"
            ),
            SiriCommandHelp(
                command: "Create assignment in Education",
                description: "Create a new assignment"
            ),
            SiriCommandHelp(
                command: "Show learning insights in Education",
                description: "View analytics and predictions"
            )
        ],
        videoTutorials: []
    )
}

#Preview {
    EducationOnboardingFlow {
        print("Onboarding complete")
    }
}


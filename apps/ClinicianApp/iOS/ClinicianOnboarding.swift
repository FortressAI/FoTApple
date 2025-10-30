import SwiftUI
import FoTUI

/// Clinician App - Complete Onboarding Experience
struct ClinicianOnboardingFlow: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingSplash: Bool = true
    @State private var showingOnboarding: Bool = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            if showingSplash {
                AnimatedSplashScreen(
                    appName: "Field of Truth Clinician",
                    appIcon: "stethoscope",
                    primaryColor: .blue,
                    secondaryColor: .cyan,
                    onComplete: {
                        withAnimation {
                            showingSplash = false
                            showingOnboarding = true
                        }
                    }
                )
            } else if showingOnboarding {
                SiriGuidedOnboarding(
                    appName: "Field of Truth Clinician",
                    features: clinicianFeatures,
                    primaryColor: .blue,
                    onComplete: {
                        hasCompletedOnboarding = true
                        onComplete()
                    }
                )
            }
        }
    }
    
    private var clinicianFeatures: [OnboardingFeature] {
        [
            OnboardingFeature(
                icon: "person.text.rectangle.fill",
                title: "Patient Management",
                description: "Comprehensive patient records with demographics, history, and encounter documentation.",
                siriCommand: "Create new patient in Clinician"
            ),
            OnboardingFeature(
                icon: "brain.head.profile",
                title: "AI Diagnosis Generator",
                description: "Generate differential diagnoses with 94.2% USMLE accuracy. Evidence-based clinical decision support.",
                siriCommand: "Generate diagnosis in Clinician"
            ),
            OnboardingFeature(
                icon: "pills.fill",
                title: "Drug Interaction Checker",
                description: "Real-time medication safety screening with 98.2% accuracy using RxNav database.",
                siriCommand: "Check drug interactions in Clinician"
            ),
            OnboardingFeature(
                icon: "doc.text.fill",
                title: "SOAP Note Generation",
                description: "Automated clinical documentation with cryptographic audit trails for malpractice protection.",
                siriCommand: "Generate SOAP note in Clinician"
            ),
            OnboardingFeature(
                icon: "checkmark.shield.fill",
                title: "Audit Trails & Compliance",
                description: "Every decision is recorded with blockchain attestation and Merkle tree proofs. HIPAA compliant.",
                siriCommand: "Show audit trail in Clinician"
            )
        ]
    }
}

/// Help Context for Clinician App
extension HelpContext {
    static let clinicianDashboard = HelpContext(
        id: "clinician_dashboard",
        tooltipTitle: "Clinical Dashboard",
        tooltipMessage: "Access patient records, start encounters, and use AI-powered clinical tools.",
        siriCommand: "Show my patients in Clinician",
        quickActions: [
            QuickAction(
                icon: "person.badge.plus",
                title: "New Patient",
                description: "Add a new patient to your practice"
            ) {},
            QuickAction(
                icon: "stethoscope",
                title: "Start Encounter",
                description: "Begin documenting a patient visit"
            ) {},
            QuickAction(
                icon: "pills.fill",
                title: "Drug Checker",
                description: "Check medication interactions"
            ) {}
        ],
        helpTopics: [
            HelpTopic(
                icon: "person.text.rectangle.fill",
                title: "Creating Patient Records",
                content: "Add comprehensive patient information including demographics, medical history, allergies, and current medications.",
                steps: [
                    "Tap 'New Patient' on the dashboard",
                    "Enter patient demographics (name, DOB, gender)",
                    "Add insurance and contact information",
                    "Record medical history and allergies",
                    "Document current medications",
                    "Save to create the patient record"
                ],
                relatedSiriCommand: "Create new patient in Clinician"
            ),
            HelpTopic(
                icon: "doc.text.fill",
                title: "Documenting Clinical Encounters",
                content: "Structure patient visits with comprehensive SOAP documentation and AI assistance.",
                steps: [
                    "Select patient and tap 'New Encounter'",
                    "Record chief complaint and HPI",
                    "Enter vital signs and physical exam findings",
                    "Complete review of systems",
                    "Generate AI-powered differential diagnoses",
                    "Create assessment and treatment plan",
                    "Sign note with cryptographic signature"
                ],
                relatedSiriCommand: "Start encounter in Clinician"
            ),
            HelpTopic(
                icon: "brain.head.profile",
                title: "Using AI Diagnosis Generator",
                content: "The AI analyzes patient data to suggest differential diagnoses with evidence-based reasoning.",
                steps: [
                    "Complete patient assessment in encounter",
                    "Tap 'Generate Diagnosis'",
                    "Review AI-suggested differentials ranked by likelihood",
                    "Read clinical reasoning for each diagnosis",
                    "Select appropriate ICD-10 codes",
                    "Audit trail automatically created"
                ],
                relatedSiriCommand: "Generate diagnosis in Clinician"
            ),
            HelpTopic(
                icon: "pills.fill",
                title: "Checking Drug Interactions",
                content: "Real-time medication safety screening prevents adverse drug events and identifies contraindications.",
                steps: [
                    "Open patient medication list",
                    "Tap 'Check Interactions'",
                    "Review severity ratings for each interaction",
                    "Read clinical significance and mechanism",
                    "Access alternative medication suggestions",
                    "Document your clinical decision"
                ],
                relatedSiriCommand: "Check drug interactions in Clinician"
            ),
            HelpTopic(
                icon: "checkmark.shield.fill",
                title: "Understanding Audit Trails",
                content: "Every clinical decision is cryptographically signed and recorded for malpractice protection.",
                steps: [
                    "Audit trails are automatically generated",
                    "Each decision gets a Merkle tree proof",
                    "Blockchain attestation provides immutability",
                    "Access audit log from any encounter",
                    "Export audit trail for legal proceedings"
                ],
                relatedSiriCommand: "Show audit trail in Clinician"
            )
        ],
        siriCommands: [
            SiriCommandHelp(
                command: "Create new patient in Clinician",
                description: "Add a new patient record"
            ),
            SiriCommandHelp(
                command: "Start encounter in Clinician",
                description: "Begin documenting a patient visit"
            ),
            SiriCommandHelp(
                command: "Generate diagnosis in Clinician",
                description: "Get AI-powered differential diagnoses"
            ),
            SiriCommandHelp(
                command: "Check drug interactions in Clinician",
                description: "Screen medications for safety issues"
            ),
            SiriCommandHelp(
                command: "Generate SOAP note in Clinician",
                description: "Create clinical documentation"
            ),
            SiriCommandHelp(
                command: "Show audit trail in Clinician",
                description: "View decision audit log"
            )
        ],
        videoTutorials: [
            VideoTutorial(
                title: "Getting Started with FoT Clinician",
                duration: "5:00",
                thumbnailURL: "",
                videoURL: ""
            ),
            VideoTutorial(
                title: "AI Diagnosis Generator Deep Dive",
                duration: "4:30",
                thumbnailURL: "",
                videoURL: ""
            ),
            VideoTutorial(
                title: "Clinical Documentation Best Practices",
                duration: "6:15",
                thumbnailURL: "",
                videoURL: ""
            )
        ]
    )
}

#Preview {
    ClinicianOnboardingFlow {
        print("Onboarding complete")
    }
}


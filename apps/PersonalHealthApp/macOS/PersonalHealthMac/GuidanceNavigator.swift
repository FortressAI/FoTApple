// GuidanceNavigator.swift
// Interactive guidance system to help users know when to involve professionals

import SwiftUI
import FoTCore
import FoTUI

// MARK: - Guidance Categories

enum ProfessionalType: String, CaseIterable {
    case medical = "Medical Professional"
    case mentalHealth = "Mental Health Professional"
    case legal = "Legal Professional"
    case educational = "Teacher/School"
    case emergency = "Emergency Services"
    case none = "Self-Care & Monitoring"
    
    var icon: String {
        switch self {
        case .medical: return "stethoscope"
        case .mentalHealth: return "brain.head.profile"
        case .legal: return "hammer.fill"
        case .educational: return "graduationcap.fill"
        case .emergency: return "phone.fill"
        case .none: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .medical: return .blue
        case .mentalHealth: return .purple
        case .legal: return .orange
        case .educational: return .green
        case .emergency: return .red
        case .none: return .teal
        }
    }
}

struct GuidanceQuestion: Identifiable {
    let id = UUID()
    let question: String
    let category: String
    let options: [GuidanceOption]
    let isUrgent: Bool
}

struct GuidanceOption: Identifiable {
    let id = UUID()
    let text: String
    let score: Int // Higher score = more urgent professional help needed
    let triggers: [ProfessionalType]
}

struct GuidanceRecommendation {
    let professionalType: ProfessionalType
    let urgency: Urgency
    let reason: String
    let nextSteps: [String]
    let resources: [Resource]
    
    enum Urgency: String {
        case immediate = "Seek Help Immediately"
        case urgent = "Schedule Within 24-48 Hours"
        case soon = "Schedule Within 1-2 Weeks"
        case routine = "Consider When Convenient"
    }
    
    struct Resource {
        let name: String
        let contact: String
        let description: String
    }
}

// MARK: - Guidance Navigator View

struct GuidanceNavigatorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestionIndex = 0
    @State private var answers: [UUID: Int] = [:]
    @State private var showResults = false
    @State private var recommendations: [GuidanceRecommendation] = []
    
    let questions: [GuidanceQuestion] = [
        // Physical Health Questions
        GuidanceQuestion(
            question: "Are you experiencing severe chest pain, difficulty breathing, or signs of a stroke?",
            category: "Physical Emergency",
            options: [
                GuidanceOption(text: "Yes - happening right now", score: 100, triggers: [.emergency]),
                GuidanceOption(text: "Yes - but manageable", score: 80, triggers: [.medical, .emergency]),
                GuidanceOption(text: "No", score: 0, triggers: [])
            ],
            isUrgent: true
        ),
        
        GuidanceQuestion(
            question: "Do you have persistent physical symptoms that are affecting your daily life?",
            category: "Physical Health",
            options: [
                GuidanceOption(text: "Yes - severe impact (can't work/function)", score: 70, triggers: [.medical]),
                GuidanceOption(text: "Yes - moderate impact", score: 50, triggers: [.medical]),
                GuidanceOption(text: "Yes - mild symptoms", score: 30, triggers: [.medical]),
                GuidanceOption(text: "No persistent symptoms", score: 0, triggers: [.none])
            ],
            isUrgent: false
        ),
        
        // Mental Health Questions
        GuidanceQuestion(
            question: "Are you having thoughts of harming yourself or others?",
            category: "Mental Health Emergency",
            options: [
                GuidanceOption(text: "Yes - with a plan", score: 100, triggers: [.emergency, .mentalHealth]),
                GuidanceOption(text: "Yes - but no specific plan", score: 90, triggers: [.emergency, .mentalHealth]),
                GuidanceOption(text: "Sometimes, but I'm safe", score: 70, triggers: [.mentalHealth]),
                GuidanceOption(text: "No", score: 0, triggers: [])
            ],
            isUrgent: true
        ),
        
        GuidanceQuestion(
            question: "How is your mood affecting your daily functioning?",
            category: "Mental Health",
            options: [
                GuidanceOption(text: "Can't function - missed work/school multiple days", score: 80, triggers: [.mentalHealth, .medical]),
                GuidanceOption(text: "Struggling but managing to function", score: 60, triggers: [.mentalHealth]),
                GuidanceOption(text: "Some difficult days, mostly okay", score: 30, triggers: [.mentalHealth]),
                GuidanceOption(text: "Mood is stable", score: 0, triggers: [.none])
            ],
            isUrgent: false
        ),
        
        GuidanceQuestion(
            question: "How is your sleep pattern?",
            category: "Mental Health",
            options: [
                GuidanceOption(text: "Severe insomnia (< 3 hours/night) for weeks", score: 60, triggers: [.medical, .mentalHealth]),
                GuidanceOption(text: "Difficulty sleeping most nights", score: 40, triggers: [.mentalHealth]),
                GuidanceOption(text: "Occasional sleep issues", score: 20, triggers: [.none]),
                GuidanceOption(text: "Sleeping well", score: 0, triggers: [.none])
            ],
            isUrgent: false
        ),
        
        // Legal Questions
        GuidanceQuestion(
            question: "Are you experiencing workplace discrimination, harassment, or unsafe conditions?",
            category: "Legal/Workplace",
            options: [
                GuidanceOption(text: "Yes - severe/ongoing", score: 70, triggers: [.legal, .medical]),
                GuidanceOption(text: "Yes - occasional incidents", score: 50, triggers: [.legal]),
                GuidanceOption(text: "Unsure if it qualifies", score: 30, triggers: [.legal]),
                GuidanceOption(text: "No workplace issues", score: 0, triggers: [])
            ],
            isUrgent: false
        ),
        
        GuidanceQuestion(
            question: "Do you need documentation for disability, workers' comp, or legal claims?",
            category: "Legal Documentation",
            options: [
                GuidanceOption(text: "Yes - for active legal case", score: 80, triggers: [.legal, .medical]),
                GuidanceOption(text: "Yes - planning to file claim", score: 60, triggers: [.legal, .medical]),
                GuidanceOption(text: "Maybe in the future", score: 30, triggers: [.medical]),
                GuidanceOption(text: "No legal needs", score: 0, triggers: [])
            ],
            isUrgent: false
        ),
        
        // Educational Questions
        GuidanceQuestion(
            question: "Are you (or your child) struggling in school due to health issues?",
            category: "Educational Support",
            options: [
                GuidanceOption(text: "Yes - failing/at risk of expulsion", score: 70, triggers: [.educational, .medical, .mentalHealth]),
                GuidanceOption(text: "Yes - grades dropping significantly", score: 50, triggers: [.educational, .mentalHealth]),
                GuidanceOption(text: "Some difficulties, manageable", score: 30, triggers: [.educational]),
                GuidanceOption(text: "No school issues", score: 0, triggers: [])
            ],
            isUrgent: false
        ),
        
        // Substance Use
        GuidanceQuestion(
            question: "Are you concerned about substance use (alcohol, drugs, medications)?",
            category: "Substance Use",
            options: [
                GuidanceOption(text: "Yes - daily use affecting life", score: 80, triggers: [.medical, .mentalHealth]),
                GuidanceOption(text: "Yes - occasional but concerned", score: 50, triggers: [.mentalHealth]),
                GuidanceOption(text: "No concerns", score: 0, triggers: [])
            ],
            isUrgent: false
        ),
        
        // Abuse/Safety
        GuidanceQuestion(
            question: "Are you experiencing abuse, violence, or feeling unsafe?",
            category: "Safety",
            options: [
                GuidanceOption(text: "Yes - in immediate danger", score: 100, triggers: [.emergency, .legal]),
                GuidanceOption(text: "Yes - ongoing abuse", score: 90, triggers: [.legal, .mentalHealth, .medical]),
                GuidanceOption(text: "Past trauma affecting me now", score: 60, triggers: [.mentalHealth]),
                GuidanceOption(text: "No safety concerns", score: 0, triggers: [])
            ],
            isUrgent: true
        )
    ]
    
    var body: some View {
        ZStack {
            DomainBackground(domain: .clinician)
            
            if showResults {
                resultsView
            } else {
                questionnaireView
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
    
    // MARK: - Questionnaire View
    
    var questionnaireView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "map.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Health Concerns Navigator")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Let's figure out what kind of help you need")
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                    .frame(maxWidth: 400)
                
                Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            if currentQuestionIndex < questions.count {
                let question = questions[currentQuestionIndex]
                
                ScrollView {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 20) {
                            if question.isUrgent {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text("IMPORTANT")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            Text(question.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Text(question.question)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Divider()
                            
                            ForEach(question.options) { option in
                                Button(action: {
                                    selectOption(question: question, score: option.score)
                                }) {
                                    HStack {
                                        Text(option.text)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(32)
                    }
                    .frame(maxWidth: 600)
                }
            }
            
            HStack {
                if currentQuestionIndex > 0 {
                    Button("← Previous") {
                        currentQuestionIndex -= 1
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
    
    // MARK: - Results View
    
    var resultsView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Your Personalized Guidance")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Based on your responses, here's what we recommend")
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Recommendations
                ForEach(recommendations, id: \.professionalType.rawValue) { rec in
                    RecommendationCard(recommendation: rec)
                        .frame(maxWidth: 700)
                }
                
                // General Advice
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("Remember")
                                .font(.headline)
                        }
                        
                        Text("• This app provides guidance, not diagnosis")
                        Text("• When in doubt, seek professional help")
                        Text("• Keep tracking your symptoms in this app")
                        Text("• Share your cryptographic receipts with professionals")
                        Text("• You deserve support and care")
                    }
                    .padding(24)
                }
                .frame(maxWidth: 700)
                
                HStack {
                    Button("Start Over") {
                        currentQuestionIndex = 0
                        answers.removeAll()
                        recommendations.removeAll()
                        showResults = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save Recommendations") {
                        saveRecommendations()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .padding()
        }
    }
    
    // MARK: - Helper Functions
    
    func selectOption(question: GuidanceQuestion, score: Int) {
        answers[question.id] = score
        
        // Check for immediate emergency
        if score >= 90 && question.isUrgent {
            // Show emergency alert
            showEmergencyAlert()
        }
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            generateRecommendations()
            showResults = true
        }
    }
    
    func showEmergencyAlert() {
        // This would show an NSAlert on macOS
        print("🚨 EMERGENCY DETECTED - Showing crisis resources")
    }
    
    func generateRecommendations() {
        var professionalScores: [ProfessionalType: Int] = [:]
        
        // Calculate scores for each professional type
        for (questionId, score) in answers {
            if let question = questions.first(where: { $0.id == questionId }) {
                if let option = question.options.first(where: { abs($0.score - score) < 5 }) {
                    for trigger in option.triggers {
                        professionalScores[trigger, default: 0] += score
                    }
                }
            }
        }
        
        // Generate recommendations based on scores
        recommendations = professionalScores
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .map { type, score in
                generateRecommendation(for: type, score: score)
            }
        
        // Ensure at least one recommendation
        if recommendations.isEmpty {
            recommendations.append(generateRecommendation(for: .none, score: 0))
        }
    }
    
    func generateRecommendation(for type: ProfessionalType, score: Int) -> GuidanceRecommendation {
        let urgency: GuidanceRecommendation.Urgency
        if score >= 90 {
            urgency = .immediate
        } else if score >= 60 {
            urgency = .urgent
        } else if score >= 30 {
            urgency = .soon
        } else {
            urgency = .routine
        }
        
        let (reason, steps, resources) = getDetailsFor(type: type, urgency: urgency)
        
        return GuidanceRecommendation(
            professionalType: type,
            urgency: urgency,
            reason: reason,
            nextSteps: steps,
            resources: resources
        )
    }
    
    func getDetailsFor(type: ProfessionalType, urgency: GuidanceRecommendation.Urgency) -> (String, [String], [GuidanceRecommendation.Resource]) {
        switch type {
        case .emergency:
            return (
                "Your responses indicate you may need immediate help.",
                [
                    "Call 911 if this is a life-threatening emergency",
                    "Call or text 988 for suicide/crisis support",
                    "Go to nearest emergency room",
                    "Don't wait - act now"
                ],
                [
                    .init(name: "911", contact: "911", description: "Emergency services"),
                    .init(name: "988 Suicide & Crisis Lifeline", contact: "988", description: "Call or text anytime"),
                    .init(name: "Crisis Text Line", contact: "Text HOME to 741741", description: "24/7 text support")
                ]
            )
            
        case .medical:
            return (
                "You should see a medical doctor to evaluate your symptoms.",
                [
                    urgency == .immediate ? "Seek emergency care or urgent care" : "Schedule appointment with primary care physician",
                    "Bring your symptom timeline from this app",
                    "Share cryptographic receipts to prove symptom history",
                    "Ask about specialist referrals if needed"
                ],
                [
                    .init(name: "Primary Care Doctor", contact: "Your usual physician", description: "First stop for medical concerns"),
                    .init(name: "Urgent Care", contact: "Local urgent care center", description: "For urgent but non-emergency issues"),
                    .init(name: "Specialist", contact: "Via referral", description: "For specific conditions")
                ]
            )
            
        case .mentalHealth:
            return (
                "A mental health professional can provide support and treatment.",
                [
                    urgency == .immediate ? "Call 988 or go to emergency room" : "Schedule appointment with therapist or psychiatrist",
                    "Share mood tracking data from this app",
                    "Consider both therapy (talk) and psychiatry (medication)",
                    "Ask about evidence-based treatments (CBT, DBT, etc.)"
                ],
                [
                    .init(name: "Psychology Today", contact: "psychologytoday.com", description: "Find therapists near you"),
                    .init(name: "NAMI Helpline", contact: "1-800-950-6264", description: "Mental health support and referrals"),
                    .init(name: "SAMHSA", contact: "1-800-662-4357", description: "Treatment referral helpline")
                ]
            )
            
        case .legal:
            return (
                "You may benefit from legal consultation.",
                [
                    "Consult with attorney specializing in your issue (employment, disability, personal injury)",
                    "Gather all documentation (medical records, photos, communications)",
                    "Your cryptographic receipts provide tamper-proof evidence",
                    "Many attorneys offer free initial consultations"
                ],
                [
                    .init(name: "Legal Aid", contact: "lawhelp.org", description: "Free/low-cost legal services"),
                    .init(name: "Bar Association Referral", contact: "State bar association", description: "Find qualified attorneys"),
                    .init(name: "EEOC", contact: "eeoc.gov", description: "For workplace discrimination")
                ]
            )
            
        case .educational:
            return (
                "Reach out to school support services.",
                [
                    "Schedule meeting with teacher, counselor, or principal",
                    "Request 504 plan or IEP evaluation if health affects learning",
                    "Bring medical documentation if available",
                    "Know your rights under ADA and IDEA"
                ],
                [
                    .init(name: "School Counselor", contact: "At your school", description: "First point of contact"),
                    .init(name: "Special Education Services", contact: "School district", description: "For accommodations"),
                    .init(name: "Parent Advocacy Groups", contact: "Local and online", description: "Support navigating school systems")
                ]
            )
            
        case .none:
            return (
                "Continue monitoring your health with this app.",
                [
                    "Keep tracking symptoms, mood, and vitals",
                    "Practice self-care and wellness activities",
                    "Reach out to trusted friends and family",
                    "If symptoms worsen, revisit this navigator"
                ],
                [
                    .init(name: "This App", contact: "Personal Health Monitor", description: "Track your health journey"),
                    .init(name: "Primary Care", contact: "Annual checkups", description: "Preventive care"),
                    .init(name: "Community Support", contact: "Support groups, online forums", description: "Peer connection")
                ]
            )
        }
    }
    
    func saveRecommendations() {
        print("✅ Saving recommendations with cryptographic receipt...")
        // This would save the recommendations to the user's health record
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let recommendation: GuidanceRecommendation
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: recommendation.professionalType.icon)
                        .font(.largeTitle)
                        .foregroundColor(recommendation.professionalType.color)
                    
                    VStack(alignment: .leading) {
                        Text(recommendation.professionalType.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(recommendation.urgency.rawValue)
                            .font(.subheadline)
                            .foregroundColor(urgencyColor(recommendation.urgency))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(urgencyColor(recommendation.urgency).opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                Divider()
                
                // Reason
                Text("Why:")
                    .font(.headline)
                Text(recommendation.reason)
                    .foregroundColor(.secondary)
                
                // Next Steps
                Text("Next Steps:")
                    .font(.headline)
                    .padding(.top, 8)
                
                ForEach(Array(recommendation.nextSteps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1).")
                            .fontWeight(.bold)
                            .foregroundColor(recommendation.professionalType.color)
                        Text(step)
                    }
                }
                
                // Resources
                if !recommendation.resources.isEmpty {
                    Text("Resources:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    ForEach(recommendation.resources, id: \.name) { resource in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(resource.name)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(resource.contact)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            Text(resource.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(24)
        }
    }
    
    func urgencyColor(_ urgency: GuidanceRecommendation.Urgency) -> Color {
        switch urgency {
        case .immediate: return .red
        case .urgent: return .orange
        case .soon: return .yellow
        case .routine: return .green
        }
    }
}


import SwiftUI
import AVFoundation

/// Siri-Guided Onboarding - Voice-First Experience
/// Siri introduces the app and explains features step-by-step
public struct SiriGuidedOnboarding: View {
    let appName: String
    let features: [OnboardingFeature]
    let primaryColor: Color
    let onComplete: () -> Void
    
    @State private var currentStep: Int = 0
    @State private var showContent: Bool = false
    @State private var isListening: Bool = false
    @StateObject private var voiceGuide = VoiceGuide()
    
    public init(
        appName: String,
        features: [OnboardingFeature],
        primaryColor: Color,
        onComplete: @escaping () -> Void
    ) {
        self.appName = appName
        self.features = features
        self.primaryColor = primaryColor
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Siri Wave Indicator
                SiriWaveView(isAnimating: $voiceGuide.isSpeaking)
                    .frame(height: 150)
                    .padding(.top, 60)
                
                // Content
                if showContent {
                    TabView(selection: $currentStep) {
                        ForEach(features.indices, id: \.self) { index in
                            OnboardingStepView(
                                feature: features[index],
                                stepNumber: index + 1,
                                totalSteps: features.count,
                                primaryColor: primaryColor
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .transition(.opacity)
                }
                
                // Controls
                HStack(spacing: 20) {
                    // Previous button
                    if currentStep > 0 {
                        Button(action: previousStep) {
                            Label("Previous", systemImage: "chevron.left")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                    
                    // Replay Siri button
                    Button(action: replaySiri) {
                        Image(systemName: voiceGuide.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [primaryColor, primaryColor.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                            .shadow(color: primaryColor.opacity(0.5), radius: 10)
                    }
                    
                    Spacer()
                    
                    // Next/Done button
                    Button(action: nextStep) {
                        Label(
                            currentStep == features.count - 1 ? "Get Started" : "Next",
                            systemImage: currentStep == features.count - 1 ? "checkmark" : "chevron.right"
                        )
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            startOnboarding()
        }
        .onChange(of: currentStep) { newStep in
            speakStep(newStep)
        }
    }
    
    private func startOnboarding() {
        // Wait for splash screen to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showContent = true
            }
            
            // Siri introduces the app
            let welcome = "Welcome to \(appName). I'm Siri, and I'll guide you through the app. Let's get started!"
            voiceGuide.speak(welcome)
            
            // After welcome, speak first step
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                speakStep(0)
            }
        }
    }
    
    private func speakStep(_ step: Int) {
        guard step < features.count else { return }
        let feature = features[step]
        
        let message = "\(feature.title). \(feature.description). You can say '\(feature.siriCommand)' anytime to access this feature."
        voiceGuide.speak(message)
    }
    
    private func replaySiri() {
        speakStep(currentStep)
    }
    
    private func nextStep() {
        if currentStep < features.count - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            // Complete onboarding
            voiceGuide.speak("You're all set! Let's start using \(appName).")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onComplete()
            }
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            withAnimation {
                currentStep -= 1
            }
        }
    }
}

/// Individual onboarding step view
struct OnboardingStepView: View {
    let feature: OnboardingFeature
    let stepNumber: Int
    let totalSteps: Int
    let primaryColor: Color
    
    var body: some View {
        VStack(spacing: 30) {
            // Step indicator
            Text("Step \(stepNumber) of \(totalSteps)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 20)
            
            // Icon
            Image(systemName: feature.icon)
                .font(.system(size: 80))
                .foregroundColor(primaryColor)
                .shadow(color: primaryColor.opacity(0.5), radius: 20)
            
            // Title
            Text(feature.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Description
            Text(feature.description)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Siri Command
            VStack(spacing: 12) {
                Text("Try saying:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundColor(primaryColor)
                    Text(""\(feature.siriCommand)"")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

/// Siri wave animation view
struct SiriWaveView: View {
    @Binding var isAnimating: Bool
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<3) { index in
                    Wave(phase: phase, index: index)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.8),
                                    Color.purple.opacity(0.6),
                                    Color.pink.opacity(0.4)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 3
                        )
                        .opacity(isAnimating ? 1.0 : 0.3)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

struct Wave: Shape {
    var phase: CGFloat
    let index: Int
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let amplitude: CGFloat = 30 + CGFloat(index) * 10
        let frequency: CGFloat = 0.02 + CGFloat(index) * 0.01
        let midHeight = rect.height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / rect.width
            let sine = sin((relativeX + phase) * .pi * 2 * frequency)
            let y = midHeight + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

/// Voice guide using AVSpeechSynthesizer
class VoiceGuide: ObservableObject {
    @Published var isSpeaking: Bool = false
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {
        synthesizer.delegate = SpeechDelegate(guide: self)
    }
    
    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    weak var guide: VoiceGuide?
    
    init(guide: VoiceGuide) {
        self.guide = guide
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.guide?.isSpeaking = false
        }
    }
}

/// Onboarding feature model
public struct OnboardingFeature {
    public let icon: String
    public let title: String
    public let description: String
    public let siriCommand: String
    
    public init(icon: String, title: String, description: String, siriCommand: String) {
        self.icon = icon
        self.title = title
        self.description = description
        self.siriCommand = siriCommand
    }
}

#Preview {
    SiriGuidedOnboarding(
        appName: "Personal Health",
        features: [
            OnboardingFeature(
                icon: "heart.fill",
                title: "Track Your Health",
                description: "Monitor your mental and physical wellbeing with daily check-ins",
                siriCommand: "Log my mood in Personal Health"
            ),
            OnboardingFeature(
                icon: "phone.fill",
                title: "Crisis Support",
                description: "Access immediate help when you need it most",
                siriCommand: "Get crisis support in Personal Health"
            ),
            OnboardingFeature(
                icon: "chart.line.uptrend.xyaxis",
                title: "Health Insights",
                description: "Get AI-powered guidance based on your health patterns",
                siriCommand: "Should I see a doctor in Personal Health"
            )
        ],
        primaryColor: .pink,
        onComplete: {}
    )
}


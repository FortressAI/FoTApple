import SwiftUI

/// Animated Splash Screen - Beautiful Launch Experience
/// Shows app logo with elegant animations and transitions to onboarding
public struct AnimatedSplashScreen: View {
    let appName: String
    let appIcon: String
    let primaryColor: Color
    let secondaryColor: Color
    let onComplete: () -> Void
    
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var showTagline: Bool = false
    @State private var showLoader: Bool = false
    @State private var progress: Double = 0.0
    
    public init(
        appName: String,
        appIcon: String,
        primaryColor: Color,
        secondaryColor: Color,
        onComplete: @escaping () -> Void
    ) {
        self.appName = appName
        self.appIcon = appIcon
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [primaryColor, secondaryColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated particles
            ParticleSystem()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo
                Image(systemName: appIcon)
                    .font(.system(size: 100))
                    .foregroundStyle(.white)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // App Name
                Text(appName)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(logoOpacity)
                
                // Tagline
                if showTagline {
                    Text(tagline)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                
                // Loading indicator
                if showLoader {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(1.5)
                        
                        Text("Initializing AI...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                    .frame(height: 60)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private var tagline: String {
        switch appName {
        case "Personal Health":
            return "Your Mind & Body Companion"
        case "Field of Truth Clinician":
            return "AI-Powered Clinical Excellence"
        case "Field of Truth Legal":
            return "Intelligent Legal Practice"
        case "Field of Truth Education":
            return "Learning Reimagined"
        case "Field of Truth Parent":
            return "Confident Parenting, Together"
        default:
            return "Powered by Field of Truth"
        }
    }
    
    private func startAnimation() {
        // Phase 1: Logo appears (0-1s)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Phase 2: Tagline appears (1-1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                showTagline = true
            }
        }
        
        // Phase 3: Loading indicator (1.5-3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeIn(duration: 0.3)) {
                showLoader = true
            }
            
            // Simulate initialization
            simulateInitialization()
        }
        
        // Phase 4: Complete (3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                logoOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
            }
        }
    }
    
    private func simulateInitialization() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            progress += 0.05
            if progress >= 1.0 {
                timer.invalidate()
            }
        }
    }
}

/// Animated particle system for splash screen background
struct ParticleSystem: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .blur(radius: 2)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                animateParticles()
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<20).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 20...60)
            )
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 3.0)) {
                particles = particles.map { particle in
                    var updated = particle
                    updated.position.x += CGFloat.random(in: -50...50)
                    updated.position.y += CGFloat.random(in: -50...50)
                    return updated
                }
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
}

#Preview("Personal Health") {
    AnimatedSplashScreen(
        appName: "Personal Health",
        appIcon: "heart.fill",
        primaryColor: .pink,
        secondaryColor: .purple,
        onComplete: {}
    )
}

#Preview("Clinician") {
    AnimatedSplashScreen(
        appName: "Field of Truth Clinician",
        appIcon: "stethoscope",
        primaryColor: .blue,
        secondaryColor: .cyan,
        onComplete: {}
    )
}

#Preview("Legal") {
    AnimatedSplashScreen(
        appName: "Field of Truth Legal",
        appIcon: "scale.3d",
        primaryColor: .indigo,
        secondaryColor: .blue,
        onComplete: {}
    )
}

#Preview("Education") {
    AnimatedSplashScreen(
        appName: "Field of Truth Education",
        appIcon: "book.fill",
        primaryColor: .green,
        secondaryColor: .teal,
        onComplete: {}
    )
}

#Preview("Parent") {
    AnimatedSplashScreen(
        appName: "Field of Truth Parent",
        appIcon: "figure.2.and.child.holdinghands",
        primaryColor: .orange,
        secondaryColor: .yellow,
        onComplete: {}
    )
}


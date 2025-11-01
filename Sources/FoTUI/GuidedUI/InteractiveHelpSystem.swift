import SwiftUI

/// Interactive Help System - Context-Aware Guidance
/// Shows tooltips, help screens, and Siri-guided tours
public struct InteractiveHelpSystem: ViewModifier {
    let helpContext: HelpContext
    @StateObject private var helpManager = HelpManager.shared
    @State private var showTooltip: Bool = false
    @State private var showHelpSheet: Bool = false
    
    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if helpManager.tooltipsEnabled && showTooltip {
                    TooltipView(
                        title: helpContext.tooltipTitle,
                        message: helpContext.tooltipMessage,
                        siriCommand: helpContext.siriCommand
                    )
                    .transition(.scale.combined(with: .opacity))
                    .onTapGesture {
                        withAnimation {
                            showTooltip = false
                        }
                    }
                }
            }
            .onAppear {
                if helpManager.shouldShowTooltip(for: helpContext.id) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showTooltip = true
                        }
                        
                        // Auto-hide after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            withAnimation {
                                showTooltip = false
                            }
                        }
                    }
                    
                    helpManager.markTooltipShown(helpContext.id)
                }
            }
            .sheet(isPresented: $showHelpSheet) {
                HelpScreenView(context: helpContext)
            }
    }
}

/// Tooltip view with animated arrow
struct TooltipView: View {
    let title: String
    let message: String
    let siriCommand: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            if let command = siriCommand {
                HStack(spacing: 6) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                    
                    Text("Try: \"\(command)\"")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
        .frame(maxWidth: 300)
        .padding()
    }
}

/// Full help screen with searchable content
public struct HelpScreenView: View {
    let context: HelpContext
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var selectedTopic: HelpTopic?
    @StateObject private var voiceGuide = VoiceGuide()
    
    public var body: some View {
        NavigationView {
            List {
                // Search bar
                Section {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search help topics...", text: $searchText)
                    }
                }
                
                // Quick Actions
                Section("Quick Actions") {
                    ForEach(context.quickActions, id: \.title) { action in
                        QuickActionRow(action: action)
                    }
                }
                
                // Help Topics
                Section("Help Topics") {
                    ForEach(filteredTopics, id: \.title) { topic in
                        NavigationLink(destination: HelpTopicDetail(topic: topic, voiceGuide: voiceGuide)) {
                            HelpTopicRow(topic: topic)
                        }
                    }
                }
                
                // Siri Commands
                Section("Siri Commands") {
                    ForEach(context.siriCommands, id: \.command) { siriCommand in
                        SiriCommandRow(siriCommand: siriCommand)
                    }
                }
                
                // Video Tutorials
                if !context.videoTutorials.isEmpty {
                    Section("Video Tutorials") {
                        ForEach(context.videoTutorials, id: \.title) { video in
                            VideoTutorialRow(video: video)
                        }
                    }
                }
                
                // Contact Support
                Section {
                    Button(action: contactSupport) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                    
                    Button(action: startGuidedTour) {
                        Label("Start Guided Tour", systemImage: "figure.walk.motion")
                    }
                }
            }
            .navigationTitle("Help & Support")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #elseif os(macOS)
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
    
    private var filteredTopics: [HelpTopic] {
        if searchText.isEmpty {
            return context.helpTopics
        }
        return context.helpTopics.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func contactSupport() {
        // Open support email or in-app messaging
    }
    
    private func startGuidedTour() {
        // Launch guided tour
    }
}

struct HelpTopicDetail: View {
    let topic: HelpTopic
    @ObservedObject var voiceGuide: VoiceGuide
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Icon
                Image(systemName: topic.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                
                // Content
                Text(topic.content)
                    .font(.body)
                    .padding()
                
                // Steps (if any)
                if !topic.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(Array(topic.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Circle().fill(Color.blue))
                                
                                Text(step)
                                    .font(.body)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Related Siri command
                if let command = topic.relatedSiriCommand {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Try with Siri:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.blue)
                            Text("\"\(command)\"")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                // Listen button
                Button(action: {
                    voiceGuide.speak(topic.content)
                }) {
                    Label(
                        voiceGuide.isSpeaking ? "Listening..." : "Read Aloud",
                        systemImage: voiceGuide.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle(topic.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct QuickActionRow: View {
    let action: QuickAction
    
    var body: some View {
        Button(action: action.action) {
            HStack {
                Image(systemName: action.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.title)
                        .font(.headline)
                    Text(action.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct HelpTopicRow: View {
    let topic: HelpTopic
    
    var body: some View {
        HStack {
            Image(systemName: topic.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            Text(topic.title)
                .font(.body)
            
            Spacer()
        }
    }
}

struct SiriCommandRow: View {
    let siriCommand: SiriCommandHelp
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mic.fill")
                    .foregroundColor(.blue)
                Text("\"\(siriCommand.command)\"")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            Text(siriCommand.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct VideoTutorialRow: View {
    let video: VideoTutorial
    
    var body: some View {
        HStack {
            Image(systemName: "play.rectangle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.headline)
                Text(video.duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Help Manager

public class HelpManager: ObservableObject {
    public static let shared = HelpManager()
    
    @Published public var tooltipsEnabled: Bool = true
    private var shownTooltips: Set<String> = []
    
    private init() {
        // Load shown tooltips from UserDefaults
        if let saved = UserDefaults.standard.array(forKey: "shown_tooltips") as? [String] {
            shownTooltips = Set(saved)
        }
    }
    
    public func shouldShowTooltip(for id: String) -> Bool {
        return tooltipsEnabled && !shownTooltips.contains(id)
    }
    
    public func markTooltipShown(_ id: String) {
        shownTooltips.insert(id)
        UserDefaults.standard.set(Array(shownTooltips), forKey: "shown_tooltips")
    }
    
    public func resetTooltips() {
        shownTooltips.removeAll()
        UserDefaults.standard.removeObject(forKey: "shown_tooltips")
    }
}

// MARK: - Models

public struct HelpContext {
    public let id: String
    public let tooltipTitle: String
    public let tooltipMessage: String
    public let siriCommand: String?
    public let quickActions: [QuickAction]
    public let helpTopics: [HelpTopic]
    public let siriCommands: [SiriCommandHelp]
    public let videoTutorials: [VideoTutorial]
    
    public init(
        id: String,
        tooltipTitle: String,
        tooltipMessage: String,
        siriCommand: String? = nil,
        quickActions: [QuickAction] = [],
        helpTopics: [HelpTopic] = [],
        siriCommands: [SiriCommandHelp] = [],
        videoTutorials: [VideoTutorial] = []
    ) {
        self.id = id
        self.tooltipTitle = tooltipTitle
        self.tooltipMessage = tooltipMessage
        self.siriCommand = siriCommand
        self.quickActions = quickActions
        self.helpTopics = helpTopics
        self.siriCommands = siriCommands
        self.videoTutorials = videoTutorials
    }
}

public struct QuickAction {
    public let icon: String
    public let title: String
    public let description: String
    public let action: () -> Void
    
    public init(icon: String, title: String, description: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.description = description
        self.action = action
    }
}

public struct HelpTopic {
    public let icon: String
    public let title: String
    public let content: String
    public let steps: [String]
    public let relatedSiriCommand: String?
    
    public init(
        icon: String,
        title: String,
        content: String,
        steps: [String] = [],
        relatedSiriCommand: String? = nil
    ) {
        self.icon = icon
        self.title = title
        self.content = content
        self.steps = steps
        self.relatedSiriCommand = relatedSiriCommand
    }
}

public struct SiriCommandHelp {
    public let command: String
    public let description: String
    
    public init(command: String, description: String) {
        self.command = command
        self.description = description
    }
}

public struct VideoTutorial {
    public let title: String
    public let duration: String
    public let thumbnailURL: String
    public let videoURL: String
    
    public init(title: String, duration: String, thumbnailURL: String, videoURL: String) {
        self.title = title
        self.duration = duration
        self.thumbnailURL = thumbnailURL
        self.videoURL = videoURL
    }
}

// MARK: - View Extension

public extension View {
    func interactiveHelp(_ context: HelpContext) -> some View {
        modifier(InteractiveHelpSystem(helpContext: context))
    }
}


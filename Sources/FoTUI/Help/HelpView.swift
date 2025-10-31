//
//  HelpView.swift
//  FoT Apple Help System
//
//  Apple-compliant in-app help viewer for iOS/iPadOS
//

import SwiftUI
#if canImport(WebKit)
import WebKit
#endif

// MARK: - Help View (Main Interface)

/// Main help view that displays searchable help content
public struct HelpView: View {
    @StateObject private var viewModel = HelpViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Header
                    heroHeader
                    
                    // Search Bar
                    searchBar
                    
                    // Help Categories
                    if viewModel.searchQuery.isEmpty {
                        categoriesView
                    } else {
                        searchResultsView
                    }
                }
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #if os(iOS)
            .background(Color(uiColor: .systemGroupedBackground))
            #elseif os(macOS)
            .background(Color(nsColor: .controlBackgroundColor))
            #else
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            #endif
        }
        .task {
            await viewModel.loadHelpData()
        }
    }
    
    // MARK: - Hero Header
    
    private var heroHeader: some View {
        VStack(spacing: 16) {
            Image("FoT_core_256")
                .resizable()
                .frame(width: 128, height: 128)
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            Text("FoT Apple Help")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            
            Text("AI-Powered Decision Support")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search help...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
            
            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #elseif os(macOS)
        .background(Color(nsColor: .windowBackgroundColor))
        #else
        .background(Color.black)
        #endif
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding()
    }
    
    // MARK: - Categories View
    
    private var categoriesView: some View {
        LazyVStack(spacing: 24, pinnedViews: []) {
            ForEach(viewModel.categories, id: \.name) { category in
                HelpCategoryView(category: category) { topic in
                    viewModel.selectedTopic = topic
                }
            }
        }
        .padding()
        .sheet(item: $viewModel.selectedTopic) { topic in
            HelpTopicDetailView(topic: topic)
        }
    }
    
    // MARK: - Search Results View
    
    private var searchResultsView: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.searchResults) { result in
                HelpSearchResultRow(result: result) {
                    viewModel.selectedTopic = result
                }
            }
        }
        .padding()
    }
}

// MARK: - Help Category View

struct HelpCategoryView: View {
    let category: HelpCategory
    let onTopicTap: (SearchableHelpTopic) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Header
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(category.color)
                
                Text(category.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            // Topics
            ForEach(category.topics) { topic in
                Button(action: { onTopicTap(topic) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(topic.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let summary = topic.summary {
                                Text(summary)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    #if os(iOS)
                    .background(Color(uiColor: .systemBackground))
                    #elseif os(macOS)
                    .background(Color(nsColor: .windowBackgroundColor))
                    #else
                    .background(Color.black)
                    #endif
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                #if os(iOS)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                #elseif os(macOS)
                .fill(Color(nsColor: .controlBackgroundColor))
                #else
                .fill(Color.gray.opacity(0.2))
                #endif
        )
    }
}

// MARK: - Help Search Result Row

struct HelpSearchResultRow: View {
    let result: SearchableHelpTopic
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let summary = result.summary {
                        Text(summary)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            #if os(iOS)
            .background(Color(uiColor: .systemBackground))
            #elseif os(macOS)
            .background(Color(nsColor: .windowBackgroundColor))
            #else
            .background(Color.black)
            #endif
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Help Topic Detail View

struct HelpTopicDetailView: View {
    let topic: SearchableHelpTopic
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            #if canImport(WebKit) && canImport(UIKit)
            WebView(htmlFileName: topic.id)
                .navigationTitle(topic.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            #else
            VStack {
                Text(topic.title)
                    .font(.headline)
                Text("Web content not available on this platform")
                    .foregroundColor(.secondary)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
}

// MARK: - Web View (HTML Renderer)

#if canImport(WebKit) && canImport(UIKit)
struct WebView: UIViewRepresentable {
    let htmlFileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        loadHTML(in: webView)
    }
    
    private func loadHTML(in webView: WKWebView) {
        guard let htmlURL = Bundle.main.url(forResource: htmlFileName, withExtension: "html", subdirectory: "Help") else {
            let errorHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body { 
                        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                        padding: 20px;
                        text-align: center;
                    }
                </style>
            </head>
            <body>
                <h1>Help Content Not Available</h1>
                <p>The requested help topic could not be loaded.</p>
            </body>
            </html>
            """
            webView.loadHTMLString(errorHTML, baseURL: nil)
            return
        }
        
        webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
    }
}
#endif

// MARK: - View Model

@MainActor
class HelpViewModel: ObservableObject {
    @Published var categories: [HelpCategory] = []
    @Published var searchQuery: String = ""
    @Published var selectedTopic: SearchableHelpTopic?
    @Published var isLoading = false
    
    var searchResults: [SearchableHelpTopic] {
        guard !searchQuery.isEmpty else { return [] }
        
        let query = searchQuery.lowercased()
        var results: [SearchableHelpTopic] = []
        
        for category in categories {
            for topic in category.topics {
                if topic.title.lowercased().contains(query) ||
                   topic.summary?.lowercased().contains(query) == true ||
                   topic.keywords.contains(where: { $0.lowercased().contains(query) }) {
                    results.append(topic)
                }
            }
        }
        
        return results
    }
    
    func loadHelpData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load help data from JSON
        guard let url = Bundle.main.url(forResource: "help-data", withExtension: "json", subdirectory: "Help"),
              let data = try? Data(contentsOf: url),
              let helpData = try? JSONDecoder().decode(HelpData.self, from: data) else {
            // Fallback to default categories
            loadDefaultCategories()
            return
        }
        
        categories = parseHelpData(helpData)
    }
    
    private func parseHelpData(_ data: HelpData) -> [HelpCategory] {
        var categories: [HelpCategory] = []
        
        for (categoryName, topics) in data.categories {
            let icon = iconForCategory(categoryName)
            let color = colorForCategory(categoryName)
            
            let helpTopics = topics.map { topicData in
                SearchableHelpTopic(
                    id: topicData.id,
                    title: topicData.title,
                    summary: nil,
                    keywords: topicData.keywords
                )
            }
            
            categories.append(HelpCategory(
                name: categoryName,
                icon: icon,
                color: color,
                topics: helpTopics
            ))
        }
        
        return categories.sorted { $0.name < $1.name }
    }
    
    private func iconForCategory(_ name: String) -> String {
        switch name.lowercased() {
        case "getting started": return "play.circle.fill"
        case "apps": return "square.stack.3d.up.fill"
        case "compliance": return "checkmark.shield.fill"
        case "technical": return "gear"
        case "support": return "questionmark.circle.fill"
        default: return "book.fill"
        }
    }
    
    private func colorForCategory(_ name: String) -> Color {
        switch name.lowercased() {
        case "getting started": return .green
        case "apps": return .blue
        case "compliance": return .orange
        case "technical": return .purple
        case "support": return .red
        default: return .gray
        }
    }
    
    private func loadDefaultCategories() {
        categories = [
            HelpCategory(
                name: "Getting Started",
                icon: "star.fill",
                color: Color.green,
                topics: [
                    SearchableHelpTopic(id: "quick-start", title: "Quick Start Guide", summary: "Get started with FoT Apple in 5 minutes", keywords: ["start", "begin", "setup"]),
                    SearchableHelpTopic(id: "installation", title: "Installation", summary: "How to install FoT Apple apps", keywords: ["install", "download", "testflight"])
                ]
            ),
            HelpCategory(
                name: "Apps",
                icon: "square.stack.3d.up.fill",
                color: Color.blue,
                topics: [
                    SearchableHelpTopic(id: "clinician-app", title: "Clinician App", summary: "Medical decision support for healthcare professionals", keywords: ["medical", "doctor", "clinician"]),
                    SearchableHelpTopic(id: "personal-health-app", title: "Personal Health", summary: "Your health, your proof", keywords: ["health", "wellness", "personal"]),
                    SearchableHelpTopic(id: "legal-us-app", title: "Legal US App", summary: "Legal practice management", keywords: ["legal", "attorney", "lawyer"]),
                    SearchableHelpTopic(id: "education-k18-app", title: "Education K-18", summary: "Adaptive learning for students", keywords: ["education", "student", "learning"])
                ]
            ),
            HelpCategory(
                name: "Support",
                icon: "questionmark.circle.fill",
                color: Color.red,
                topics: [
                    SearchableHelpTopic(id: "faq", title: "FAQ", summary: "Frequently asked questions", keywords: ["question", "faq", "help"]),
                    SearchableHelpTopic(id: "contact", title: "Contact Support", summary: "Get help from our team", keywords: ["contact", "support", "help"])
                ]
            )
        ]
    }
}

// MARK: - Data Models

struct HelpCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let topics: [SearchableHelpTopic]
}

struct SearchableHelpTopic: Identifiable {
    let id: String
    let title: String
    let summary: String?
    let keywords: [String]
}

struct HelpData: Codable {
    let version: String
    let title: String
    let categories: [String: [TopicData]]
}

struct TopicData: Codable {
    let id: String
    let title: String
    let keywords: [String]
}

// MARK: - Preview

#if DEBUG
struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
#endif


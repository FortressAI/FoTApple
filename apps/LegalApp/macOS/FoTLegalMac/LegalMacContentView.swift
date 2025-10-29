// LegalMacContentView.swift
// Main UI for FoT Legal US macOS App

import SwiftUI
import FoTUI
import FoTLegalUS

struct LegalMacContentView: View {
    @EnvironmentObject var appState: LegalAppState
    @State private var selectedView: ViewType = .showcase
    
    enum ViewType {
        case showcase, cases, research, analytics
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedView) {
                NavigationLink(value: ViewType.showcase) {
                    Label("Showcase", systemImage: "sparkles")
                }
                
                NavigationLink(value: ViewType.cases) {
                    Label("Cases", systemImage: "folder.fill")
                }
                
                NavigationLink(value: ViewType.research) {
                    Label("Legal Research", systemImage: "books.vertical.fill")
                }
                
                NavigationLink(value: ViewType.analytics) {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                
                Section("Recent Cases") {
                    ForEach(appState.cases.prefix(5)) { legalCase in
                        NavigationLink(value: legalCase) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(legalCase.client)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(legalCase.caseNumber)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("FoT Legal US")
            .listStyle(.sidebar)
        } detail: {
            // Main content area
            Group {
                switch selectedView {
                case .showcase:
                    GlassShowcaseView(domain: .legal)
                case .cases:
                    CasesView()
                case .research:
                    LegalResearchView()
                case .analytics:
                    AnalyticsView()
                }
            }
        }
    }
}

// MARK: - Cases View

struct CasesView: View {
    @EnvironmentObject var appState: LegalAppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Case Management")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("\(appState.cases.count) active cases")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Label("New Case", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                // Cases grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))], spacing: 20) {
                    ForEach(appState.cases) { legalCase in
                        CaseCard(case: legalCase)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CaseCard: View {
    let `case`: LegalCase
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(`case`.client)
                        .font(.headline)
                    Spacer()
                    StatusBadge(status: `case`.status)
                }
                
                Text(`case`.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(`case`.caseNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                HStack {
                    Label("Opened", systemImage: "calendar")
                        .font(.caption)
                    Spacer()
                    Text(`case`.dateOpened, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

struct StatusBadge: View {
    let status: CaseStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
    
    var color: Color {
        switch status {
        case .active: return .green
        case .pending: return .orange
        case .closed: return .gray
        }
    }
}

// MARK: - Legal Research View

struct LegalResearchView: View {
    @State private var searchQuery = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Legal Research")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Constitutional law analysis & case precedents")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search legal precedents, statutes, regulations...", text: $searchQuery)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            
            // Research areas
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) {
                ResearchCard(
                    title: "Constitutional Law",
                    icon: "doc.text.fill",
                    description: "US Constitution analysis and interpretation"
                )
                ResearchCard(
                    title: "Federal Regulations",
                    icon: "building.columns.fill",
                    description: "Code of Federal Regulations (CFR) search"
                )
                ResearchCard(
                    title: "Case Precedents",
                    icon: "book.closed.fill",
                    description: "Supreme Court and Circuit Court decisions"
                )
                ResearchCard(
                    title: "Statutes",
                    icon: "scroll.fill",
                    description: "US Code and state statutes"
                )
            }
            .padding()
            
            Spacer()
        }
    }
}

struct ResearchCard: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

// MARK: - Analytics View

struct AnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Practice Analytics")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Insights and performance metrics")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    MetricCard(title: "Active Cases", value: "12", trend: "+2", icon: "folder.fill")
                    MetricCard(title: "Billable Hours", value: "156", trend: "+8%", icon: "clock.fill")
                    MetricCard(title: "Win Rate", value: "87%", trend: "+3%", icon: "chart.line.uptrend.xyaxis")
                    MetricCard(title: "Client Satisfaction", value: "4.8/5", trend: "↑", icon: "star.fill")
                }
                .padding()
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let trend: String
    let icon: String
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.accentColor)
                    Spacer()
                    Text(trend)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}


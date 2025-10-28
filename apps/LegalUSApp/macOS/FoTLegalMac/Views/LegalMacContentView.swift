// LegalMacContentView.swift
// Main macOS interface for Legal US app

import SwiftUI
import FoTLegalUS

struct LegalMacContentView: View {
    @EnvironmentObject var appState: LegalMacAppState
    @State private var selectedTab: SidebarItem = .cases
    
    enum SidebarItem: String, CaseIterable {
        case cases = "Cases"
        case deadlines = "Deadlines"
        case citations = "Citations"
        case calendar = "Calendar"
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, id: \.self, selection: $selectedTab) { item in
                Label(item.rawValue, systemImage: icon(for: item))
            }
            .navigationTitle("Legal US")
        } content: {
            // Middle panel - Case list
            CaseListMac()
        } detail: {
            // Detail panel - Case details
            if let legalCase = appState.selectedCase {
                CaseDetailMac(legalCase: legalCase)
            } else {
                Text("Select a case")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private func icon(for item: SidebarItem) -> String {
        switch item {
        case .cases: return "folder.fill"
        case .deadlines: return "calendar.badge.exclamationmark"
        case .citations: return "book.fill"
        case .calendar: return "calendar"
        }
    }
}

struct CaseListMac: View {
    @EnvironmentObject var appState: LegalMacAppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search cases", text: $appState.searchText)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color(.textBackgroundColor))
            
            Divider()
            
            // Case list
            List(appState.filteredCases, selection: $appState.selectedCase) { legalCase in
                CaseRowMac(legalCase: legalCase)
                    .tag(legalCase)
            }
            .listStyle(.sidebar)
        }
        .frame(minWidth: 300)
        .navigationTitle("Cases")
    }
}

struct CaseRowMac: View {
    let legalCase: LegalCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(legalCase.caseNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                StatusBadgeMac(status: legalCase.status)
            }
            
            Text(legalCase.title)
                .font(.headline)
            
            Text("Client: \(legalCase.clientName)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(legalCase.caseType.rawValue, systemImage: "scale.3d")
                    .font(.caption)
                Spacer()
                if let nextDeadline = legalCase.deadlines.filter({ !$0.completed }).sorted(by: { $0.dueDate < $1.dueDate }).first {
                    Text("\(abs(nextDeadline.daysUntil)) days")
                        .font(.caption)
                        .foregroundColor(nextDeadline.isOverdue ? .red : .orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadgeMac: View {
    let status: CaseStatus
    
    var color: Color {
        switch status {
        case .active: return .blue
        case .pending: return .orange
        case .closed: return .gray
        case .settled: return .green
        case .dismissed: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

struct CaseDetailMac: View {
    let legalCase: LegalCase
    @State private var selectedDetailTab: DetailTab = .overview
    
    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case deadlines = "Deadlines"
        case documents = "Documents"
        case citations = "Citations"
        case notes = "Notes"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Case header
            CaseHeaderMac(legalCase: legalCase)
            
            Divider()
            
            // Tab picker
            Picker("Section", selection: $selectedDetailTab) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            ScrollView {
                switch selectedDetailTab {
                case .overview:
                    OverviewSectionLegal(legalCase: legalCase)
                case .deadlines:
                    DeadlinesSectionMac(deadlines: legalCase.deadlines)
                case .documents:
                    DocumentsSectionLegal(documents: legalCase.documents)
                case .citations:
                    CitationsSectionMac(citations: legalCase.citations)
                case .notes:
                    NotesSectionMac(notes: legalCase.notes)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: {}) {
                    Label("Add Deadline", systemImage: "calendar.badge.plus")
                }
                Button(action: {}) {
                    Label("Export Brief", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

struct CaseHeaderMac: View {
    let legalCase: LegalCase
    
    var body: some View {
        HStack(spacing: 20) {
            // Case icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 80, height: 80)
                Image(systemName: "scale.3d")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(legalCase.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 16) {
                    Label(legalCase.caseNumber, systemImage: "number")
                    Label(legalCase.clientName, systemImage: "person")
                    Label(legalCase.caseType.rawValue, systemImage: "scale.3d")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status & Deadlines
            VStack(alignment: .trailing, spacing: 8) {
                StatusBadgeMac(status: legalCase.status)
                
                if let nextDeadline = legalCase.deadlines.filter({ !$0.completed }).sorted(by: { $0.dueDate < $1.dueDate }).first {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Next Deadline:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(nextDeadline.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("\(abs(nextDeadline.daysUntil)) days")
                            .font(.caption)
                            .foregroundColor(nextDeadline.isOverdue ? .red : .orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
}

struct OverviewSectionLegal: View {
    let legalCase: LegalCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox("Case Information") {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                    GridRow {
                        Text("Case Number:")
                            .foregroundColor(.secondary)
                        Text(legalCase.caseNumber)
                    }
                    GridRow {
                        Text("Filing Date:")
                            .foregroundColor(.secondary)
                        Text(formatDate(legalCase.filingDate))
                    }
                    GridRow {
                        Text("Case Type:")
                            .foregroundColor(.secondary)
                        Text(legalCase.caseType.rawValue)
                    }
                    GridRow {
                        Text("Status:")
                            .foregroundColor(.secondary)
                        Text(legalCase.status.rawValue)
                    }
                }
                .padding()
            }
            
            GroupBox("Jurisdiction") {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                    GridRow {
                        Text("Court:")
                            .foregroundColor(.secondary)
                        Text(legalCase.jurisdiction.court)
                    }
                    GridRow {
                        Text("District:")
                            .foregroundColor(.secondary)
                        Text(legalCase.jurisdiction.district)
                    }
                    GridRow {
                        Text("State:")
                            .foregroundColor(.secondary)
                        Text(legalCase.jurisdiction.state)
                    }
                }
                .padding()
            }
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct DeadlinesSectionMac: View {
    let deadlines: [Deadline]
    
    var sortedDeadlines: [Deadline] {
        deadlines.sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(sortedDeadlines) { deadline in
                GroupBox {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(deadline.title)
                                .font(.headline)
                            Text(deadline.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let rule = deadline.ruleReference {
                                Text("Rule: \(rule)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            Text("Due: \(formatDate(deadline.dueDate))")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            if deadline.completed {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title)
                            } else {
                                Text("\(abs(deadline.daysUntil))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(deadline.isOverdue ? .red : .orange)
                                Text(deadline.isOverdue ? "overdue" : "days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            }
            
            Button(action: {}) {
                Label("Calculate New Deadlines", systemImage: "calendar.badge.plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DocumentsSectionLegal: View {
    let documents: [LegalDocument]
    
    var body: some View {
        VStack(spacing: 20) {
            if documents.isEmpty {
                GroupBox {
                    Text("No documents yet")
                        .foregroundColor(.secondary)
                        .padding()
                }
            } else {
                ForEach(documents) { document in
                    GroupBox {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(document.title)
                                    .font(.headline)
                                Text(document.documentType.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let filedDate = document.filedDate {
                                    Text("Filed: \(formatDate(filedDate))")
                                        .font(.caption)
                                }
                            }
                            Spacer()
                            Button(action: {}) {
                                Label("Open", systemImage: "arrow.up.right")
                            }
                        }
                        .padding()
                    }
                }
            }
            
            Button(action: {}) {
                Label("Upload Document", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct CitationsSectionMac: View {
    let citations: [Citation]
    
    var body: some View {
        VStack(spacing: 20) {
            if citations.isEmpty {
                GroupBox {
                    Text("No citations yet")
                        .foregroundColor(.secondary)
                        .padding()
                }
            } else {
                ForEach(citations) { citation in
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(citation.caseTitle)
                                .font(.headline)
                            Text(citation.citationText)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            HStack {
                                Text("\(citation.court) (\(citation.year))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            if !citation.relevance.isEmpty {
                                Text("Relevance: \(citation.relevance)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                    }
                }
            }
            
            Button(action: {}) {
                Label("Add Citation", systemImage: "book.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct NotesSectionMac: View {
    let notes: String
    
    var body: some View {
        VStack(spacing: 20) {
            GroupBox("Case Notes") {
                if notes.isEmpty {
                    Text("No notes yet")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    Text(notes)
                        .padding()
                }
            }
        }
        .padding()
    }
}

struct CaseDetailWindow: View {
    let legalCase: LegalCase
    
    var body: some View {
        CaseDetailMac(legalCase: legalCase)
            .frame(minWidth: 800, minHeight: 600)
    }
}

struct LegalSettingsView: View {
    var body: some View {
        TabView {
            LegalGeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            LegalJurisdictionSettings()
                .tabItem {
                    Label("Jurisdiction", systemImage: "location")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct LegalGeneralSettings: View {
    @State private var defaultCourt = "U.S. District Court"
    
    var body: some View {
        Form {
            TextField("Default Court:", text: $defaultCourt)
            Divider()
            Button("Reset to Defaults") {}
        }
        .padding()
    }
}

struct LegalJurisdictionSettings: View {
    var body: some View {
        Form {
            Text("Default jurisdiction settings")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}


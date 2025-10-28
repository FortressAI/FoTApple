// LegalContentView.swift
// Main content view for Legal US app

import SwiftUI
import FoTLegalUS

struct LegalContentView: View {
    @EnvironmentObject var appState: LegalAppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CaseListView()
                .tabItem {
                    Label("Cases", systemImage: "folder.fill")
                }
                .tag(0)
            
            if appState.currentCase != nil {
                CaseDetailView()
                    .tabItem {
                        Label("Details", systemImage: "doc.text.fill")
                    }
                    .tag(1)
            }
        }
    }
}

struct CaseListView: View {
    @EnvironmentObject var appState: LegalAppState
    @State private var searchText = ""
    
    var filteredCases: [LegalCase] {
        if searchText.isEmpty {
            return appState.cases
        }
        return appState.cases.filter { legalCase in
            legalCase.title.localizedCaseInsensitiveContains(searchText) ||
            legalCase.caseNumber.localizedCaseInsensitiveContains(searchText) ||
            legalCase.clientName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredCases) { legalCase in
                CaseRowView(legalCase: legalCase)
                    .onTapGesture {
                        appState.selectCase(legalCase)
                    }
            }
            .searchable(text: $searchText, prompt: "Search cases")
            .navigationTitle("Legal Cases")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct CaseRowView: View {
    let legalCase: LegalCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(legalCase.caseNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                StatusBadge(status: legalCase.status)
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
                Text(legalCase.jurisdiction.court)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Upcoming deadlines
            if let nextDeadline = legalCase.deadlines.filter({ !$0.completed }).sorted(by: { $0.dueDate < $1.dueDate }).first {
                HStack {
                    Image(systemImage: "calendar")
                        .foregroundColor(nextDeadline.isOverdue ? .red : .orange)
                    Text(nextDeadline.title)
                        .font(.caption)
                    Text("- \(nextDeadline.daysUntil) days")
                        .font(.caption)
                        .foregroundColor(nextDeadline.isOverdue ? .red : .orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
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

struct CaseDetailView: View {
    @EnvironmentObject var appState: LegalAppState
    @State private var selectedSection: DetailSection = .overview
    
    enum DetailSection: String, CaseIterable {
        case overview = "Overview"
        case deadlines = "Deadlines"
        case documents = "Documents"
        case citations = "Citations"
    }
    
    var body: some View {
        NavigationStack {
            if let legalCase = appState.currentCase {
                VStack(spacing: 0) {
                    // Case header
                    CaseHeaderView(legalCase: legalCase)
                    
                    // Section picker
                    Picker("Section", selection: $selectedSection) {
                        ForEach(DetailSection.allCases, id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Section content
                    ScrollView {
                        switch selectedSection {
                        case .overview:
                            OverviewSection(legalCase: legalCase)
                        case .deadlines:
                            DeadlinesSection(deadlines: legalCase.deadlines)
                        case .documents:
                            DocumentsSection(documents: legalCase.documents)
                        case .citations:
                            CitationsSection(citations: legalCase.citations)
                        }
                    }
                }
                .navigationTitle(legalCase.caseNumber)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct CaseHeaderView: View {
    let legalCase: LegalCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(legalCase.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Client: \(legalCase.clientName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge(status: legalCase.status)
            }
            
            HStack {
                Label(legalCase.caseType.rawValue, systemImage: "scale.3d")
                Spacer()
                Text(legalCase.jurisdiction.court)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct OverviewSection: View {
    let legalCase: LegalCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRow(label: "Case Number", value: legalCase.caseNumber)
            InfoRow(label: "Filing Date", value: formatDate(legalCase.filingDate))
            InfoRow(label: "Court", value: legalCase.jurisdiction.court)
            InfoRow(label: "District", value: legalCase.jurisdiction.district)
            InfoRow(label: "State", value: legalCase.jurisdiction.state)
            
            if !legalCase.notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.headline)
                    Text(legalCase.notes)
                        .font(.body)
                }
            }
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct DeadlinesSection: View {
    let deadlines: [Deadline]
    
    var sortedDeadlines: [Deadline] {
        deadlines.sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(sortedDeadlines) { deadline in
                DeadlineCard(deadline: deadline)
            }
        }
        .padding()
    }
}

struct DeadlineCard: View {
    let deadline: Deadline
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(deadline.title)
                    .font(.headline)
                Spacer()
                if deadline.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if deadline.isOverdue {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
            }
            
            Text(deadline.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("Due: \(formatDate(deadline.dueDate))", systemImage: "calendar")
                    .font(.caption)
                Spacer()
                if !deadline.completed {
                    Text("\(abs(deadline.daysUntil)) days \(deadline.isOverdue ? "overdue" : "remaining")")
                        .font(.caption)
                        .foregroundColor(deadline.isOverdue ? .red : .orange)
                }
            }
            
            if let rule = deadline.ruleReference {
                Text("Rule: \(rule)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DocumentsSection: View {
    let documents: [LegalDocument]
    
    var body: some View {
        VStack(spacing: 12) {
            if documents.isEmpty {
                Text("No documents yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(documents) { document in
                    DocumentCard(document: document)
                }
            }
        }
        .padding()
    }
}

struct DocumentCard: View {
    let document: LegalDocument
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(document.title)
                    .font(.headline)
                Spacer()
                Text(document.documentType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            if !document.summary.isEmpty {
                Text(document.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let filedDate = document.filedDate {
                Text("Filed: \(formatDate(filedDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct CitationsSection: View {
    let citations: [Citation]
    
    var body: some View {
        VStack(spacing: 12) {
            if citations.isEmpty {
                Text("No citations yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(citations) { citation in
                    CitationCard(citation: citation)
                }
            }
        }
        .padding()
    }
}

struct CitationCard: View {
    let citation: Citation
    
    var body: some View {
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
            
            if !citation.bluebookFormat.isEmpty {
                Text("Bluebook: \(citation.bluebookFormat)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}


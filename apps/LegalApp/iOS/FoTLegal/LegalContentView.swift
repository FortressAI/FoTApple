// LegalContentView.swift
// Main UI for FoT Legal US App

import SwiftUI
import FoTUI
import FoTLegalUS

struct LegalContentView: View {
    @EnvironmentObject var appState: LegalAppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GlassShowcaseView(
                domain: .legal,
                appIconName: "FoT_legal_AppIcon_1024",
                badgeIconName: "FoT_legal_Badge_128",
                appDisplayName: "FoT Legal US"
            )
            .tabItem {
                Label("Showcase", systemImage: "sparkles")
            }
            .tag(0)
            
            NavigationStack {
                CaseListView()
            }
            .tabItem {
                Label("Cases", systemImage: "folder.fill")
            }
            .tag(1)
            
            if appState.currentCase != nil {
                NavigationStack {
                    CaseDetailView()
                }
                .tabItem {
                    Label("Case", systemImage: "doc.text.fill")
                }
                .tag(2)
            }
        }
    }
}

// MARK: - Case List View

struct CaseListView: View {
    @EnvironmentObject var appState: LegalAppState
    
    var body: some View {
        List {
            ForEach(appState.cases) { legalCase in
                Button(action: {
                    appState.selectCase(legalCase)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(legalCase.title)
                                .font(.headline)
                            Text(legalCase.caseNumber)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(legalCase.caseType.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(caseTypeColor(legalCase.caseType).opacity(0.2))
                                    .foregroundColor(caseTypeColor(legalCase.caseType))
                                    .cornerRadius(4)
                                
                                Text(legalCase.status.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(statusColor(legalCase.status).opacity(0.2))
                                    .foregroundColor(statusColor(legalCase.status))
                                    .cornerRadius(4)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("My Cases")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }
    
    func caseTypeColor(_ type: LegalCase.CaseType) -> Color {
        switch type {
        case .employment: return .blue
        case .personalInjury: return .red
        case .family: return .purple
        case .criminal: return .orange
        case .civilRights: return .green
        case .contract: return .indigo
        case .other: return .gray
        }
    }
    
    func statusColor(_ status: LegalCase.CaseStatus) -> Color {
        switch status {
        case .pending: return .yellow
        case .active: return .green
        case .settled: return .blue
        case .closed: return .gray
        case .appealed: return .orange
        }
    }
}

// MARK: - Case Detail View

struct CaseDetailView: View {
    @EnvironmentObject var appState: LegalAppState
    
    var body: some View {
        if let legalCase = appState.currentCase {
            List {
                Section("Case Information") {
                    HStack {
                        Text("Case Number")
                        Spacer()
                        Text(legalCase.caseNumber)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(legalCase.caseType.rawValue)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(legalCase.status.rawValue)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Filing Date")
                        Spacer()
                        Text(legalCase.filingDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Description") {
                    Text(legalCase.description)
                }
                
                Section("Timeline") {
                    ForEach(legalCase.timeline.sorted(by: { $0.date > $1.date })) { event in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(event.description)
                                    .font(.subheadline)
                                Text(event.eventType.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {}) {
                        Label("Add Timeline Event", systemImage: "plus.circle")
                    }
                }
                
                Section("Evidence") {
                    if legalCase.evidence.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("No evidence collected yet")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    } else {
                        ForEach(legalCase.evidence) { item in
                            HStack {
                                Image(systemName: evidenceIcon(item.type))
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.headline)
                                    Text(item.type.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if item.receiptID != nil {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    
                    Button(action: {}) {
                        Label("Capture Evidence", systemImage: "camera.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Section("Notes") {
                    Text(legalCase.notes)
                    Button(action: {}) {
                        Label("Edit Notes", systemImage: "pencil")
                    }
                }
                
                Section("Actions") {
                    Button(action: {}) {
                        Label("Generate Case Summary", systemImage: "doc.text")
                    }
                    Button(action: {}) {
                        Label("Export Evidence", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {}) {
                        Label("Share with Attorney", systemImage: "person.2")
                    }
                }
            }
            .navigationTitle(legalCase.title)
        }
    }
    
    func evidenceIcon(_ type: Evidence.EvidenceType) -> String {
        switch type {
        case .document: return "doc.fill"
        case .photo: return "photo.fill"
        case .video: return "video.fill"
        case .audio: return "waveform"
        case .testimony: return "text.quote"
        case .physical: return "cube.fill"
        }
    }
}


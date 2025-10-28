// LegalWatchContentView.swift
// Main watch interface for Legal US app

import SwiftUI
import FoTLegalUS

struct LegalWatchContentView: View {
    @EnvironmentObject var appState: LegalWatchAppState
    
    var body: some View {
        NavigationStack {
            List {
                // Deadlines
                Section {
                    NavigationLink(destination: DeadlinesWatchView()) {
                        Label("Deadlines", systemImage: "calendar.badge.exclamationmark")
                            .foregroundColor(.red)
                            .badge(urgentDeadlineCount)
                    }
                } header: {
                    Text("Urgent")
                }
                
                // Recent Cases
                Section("Recent Cases") {
                    ForEach(appState.recentCases) { legalCase in
                        NavigationLink(destination: CaseDetailWatch(legalCase: legalCase)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(legalCase.caseNumber)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(legalCase.title)
                                    .font(.headline)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Legal")
        }
    }
    
    private var urgentDeadlineCount: Int {
        appState.upcomingDeadlines.filter { $0.daysUntil <= 7 }.count
    }
}

struct DeadlinesWatchView: View {
    @EnvironmentObject var appState: LegalWatchAppState
    
    var sortedDeadlines: [Deadline] {
        appState.upcomingDeadlines.sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        List(sortedDeadlines) { deadline in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(deadline.title)
                        .font(.headline)
                    Spacer()
                    if deadline.isOverdue {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
                
                Text("\(abs(deadline.daysUntil)) days \(deadline.isOverdue ? "overdue" : "remaining")")
                    .font(.caption)
                    .foregroundColor(deadline.isOverdue ? .red : .orange)
                
                if let rule = deadline.ruleReference {
                    Text(rule)
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Deadlines")
    }
}

struct CaseDetailWatch: View {
    let legalCase: LegalCase
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Case Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(legalCase.caseNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(legalCase.title)
                        .font(.headline)
                    Text(legalCase.clientName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Status
                HStack {
                    Text("Status:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(legalCase.status.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                // Case Type
                HStack {
                    Text("Type:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(legalCase.caseType.rawValue)
                        .font(.caption)
                }
                
                // Court
                VStack(alignment: .leading, spacing: 2) {
                    Text("Court:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(legalCase.jurisdiction.court)
                        .font(.caption2)
                }
                
                // Next Deadline
                if let nextDeadline = legalCase.deadlines.filter({ !$0.completed }).sorted(by: { $0.dueDate < $1.dueDate }).first {
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Next Deadline", systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(nextDeadline.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("\(abs(nextDeadline.daysUntil)) days")
                            .font(.caption2)
                            .foregroundColor(nextDeadline.isOverdue ? .red : .orange)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Case")
        .navigationBarTitleDisplayMode(.inline)
    }
}


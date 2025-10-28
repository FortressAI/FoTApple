// EducationContentView.swift
// Main UI for FoT Education K-18 App

import SwiftUI
import FoTUI
import FoTEducationK18

struct EducationContentView: View {
    @EnvironmentObject var appState: EducationAppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GlassShowcaseView(domain: .education)
            .tabItem {
                Label("Showcase", systemImage: "sparkles")
            }
            .tag(0)
            
            NavigationStack {
                StudentListView()
            }
            .tabItem {
                Label("Students", systemImage: "person.3.fill")
            }
            .tag(1)
            
            if appState.currentStudent != nil {
                NavigationStack {
                    StudentDetailView()
                }
                .tabItem {
                    Label("Student", systemImage: "person.fill")
                }
                .tag(2)
            }
        }
    }
}

// MARK: - Student List View

struct StudentListView: View {
    @EnvironmentObject var appState: EducationAppState
    
    var body: some View {
        List {
            ForEach(appState.students) { student in
                Button(action: {
                    appState.selectStudent(student)
                }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(student.firstName) \(student.lastName)")
                            .font(.headline)
                        Text("Grade: \(student.gradeLevel.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if student.learningProfile.accommodations.contains(where: { $0.lowercased().contains("iep") }) {
                            Text("IEP")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
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
        .navigationTitle("My Students")
    }
}

// MARK: - Student Detail View

struct StudentDetailView: View {
    @EnvironmentObject var appState: EducationAppState
    
    var body: some View {
        if let student = appState.currentStudent {
            List {
                Section("Student Information") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("\(student.firstName) \(student.lastName)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Student ID")
                        Spacer()
                        Text(student.studentId)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Grade Level")
                        Spacer()
                        Text(student.gradeLevel.rawValue)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Age")
                        Spacer()
                        Text("\(calculateAge(from: student.dateOfBirth)) years")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Learning Profile") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Strengths")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        ForEach(student.learningProfile.strengths, id: \.self) { strength in
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text(strength)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Challenges")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        ForEach(student.learningProfile.challenges, id: \.self) { challenge in
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text(challenge)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accommodations")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        ForEach(student.learningProfile.accommodations, id: \.self) { accommodation in
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(accommodation)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if student.learningProfile.accommodations.contains(where: { $0.lowercased().contains("iep") }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                            Text("IEP Accommodations Active")
                                .fontWeight(.medium)
                            Spacer()
                            Button("View") {
                                // Action to view IEP
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Virtue Scores (Aristotelian Virtues)") {
                    VirtueScoreRow(virtue: "Justice", score: student.virtueScores.justice)
                    VirtueScoreRow(virtue: "Temperance", score: student.virtueScores.temperance)
                    VirtueScoreRow(virtue: "Prudence", score: student.virtueScores.prudence)
                    VirtueScoreRow(virtue: "Fortitude", score: student.virtueScores.fortitude)
                    
                    HStack {
                        Text("Average")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(String(format: "%.2f", student.virtueScores.average))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                }
                
                Section("Assignments") {
                    if student.assignments.isEmpty {
                        Text("No assignments yet")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(student.assignments) { assignment in
                            VStack(alignment: .leading) {
                                Text(assignment.title)
                                    .font(.headline)
                                Text(assignment.subject.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: {}) {
                        Label("Add Assignment", systemImage: "plus.circle")
                    }
                }
                
                Section("Assessments") {
                    if student.assessments.isEmpty {
                        Text("No assessments yet")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(student.assessments) { assessment in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(assessment.title)
                                        .font(.headline)
                                    Text(assessment.subject.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(Int(assessment.score))%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(scoreColor(assessment.score))
                            }
                        }
                    }
                    
                    Button(action: {}) {
                        Label("Add Assessment", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("\(student.firstName) \(student.lastName)")
        }
    }
    
    func calculateAge(from dateOfBirth: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year ?? 0
    }
    
    func scoreColor(_ score: Double) -> Color {
        switch score {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .orange
        default: return .red
        }
    }
}

struct VirtueScoreRow: View {
    let virtue: String
    let score: Double
    
    var body: some View {
        HStack {
            Text(virtue)
            Spacer()
            ProgressView(value: score, total: 1.0)
                .frame(width: 100)
            Text(String(format: "%.2f", score))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40)
        }
    }
}


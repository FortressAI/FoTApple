// EducationContentView.swift
// Main content view for Education K-18 app

import SwiftUI
import FoTEducationK18

struct EducationContentView: View {
    @EnvironmentObject var appState: EducationAppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StudentListView()
                .tabItem {
                    Label("Students", systemImage: "person.3.fill")
                }
                .tag(0)
            
            if appState.currentStudent != nil {
                StudentDetailView()
                    .tabItem {
                        Label("Details", systemImage: "book.fill")
                    }
                    .tag(1)
            }
        }
    }
}

struct StudentListView: View {
    @EnvironmentObject var appState: EducationAppState
    @State private var searchText = ""
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return appState.students
        }
        return appState.students.filter { student in
            student.fullName.localizedCaseInsensitiveContains(searchText) ||
            student.studentId.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredStudents) { student in
                StudentRowView(student: student)
                    .onTapGesture {
                        appState.selectStudent(student)
                    }
            }
            .searchable(text: $searchText, prompt: "Search students")
            .navigationTitle("Students")
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

struct StudentRowView: View {
    let student: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(student.fullName)
                    .font(.headline)
                Spacer()
                Text(student.gradeLevel.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text("ID: \(student.studentId)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Assignments due
            if let nextAssignment = student.assignments.filter({ $0.status != .completed }).sorted(by: { $0.dueDate < $1.dueDate }).first {
                HStack {
                    Image(systemName: "doc.fill")
                    Text(nextAssignment.title)
                        .font(.caption)
                    if nextAssignment.isOverdue {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
                .foregroundColor(nextAssignment.isOverdue ? .red : .orange)
            }
            
            // Virtue scores preview
            HStack {
                VirtueBar(label: "J", value: student.virtueScores.justice, color: .blue)
                VirtueBar(label: "T", value: student.virtueScores.temperance, color: .green)
                VirtueBar(label: "P", value: student.virtueScores.prudence, color: .orange)
                VirtueBar(label: "F", value: student.virtueScores.fortitude, color: .purple)
            }
        }
        .padding(.vertical, 4)
    }
}

struct VirtueBar: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    Rectangle()
                        .fill(color)
                        .frame(height: geometry.size.height * CGFloat(value))
                }
            }
            .frame(height: 30)
            .frame(maxWidth: 30)
        }
    }
}

struct StudentDetailView: View {
    @EnvironmentObject var appState: EducationAppState
    @State private var selectedSection: DetailSection = .overview
    
    enum DetailSection: String, CaseIterable {
        case overview = "Overview"
        case assignments = "Assignments"
        case assessments = "Assessments"
        case virtues = "Virtues"
    }
    
    var body: some View {
        NavigationStack {
            if let student = appState.currentStudent {
                VStack(spacing: 0) {
                    // Student header
                    StudentHeaderView(student: student)
                    
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
                            OverviewSection(student: student)
                        case .assignments:
                            AssignmentsSection(assignments: student.assignments)
                        case .assessments:
                            AssessmentsSection(assessments: student.assessments)
                        case .virtues:
                            VirtuesSection(virtueScores: student.virtueScores)
                        }
                    }
                }
                .navigationTitle(student.studentId)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct StudentHeaderView: View {
    let student: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(student.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(student.gradeLevel.rawValue) • Age \(student.age)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(student.studentId)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            if student.guardianConsent {
                Label("Guardian Consent: Active", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct OverviewSection: View {
    let student: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Profile")
                .font(.headline)
            
            if !student.learningProfile.strengths.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Strengths")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    ForEach(student.learningProfile.strengths, id: \.self) { strength in
                        Label(strength, systemImage: "star.fill")
                            .font(.caption)
                    }
                }
            }
            
            if !student.learningProfile.challenges.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Areas for Growth")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    ForEach(student.learningProfile.challenges, id: \.self) { challenge in
                        Label(challenge, systemImage: "arrow.up.circle")
                            .font(.caption)
                    }
                }
            }
            
            HStack {
                Text("Learning Style:")
                    .foregroundColor(.secondary)
                Text(student.learningProfile.learningStyle.rawValue)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            
            if !student.learningProfile.accommodations.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Accommodations")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    ForEach(student.learningProfile.accommodations, id: \.self) { accommodation in
                        Label(accommodation, systemImage: "hand.raised.fill")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
    }
}

struct AssignmentsSection: View {
    let assignments: [Assignment]
    
    var sortedAssignments: [Assignment] {
        assignments.sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(sortedAssignments) { assignment in
                AssignmentCard(assignment: assignment)
            }
        }
        .padding()
    }
}

struct AssignmentCard: View {
    let assignment: Assignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(assignment.title)
                    .font(.headline)
                Spacer()
                StatusBadge(status: assignment.status)
            }
            
            HStack {
                Label(assignment.subject.rawValue, systemImage: "book.fill")
                    .font(.caption)
                Spacer()
                Label("Due: \(formatDate(assignment.dueDate))", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(assignment.isOverdue ? .red : .secondary)
            }
            
            if assignment.isOverdue && assignment.status != .completed {
                Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if let score = assignment.score {
                Text("Score: \(Int(score * 100))%")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            if !assignment.feedback.isEmpty {
                Text("Feedback: \(assignment.feedback)")
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

struct StatusBadge: View {
    let status: AssignmentStatus
    
    var color: Color {
        switch status {
        case .assigned: return .blue
        case .inProgress: return .orange
        case .submitted: return .purple
        case .graded: return .green
        case .completed: return .gray
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

struct AssessmentsSection: View {
    let assessments: [Assessment]
    
    var sortedAssessments: [Assessment] {
        assessments.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if assessments.isEmpty {
                Text("No assessments yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(sortedAssessments) { assessment in
                    AssessmentCard(assessment: assessment)
                }
            }
        }
        .padding()
    }
}

struct AssessmentCard: View {
    let assessment: Assessment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(assessment.title)
                    .font(.headline)
                Spacer()
                Text(assessment.letterGrade)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(gradeColor)
            }
            
            HStack {
                Label(assessment.subject.rawValue, systemImage: "book.fill")
                    .font(.caption)
                Spacer()
                Text(formatDate(assessment.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("\(Int(assessment.score))/\(Int(assessment.maxScore))")
                    .font(.subheadline)
                Spacer()
                Text("\(Int(assessment.percentage))%")
                    .font(.subheadline)
                    .foregroundColor(gradeColor)
            }
            
            MasteryBadge(level: assessment.masteryLevel)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var gradeColor: Color {
        switch assessment.letterGrade {
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        default: return .red
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct MasteryBadge: View {
    let level: MasteryLevel
    
    var color: Color {
        switch level {
        case .beginning: return .red
        case .developing: return .orange
        case .proficient: return .blue
        case .advanced: return .green
        }
    }
    
    var body: some View {
        Text("Mastery: \(level.rawValue)")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

struct VirtuesSection: View {
    let virtueScores: VirtueScores
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Aristotelian Virtues")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Character development and learning behaviors based on classical virtues.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VirtueRow(name: "Justice", description: "Fairness in collaboration", score: virtueScores.justice, color: .blue)
            VirtueRow(name: "Temperance", description: "Self-control and patience", score: virtueScores.temperance, color: .green)
            VirtueRow(name: "Prudence", description: "Planning and foresight", score: virtueScores.prudence, color: .orange)
            VirtueRow(name: "Fortitude", description: "Persistence and resilience", score: virtueScores.fortitude, color: .purple)
            
            Divider()
            
            HStack {
                Text("Overall Virtue Score")
                    .font(.headline)
                Spacer()
                Text("\(Int(virtueScores.average * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}

struct VirtueRow: View {
    let name: String
    let description: String
    let score: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.headline)
                Spacer()
                Text("\(Int(score * 100))%")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(score), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}


// EducationMacContentView.swift
// Main macOS interface for Education K-18 app

import SwiftUI
import FoTEducationK18

struct EducationMacContentView: View {
    @EnvironmentObject var appState: EducationMacAppState
    @State private var selectedTab: SidebarItem = .students
    
    enum SidebarItem: String, CaseIterable {
        case students = "Students"
        case assignments = "Assignments"
        case assessments = "Assessments"
        case gradeBook = "Grade Book"
        case virtues = "Virtues"
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, id: \.self, selection: $selectedTab) { item in
                Label(item.rawValue, systemImage: icon(for: item))
            }
            .navigationTitle("Education K-18")
        } content: {
            // Middle panel - Student list
            StudentListMac()
        } detail: {
            // Detail panel - Student details
            if let student = appState.selectedStudent {
                StudentDetailMac(student: student)
            } else {
                Text("Select a student")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private func icon(for item: SidebarItem) -> String {
        switch item {
        case .students: return "person.3.fill"
        case .assignments: return "doc.text.fill"
        case .assessments: return "checkmark.circle.fill"
        case .gradeBook: return "book.fill"
        case .virtues: return "star.fill"
        }
    }
}

struct StudentListMac: View {
    @EnvironmentObject var appState: EducationMacAppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search students", text: $appState.searchText)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color(.textBackgroundColor))
            
            Divider()
            
            // Student list
            List(appState.filteredStudents, selection: $appState.selectedStudent) { student in
                StudentRowMac(student: student)
                    .tag(student)
            }
            .listStyle(.sidebar)
        }
        .frame(minWidth: 300)
        .navigationTitle("Students")
    }
}

struct StudentRowMac: View {
    let student: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(student.fullName)
                .font(.headline)
            
            HStack {
                Text("ID: \(student.studentId)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(student.gradeLevel.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            // Next assignment
            if let nextAssignment = student.assignments.filter({ $0.status != .completed }).sorted(by: { $0.dueDate < $1.dueDate }).first {
                HStack(spacing: 4) {
                    Image(systemName: "doc.fill")
                        .font(.caption)
                    Text(nextAssignment.title)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(nextAssignment.isOverdue ? .red : .orange)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StudentDetailMac: View {
    let student: Student
    @State private var selectedDetailTab: DetailTab = .overview
    
    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case assignments = "Assignments"
        case assessments = "Assessments"
        case virtues = "Virtues"
        case reports = "Reports"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Student header
            StudentHeaderMac(student: student)
            
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
                    OverviewSectionEducation(student: student)
                case .assignments:
                    AssignmentsSectionMac(assignments: student.assignments)
                case .assessments:
                    AssessmentsSectionMac(assessments: student.assessments)
                case .virtues:
                    VirtuesSectionMac(virtueScores: student.virtueScores)
                case .reports:
                    ReportsSectionMac(student: student)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: {}) {
                    Label("New Assignment", systemImage: "doc.badge.plus")
                }
                Button(action: {}) {
                    Label("Generate Report", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

struct StudentHeaderMac: View {
    let student: Student
    
    var body: some View {
        HStack(spacing: 20) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 80, height: 80)
                Text(student.initials)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(student.fullName)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 16) {
                    Label("ID: \(student.studentId)", systemImage: "number")
                    Label(student.gradeLevel.rawValue, systemImage: "graduationcap")
                    Label("\(student.age) years old", systemImage: "calendar")
                    if student.guardianConsent {
                        Label("Consent", systemImage: "checkmark.shield.fill")
                            .foregroundColor(.green)
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Virtue summary
            VStack(alignment: .trailing, spacing: 8) {
                Text("Character Development")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 12) {
                    VirtueMiniBar(label: "J", value: student.virtueScores.justice, color: .blue)
                    VirtueMiniBar(label: "T", value: student.virtueScores.temperance, color: .green)
                    VirtueMiniBar(label: "P", value: student.virtueScores.prudence, color: .orange)
                    VirtueMiniBar(label: "F", value: student.virtueScores.fortitude, color: .purple)
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
}

struct VirtueMiniBar: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 20, height: 40)
                Rectangle()
                    .fill(color)
                    .frame(width: 20, height: 40 * CGFloat(value))
            }
            .cornerRadius(2)
        }
    }
}

struct OverviewSectionEducation: View {
    let student: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox("Student Information") {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                    GridRow {
                        Text("Student ID:")
                            .foregroundColor(.secondary)
                        Text(student.studentId)
                    }
                    GridRow {
                        Text("Grade Level:")
                            .foregroundColor(.secondary)
                        Text(student.gradeLevel.rawValue)
                    }
                    GridRow {
                        Text("Age:")
                            .foregroundColor(.secondary)
                        Text("\(student.age) years")
                    }
                    GridRow {
                        Text("Guardian Consent:")
                            .foregroundColor(.secondary)
                        Text(student.guardianConsent ? "Active" : "Pending")
                            .foregroundColor(student.guardianConsent ? .green : .orange)
                    }
                }
                .padding()
            }
            
            GroupBox("Learning Profile") {
                VStack(alignment: .leading, spacing: 12) {
                    if !student.learningProfile.strengths.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Strengths:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            ForEach(student.learningProfile.strengths, id: \.self) { strength in
                                Label(strength, systemImage: "star.fill")
                                    .font(.caption)
                            }
                        }
                    }
                    
                    if !student.learningProfile.challenges.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Areas for Growth:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
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
                            Text("Accommodations:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
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
        .padding()
    }
}

struct AssignmentsSectionMac: View {
    let assignments: [Assignment]
    
    var sortedAssignments: [Assignment] {
        assignments.sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(sortedAssignments) { assignment in
                GroupBox {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(assignment.title)
                                .font(.headline)
                            Label(assignment.subject.rawValue, systemImage: "book.fill")
                                .font(.caption)
                            Text("Due: \(formatDate(assignment.dueDate))")
                                .font(.caption)
                                .foregroundColor(assignment.isOverdue ? .red : .secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            StatusBadgeEducation(status: assignment.status)
                            if let score = assignment.score {
                                Text("\(Int(score * 100))%")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            if assignment.isOverdue && assignment.status != .completed {
                                Text("Overdue")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                }
            }
            
            Button(action: {}) {
                Label("Add Assignment", systemImage: "doc.badge.plus")
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

struct StatusBadgeEducation: View {
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

struct AssessmentsSectionMac: View {
    let assessments: [Assessment]
    
    var sortedAssessments: [Assessment] {
        assessments.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if assessments.isEmpty {
                GroupBox {
                    Text("No assessments yet")
                        .foregroundColor(.secondary)
                        .padding()
                }
            } else {
                ForEach(sortedAssessments) { assessment in
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(assessment.title)
                                    .font(.headline)
                                Label(assessment.subject.rawValue, systemImage: "book.fill")
                                    .font(.caption)
                                Text(formatDate(assessment.date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(spacing: 8) {
                                Text(assessment.letterGrade)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(gradeColor(assessment.letterGrade))
                                Text("\(Int(assessment.percentage))%")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                MasteryBadgeEducation(level: assessment.masteryLevel)
                            }
                        }
                        .padding()
                    }
                }
            }
            
            Button(action: {}) {
                Label("Add Assessment", systemImage: "checkmark.circle.fill")
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
    
    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        default: return .red
        }
    }
}

struct MasteryBadgeEducation: View {
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
        Text(level.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

struct VirtuesSectionMac: View {
    let virtueScores: VirtueScores
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            GroupBox("Aristotelian Virtues") {
                VStack(spacing: 20) {
                    VirtueRowMacDetailed(name: "Justice", description: "Fairness in collaboration", score: virtueScores.justice, color: .blue)
                    VirtueRowMacDetailed(name: "Temperance", description: "Self-control and patience", score: virtueScores.temperance, color: .green)
                    VirtueRowMacDetailed(name: "Prudence", description: "Planning and foresight", score: virtueScores.prudence, color: .orange)
                    VirtueRowMacDetailed(name: "Fortitude", description: "Persistence and resilience", score: virtueScores.fortitude, color: .purple)
                }
                .padding()
            }
            
            GroupBox("Overall Character Development") {
                HStack {
                    Text("Average Virtue Score:")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(virtueScores.average * 100))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
            }
        }
        .padding()
    }
}

struct VirtueRowMacDetailed: View {
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
    }
}

struct ReportsSectionMac: View {
    let student: Student
    
    var body: some View {
        VStack(spacing: 20) {
            GroupBox("Generate Reports") {
                VStack(spacing: 12) {
                    Button(action: {}) {
                        Label("Progress Report", systemImage: "doc.text.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {}) {
                        Label("Report Card", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {}) {
                        Label("Parent Conference Notes", systemImage: "bubble.left.and.bubble.right.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
        .padding()
    }
}

struct StudentDetailWindow: View {
    let student: Student
    
    var body: some View {
        StudentDetailMac(student: student)
            .frame(minWidth: 800, minHeight: 600)
    }
}

struct EducationSettingsView: View {
    var body: some View {
        TabView {
            EducationGeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            EducationPrivacySettings()
                .tabItem {
                    Label("Privacy", systemImage: "lock.shield")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct EducationGeneralSettings: View {
    @State private var defaultGradeLevel = "5th Grade"
    
    var body: some View {
        Form {
            Picker("Default Grade Level:", selection: $defaultGradeLevel) {
                Text("Kindergarten").tag("K")
                Text("1st Grade").tag("1")
                Text("5th Grade").tag("5")
                Text("8th Grade").tag("8")
            }
            Divider()
            Button("Reset to Defaults") {}
        }
        .padding()
    }
}

struct EducationPrivacySettings: View {
    var body: some View {
        Form {
            Text("FERPA Compliance: Enabled")
                .foregroundColor(.green)
            Text("Guardian consent required for all students")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

extension Student {
    var initials: String {
        let first = String(firstName.prefix(1))
        let last = String(lastName.prefix(1))
        return "\(first)\(last)"
    }
}


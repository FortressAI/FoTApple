// ParentContentView.swift
// Main view for Parent/Guardian app

import SwiftUI
import FoTCore
import FoTUI

struct ParentContentView: View {
    @EnvironmentObject var appState: ParentAppState
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Progress Tab
                ProgressView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
                    .tag(0)
                
                // Assignments Tab
                AssignmentsView()
                    .tabItem {
                        Label("Homework", systemImage: "book.fill")
                    }
                    .tag(1)
                
                // Behavior Tab
                BehaviorView()
                    .tabItem {
                        Label("Behavior", systemImage: "hand.raised.fill")
                    }
                    .tag(2)
                
                // Settings Tab
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .navigationTitle("FoT Parent")
        }
    }
}

struct ProgressView: View {
    @EnvironmentObject var appState: ParentAppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let child = appState.selectedChild {
                    // Student Selector
                    Picker("Student", selection: $appState.selectedChild) {
                        ForEach(appState.children) { student in
                            Text(student.name).tag(student as StudentInfo?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    
                    // Academic Performance Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Academic Performance")
                                .font(.headline)
                            
                            HStack {
                                Text("Overall GPA:")
                                Spacer()
                                Text(String(format: "%.2f", child.gpa))
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Grade Level:")
                                Spacer()
                                Text(child.gradeLevel.rawValue)
                            }
                        }
                        .padding()
                    }
                    
                    // Attendance Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Attendance")
                                .font(.headline)
                            
                            HStack {
                                Text("Attendance Rate:")
                                Spacer()
                                Text(String(format: "%.1f%%", child.attendance))
                                    .fontWeight(.bold)
                                    .foregroundColor(child.attendance >= 95 ? .green : child.attendance >= 90 ? .orange : .red)
                            }
                        }
                        .padding()
                    }
                    
                    // Behavior Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Behavior & Character")
                                .font(.headline)
                            
                            HStack {
                                Text("Overall Rating:")
                                Spacer()
                                Text(child.behaviorRating.rawValue)
                                    .fontWeight(.bold)
                                    .foregroundColor(behaviorColor(child.behaviorRating))
                            }
                        }
                        .padding()
                    }
                    
                    // AI Insights Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("VQbit AI Insights")
                                    .font(.headline)
                            }
                            
                            Text("Your child is performing well academically and showing positive character development. Consider discussing time management strategies to maintain consistent progress.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
            }
            .padding()
        }
    }
    
    private func behaviorColor(_ rating: StudentInfo.BehaviorRating) -> Color {
        switch rating {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .needsImprovement: return .red
        }
    }
}

struct AssignmentsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Upcoming Assignments")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Math Homework")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("Due Today")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        Text("Chapter 5 Problems")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Science Lab Report")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("Due Wed")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        Text("Photosynthesis Experiment")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("English Essay")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("Due Friday")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        Text("Civil War Analysis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct BehaviorView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Behavior Reports")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Positive Notes
                Text("✅ Positive Notes")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Helped new student feel welcome")
                            .font(.subheadline)
                        Text("Oct 25 • Ms. Johnson (English)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Excellent group project leadership")
                            .font(.subheadline)
                        Text("Oct 20 • Mr. Chen (Science)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                // Minor Incidents (if any)
                Text("⚠️ Minor Incidents")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Talking during quiet work time")
                            .font(.subheadline)
                        Text("Oct 18 • Ms. Johnson")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Action: Verbal reminder • Resolved")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    .padding()
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") {
                NavigationLink("Emergency Contacts") {
                    Text("Emergency Contacts")
                }
                NavigationLink("Communication Preferences") {
                    Text("Preferences")
                }
            }
            
            Section("Children") {
                NavigationLink("Manage Children") {
                    Text("Children")
                }
            }
            
            Section("Notifications") {
                Toggle("Grade Notifications", isOn: .constant(true))
                Toggle("Behavior Alerts", isOn: .constant(true))
                Toggle("Assignment Reminders", isOn: .constant(true))
            }
            
            Section("Privacy & Security") {
                NavigationLink("Cryptographic Receipts") {
                    Text("Receipts")
                }
                NavigationLink("Data Export") {
                    Text("Export")
                }
            }
        }
    }
}

#Preview {
    ParentContentView()
        .environmentObject(ParentAppState())
}


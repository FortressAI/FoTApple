// EducationWatchContentView.swift
// Main watch interface for Education K-18 app

import SwiftUI
import FoTEducationK18

struct EducationWatchContentView: View {
    @EnvironmentObject var appState: EducationWatchAppState
    
    var body: some View {
        NavigationStack {
            List {
                // Today's Assignments
                Section("Today") {
                    NavigationLink(destination: AssignmentsWatchView()) {
                        Label("Assignments", systemImage: "doc.text.fill")
                            .badge(dueCount)
                    }
                }
                
                // Virtues
                if let student = appState.currentStudent {
                    Section("My Progress") {
                        NavigationLink(destination: VirtuesWatchView(virtueScores: student.virtueScores)) {
                            Label("Virtues", systemImage: "star.fill")
                        }
                    }
                }
                
                // Quick Timer
                Section("Tools") {
                    NavigationLink(destination: StudyTimerView()) {
                        Label("Study Timer", systemImage: "timer")
                    }
                }
            }
            .navigationTitle("Education")
        }
    }
    
    private var dueCount: Int {
        appState.todayAssignments.filter { $0.status != .completed }.count
    }
}

struct AssignmentsWatchView: View {
    @EnvironmentObject var appState: EducationWatchAppState
    
    var body: some View {
        List(appState.todayAssignments) { assignment in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(assignment.title)
                        .font(.headline)
                        .lineLimit(2)
                    Spacer()
                    if assignment.isOverdue {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
                
                HStack {
                    Label(assignment.subject.rawValue, systemImage: "book.fill")
                        .font(.caption)
                    Spacer()
                    Text(assignment.status.rawValue)
                        .font(.caption)
                        .foregroundColor(statusColor(assignment.status))
                }
            }
        }
        .navigationTitle("Assignments")
    }
    
    private func statusColor(_ status: AssignmentStatus) -> Color {
        switch status {
        case .assigned: return .blue
        case .inProgress: return .orange
        case .submitted: return .purple
        case .graded: return .green
        case .completed: return .gray
        }
    }
}

struct VirtuesWatchView: View {
    let virtueScores: VirtueScores
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Character Development")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VirtueRowWatch(name: "Justice", value: virtueScores.justice, color: .blue)
                VirtueRowWatch(name: "Temperance", value: virtueScores.temperance, color: .green)
                VirtueRowWatch(name: "Prudence", value: virtueScores.prudence, color: .orange)
                VirtueRowWatch(name: "Fortitude", value: virtueScores.fortitude, color: .purple)
                
                Divider()
                
                HStack {
                    Text("Overall")
                        .font(.caption)
                    Spacer()
                    Text("\(Int(virtueScores.average * 100))%")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            .padding()
        }
        .navigationTitle("Virtues")
    }
}

struct VirtueRowWatch: View {
    let name: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

struct StudyTimerView: View {
    @State private var timeRemaining = 1500 // 25 minutes
    @State private var isRunning = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(timeString)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            HStack(spacing: 16) {
                Button(action: toggleTimer) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .tint(isRunning ? .orange : .green)
                
                Button(action: resetTimer) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("Study Timer")
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleTimer() {
        isRunning.toggle()
        
        if isRunning {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    isRunning = false
                    timer?.invalidate()
                }
            }
        } else {
            timer?.invalidate()
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        isRunning = false
        timeRemaining = 1500
    }
}


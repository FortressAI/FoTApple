// PersonalHealthMacContentView.swift
// macOS main UI with sidebar navigation

import SwiftUI
import FoTUI

struct PersonalHealthMacContentView: View {
    @EnvironmentObject var healthState: HealthStateMac
    @State private var selectedView: SidebarItem = .today
    
    enum SidebarItem: String, CaseIterable {
        case today = "Today"
        case vitals = "Vitals"
        case symptoms = "Symptoms"
        case mental = "Mental Health"
        case timeline = "Timeline"
        case share = "Share"
        
        var icon: String {
            switch self {
            case .today: return "calendar"
            case .vitals: return "heart.fill"
            case .symptoms: return "stethoscope"
            case .mental: return "brain.head.profile"
            case .timeline: return "clock.fill"
            case .share: return "person.2.fill"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, id: \.self, selection: $selectedView) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.icon)
                }
            }
            .navigationTitle("My Health")
        } detail: {
            // Main content
            ZStack {
                DomainBackground(domain: .clinician)
                
                ScrollView {
                    switch selectedView {
                    case .today:
                        TodayViewMac()
                    case .vitals:
                        VitalsViewMac()
                    case .symptoms:
                        SymptomsViewMac()
                    case .mental:
                        MentalHealthViewMac()
                    case .timeline:
                        TimelineViewMac()
                    case .share:
                        ShareViewMac()
                    }
                }
            }
        }
    }
}

// MARK: - Today View

struct TodayViewMac: View {
    @EnvironmentObject var healthState: HealthStateMac
    @State private var showGuidanceNavigator = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Good Morning")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Monday, October 28, 2025")
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: { showGuidanceNavigator = true }) {
                    Label("Need Help?", systemImage: "map.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .sheet(isPresented: $showGuidanceNavigator) {
                GuidanceNavigatorView()
            }
            
            HStack(spacing: 20) {
                // Guidance Navigator Card
                GlassCard {
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.purple)
                        
                        Text("When Do I Need Help?")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Text("Interactive guidance for medical, legal, or school concerns")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { showGuidanceNavigator = true }) {
                            Label("Start Navigator", systemImage: "arrow.right.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                
                // Quick Capture Card
                GlassCard {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        
                        Text("Quick Capture")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Photo + Sensors + Receipt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {}) {
                            Label("Capture Now", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                
                // Today's Stats
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Summary")
                            .font(.headline)
                        
                        StatRow(icon: "heart.fill", label: "Heart Rate", value: "72 BPM", color: .red)
                        StatRow(icon: "figure.walk", label: "Steps", value: "8,234", color: .blue)
                        StatRow(icon: "flame.fill", label: "Calories", value: "1,847", color: .orange)
                        StatRow(icon: "pills.fill", label: "Medications", value: "2/3 taken", color: .purple)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Recent Activity
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Activity")
                        .font(.headline)
                    
                    ForEach(healthState.healthRecords.prefix(3)) { record in
                        HStack {
                            Image(systemName: record.type == .vitals ? "heart.fill" : "stethoscope")
                                .foregroundColor(record.type == .vitals ? .green : .orange)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading) {
                                Text(record.type.rawValue)
                                    .fontWeight(.medium)
                                Text(record.notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(record.date, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        
                        if record.id != healthState.healthRecords.prefix(3).last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Vitals View

struct VitalsViewMac: View {
    @State private var temperature = "98.6"
    @State private var heartRate = "72"
    @State private var systolic = "120"
    @State private var diastolic = "80"
    @State private var weight = "165"
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Track Your Vitals")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            GlassCard {
                VStack(spacing: 20) {
                    VitalRowMac(label: "Temperature", value: $temperature, unit: "°F", icon: "thermometer")
                    Divider()
                    VitalRowMac(label: "Heart Rate", value: $heartRate, unit: "BPM", icon: "heart.fill")
                    Divider()
                    
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .frame(width: 40)
                        Text("Blood Pressure")
                            .frame(width: 150, alignment: .leading)
                        TextField("Systolic", text: $systolic)
                            .textFieldStyle(.roundedBorder)
                        Text("/")
                        TextField("Diastolic", text: $diastolic)
                            .textFieldStyle(.roundedBorder)
                        Text("mmHg")
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    VitalRowMac(label: "Weight", value: $weight, unit: "lbs", icon: "figure.stand")
                    
                    Button(action: saveVitals) {
                        Label("Save & Generate Receipt", systemImage: "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(24)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    func saveVitals() {
        print("✅ Saving vitals with cryptographic receipt...")
    }
}

struct VitalRowMac: View {
    let label: String
    @Binding var value: String
    let unit: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 40)
            Text(label)
                .frame(width: 150, alignment: .leading)
            TextField(label, text: $value)
                .textFieldStyle(.roundedBorder)
            Text(unit)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
        }
    }
}

// MARK: - Symptoms View

struct SymptomsViewMac: View {
    @State private var symptomText = ""
    @State private var severity = 5.0
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Document Symptoms")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            GlassCard {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Describe what you're feeling:")
                        .font(.headline)
                    
                    TextEditor(text: $symptomText)
                        .frame(height: 200)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading) {
                        Text("Severity: \(Int(severity))/10")
                            .font(.headline)
                        Slider(value: $severity, in: 1...10, step: 1)
                    }
                    
                    HStack {
                        Button(action: {}) {
                            Label("Add Photo", systemImage: "camera.fill")
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button(action: saveSymptom) {
                            Label("Save Symptom", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(24)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    func saveSymptom() {
        print("✅ Saving symptom with receipt...")
    }
}

// MARK: - Mental Health View

struct MentalHealthViewMac: View {
    @State private var moodRating = 5.0
    @State private var sleepHours = 7.5
    @State private var stressLevel = 3.0
    @State private var gratitudeText = ""
    @State private var journalEntry = ""
    @State private var showCrisisResources = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with crisis support
            HStack {
                VStack(alignment: .leading) {
                    Text("Mental Health & Wellness")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Your mind-body journal with private, cryptographic proof")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showCrisisResources = true }) {
                    Label("Crisis Support", systemImage: "heart.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .sheet(isPresented: $showCrisisResources) {
                CrisisResourcesView()
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Check-in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Today's Check-In")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                // Mood
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("How are you feeling?")
                                        Spacer()
                                        Text(moodEmoji(for: moodRating))
                                            .font(.title)
                                    }
                                    Slider(value: $moodRating, in: 1...10, step: 1)
                                    HStack {
                                        Text("Struggling")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("Thriving")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Divider()
                                
                                // Sleep
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "bed.double.fill")
                                        Text("Sleep last night:")
                                        Spacer()
                                        Text(String(format: "%.1f hours", sleepHours))
                                            .fontWeight(.medium)
                                    }
                                    Slider(value: $sleepHours, in: 0...12, step: 0.5)
                                }
                                
                                Divider()
                                
                                // Stress
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "brain.head.profile")
                                        Text("Stress level:")
                                        Spacer()
                                        Text(stressLabel(for: stressLevel))
                                            .fontWeight(.medium)
                                    }
                                    Slider(value: $stressLevel, in: 1...5, step: 1)
                                    HStack {
                                        Text("Calm")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("Overwhelmed")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(24)
                    }
                    .padding(.horizontal)
                    
                    // Gratitude Practice
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sun.max.fill")
                                    .foregroundColor(.orange)
                                Text("Gratitude Practice")
                                    .font(.headline)
                            }
                            
                            Text("What are you grateful for today?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $gratitudeText)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(24)
                    }
                    .padding(.horizontal)
                    
                    // Daily Journal
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.blue)
                                Text("Daily Journal")
                                    .font(.headline)
                            }
                            
                            Text("A safe space for your thoughts, feelings, and reflections")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $journalEntry)
                                .frame(height: 200)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            
                            HStack {
                                Text("🔒 Private • Encrypted • Yours alone")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(action: saveJournalEntry) {
                                    Label("Save with Receipt", systemImage: "checkmark.seal.fill")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(24)
                    }
                    .padding(.horizontal)
                    
                    // Wellness Tips
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                Text("Wellness Reminders")
                                    .font(.headline)
                            }
                            
                            WellnessTip(icon: "figure.walk", text: "Take a 10-minute walk outside")
                            WellnessTip(icon: "lungs.fill", text: "Practice deep breathing: 4-7-8 technique")
                            WellnessTip(icon: "person.2.fill", text: "Connect with someone you trust")
                            WellnessTip(icon: "cup.and.saucer.fill", text: "Stay hydrated and eat nourishing food")
                            
                            Text("Remember: These entries are for tracking, not diagnosis. Always consult mental health professionals for clinical guidance.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .padding(24)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
    }
    
    func moodEmoji(for rating: Double) -> String {
        switch Int(rating) {
        case 1...2: return "😞"
        case 3...4: return "😕"
        case 5...6: return "😐"
        case 7...8: return "🙂"
        case 9...10: return "😊"
        default: return "😐"
        }
    }
    
    func stressLabel(for level: Double) -> String {
        switch Int(level) {
        case 1: return "Calm"
        case 2: return "Mild"
        case 3: return "Moderate"
        case 4: return "High"
        case 5: return "Severe"
        default: return "Moderate"
        }
    }
    
    func saveJournalEntry() {
        print("✅ Saving mental health journal with cryptographic receipt...")
        print("   Mood: \(Int(moodRating))/10")
        print("   Sleep: \(sleepHours) hours")
        print("   Stress: Level \(Int(stressLevel))")
    }
}

struct WellnessTip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct CrisisResourcesView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            DomainBackground(domain: .clinician)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("Crisis Support Resources")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("You are not alone. Help is available 24/7.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Crisis Hotlines
                    GlassCard {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("🚨 Immediate Help")
                                .font(.headline)
                            
                            CrisisResourceRow(
                                service: "988 Suicide & Crisis Lifeline",
                                number: "988",
                                description: "Call or text 988 for immediate support"
                            )
                            
                            Divider()
                            
                            CrisisResourceRow(
                                service: "Crisis Text Line",
                                number: "Text HOME to 741741",
                                description: "24/7 support via text message"
                            )
                            
                            Divider()
                            
                            CrisisResourceRow(
                                service: "Veterans Crisis Line",
                                number: "988 then press 1",
                                description: "Support for veterans and families"
                            )
                            
                            Divider()
                            
                            CrisisResourceRow(
                                service: "Emergency Services",
                                number: "911",
                                description: "For life-threatening emergencies"
                            )
                        }
                        .padding(24)
                    }
                    .padding(.horizontal)
                    
                    // Mental Health Resources
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🧠 Mental Health Support")
                                .font(.headline)
                            
                            Text("NAMI Helpline: 1-800-950-6264")
                            Text("SAMHSA National Helpline: 1-800-662-4357")
                            Text("The Trevor Project (LGBTQ+ Youth): 1-866-488-7386")
                            Text("Trans Lifeline: 1-877-565-8860")
                            
                            Button(action: {
                                if let url = URL(string: "https://findtreatment.samhsa.gov/") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Label("Find Treatment Facilities", systemImage: "magnifyingglass")
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                    }
                    .padding(.horizontal)
                    
                    Text("These resources provide confidential, free support. Reaching out is a sign of strength, not weakness.")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
        .frame(minWidth: 600, minHeight: 700)
    }
}

struct CrisisResourceRow: View {
    let service: String
    let number: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(service)
                .font(.headline)
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Timeline View

struct TimelineViewMac: View {
    @EnvironmentObject var healthState: HealthStateMac
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Health Timeline")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            ForEach(healthState.healthRecords) { record in
                GlassCard {
                    HStack(alignment: .top, spacing: 20) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(record.type == .vitals ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                                .frame(width: 50, height: 50)
                            Image(systemName: record.type == .vitals ? "heart.fill" : "stethoscope")
                                .foregroundColor(record.type == .vitals ? .green : .orange)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(record.type.rawValue)
                                    .font(.headline)
                                Spacer()
                                Text(record.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(record.notes)
                                .foregroundColor(.secondary)
                            
                            if let temp = record.temperature, let hr = record.heartRate {
                                HStack(spacing: 16) {
                                    Label("\(String(format: "%.1f", temp))°F", systemImage: "thermometer")
                                        .font(.caption)
                                    Label("\(hr) BPM", systemImage: "heart.fill")
                                        .font(.caption)
                                    if let bp = record.bloodPressure {
                                        Label(bp, systemImage: "waveform.path.ecg")
                                            .font(.caption)
                                    }
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Share View

struct ShareViewMac: View {
    @State private var clinicianCode = ""
    @State private var shareDuration = 7
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Share with Your Doctor")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            GlassCard {
                VStack(spacing: 24) {
                    Image(systemName: "person.2.badge.key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Temporary Access")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Give your doctor secure, time-limited access to your health data")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Doctor's Access Code:")
                        TextField("Enter code", text: $clinicianCode)
                            .textFieldStyle(.roundedBorder)
                        
                        Picker("Share Duration:", selection: $shareDuration) {
                            Text("24 hours").tag(1)
                            Text("7 days").tag(7)
                            Text("30 days").tag(30)
                        }
                    }
                    .frame(maxWidth: 400)
                    
                    Button(action: shareWithDoctor) {
                        Label("Share Health Data", systemImage: "checkmark.shield.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Text("You can revoke access at any time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(32)
            }
            .padding(.horizontal)
            .frame(maxWidth: 600)
            
            Spacer()
        }
        .padding()
    }
    
    func shareWithDoctor() {
        print("✅ Sharing health data with clinician for \(shareDuration) days")
    }
}


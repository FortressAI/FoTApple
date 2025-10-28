// PersonalHealthContentView.swift
// Main UI for Personal Health Monitor

import SwiftUI
import FoTUI

struct PersonalHealthContentView: View {
    @EnvironmentObject var healthState: HealthState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // TODAY tab - Quick capture
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(0)
            
            // VITALS tab - Track measurements
            VitalsTrackingView()
                .tabItem {
                    Label("Vitals", systemImage: "heart.fill")
                }
                .tag(1)
            
            // SYMPTOMS tab - Document symptoms
            SymptomsView()
                .tabItem {
                    Label("Symptoms", systemImage: "stethoscope")
                }
                .tag(2)
            
            // TIMELINE tab - Health history
            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "clock.fill")
                }
                .tag(3)
            
            // SHARE tab - Share with doctor
            ShareView()
                .tabItem {
                    Label("Share", systemImage: "person.2.fill")
                }
                .tag(4)
        }
    }
}

// MARK: - Today View (Quick Capture)

struct TodayView: View {
    @EnvironmentObject var healthState: HealthState
    @State private var showCamera = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DomainBackground(domain: .clinician) // Green theme for health
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Quick capture card
                        GlassCard {
                            VStack(spacing: 16) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.green)
                                
                                Text("Capture Health Moment")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("One tap captures: Photo, Location, Time, Sensors")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: { showCamera = true }) {
                                    Label("Quick Capture", systemImage: "camera.fill")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                        }
                        
                        // Today's summary
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Summary")
                                    .font(.headline)
                                
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("Heart Rate: 72 BPM")
                                    Spacer()
                                    Text("Normal")
                                        .foregroundColor(.green)
                                }
                                
                                HStack {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(.blue)
                                    Text("Steps: 8,234")
                                    Spacer()
                                    Text("Active")
                                        .foregroundColor(.green)
                                }
                                
                                HStack {
                                    Image(systemName: "pills.fill")
                                        .foregroundColor(.orange)
                                    Text("Medications: 2/3 taken")
                                    Spacer()
                                    Text("1 missed")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        // Emergency capture
                        GlassCard {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                                
                                Text("Emergency Capture")
                                    .font(.headline)
                                
                                Text("Captures ALL sensors + generates legal receipt")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: { healthState.captureHealthIncident() }) {
                                    Label("Emergency Capture", systemImage: "exclamationmark.circle.fill")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Health")
        }
        .sheet(isPresented: $showCamera) {
            Text("Camera Capture - Coming Soon")
        }
    }
}

// MARK: - Vitals Tracking View

struct VitalsTrackingView: View {
    @State private var temperature = ""
    @State private var heartRate = ""
    @State private var bloodPressureSystolic = ""
    @State private var bloodPressureDiastolic = ""
    @State private var weight = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                DomainBackground(domain: .clinician)
                
                ScrollView {
                    VStack(spacing: 20) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Record Your Vitals")
                                    .font(.headline)
                                
                                VitalEntryRow(label: "Temperature", value: $temperature, unit: "°F")
                                VitalEntryRow(label: "Heart Rate", value: $heartRate, unit: "BPM")
                                
                                HStack {
                                    Text("Blood Pressure")
                                        .frame(width: 120, alignment: .leading)
                                    TextField("Systolic", text: $bloodPressureSystolic)
                                        .textFieldStyle(.roundedBorder)
                                        .keyboardType(.numberPad)
                                    Text("/")
                                    TextField("Diastolic", text: $bloodPressureDiastolic)
                                        .textFieldStyle(.roundedBorder)
                                        .keyboardType(.numberPad)
                                    Text("mmHg")
                                        .foregroundColor(.secondary)
                                }
                                
                                VitalEntryRow(label: "Weight", value: $weight, unit: "lbs")
                                
                                Button(action: saveVitals) {
                                    Label("Save & Generate Receipt", systemImage: "checkmark.seal.fill")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Recent vitals
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Measurements")
                                    .font(.headline)
                                
                                Text("No measurements yet - record your first vitals above!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Track Vitals")
        }
    }
    
    func saveVitals() {
        print("Saving vitals and generating cryptographic receipt...")
        // Generate receipt proving vitals were recorded at this time
    }
}

struct VitalEntryRow: View {
    let label: String
    @Binding var value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            TextField(label, text: $value)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
            Text(unit)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Symptoms View

struct SymptomsView: View {
    @State private var symptomDescription = ""
    @State private var severity = 5.0
    @State private var showCamera = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DomainBackground(domain: .clinician)
                
                ScrollView {
                    VStack(spacing: 20) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Document Symptoms")
                                    .font(.headline)
                                
                                Text("Describe what you're feeling:")
                                    .font(.subheadline)
                                
                                TextEditor(text: $symptomDescription)
                                    .frame(height: 150)
                                    .padding(8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading) {
                                    Text("Severity: \(Int(severity))/10")
                                        .font(.subheadline)
                                    Slider(value: $severity, in: 1...10, step: 1)
                                }
                                
                                Button(action: { showCamera = true }) {
                                    Label("Add Photo", systemImage: "camera.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: saveSymptom) {
                                    Label("Save Symptom", systemImage: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Symptoms")
        }
    }
    
    func saveSymptom() {
        print("Saving symptom with receipt...")
    }
}

// MARK: - Timeline View

struct TimelineView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DomainBackground(domain: .clinician)
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Your Health Timeline")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        
                        GlassCard {
                            Text("No health records yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Timeline")
        }
    }
}

// MARK: - Share View

struct ShareView: View {
    @State private var clinicianCode = ""
    @State private var shareShowcase = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DomainBackground(domain: .clinician)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if shareShowcase {
                            GlassShowcaseView(domain: .clinician)
                        } else {
                            GlassCard {
                                VStack(spacing: 16) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.blue)
                                    
                                    Text("Share with Doctor")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("Give your doctor temporary access to your health data")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    
                                    TextField("Doctor's code", text: $clinicianCode)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                    
                                    Button(action: shareWithDoctor) {
                                        Label("Share for 7 Days", systemImage: "checkmark.shield.fill")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .cornerRadius(12)
                                    }
                                    
                                    Button(action: { shareShowcase = true }) {
                                        Text("View System Showcase")
                                            .font(.caption)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Share")
        }
    }
    
    func shareWithDoctor() {
        print("Sharing health data with clinician...")
    }
}


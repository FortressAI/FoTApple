// SOAPNoteView.swift
// SOAP note display and generation

import SwiftUI
import FoTClinician

struct SOAPNoteView: View {
    let patient: Patient
    let encounter: ClinicalEncounter
    @State private var soapNote: SOAPNote?
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("SOAP Note")
                    .font(.headline)
                Spacer()
                Button(action: {
                    generateNote()
                }) {
                    Label("Generate", systemImage: "doc.text")
                }
                .buttonStyle(.bordered)
                
                if soapNote != nil {
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            if let note = soapNote {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header info
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SOAP NOTE")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Divider()
                            
                            Text("Patient: \(patient.fullName) (\(patient.mrn))")
                            Text("DOB: \(formatDate(patient.dateOfBirth)) (Age: \(patient.ageDisplay))")
                            Text("Date of Visit: \(formatDate(note.date))")
                            Text("Encounter Type: \(encounter.type.rawValue)")
                        }
                        .font(.caption)
                        
                        Divider()
                        
                        // Subjective
                        SOAPSection(title: "SUBJECTIVE", content: note.subjective)
                        
                        // Objective
                        SOAPSection(title: "OBJECTIVE", content: note.objective)
                        
                        // Assessment
                        SOAPSection(title: "ASSESSMENT", content: note.assessment)
                        
                        // Plan
                        SOAPSection(title: "PLAN", content: note.plan)
                        
                        // Signature
                        if note.isSigned, let signature = note.signature, let signedAt = note.signedAt {
                            Divider()
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Signed: \(formatDateTime(signedAt))")
                                    .font(.caption)
                                Text("Signature: \(signature)")
                                    .font(.caption)
                            }
                        } else {
                            Button(action: {
                                signNote()
                            }) {
                                Text("Sign Note")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 2)
            } else {
                Text("Click 'Generate' to create the SOAP note")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .sheet(isPresented: $showShareSheet) {
            if let note = soapNote {
                ShareSheet(activityItems: [note.formattedText(patient: patient, encounter: encounter)])
            }
        }
    }
    
    private func generateNote() {
        soapNote = SOAPNoteBuilder.generate(from: encounter, patient: patient)
    }
    
    private func signNote() {
        guard var note = soapNote else { return }
        note.signature = "Dr. Provider" // In production, use actual provider credentials
        note.signedAt = Date()
        soapNote = note
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SOAPSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


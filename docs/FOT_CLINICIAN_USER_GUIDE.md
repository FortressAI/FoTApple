# FoT Clinician - Complete User Guide

**HIPAA-compliant clinical decision support with cryptographic audit trails**

---

## Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Patient Management](#patient-management)
4. [Clinical Encounters](#clinical-encounters)
5. [SOAP Documentation](#soap-documentation)
6. [Medication Management](#medication-management)
7. [Clinical Decision Support](#clinical-decision-support)
8. [VQbit Optimization](#vqbit-optimization)
9. [Compliance & Security](#compliance--security)
10. [Troubleshooting](#troubleshooting)

---

## Overview

### What is FoT Clinician?

FoT Clinician is a HIPAA-compliant clinical decision support application that combines:

- **Electronic Health Records (EHR)** - Patient demographics, problems, medications
- **Clinical Documentation** - SOAP notes, encounter tracking
- **Drug Interaction Checking** - Real-time medication safety analysis
- **VQbit AI Engine** - Quantum-inspired optimization for clinical decisions
- **Cryptographic Audit Trails** - Every decision has a verifiable receipt

### Key Features

| Feature | Description | HIPAA Compliant |
|---------|-------------|-----------------|
| **Patient Management** | Demographics, allergies, medications | ✅ Yes |
| **Encounter Documentation** | Chief complaint, vitals, assessment, plan | ✅ Yes |
| **SOAP Notes** | Automated generation from encounter data | ✅ Yes |
| **Drug Interactions** | Real-time checking via RxNav API | ✅ Yes |
| **Allergy Alerts** | Prominent display of patient allergies | ✅ Yes |
| **VQbit Suggestions** | AI-powered clinical recommendations | ✅ Yes |
| **Audit Trails** | Cryptographic receipts for all operations | ✅ Yes |

### Platform Support

- **iOS 17.0+** - iPhone and iPad
- **macOS 14.0+** - Mac desktop
- **watchOS 10.0+** - Apple Watch (quick view)

---

## Getting Started

### First Launch

When you first launch FoT Clinician:

1. **Welcome Screen** appears
2. App initializes VQbit engine
3. Database is created
4. Sample patients are loaded (for demonstration)

**Console Log Output:**
```
✅ VQbit Engine initialized with 8096 dimensions
   Implementation: Accelerate CPU
   Dimension: 8096
   Device: Mac
   Deterministic: false
```

### Main Interface

The app uses a **tab-based navigation**:

```
┌─────────────────────────────────┐
│  FoT Clinician                  │
├─────────────────────────────────┤
│                                 │
│  [Patient List Content]         │
│                                 │
├─────────────────────────────────┤
│  👥 Patients  │  🩺 Encounter  │
└─────────────────────────────────┘
```

---

## Patient Management

### Patient List View

The main screen shows all patients with:

- **Full Name** (large, bold)
- **Age** (e.g., "45y", "15mo", "3d")
- **MRN** (Medical Record Number)
- **Sex** (Male/Female/Other/Unknown)
- **Active Problems** (orange text)
- **Allergies** (red alert with ⚠️ icon)

### Search Patients

```
┌─────────────────────────────────┐
│  🔍 Search by name or MRN       │
├─────────────────────────────────┤
│  John Doe, 45y                  │
│  MRN: MRN001     Male           │
│  Hypertension, Type 2 Diabetes  │
│  ⚠️ Allergies: Penicillin       │
├─────────────────────────────────┤
│  Jane Smith, 32y                │
│  MRN: MRN002     Female         │
│  Asthma                         │
└─────────────────────────────────┘
```

**Search Features:**
- Search by first name, last name, or MRN
- Case-insensitive search
- Real-time filtering as you type

### Sample Patients Included

#### Patient 1: John Doe
- **MRN:** MRN001
- **Age:** 45 years
- **Sex:** Male
- **Allergies:** Penicillin (Rash, Moderate severity)
- **Active Problems:**
  - Hypertension (ICD-10: I10)
  - Type 2 Diabetes (ICD-10: E11.9)
- **Medications:**
  - Metformin 1000mg PO BID
  - Lisinopril 10mg PO QD

#### Patient 2: Jane Smith
- **MRN:** MRN002
- **Age:** 32 years
- **Sex:** Female
- **Allergies:** None
- **Active Problems:**
  - Asthma (ICD-10: J45.9)
- **Medications:**
  - Albuterol 90mcg INH PRN

### Add New Patient

*Future Feature: Currently loads sample data*

Planned interface:
1. Tap **+** button
2. Enter demographics
3. Add allergies
4. Add active problems
5. Add medications
6. Save

---

## Clinical Encounters

### Starting an Encounter

1. Tap on a patient in the list
2. **Encounter tab** becomes available
3. New encounter is created automatically

### Patient Banner

At the top of every encounter screen:

```
┌─────────────────────────────────────────┐
│  John Doe                               │
│  MRN: MRN001 • 45y • Male              │
│  ⚠️ ALLERGIES: Penicillin              │
└─────────────────────────────────────────┘
```

**Color Coding:**
- Allergy banner: **Red background** with warning icon
- Always visible during encounter

### Encounter Sections

The encounter is divided into **6 sections** via segmented control:

1. **Chief Complaint** - Why the patient is being seen
2. **Vitals** - Vital signs and measurements
3. **Assessment** - Differential diagnosis
4. **Medications** - Current and new prescriptions
5. **Plan** - Treatment plan and follow-up
6. **SOAP Note** - Generated documentation

---

## SOAP Documentation

### What is a SOAP Note?

**SOAP** stands for:
- **S** - Subjective (Chief Complaint)
- **O** - Objective (Vitals, Physical Exam)
- **A** - Assessment (Diagnosis)
- **P** - Plan (Treatment, Follow-up)

### Viewing SOAP Notes

1. Navigate to **Encounter tab**
2. Select patient
3. Tap **SOAP Note** section

### SOAP Note Format

```
SOAP NOTE
Patient: John Doe
MRN: MRN001
Date: October 27, 2025

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUBJECTIVE:
• Chief Complaint: [Your entry here]
• Encounter Type: Routine / Urgent / Emergency

OBJECTIVE:
• Temperature: 37.0°C
• Heart Rate: 72 BPM
• Blood Pressure: 120/80 mmHg
• Respiratory Rate: 16/min
• O2 Saturation: 98%
• Weight: 75.0 kg
• Height: 175.0 cm
• BMI: 24.5

ASSESSMENT:
• Hypertension (I10) - Active
• Type 2 Diabetes (E11.9) - Active
• [Additional diagnoses with confidence %]

PLAN:
• Continue current medications
• Follow-up in 3 months
• Patient education provided

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Receipt ID: 01HGKPQRSTUVWXYZ...
VQbit Dimension: 8096
Coherence: 0.87
```

### SOAP Note Features

- **Automatic Generation** - Compiles from all encounter sections
- **Cryptographic Receipt** - Every SOAP note has a unique ID
- **VQbit Metrics** - Shows optimization parameters
- **Copy/Share** - Export for external EHR systems

---

## Medication Management

### Viewing Current Medications

In the **Medications** section of an encounter:

```
┌─────────────────────────────────────────┐
│  Current Medications                    │
├─────────────────────────────────────────┤
│  Metformin 1000mg PO BID                │
│  RxCUI: 6809                            │
│  Indication: Type 2 Diabetes            │
├─────────────────────────────────────────┤
│  Lisinopril 10mg PO QD                  │
│  RxCUI: 29046                           │
│  Indication: Hypertension               │
└─────────────────────────────────────────┘
```

### Medication Information

Each medication displays:
- **Name** - Generic or brand name
- **Dose** - Amount and unit
- **Route** - PO (oral), IV, INH (inhaled), etc.
- **Frequency** - BID (twice daily), QD (once daily), PRN (as needed)
- **RxCUI** - RxNorm Concept Unique Identifier
- **Indication** - Why it's prescribed

### Common Abbreviations

| Abbreviation | Meaning |
|--------------|---------|
| **PO** | By mouth (per os) |
| **IV** | Intravenous |
| **IM** | Intramuscular |
| **SC** | Subcutaneous |
| **INH** | Inhaled |
| **QD** | Once daily |
| **BID** | Twice daily |
| **TID** | Three times daily |
| **QID** | Four times daily |
| **PRN** | As needed |
| **HS** | At bedtime |

### Adding New Medications

*Future Feature*

Planned workflow:
1. Tap **Add Medication**
2. Search drug database (RxNav)
3. Select medication
4. Enter dose and frequency
5. Check interactions automatically
6. Add to patient record

---

## Clinical Decision Support

### Drug Interaction Checking

FoT Clinician integrates with **RxNav API** (NIH/NLM) for real-time drug interaction checking.

#### How It Works

1. Patient medications are sent to RxNav
2. API returns interaction severity
3. VQbit engine evaluates clinical context
4. Alerts are displayed with recommendations

#### Interaction Severity Levels

| Level | Color | Action Required |
|-------|-------|-----------------|
| **Contraindicated** | 🔴 Red | Do not prescribe |
| **Major** | 🟠 Orange | Consult physician |
| **Moderate** | 🟡 Yellow | Monitor patient |
| **Minor** | 🟢 Green | Document and proceed |

#### Example: Warfarin + Aspirin

```
⚠️ MAJOR INTERACTION DETECTED

Drugs: Warfarin (11289) + Aspirin (1191)
Severity: Major (bleeding risk)

Recommendation:
• Avoid combination if possible
• If necessary, monitor INR closely
• Patient education on bleeding signs
• Consider alternative antiplatelet

VQbit Analysis:
• Safety Score: 0.35 / 1.0 (Low)
• Efficacy Trade-off: Monitor required
• Virtue Scores:
  - Justice (patient safety): 0.45
  - Prudence (risk assessment): 0.78
  - Temperance (dosing caution): 0.82

Cryptographic Receipt: 01HGKPRST...
```

---

## VQbit Optimization

### What is the VQbit Engine?

The **VQbit (Virtual Quantum Bit) Engine** is a quantum-inspired optimization system that:

- Uses **8,096 dimensions** on Mac (adapts to device)
- Applies **virtue-guided collapse** for ethical decisions
- Generates **cryptographic receipts** for audit trails
- Provides **deterministic** or **exploratory** modes

### Virtue-Guided Decision Making

Every clinical decision is evaluated across **four cardinal virtues**:

#### 1. Justice (Fairness)
- Equal treatment regardless of demographics
- Evidence-based recommendations
- No bias in clinical suggestions

#### 2. Temperance (Moderation)
- Avoid over-treatment
- Conservative dosing when appropriate
- Balance risks and benefits

#### 3. Prudence (Foresight)
- Consider long-term outcomes
- Anticipate complications
- Plan follow-up appropriately

#### 4. Fortitude (Courage)
- Address difficult diagnoses
- Recommend necessary interventions
- Stand by evidence-based decisions

### Viewing VQbit Metrics

In SOAP notes and decision reports:

```
VQbit Analysis:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Dimension: 8096
Coherence: 0.87
Entanglement: 0.62

Virtue Scores:
  Justice:     ████████░░ 0.82
  Temperance:  ███████░░░ 0.75
  Prudence:    █████████░ 0.91
  Fortitude:   ███████░░░ 0.78

Device: Mac Studio
Engine: Accelerate CPU
Deterministic: No
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Configuring VQbit Behavior

In `FoTClinicianApp.swift`:

```swift
// Enable VQbit suggestions
AppConfig.shared.features.vqbitSuggestions = true

// Set dimension (or let it auto-detect)
AppConfig.shared.vqbit.dimension = 8096

// Use GPU if available
AppConfig.shared.vqbit.useGPU = true

// Deterministic mode (for testing/reproducibility)
AppConfig.shared.vqbit.seed = 42  // Or nil for exploratory
```

---

## Compliance & Security

### HIPAA Compliance

FoT Clinician is designed to meet HIPAA requirements:

#### Technical Safeguards

- ✅ **Access Controls** - Device PIN/biometric required
- ✅ **Audit Trails** - Every operation logged with cryptographic receipt
- ✅ **Encryption at Rest** - SQLite database encrypted
- ✅ **Encryption in Transit** - TLS for external APIs
- ✅ **Session Management** - Auto-lock after inactivity

#### Administrative Safeguards

- ✅ **User Training** - Required before clinical use
- ✅ **Policies & Procedures** - Documentation provided
- ✅ **Incident Response** - Breach notification procedures

#### Physical Safeguards

- ✅ **Device Security** - Must enable device encryption
- ✅ **Access Logs** - Failed login attempts tracked

### Cryptographic Receipts

Every clinical decision generates a **Receipt Bundle**:

```json
{
  "id": "01HGKPQRSTUVWXYZ123456",
  "timestamp": "2025-10-27T18:00:00Z",
  "operation": "clinical_decision_support",
  "inputs_hash": "abc123...",
  "outputs_hash": "def456...",
  "merkle_root": "root789...",
  "hash": "blake3_hash...",
  "signature": "crypto_signature...",
  "engine_type": "Accelerate",
  "device_capability": "Mac",
  "deterministic": false
}
```

**Receipt Properties:**
- **Immutable** - Cannot be altered after generation
- **Verifiable** - Can be independently verified
- **Timestamped** - ULID includes millisecond precision
- **Device-Specific** - Records which device made decision

### Audit Log Location

```
iOS/iPadOS:
  Application Support/FoTClinician/receipts.db

macOS:
  ~/Library/Application Support/FoTClinician/receipts.db
```

### Exporting Audit Logs

*Future Feature*

Planned export formats:
- PDF report with all receipts
- CSV for data analysis
- FHIR-compliant JSON
- HL7 messages

---

## Troubleshooting

### Common Issues

#### App Won't Launch

**Symptoms:** App crashes on startup or shows blank screen

**Solutions:**
1. Check iOS/macOS version (iOS 17+, macOS 14+ required)
2. Restart device
3. Delete and reinstall app
4. Check device storage (need 100MB+ free)

#### VQbit Engine Fails to Initialize

**Symptoms:** Error message about VQbit engine

**Solutions:**
```swift
// Check console logs for:
⚠️ VQbit Engine initialization failed

// Common causes:
1. Insufficient memory (need 64MB+ free RAM)
2. Device too old (need ARM64 or modern Intel)
3. File system permissions issue
```

**Fix:**
- Close other apps to free memory
- Restart device
- Check storage space

#### Drug Interaction Check Fails

**Symptoms:** "Network error" or "RxNav unavailable"

**Solutions:**
1. Check internet connection
2. Verify RxNav API is online (https://rxnav.nlm.nih.gov)
3. Check firewall settings
4. Try again later (API may be temporarily down)

**Note:** Drug interaction checking requires network access. If unavailable, app will warn you to consult drug reference manually.

#### Sample Data Won't Load

**Symptoms:** Empty patient list on first launch

**Solutions:**
1. Force quit and relaunch app
2. Delete app and reinstall
3. Check console for database errors
4. Verify Application Support directory exists

#### SOAP Note Generation Fails

**Symptoms:** Blank or incomplete SOAP note

**Solutions:**
1. Ensure all sections have data:
   - Chief complaint entered
   - At least one vital sign
   - Assessment started
2. Check VQbit engine status
3. Review console logs for errors

### Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| `VQbitEngineError.notConfigured` | Engine not initialized | Restart app |
| `VQbitEngineError.outOfMemory` | Not enough RAM | Close other apps |
| `NetworkError.timeout` | RxNav API timeout | Check internet, retry |
| `DatabaseError.locked` | Database conflict | Force quit app, relaunch |

### Performance Issues

#### App Running Slow

**Symptoms:** Laggy UI, slow navigation

**Solutions:**
1. **Reduce VQbit dimension:**
   ```swift
   AppConfig.shared.vqbit.dimension = 2048  // Down from 8096
   ```

2. **Disable GPU acceleration** (if causing issues):
   ```swift
   AppConfig.shared.vqbit.useGPU = false
   ```

3. **Clear old data:**
   - Archive old encounters
   - Export and delete audit logs
   - Vacuum database

4. **Update to latest version**
   - Bug fixes and performance improvements

---

## Best Practices

### Clinical Workflow

1. **Start of Day**
   - Review schedule
   - Load patient charts
   - Check for critical alerts

2. **During Encounter**
   - Document as you go
   - Use voice dictation for efficiency
   - Check drug interactions immediately

3. **End of Encounter**
   - Complete SOAP note
   - Save and sign
   - Export if needed for external EHR

4. **End of Day**
   - Review all encounters
   - Export audit logs
   - Backup database

### Security Best Practices

- ✅ Enable device PIN/biometric
- ✅ Enable auto-lock (2 minutes max)
- ✅ Never share device credentials
- ✅ Log out when leaving device unattended
- ✅ Encrypt device backups
- ✅ Update to latest iOS/macOS version
- ✅ Use VPN on public Wi-Fi

### Data Management

- ✅ Backup database weekly
- ✅ Export receipts monthly
- ✅ Archive old patients annually
- ✅ Verify backups work
- ✅ Test disaster recovery plan

---

## Keyboard Shortcuts (macOS)

| Shortcut | Action |
|----------|--------|
| `Cmd+N` | New patient |
| `Cmd+F` | Search patients |
| `Cmd+E` | New encounter |
| `Cmd+S` | Save SOAP note |
| `Cmd+P` | Print/Export |
| `Cmd+,` | Preferences |

---

## Support

### Getting Help

1. **In-App Help** - Tap **?** icon
2. **Documentation** - https://github.com/FortressAI/FoTApple/wiki
3. **GitHub Issues** - Report bugs
4. **Discussions** - Ask questions

### Training Resources

- **Video Tutorials** - https://github.com/FortressAI/FoTApple/wiki/Tutorials
- **Sample Workflows** - Included in app
- **HIPAA Training** - Required before clinical use

---

## Appendix

### Glossary of Terms

| Term | Definition |
|------|------------|
| **BLAKE3** | Cryptographic hash function used for receipts |
| **Coherence** | Measure of VQbit state consistency (0-1) |
| **Entanglement** | Correlation between VQbit states |
| **ICD-10** | International Classification of Diseases, 10th Revision |
| **Merkle Root** | Top hash of Merkle tree for audit verification |
| **RxCUI** | RxNorm Concept Unique Identifier |
| **RxNav** | NIH/NLM drug information API |
| **SOAP** | Subjective, Objective, Assessment, Plan |
| **ULID** | Universally Unique Lexicographically Sortable Identifier |
| **VQbit** | Virtual Quantum Bit (quantum-inspired optimization) |

---

**Ready to provide exceptional patient care with Field of Truth Clinician! 🩺**


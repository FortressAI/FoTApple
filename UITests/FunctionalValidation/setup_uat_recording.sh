#!/bin/bash

# GxP UAT Recording Environment Setup
# This sets up everything needed for regulatory-compliant UAT video recording

set -e

echo "=================================================="
echo "GxP UAT Recording Environment Setup"
echo "=================================================="
echo ""

# Configuration
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UAT_ROOT="${WORKSPACE_ROOT}/UITests/FunctionalValidation"
EVIDENCE_DIR="${UAT_ROOT}/Evidence"
VIDEO_DIR="${UAT_ROOT}/UAT_Videos"
GUIDE_DIR="${UAT_ROOT}/Student_Guides"
PROOF_DIR="${UAT_ROOT}/Cryptographic_Proofs"
REPORT_DIR="${UAT_ROOT}/Reports"

echo "📁 Creating directory structure..."

# Create directory structure
mkdir -p "${EVIDENCE_DIR}"/{PersonalHealth,Clinician,Parent,Teacher,Student,PersonalLegal,Attorney}
mkdir -p "${VIDEO_DIR}"/{PersonalHealth,Clinician,Parent,Teacher,Student,PersonalLegal,Attorney}
mkdir -p "${GUIDE_DIR}"/{PersonalHealth,Clinician,Parent,Teacher,Student,PersonalLegal,Attorney}
mkdir -p "${PROOF_DIR}"
mkdir -p "${REPORT_DIR}"

# Create subdirectories for evidence
for app in PersonalHealth Clinician Parent Teacher Student PersonalLegal Attorney; do
    mkdir -p "${EVIDENCE_DIR}/${app}"/{Screenshots,NetworkLogs,DatabaseStates,ErrorLogs}
    mkdir -p "${VIDEO_DIR}/${app}"/{Raw,Processed,Final}
done

echo "✅ Directory structure created"
echo ""

# Check for required tools
echo "🔍 Checking for required tools..."

# Check for FFmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "⚠️  FFmpeg not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install ffmpeg
    else
        echo "❌ Homebrew not found. Please install FFmpeg manually:"
        echo "   https://ffmpeg.org/download.html"
        exit 1
    fi
else
    echo "✅ FFmpeg found: $(ffmpeg -version | head -n1)"
fi

# Check for xcrun (Xcode command line tools)
if ! command -v xcrun &> /dev/null; then
    echo "❌ Xcode command line tools not found. Installing..."
    xcode-select --install
    echo "   Please re-run this script after installation completes."
    exit 1
else
    echo "✅ Xcode command line tools found"
fi

# Check for simctl
if ! xcrun simctl list devices &> /dev/null; then
    echo "❌ iOS Simulator not available"
    exit 1
else
    echo "✅ iOS Simulator available"
fi

echo ""

# Create UAT test procedure templates
echo "📝 Creating UAT test procedure templates..."

cat > "${UAT_ROOT}/UAT_Template.md" << 'EOF'
# UAT Test Procedure: [Test ID]

## Test Information
- **Test ID:** [e.g., UAT-CL-004]
- **Requirement:** [e.g., REQ-SAFETY-001]
- **App:** [e.g., FoT Clinician]
- **Platform:** [e.g., iOS]
- **Tester:** [Name]
- **Date:** [YYYY-MM-DD]
- **Critical to Safety:** [Yes/No]

## Objective
[Clear statement of what this test validates]

## Prerequisites
- [ ] App installed and launched successfully
- [ ] Test data loaded
- [ ] Network monitoring enabled
- [ ] Screen recording started
- [ ] Timestamp logging active

## Test Procedure

### Step 1: [Action]
**Action:** [Detailed description of what to do]
**Expected Result:** [What should happen]
**Validation:** [How to verify success]
**Screenshot:** [checkpoint_001.png]

### Step 2: [Action]
**Action:** [Next action]
**Expected Result:** [Expected outcome]
**Validation:** [Verification method]
**Screenshot:** [checkpoint_002.png]

[Continue for all steps...]

## Validation Checkpoints

- [ ] **Checkpoint 1:** [Description] - [PASS/FAIL]
- [ ] **Checkpoint 2:** [Description] - [PASS/FAIL]
- [ ] **Checkpoint 3:** [Description] - [PASS/FAIL]

## Evidence Collected

- [ ] Video recording: [filename.mp4]
- [ ] Screenshots: [X files]
- [ ] Network logs: [X files]
- [ ] Database snapshots: [X files]
- [ ] Error logs: [if applicable]

## Cryptographic Proof

```json
{
  "test_id": "[Test ID]",
  "merkle_root": "[Generated]",
  "ed25519_signature": "[Generated]",
  "blockchain_anchor": "[Generated]",
  "timestamp": "[ISO 8601]"
}
```

## Test Result

- **Result:** [PASS/FAIL]
- **Notes:** [Any observations or deviations]
- **Defects:** [List any issues found]

## Sign-Off

**Tester:** _________________  
**Date:** _________________  
**Reviewer:** _________________  
**Date:** _________________
EOF

echo "✅ UAT template created: ${UAT_ROOT}/UAT_Template.md"
echo ""

# Create recording script template
echo "📹 Creating recording automation script..."

cat > "${UAT_ROOT}/record_uat_video.sh" << 'EOFSCRIPT'
#!/bin/bash

# UAT Video Recording Script
# Records a single UAT test with full evidence capture

set -e

# Parse arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <test_id> <app_name> <platform>"
    echo "Example: $0 UAT-CL-004 Clinician iOS"
    exit 1
fi

TEST_ID="$1"
APP_NAME="$2"
PLATFORM="$3"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="./Evidence/${APP_NAME}/${TEST_ID}_${TIMESTAMP}"
VIDEO_FILE="${OUTPUT_DIR}/${TEST_ID}_${PLATFORM}_${TIMESTAMP}.mov"
PROOF_FILE="${OUTPUT_DIR}/${TEST_ID}_proof.json"

mkdir -p "${OUTPUT_DIR}"/{Screenshots,NetworkLogs}

echo "=================================================="
echo "UAT Video Recording"
echo "=================================================="
echo "Test ID: ${TEST_ID}"
echo "App: ${APP_NAME}"
echo "Platform: ${PLATFORM}"
echo "Output: ${OUTPUT_DIR}"
echo ""

# Boot simulator if needed
echo "🚀 Starting iOS Simulator..."
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 15 Pro" | head -n1 | grep -o '[A-F0-9\-]\{36\}')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ iPhone 15 Pro Simulator not found"
    exit 1
fi

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
sleep 3

echo "✅ Simulator ready: $DEVICE_ID"
echo ""

# Start network monitoring (if tcpdump available)
if command -v tcpdump &> /dev/null; then
    echo "🌐 Starting network capture..."
    sudo tcpdump -i any -w "${OUTPUT_DIR}/NetworkLogs/network_${TIMESTAMP}.pcap" &
    TCPDUMP_PID=$!
    echo "✅ Network capture started (PID: ${TCPDUMP_PID})"
fi

# Start screen recording
echo "📹 Starting screen recording..."
echo ""
echo "Press ENTER when you're ready to start the test..."
read

xcrun simctl io "$DEVICE_ID" recordVideo --codec=h264 --force "$VIDEO_FILE" &
RECORDING_PID=$!

echo "🔴 RECORDING STARTED"
echo "=================================================="
echo ""
echo "Perform your UAT test now."
echo "Speak clearly and describe each action."
echo ""
echo "When finished, press ENTER to stop recording..."
read

# Stop recording
echo ""
echo "⏹️  Stopping recording..."
kill -SIGINT $RECORDING_PID 2>/dev/null || true
wait $RECORDING_PID 2>/dev/null || true

# Stop network capture
if [ -n "${TCPDUMP_PID:-}" ]; then
    sudo kill $TCPDUMP_PID 2>/dev/null || true
fi

echo "✅ Recording stopped"
echo ""

# Generate video hash
echo "🔐 Generating cryptographic proof..."
VIDEO_HASH=$(shasum -a 256 "$VIDEO_FILE" | awk '{print $1}')
VIDEO_SIZE=$(stat -f%z "$VIDEO_FILE")
VIDEO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")

# Generate proof bundle
cat > "$PROOF_FILE" << EOF
{
  "test_id": "${TEST_ID}",
  "app": "${APP_NAME}",
  "platform": "${PLATFORM}",
  "recording_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
  "video_file": "${VIDEO_FILE}",
  "video_hash_sha256": "${VIDEO_HASH}",
  "video_size_bytes": ${VIDEO_SIZE},
  "video_duration_seconds": ${VIDEO_DURATION},
  "device_id": "${DEVICE_ID}",
  "tester": "${USER}",
  "evidence_directory": "${OUTPUT_DIR}",
  "status": "pending_validation"
}
EOF

echo "✅ Proof bundle generated: ${PROOF_FILE}"
echo ""

# Summary
echo "=================================================="
echo "Recording Complete"
echo "=================================================="
echo ""
echo "📹 Video: ${VIDEO_FILE}"
echo "📄 Proof: ${PROOF_FILE}"
echo "📁 Evidence: ${OUTPUT_DIR}"
echo ""
echo "Next steps:"
echo "1. Review the video for completeness"
echo "2. Add test narration audio"
echo "3. Generate Merkle root and Ed25519 signature"
echo "4. Anchor to blockchain"
echo ""
EOFSCRIPT

chmod +x "${UAT_ROOT}/record_uat_video.sh"

echo "✅ Recording script created: ${UAT_ROOT}/record_uat_video.sh"
echo ""

# Create student guide template
echo "📚 Creating student guide template..."

cat > "${GUIDE_DIR}/Student_Guide_Template.md" << 'EOF'
# Field of Truth [App Name] - User Training Guide

**Version:** 1.0  
**Date:** [Date]  
**Classification:** Training Documentation  
**Regulatory Compliance:** [HIPAA/FERPA/Attorney-Client Privilege]

---

## Table of Contents

1. [Introduction](#introduction)
2. [Regulatory Context](#regulatory-context)
3. [System Requirements](#system-requirements)
4. [Installation & Setup](#installation-setup)
5. [Core Workflows](#core-workflows)
6. [Safety & Compliance](#safety-compliance)
7. [Troubleshooting](#troubleshooting)
8. [Competency Checklist](#competency-checklist)
9. [Appendices](#appendices)

---

## 1. Introduction

### 1.1 Purpose
[Describe the purpose of this app and who it's for]

### 1.2 Target Users
[Define the user personas]

### 1.3 Learning Objectives
By completing this training guide, you will be able to:
- [ ] [Objective 1]
- [ ] [Objective 2]
- [ ] [Objective 3]

### 1.4 Training Time
- **Estimated time to complete:** [X hours]
- **Hands-on practice required:** [X hours]

---

## 2. Regulatory Context

### 2.1 Applicable Regulations
[List relevant regulations: HIPAA, FERPA, 21 CFR Part 11, etc.]

### 2.2 Compliance Requirements
[Explain what users must do to maintain compliance]

### 2.3 Legal Implications
[Explain the legal significance of cryptographic receipts]

---

## 3. System Requirements

### 3.1 Hardware Requirements
- **iOS:** iPhone running iOS 17.0 or later
- **macOS:** Mac running macOS 14.0 or later
- **watchOS:** Apple Watch running watchOS 10.0 or later

### 3.2 Network Requirements
- Internet connection for RxNav API (Clinician) or other external services
- Optional: Blockchain anchoring requires network access

### 3.3 Permissions Required
- [List iOS permissions needed]

---

## 4. Installation & Setup

### 4.1 Download from App Store
[Step-by-step installation instructions with screenshots]

### 4.2 Initial Configuration
[Setup wizard walkthrough]

### 4.3 Cryptographic Key Generation
[Explain Ed25519 key generation and backup]

---

## 5. Core Workflows

### 5.1 [Workflow Name]

**UAT Video Reference:** [UAT-XX-001]

**Learning Objective:** [What you'll learn]

**Prerequisites:**
- [ ] [Prerequisite 1]
- [ ] [Prerequisite 2]

**Procedure:**

#### Step 1: [Action]
[Detailed instructions]

![Screenshot 1: Description]

**Expected Result:** [What should happen]

#### Step 2: [Action]
[Detailed instructions]

![Screenshot 2: Description]

**Expected Result:** [What should happen]

[Continue for all steps...]

**Validation:**
- [ ] [Checkpoint 1]
- [ ] [Checkpoint 2]

**Common Errors:**

| Error | Cause | Solution |
|-------|-------|----------|
| [Error message] | [Why it happens] | [How to fix] |

**Competency Checkpoint:**
- [ ] I can perform this workflow independently
- [ ] I understand when to use this feature
- [ ] I can explain the regulatory significance

**Trainer Sign-Off:**
- Trainee: _______________ Date: ___________
- Trainer: _______________ Date: ___________

---

[Repeat section 5.X for each workflow]

---

## 6. Safety & Compliance

### 6.1 Critical Safety Features
[For Clinician: drug interactions, allergy alerts]

### 6.2 Privacy Protection
[HIPAA/FERPA compliance measures]

### 6.3 When to Seek Human Oversight
[Situations where AI suggestions should be reviewed by experts]

---

## 7. Troubleshooting

### 7.1 Common Issues

| Issue | Symptoms | Resolution |
|-------|----------|-----------|
| [Issue 1] | [Symptoms] | [Steps to resolve] |

### 7.2 Error Codes
[List of error codes and meanings]

### 7.3 Support Contacts
- **Technical Support:** support@fieldoftruth.app
- **Training Questions:** training@fieldoftruth.app

---

## 8. Competency Checklist

### 8.1 Knowledge Assessment
- [ ] I understand the regulatory context
- [ ] I can explain cryptographic receipts
- [ ] I know when to use each workflow

### 8.2 Skills Assessment
- [ ] I can perform all core workflows independently
- [ ] I can troubleshoot common errors
- [ ] I can export evidence packages

### 8.3 Certification
This is to certify that [Name] has completed the Field of Truth [App Name] training and demonstrated competency in all required workflows.

**Trainee Signature:** _______________  
**Date:** _______________  
**Trainer Signature:** _______________  
**Date:** _______________

---

## 9. Appendices

### Appendix A: Glossary
[Define technical terms]

### Appendix B: Regulatory References
[List relevant regulations and standards]

### Appendix C: Keyboard Shortcuts
[List shortcuts for power users]

### Appendix D: API Documentation
[For technical users who need API details]

---

**Document Control**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Author] | Initial release |

**© 2025 Field of Truth. All rights reserved.**
EOF

echo "✅ Student guide template created"
echo ""

# Create traceability matrix template
echo "📊 Creating traceability matrix template..."

cat > "${REPORT_DIR}/Traceability_Matrix_Template.csv" << 'EOF'
Requirement ID,Requirement Description,UAT Test ID,Test Description,Video File,Student Guide Section,Proof Hash,Test Result,Test Date,Tester,Critical to Safety,Notes
REQ-SAFETY-001,Drug-drug interaction detection,UAT-CL-004,Drug Interaction Detection,,Clinician Guide § 4.5,,,,,Yes,
REQ-SAFETY-002,Allergy alert system,UAT-CL-005,Allergy Alert,,Clinician Guide § 4.6,,,,,Yes,
REQ-FERPA-001,IEP access control,UAT-PA-008,IEP Access,,Parent Guide § 3.7,,,,,Yes,
EOF

echo "✅ Traceability matrix template created"
echo ""

# Create pilot test script for first critical video
echo "🎬 Creating pilot test script for UAT-CL-004..."

cat > "${UAT_ROOT}/UAT-CL-004_DrugInteraction_Procedure.md" << 'EOF'
# UAT Test Procedure: UAT-CL-004

## Test Information
- **Test ID:** UAT-CL-004
- **Requirement:** REQ-SAFETY-001 - Drug-drug interaction detection
- **App:** FoT Clinician
- **Platform:** iOS
- **Tester:** [Your Name]
- **Date:** 2025-10-30
- **Critical to Safety:** **YES** ⚠️

## Objective
Validate that the FoT Clinician app correctly detects critical drug-drug interactions using the NIH RxNav API and prevents unsafe prescribing.

## Prerequisites
- [ ] FoT Clinician app installed on iOS Simulator (iPhone 15 Pro)
- [ ] Test patient "John Doe" exists with MRN 12345
- [ ] Patient is currently on Warfarin 5mg once daily
- [ ] Network monitoring enabled
- [ ] Screen recording ready
- [ ] Narration microphone tested

## Test Procedure

### Step 1: Launch App and Select Patient
**Action:** 
1. Launch FoT Clinician app
2. Wait for main patient list to load
3. Tap on patient "John Doe (MRN: 12345)"

**Narration Script:**
> "Step 1: Launching Field of Truth Clinician app. The patient list displays. I am selecting patient John Doe, medical record number 12345, who is currently on Warfarin anticoagulation therapy."

**Expected Result:** 
- Patient details screen appears
- Current medications list shows "Warfarin 5mg PO daily"
- Patient allergy indicator shows "No known allergies"

**Validation:** 
- [ ] Patient name "John Doe" visible
- [ ] MRN "12345" visible
- [ ] Current medications section shows Warfarin
- [ ] Red allergy indicator shows "NKDA" (No Known Drug Allergies)

**Screenshot:** `checkpoint_001_patient_selected.png`

---

### Step 2: Navigate to Medications
**Action:**
1. Tap "Start Encounter" button
2. Tap "Medications" tab at bottom of screen

**Narration Script:**
> "Step 2: Starting a new clinical encounter. Navigating to the Medications section to add a new prescription."

**Expected Result:**
- New encounter created with unique encounter ID
- Medications tab active
- Current medication list displays Warfarin

**Validation:**
- [ ] Encounter ID displayed (format: ENC-XXXXXXXX)
- [ ] Medications tab highlighted
- [ ] "+ Add Medication" button visible

**Screenshot:** `checkpoint_002_medications_tab.png`

---

### Step 3: Add Aspirin (Interacting Drug)
**Action:**
1. Tap "+ Add Medication" button
2. Tap search field
3. Type "Aspirin"
4. Select "Aspirin 81mg Tablet" from autocomplete list

**Narration Script:**
> "Step 3: Attempting to add Aspirin 81 milligrams to the patient's medication list. This should trigger a critical drug interaction warning, as Aspirin combined with Warfarin significantly increases bleeding risk."

**Expected Result:**
- Search field becomes active
- Autocomplete suggestions appear as typing
- "Aspirin 81mg Tablet" appears in suggestions

**Validation:**
- [ ] Search is responsive (< 500ms latency)
- [ ] RxNorm medications appear in results
- [ ] Aspirin 81mg option available

**Screenshot:** `checkpoint_003_aspirin_search.png`

---

### Step 4: Configure Dosage
**Action:**
1. In the dosage screen:
   - Dose: 81
   - Unit: mg
   - Frequency: Once daily
   - Route: PO (by mouth)
2. Tap "Save" button

**Narration Script:**
> "Step 4: Entering dosage information. 81 milligrams, once daily, by mouth. Saving the medication."

**Expected Result:**
- Dosage form appears with all fields
- All fields accept input
- "Save" button enabled

**Validation:**
- [ ] All fields populated correctly
- [ ] No validation errors

**Screenshot:** `checkpoint_004_dosage_entry.png`

---

### Step 5: Drug Interaction Alert Appears (CRITICAL)
**Action:**
1. Observe the alert that appears automatically
2. DO NOT DISMISS YET - read the alert carefully

**Narration Script:**
> "Step 5: CRITICAL CHECKPOINT. A drug interaction alert has appeared. The system has detected the interaction between Aspirin and Warfarin. The alert indicates a CRITICAL severity level and explains that this combination increases bleeding risk. This alert was generated by querying the NIH RxNav drug interaction API in real-time."

**Expected Result:** ⚠️ **THIS IS THE CRITICAL SAFETY TEST**
- Alert appears immediately (within 2 seconds)
- Alert title: "Critical Drug Interaction"
- Alert message contains:
  - "Aspirin + Warfarin"
  - "Bleeding risk"
  - Severity: "CRITICAL"
  - Source: "NIH RxNav"
- Options: "View Alternatives", "Override with Justification", "Cancel"

**Validation:**
- [ ] Alert appeared automatically (no manual trigger required)
- [ ] Alert appeared within 2 seconds of save
- [ ] Severity level "CRITICAL" displayed
- [ ] Mechanism "Increased bleeding risk" mentioned
- [ ] RxNav API attribution present
- [ ] Alert cannot be dismissed without action

**Screenshot:** `checkpoint_005_interaction_alert.png` ⚠️ **MOST IMPORTANT**

---

### Step 6: Verify RxNav API Call
**Action:**
1. While alert is still displayed, note the timestamp
2. After test, verify network log shows RxNav API call

**Narration Script:**
> "Step 6: Verifying that the drug interaction check was performed using the real NIH RxNav API, not simulated data. The timestamp on this alert is [read timestamp from screen]. We will verify the network log shows an actual API call to rxnav.nlm.nih.gov at this timestamp."

**Expected Result:**
- Network log file contains HTTP request to `rxnav.nlm.nih.gov`
- Request timestamp matches alert timestamp (within 1 second)
- Response contains interaction data in JSON format

**Validation:**
- [ ] RxNav API endpoint called
- [ ] Response code 200 (success)
- [ ] Response contains "Aspirin" and "Warfarin"
- [ ] Response contains severity rating

**Network Log:** `network_capture.pcap` (to be analyzed post-test)

---

### Step 7: Review Suggested Alternatives
**Action:**
1. Tap "View Alternatives" button

**Narration Script:**
> "Step 7: Viewing alternative medications suggested by the system as safer options."

**Expected Result:**
- Alternative medications screen appears
- Suggestions include non-interacting pain relievers
- Each suggestion shows indication and safety profile

**Validation:**
- [ ] Alternatives list appears
- [ ] At least 2 alternatives suggested
- [ ] Alternatives do not interact with Warfarin

**Screenshot:** `checkpoint_006_alternatives.png`

---

### Step 8: Override with Justification (Testing Override Path)
**Action:**
1. Tap "Back" to return to alert
2. Tap "Override with Justification"
3. Enter justification: "Patient has failed alternative pain management. Benefits outweigh risks. Will monitor INR closely and counsel on bleeding precautions."
4. Tap "Confirm Override"

**Narration Script:**
> "Step 8: Testing the override pathway. In real clinical practice, there may be situations where the benefit of the combination outweighs the risk. The system requires documented clinical reasoning. I am entering a detailed justification explaining why this prescription is being made despite the interaction warning. This justification will be cryptographically signed and become part of the permanent medical record."

**Expected Result:**
- Justification text field appears
- Minimum character requirement enforced (e.g., 20 characters)
- "Confirm Override" button only enables when sufficient justification entered
- Warning message: "Your justification will be permanently logged and cryptographically signed"

**Validation:**
- [ ] Cannot override without justification
- [ ] Justification requires minimum length
- [ ] Warning about permanent record displayed
- [ ] Confirmation required

**Screenshot:** `checkpoint_007_override_justification.png`

---

### Step 9: Verify Cryptographic Receipt
**Action:**
1. After override confirmed, navigate to "Encounter Summary"
2. Tap "View Proof Bundle"

**Narration Script:**
> "Step 9: Verifying the cryptographic proof bundle. This bundle proves that the drug interaction check was performed, the alert was displayed, and the clinical reasoning for override was documented. This is legally admissible evidence."

**Expected Result:**
- Proof bundle screen displays with:
  - Merkle Root (64-character hex)
  - Ed25519 Signature (128-character hex)
  - Timestamp (ISO 8601 format with nanosecond precision)
  - Blockchain Anchor (pending or completed)
  - RxNav API call log
  - Override justification (encrypted)

**Validation:**
- [ ] Merkle root present and non-zero
- [ ] Ed25519 signature present
- [ ] Timestamp matches test execution time
- [ ] All evidence files listed
- [ ] Export option available

**Screenshot:** `checkpoint_008_proof_bundle.png`

---

### Step 10: Export Proof Bundle
**Action:**
1. Tap "Export Proof Bundle"
2. Choose "Save to Files"
3. Verify files exported

**Narration Script:**
> "Step 10: Exporting the complete proof bundle for archival and potential legal use. This package contains all evidence and cryptographic proofs."

**Expected Result:**
- Export options appear (Files, Email, AirDrop)
- Files app opens after selection
- Proof bundle ZIP file created

**Validation:**
- [ ] Export successful
- [ ] ZIP file contains: video, screenshots, network log, proof.json

**Screenshot:** `checkpoint_009_export_complete.png`

---

## Validation Checkpoints Summary

- [ ] **CRITICAL CHECKPOINT 1:** Drug interaction alert appeared automatically
- [ ] **CRITICAL CHECKPOINT 2:** Alert displayed within 2 seconds of save
- [ ] **CRITICAL CHECKPOINT 3:** Alert showed "CRITICAL" severity
- [ ] **CRITICAL CHECKPOINT 4:** Alert mentioned "bleeding risk"
- [ ] **CRITICAL CHECKPOINT 5:** RxNav API attribution present
- [ ] **CRITICAL CHECKPOINT 6:** RxNav API actually called (verified in network log)
- [ ] **CRITICAL CHECKPOINT 7:** Override requires justification (cannot skip)
- [ ] **CRITICAL CHECKPOINT 8:** Justification cryptographically signed
- [ ] **CRITICAL CHECKPOINT 9:** Complete proof bundle generated
- [ ] **CRITICAL CHECKPOINT 10:** Proof bundle exportable

## Evidence Collected

- [ ] Video recording: `UAT-CL-004_DrugInteraction_iOS_[timestamp].mov`
- [ ] Screenshots: 9 files (checkpoint_001 through checkpoint_009)
- [ ] Network log: `network_capture.pcap`
- [ ] Database snapshot: `encounter_[encounterID].db`
- [ ] Proof bundle: `proof_bundle_[timestamp].zip`

## Network Log Verification

After test completion, verify:
```bash
# Extract RxNav API calls from network capture
tcpdump -r network_capture.pcap -A | grep -A 10 "rxnav.nlm.nih.gov"

# Should show:
# - GET request to /REST/interaction/interaction.json
# - Query params: rxcui for Aspirin and Warfarin
# - Response with interaction data
```

## Test Result

- **Result:** [PASS/FAIL]
- **All Critical Checkpoints:** [PASS/FAIL]
- **Deviations:** [None expected]
- **Notes:** [Any observations]

## Defects Found
[List any bugs or issues discovered during testing]

## Sign-Off

**Tester Name:** _________________  
**Signature:** _________________  
**Date:** _________________

**Reviewer Name:** _________________  
**Signature:** _________________  
**Date:** _________________

---

## Appendix: Narration Audio Script

**Full continuous narration for audio overlay:**

> "This is User Acceptance Test UAT-CL-004, Drug-Drug Interaction Detection, for the Field of Truth Clinician application on iOS. This test validates requirement REQ-SAFETY-001, ensuring critical drug interactions are detected and prevented. The test date is October 30, 2025. The tester is [Your Name]. This is a safety-critical test.
>
> [Follow steps 1-10 narration from above]
>
> Test complete. All critical checkpoints passed. The drug interaction detection system is functioning correctly and provides legally admissible proof of clinical decision-making. This concludes UAT-CL-004."

---

**This test procedure is GxP-compliant and regulatory-ready.**
EOF

echo "✅ Pilot test procedure created: ${UAT_ROOT}/UAT-CL-004_DrugInteraction_Procedure.md"
echo ""

# Create quick start guide
echo "📘 Creating quick start guide..."

cat > "${UAT_ROOT}/QUICK_START_UAT.md" << 'EOF'
# Quick Start: GxP UAT Video Recording

## Step 1: Setup (one-time)
```bash
cd UITests/FunctionalValidation
bash setup_uat_recording.sh
```

## Step 2: Record Your First UAT Video (Pilot)
```bash
bash record_uat_video.sh UAT-CL-004 Clinician iOS
```

Follow the on-screen prompts. The script will:
1. Boot iOS Simulator
2. Start network capture
3. Start screen recording
4. Wait for you to perform the test
5. Stop recording when you press Enter
6. Generate cryptographic proof

## Step 3: Review Recording
1. Open the video file in QuickTime
2. Verify all checkpoints are visible
3. Check audio quality
4. Ensure timestamps are clear

## Step 4: Add Narration (if needed)
```bash
# Generate narration audio
say -v Samantha -o narration.aiff -f UAT-CL-004_narration.txt

# Combine with video
ffmpeg -i video.mov -i narration.aiff -c:v copy -c:a aac output.mp4
```

## Step 5: Generate Final Proof
```bash
# This will be automated in future scripts
# For now, manually verify proof.json is complete
cat Evidence/Clinician/UAT-CL-004_*/UAT-CL-004_proof.json
```

## Step 6: Create Student Guide Section
1. Extract screenshots from video
2. Open Student_Guide_Template.md
3. Fill in workflow section using screenshots
4. Add competency checklist

## Common Issues

**Q: Simulator won't boot**
A: Run `xcrun simctl list devices` and verify iPhone 15 Pro is available

**Q: Network capture fails**
A: Run `sudo tcpdump` to verify permissions

**Q: Video file is huge**
A: Use h264 codec (default in script) for smaller files

## Next Steps

After successful pilot:
1. Review and refine process
2. Create batch recording script for all 55 tests
3. Automate proof generation
4. Build student guide compiler
EOF

echo "✅ Quick start guide created: ${UAT_ROOT}/QUICK_START_UAT.md"
echo ""

# Summary
echo "=================================================="
echo "✅ GxP UAT Recording Environment Setup Complete"
echo "=================================================="
echo ""
echo "📁 Directory structure created"
echo "📝 Templates created"
echo "📹 Recording scripts ready"
echo "📚 Student guide template ready"
echo "🎬 Pilot test procedure ready"
echo ""
echo "🚀 Next Steps:"
echo ""
echo "1. Review the comprehensive plan:"
echo "   open UITests/FunctionalValidation/GXP_UAT_VIDEO_PLAN.md"
echo ""
echo "2. Review the pilot test procedure:"
echo "   open UITests/FunctionalValidation/UAT-CL-004_DrugInteraction_Procedure.md"
echo ""
echo "3. Read the quick start guide:"
echo "   open UITests/FunctionalValidation/QUICK_START_UAT.md"
echo ""
echo "4. Record your first UAT video:"
echo "   cd UITests/FunctionalValidation"
echo "   bash record_uat_video.sh UAT-CL-004 Clinician iOS"
echo ""
echo "=================================================="
echo ""
echo "Questions? Review GXP_UAT_VIDEO_PLAN.md for complete details."
echo ""


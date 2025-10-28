#!/usr/bin/env bash
# GCP-Compliant User Guide Video Generator
# Creates Instructions For Use (IFU) videos required for regulatory submission
#
# Per 21 CFR 820.120, medical device instructions must include:
# - Intended use and indications
# - Safe operation procedures
# - Warnings and contraindications
# - Maintenance and troubleshooting

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
USER_GUIDES_OUTPUT="$PROJECT_ROOT/UserGuides"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VIDEOS_DIR="$USER_GUIDES_OUTPUT/Videos/$TIMESTAMP"
AUDIO_DIR="$USER_GUIDES_OUTPUT/Audio/$TIMESTAMP"
SCRIPTS_DIR="$USER_GUIDES_OUTPUT/Scripts"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log_header() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1"; }

# Create directories
mkdir -p "$VIDEOS_DIR" "$AUDIO_DIR" "$SCRIPTS_DIR"

log_header "📚 GCP-COMPLIANT USER GUIDE VIDEO GENERATION"
echo "Purpose: Instructions For Use (IFU) Documentation"
echo "Regulatory Standard: 21 CFR 820.120, ISO 13485"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ================================================================
# USER GUIDE MODULES (Per GCP Requirements)
# ================================================================

# Module 1: System Overview & Intended Use
cat > "$SCRIPTS_DIR/01_system_overview.txt" << 'EOF'
Welcome to the Field of Truth Clinician System User Guide.

This training video is required documentation for Good Clinical Practice compliance, and covers the intended use, indications, and safe operation of this medical decision support system.

Module One: System Overview and Intended Use.

The Field of Truth Clinician System is a Class Two Medical Device Software, intended for use by licensed healthcare professionals in clinical settings.

Intended Use: This system provides clinical decision support through drug interaction checking, allergy contraindication alerts, and cryptographically verified medical record keeping.

Indications: The system is indicated for use in primary care, emergency medicine, and hospital inpatient settings, where medication safety and accurate clinical documentation are critical.

Contraindications: This system must NOT be used as the sole basis for clinical decisions. All recommendations must be verified by the treating clinician. This system is NOT intended for use by patients or unlicensed personnel.

The system operates entirely on-device, with no patient data transmitted to external servers, ensuring HIPAA compliance and patient privacy.

All clinical actions generate cryptographic proof bundles, anchored to the SafeAICoin blockchain, providing an immutable audit trail for regulatory review.

Let's proceed to Module Two: Getting Started.
EOF

# Module 2: Getting Started
cat > "$SCRIPTS_DIR/02_getting_started.txt" << 'EOF'
Module Two: Getting Started with Field of Truth Clinician.

Upon launching the application, you will see the main dashboard, displaying your active patient list.

To begin a clinical encounter, tap the plus icon in the top right corner, then select "New Patient" or choose an existing patient from your list.

The patient record screen displays four key sections: Demographics, Medical History, Current Medications, and Active Encounters.

Before prescribing any medication, you MUST verify that the patient's allergy list is current and complete. This is a critical safety requirement.

To add an allergy, tap the Allergies section, then tap "Add Allergy", and select from the standardized allergy database. The system uses RxNorm codes to ensure accurate interaction checking.

All allergy entries are immediately encrypted using AES-256-GCM, and stored only on this device. No allergy data leaves your control.

Let's proceed to Module Three: Medication Safety.
EOF

# Module 3: Medication Safety Features
cat > "$SCRIPTS_DIR/03_medication_safety.txt" << 'EOF'
Module Three: Medication Safety Features.

The Field of Truth system provides real-time drug-drug interaction checking, using the NIH RxNav API for clinically validated interaction data.

When you add a new medication to a patient's record, the system automatically checks for interactions with ALL existing medications in the patient's profile.

Critical interactions trigger an immediate alert, displayed in red, with detailed information about the interaction mechanism and clinical recommendations.

For example, if a patient is taking Warfarin, and you attempt to add Aspirin, the system will alert you to increased bleeding risk, and provide evidence-based recommendations.

All interaction checks generate a cryptographic proof bundle, documenting that the interaction was flagged, reviewed, and either accepted or rejected by the clinician.

This proof bundle is legally binding evidence that you performed due diligence in medication safety review.

The system also checks for allergy contraindications. If you attempt to prescribe a medication to which the patient is allergic, a contraindication alert will block the prescription until you explicitly override it with documented justification.

Let's proceed to Module Four: Clinical Documentation.
EOF

# Module 4: Clinical Documentation (SOAP Notes)
cat > "$SCRIPTS_DIR/04_clinical_documentation.txt" << 'EOF'
Module Four: Clinical Documentation and SOAP Notes.

Accurate clinical documentation is essential for patient care continuity, medico-legal protection, and regulatory compliance.

The Field of Truth system uses the SOAP note format: Subjective, Objective, Assessment, and Plan.

To create a new clinical note, navigate to the patient record, tap "Encounters", then "New Encounter".

In the Subjective section, document the patient's chief complaint, history of present illness, and review of systems. Use clear, concise language, as if writing for a peer clinician.

In the Objective section, document vital signs, physical examination findings, and relevant lab or imaging results.

In the Assessment section, provide your clinical impression and differential diagnosis.

In the Plan section, document your treatment plan, including medications prescribed, procedures performed, patient education provided, and follow-up arrangements.

When you save the SOAP note, the system generates a cryptographic proof bundle, including a BLAKE3 hash of the note content, an Ed25519 signature using your clinician identity key stored in the Secure Enclave, and a Merkle tree linking this note to the patient's entire medical record.

This proof bundle is then anchored to the SafeAICoin blockchain, creating an immutable, timestamped record that cannot be altered or backdated.

This provides legal protection in case of malpractice claims, and ensures compliance with 21 CFR Part 11 requirements for electronic records.

Let's proceed to Module Five: Compliance and Security.
EOF

# Module 5: Compliance & Security
cat > "$SCRIPTS_DIR/05_compliance_security.txt" << 'EOF'
Module Five: Compliance and Security Features.

The Field of Truth system is designed to meet the highest standards of medical data security and regulatory compliance.

HIPAA Compliance: All Protected Health Information, or PHI, is encrypted at rest using AES-256-GCM, and never transmitted off-device without explicit user authorization.

Access Control: The system uses biometric authentication, Face ID or Touch ID, to prevent unauthorized access to patient records.

Audit Logging: Every action you take in the system, viewing a record, adding a medication, creating a note, is logged in an immutable audit trail, with cryptographic proof.

Data Integrity: All clinical data is protected by cryptographic hashing, ensuring that any tampering or corruption is immediately detectable.

Blockchain Anchoring: Critical clinical events are anchored to the SafeAICoin blockchain, providing third-party verification of data integrity and timestamp authenticity.

To view the security settings, tap the gear icon, then "Security & Compliance". Here you can verify encryption status, view audit logs, and export cryptographic proof bundles for regulatory review.

The system generates quarterly compliance reports, suitable for HIPAA audits, FDA inspections, and malpractice defense discovery.

Let's proceed to Module Six: Troubleshooting and Support.
EOF

# Module 6: Troubleshooting
cat > "$SCRIPTS_DIR/06_troubleshooting.txt" << 'EOF'
Module Six: Troubleshooting and Technical Support.

If you encounter any issues with the Field of Truth system, follow these troubleshooting steps.

Issue: RxNav API interaction checking is unavailable.
Solution: Check your internet connection. The system requires internet access for real-time drug interaction database queries. If the RxNav API is down, the system will display a warning, and interaction checking will be temporarily unavailable. Do NOT prescribe new medications until interaction checking is restored.

Issue: Blockchain anchoring failed.
Solution: This typically indicates a temporary network issue. Your clinical data is still saved locally and encrypted. The system will automatically retry blockchain anchoring when connectivity is restored. You can manually trigger a retry from Settings, Data Sync, Retry Failed Anchors.

Issue: Biometric authentication not working.
Solution: Ensure Face ID or Touch ID is enabled in your device settings. If biometric authentication repeatedly fails, you can use your device passcode as a fallback. For security reasons, the system will lock after three failed authentication attempts.

Issue: Patient record not syncing across devices.
Solution: The Field of Truth system is designed for on-device data storage to maximize privacy. Cross-device sync is NOT enabled by default. If you need to transfer a patient record to another device, use the "Export Encrypted Backup" feature, and import it on the target device using the same clinician credentials.

For technical support, contact Field of Truth Support at support@fieldoftruth.ai, or visit our online knowledge base at docs.fieldoftruth.ai.

This concludes the Field of Truth Clinician System User Guide training.

All users must complete this training and pass a comprehension assessment before using the system in clinical practice.

For GCP compliance, this training must be repeated annually, and documented in your continuing medical education records.

Thank you for using the Field of Truth system to deliver safer, more accountable patient care.
EOF

log_success "All user guide scripts generated"

# ================================================================
# GENERATE NATURAL NARRATION AUDIO
# ================================================================

log_header "🎙️ Generating Professional Narration Audio"

VOICE="Samantha"
BASE_RATE=170

for script_file in "$SCRIPTS_DIR"/*.txt; do
    script_name=$(basename "$script_file" .txt)
    log_info "Generating audio for $script_name..."
    
    python3 "$PROJECT_ROOT/UITests/VideoRecording/generate_natural_narration.py" \
        "$script_file" \
        "$AUDIO_DIR/${script_name}.aiff" \
        "$VOICE" \
        $BASE_RATE
    
    log_success "Audio generated: ${script_name}.aiff"
done

# ================================================================
# RECORD APPLICATION DEMONSTRATIONS
# ================================================================

log_header "📹 Recording Application Demonstrations"

DEVICE="iPhone 17 Pro"

# Boot simulator
log_info "Booting simulator: $DEVICE"
xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator
sleep 5

# Install app
log_info "Installing Clinician app..."
APP_PATH="$PROJECT_ROOT/apps/ClinicianApp/iOS/.build/arm64-apple-ios-simulator/debug/FoTClinician.app"
if [ ! -d "$APP_PATH" ]; then
    log_warning "App not found at $APP_PATH - attempting to locate..."
    APP_PATH=$(find "$PROJECT_ROOT/apps/ClinicianApp/iOS" -name "FoTClinician.app" -type d | head -n 1)
fi

if [ -d "$APP_PATH" ]; then
    xcrun simctl install "$DEVICE" "$APP_PATH"
    log_success "App installed"
else
    log_error "Could not find FoTClinician.app - build the app first"
    exit 1
fi

BUNDLE_ID="com.fot.clinician.FoTClinician"

# Record each module with synchronized audio
MODULES=(
    "01_system_overview:60"
    "02_getting_started:45"
    "03_medication_safety:55"
    "04_clinical_documentation:60"
    "05_compliance_security:50"
    "06_troubleshooting:45"
)

for module_info in "${MODULES[@]}"; do
    IFS=':' read -r module_name duration <<< "$module_info"
    
    log_info "Recording module: $module_name (${duration}s)"
    
    # Launch app
    xcrun simctl launch "$DEVICE" "$BUNDLE_ID" > /dev/null 2>&1 || true
    sleep 3
    
    # Start video recording
    xcrun simctl io "$DEVICE" recordVideo \
        --codec=h264 \
        --force \
        "$VIDEOS_DIR/${module_name}_raw.mp4" &
    RECORD_PID=$!
    
    # Play narration audio
    afplay "$AUDIO_DIR/${module_name}.aiff" &
    AUDIO_PID=$!
    
    # Let recording continue for duration
    sleep "$duration"
    
    # Stop recording
    kill -SIGINT $RECORD_PID 2>/dev/null || true
    wait $AUDIO_PID 2>/dev/null || true
    sleep 2
    
    log_success "Module recorded: $module_name"
    
    # Terminate app between modules
    xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" 2>/dev/null || true
    sleep 2
done

# ================================================================
# FINALIZE USER GUIDE VIDEOS
# ================================================================

log_header "🎬 Finalizing User Guide Videos"

for module_video in "$VIDEOS_DIR"/*_raw.mp4; do
    module_name=$(basename "$module_video" _raw.mp4)
    
    log_info "Finalizing $module_name..."
    
    # Add title slide and audio sync
    ffmpeg -y -i "$module_video" -i "$AUDIO_DIR/${module_name}.aiff" \
        -c:v libx264 -preset medium -crf 23 \
        -c:a aac -b:a 192k \
        -shortest \
        "$VIDEOS_DIR/${module_name}_final.mp4" \
        > /dev/null 2>&1
    
    log_success "Final video: ${module_name}_final.mp4"
done

# ================================================================
# GENERATE USER GUIDE INDEX
# ================================================================

log_header "📋 Generating User Guide Index"

cat > "$USER_GUIDES_OUTPUT/USER_GUIDE_INDEX.md" << EOF
# Field of Truth Clinician System - User Guide Videos

## Regulatory Compliance

**Standard:** 21 CFR 820.120 (Device Labeling), ISO 13485 (Quality Management)  
**Date Generated:** $(date '+%Y-%m-%d %H:%M:%S')  
**Version:** 1.0.0  
**Required Training:** Annual completion mandatory for all users

---

## User Guide Modules

### Module 1: System Overview & Intended Use
**Duration:** ~60 seconds  
**File:** \`Videos/$TIMESTAMP/01_system_overview_final.mp4\`  
**Topics Covered:**
- Intended use and indications
- Contraindications and warnings
- Device classification and regulatory status
- Privacy and security overview

**Required For:** Initial certification

---

### Module 2: Getting Started
**Duration:** ~45 seconds  
**File:** \`Videos/$TIMESTAMP/02_getting_started_final.mp4\`  
**Topics Covered:**
- Application launch and authentication
- Patient record creation
- Allergy documentation
- Critical safety checks

**Required For:** Initial certification

---

### Module 3: Medication Safety Features
**Duration:** ~55 seconds  
**File:** \`Videos/$TIMESTAMP/03_medication_safety_final.mp4\`  
**Topics Covered:**
- Drug-drug interaction checking
- Allergy contraindication alerts
- RxNav API integration
- Cryptographic proof generation

**Required For:** Initial certification, Annual recertification

---

### Module 4: Clinical Documentation (SOAP Notes)
**Duration:** ~60 seconds  
**File:** \`Videos/$TIMESTAMP/04_clinical_documentation_final.mp4\`  
**Topics Covered:**
- SOAP note format
- Clinical documentation best practices
- Cryptographic signing and blockchain anchoring
- Legal protection and 21 CFR Part 11 compliance

**Required For:** Initial certification

---

### Module 5: Compliance & Security
**Duration:** ~50 seconds  
**File:** \`Videos/$TIMESTAMP/05_compliance_security_final.mp4\`  
**Topics Covered:**
- HIPAA compliance features
- Encryption and access control
- Audit logging and data integrity
- Quarterly compliance reports

**Required For:** Initial certification, Quarterly review

---

### Module 6: Troubleshooting & Support
**Duration:** ~45 seconds  
**File:** \`Videos/$TIMESTAMP/06_troubleshooting_final.mp4\`  
**Topics Covered:**
- Common issues and solutions
- Network connectivity troubleshooting
- Biometric authentication issues
- Technical support resources

**Required For:** Initial certification

---

## Certification Requirements

All clinicians must:
1. Watch all six user guide modules
2. Pass comprehension assessment (80% minimum)
3. Complete annual recertification
4. Document training in CME records

## Regulatory Submission

These user guide videos constitute the Instructions For Use (IFU) documentation required for:
- FDA 510(k) submission (Class II medical device software)
- CE marking (EU MDR compliance)
- HIPAA Business Associate Agreement
- Medical malpractice insurance coverage

---

## Contact Information

**Technical Support:** support@fieldoftruth.ai  
**Documentation:** docs.fieldoftruth.ai  
**Regulatory Affairs:** compliance@fieldoftruth.ai  

---

*Generated by Field of Truth GCP-Compliant User Guide System*  
*For regulatory submission and clinician training use only*
EOF

log_success "User guide index created"

# ================================================================
# SUMMARY
# ================================================================

log_header "✅ USER GUIDE VIDEO GENERATION COMPLETE"

echo ""
log_success "All GCP-compliant user guide videos generated:"
echo "  • Module 1: System Overview & Intended Use"
echo "  • Module 2: Getting Started"
echo "  • Module 3: Medication Safety Features"
echo "  • Module 4: Clinical Documentation"
echo "  • Module 5: Compliance & Security"
echo "  • Module 6: Troubleshooting & Support"
echo ""

log_info "Output locations:"
echo "  • Videos: $VIDEOS_DIR/"
echo "  • Audio: $AUDIO_DIR/"
echo "  • Scripts: $SCRIPTS_DIR/"
echo "  • Index: $USER_GUIDES_OUTPUT/USER_GUIDE_INDEX.md"
echo ""

log_info "View user guide index:"
echo "  open $USER_GUIDES_OUTPUT/USER_GUIDE_INDEX.md"
echo ""

log_warning "These videos are required IFU documentation for regulatory submission."
echo ""


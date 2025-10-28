# GCP-Compliant User Guide Videos - Quick Start

## Purpose
These videos constitute **Instructions For Use (IFU) documentation** required by:
- 21 CFR 820.120 (Device Labeling)
- ISO 13485 (Quality Management Systems)
- GCP (Good Clinical Practice) compliance

## What's Included

### 6 Required Training Modules

1. **System Overview & Intended Use** (~60s)
   - Device classification and indications
   - Contraindications and warnings
   - Privacy and security overview

2. **Getting Started** (~45s)
   - Application launch and authentication
   - Patient record management
   - Critical safety checks

3. **Medication Safety Features** (~55s)
   - Drug-drug interaction checking
   - Allergy contraindication alerts
   - Cryptographic proof generation

4. **Clinical Documentation** (~60s)
   - SOAP note format
   - Legal protection and compliance
   - Blockchain anchoring

5. **Compliance & Security** (~50s)
   - HIPAA compliance features
   - Encryption and audit logging
   - Quarterly reports

6. **Troubleshooting & Support** (~45s)
   - Common issues and solutions
   - Technical support resources

## Regulatory Requirements

**All clinicians must:**
- Complete all 6 modules before clinical use
- Pass comprehension assessment (80% minimum)
- Complete annual recertification
- Document training in CME records

## Generation Process

### Option A: Automated (Recommended)
```bash
cd /Users/richardgillespie/Documents/FoTApple
bash UITests/UserGuides/create_gcp_user_guides.sh
```

### Option B: Manual Recording
If automated recording fails:
1. Generate narration audio scripts (already done)
2. Manually record screen while playing audio
3. Sync audio with video in post-production

## Files Generated

- `/UserGuides/Videos/` - Final MP4 videos
- `/UserGuides/Audio/` - Professional narration (Samantha voice)
- `/UserGuides/Scripts/` - Training scripts
- `/UserGuides/USER_GUIDE_INDEX.md` - Complete documentation

## Difference from Validation Videos

| Aspect | User Guide (IFU) | Validation Testing |
|--------|------------------|---------------------|
| **Purpose** | Teach clinicians how to use | Prove system works correctly |
| **Audience** | End users (clinicians) | Regulators & QA teams |
| **Style** | Educational, step-by-step | Technical, evidence-based |
| **Required By** | FDA (labeling), ISO 13485 | GCP, 21 CFR Part 11 |
| **Frequency** | Once + annual refresh | Every software version |

## Next Steps

1. Generate all user guide videos
2. Host on training portal
3. Track clinician completion
4. Generate certificates
5. Submit to regulatory body

---

**Contact:** compliance@fieldoftruth.ai  
**Version:** 1.0.0  
**Last Updated:** 2025-10-27


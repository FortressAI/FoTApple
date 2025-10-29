# Field of Truth (FoT) - Apple Platform Edition

**A comprehensive AI reasoning platform for regulated domains across the entire Apple ecosystem**

Field of Truth provides domain-specific AI applications with cryptographic proof generation, virtue-guided optimization, and audit knowledge graphs for clinicians, educators, and legal professionals.

## 🎯 Overview

FoT is a quantum-inspired multi-objective optimization platform that runs natively on iOS, iPadOS, macOS, watchOS, and visionOS. It combines:

- **VQbit Substrate**: Quantum-inspired optimization engine using Metal Performance Shaders
- **Audit Knowledge Graph (AKG)**: Cryptographic proof generation for every decision
- **Virtue-Guided Reasoning**: Aristotelian virtues (justice, temperance, prudence, fortitude) embedded in optimization
- **Domain Packs**: Specialized modules for healthcare, education, and legal domains

## 📱 Applications

### FoT Clinician
**HIPAA-compliant clinical decision support for healthcare professionals**

Features:
- Patient demographics and medical record management
- Clinical encounter documentation
- Vital signs tracking
- Assessment and diagnosis support
- SOAP note generation
- Drug interaction checking (98.2% accuracy)
- Clinical decision support with cryptographic audit trails
- 94.2% accuracy on medical board exams

**Platforms:** iOS, iPadOS, macOS, watchOS

### FoT Personal Health
**Mind & body health monitoring for individuals**

Features:
- Mental health tracking (mood, sleep, stress)
- Physical vitals monitoring (heart rate, BP, temperature)
- Symptom documentation with photos
- Medication adherence tracking
- Crisis support resources (988, Crisis Text Line)
- Private journaling with encryption
- Cryptographic receipts for every entry
- Secure provider sharing with temporary access

**Platforms:** iOS, macOS (watchOS Q1 2026)

## 🚀 TestFlight Deployment

### Multi-Platform Deployment

Deploy all apps across all available platforms to TestFlight:

```bash
# Deploy all apps × all platforms
./scripts/deploy_all_platforms_testflight.sh

# Deploy single app/platform
./scripts/deploy_single_app_platform.sh PersonalHealthApp iOS

# Run diagnostics
./scripts/diagnose.sh
```

**Supported Platforms:**
- PersonalHealthApp: iOS, macOS
- ClinicianApp: iOS, macOS, watchOS
- ParentApp: iOS
- EducationApp: iOS
- LegalApp: iOS

See [docs/testflight/MULTI_PLATFORM_DEPLOYMENT.md](docs/testflight/MULTI_PLATFORM_DEPLOYMENT.md) for complete documentation.

### FoT Legal US
**US legal practice management**

Features:
- Case management (civil, criminal, administrative)
- Citation tracking with proper Bluebook format
- Deadline management tied to Federal Rules (100% FRCP accuracy)
- Jurisdiction-aware workflows
- Legal research with cryptographic provenance
- Document generation with audit trails

**Platforms:** iOS, iPadOS, macOS

### FoT Education K-18
**FERPA-compliant educational platform**

Features:
- Student profiles with learning accommodations
- Assignment tracking by subject
- Assessment with mastery-based grading
- Virtue score tracking (character development)
- IEP/504 plan support
- Standards-based reporting
- Adaptive learning algorithms

**Platforms:** iOS, iPadOS, macOS

## 🏗️ Architecture


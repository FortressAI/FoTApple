# 👥 User Personas & App Intent Coverage Analysis

## Current Status Overview

| Persona | Has Dedicated Experience? | Intent Count | Gaps? |
|---------|---------------------------|--------------|-------|
| **Personal Health User** | ✅ Yes | 6 intents | Complete |
| **Clinician (Medical Pro)** | ✅ Yes | 10 intents | Complete |
| **Teacher** | ⚠️ Mixed | ~4 intents | Needs separation |
| **Student** | ⚠️ Mixed | ~4 intents | Needs separation |
| **Parent** | ❌ No | 0 intents | Missing |
| **Personal Legal (Individual)** | ✅ Yes | 5 intents | Good |
| **Professional Legal (Attorney)** | ⚠️ Partial | 4 intents | Needs enhancement |

---

## 1. ✅ Personal Health User (Individual) - COMPLETE

**Current App:** Personal Health App  
**Intents:** 6

### What They Have:
1. `RecordHealthCheckInIntent` - Daily check-in with mood/symptoms
2. `RecordVitalsIntent` - Track temperature, BP, heart rate
3. `LogMoodIntent` - Quick mood logging
4. `AccessCrisisSupportIntent` - 988, emergency resources
5. `StartGuidanceNavigatorIntent` - "Do I need a doctor?"
6. `SummarizeHealthIntent` - Health trends over time

### Use Cases Covered:
- ✅ Daily wellness tracking
- ✅ Vital signs monitoring
- ✅ Mental health support
- ✅ Crisis intervention
- ✅ AI-guided triage
- ✅ Health analytics

**Status:** ✅ **COMPLETE** - No gaps

---

## 2. ✅ Clinician (Medical Professional) - COMPLETE

**Current App:** Clinician App  
**Intents:** 10

### What They Have:
1. `StartEncounterIntent` - Begin patient documentation
2. `AddPatientVitalsIntent` - Capture patient vital signs
3. `RecordDiagnosisIntent` - Add ICD-10 diagnoses
4. `RecordMedicationIntent` - Prescribe medications
5. `CheckDrugInteractionsIntent` - RxNav integration
6. `GenerateSOAPNoteIntent` - AI-assisted clinical notes
7. `SummarizePatientIntent` - Patient chart overview
8. `EndEncounterIntent` - Sign and attest to blockchain

### Use Cases Covered:
- ✅ Patient encounters
- ✅ Clinical documentation
- ✅ Prescription management
- ✅ Drug safety checks
- ✅ Legal attestation
- ✅ Cross-device workflow

**Status:** ✅ **COMPLETE** - Professional-grade

---

## 3. ⚠️ Teacher - NEEDS SEPARATION

**Current App:** Education K-18 App (mixed teacher/student)  
**Teacher-Specific Intents:** ~4 currently mixed

### What They Currently Have (Mixed):
1. `RecordAssignmentIntent` - Create assignments (TEACHER)
2. `TrackVirtueScoreIntent` - Track student character (TEACHER)
3. `CheckIEPAccommodationsIntent` - View IEP requirements (TEACHER)
4. ~~`CheckScheduleIntent`~~ - More student-focused
5. ~~`TrackProgressIntent`~~ - Could be either
6. ~~`RequestTutorSupportIntent`~~ - Student-focused
7. ~~`SubmitDocumentIntent`~~ - Student-focused

### Missing Teacher Intents:
- ❌ `RecordAttendanceIntent` - Mark attendance
- ❌ `ScheduleParentMeetingIntent` - Parent conferences
- ❌ `CreateLessonPlanIntent` - Lesson planning
- ❌ `GradeAssignmentIntent` - Grade student work
- ❌ `SendClassAnnouncementIntent` - Communicate with class
- ❌ `DocumentBehaviorIncidentIntent` - Behavior tracking
- ❌ `UpdateProgressReportIntent` - Report cards

**Status:** ⚠️ **INCOMPLETE** - Needs dedicated teacher intents

---

## 4. ⚠️ Student (K-18) - NEEDS SEPARATION

**Current App:** Education K-18 App (mixed)  
**Student-Specific Intents:** ~4 currently mixed

### What They Currently Have (Mixed):
1. `CheckScheduleIntent` - "What's my schedule?" (STUDENT)
2. `TrackProgressIntent` - "How am I doing?" (STUDENT)
3. `RequestTutorSupportIntent` - Get tutoring help (STUDENT)
4. `SubmitDocumentIntent` - Turn in homework (STUDENT)

### Missing Student Intents:
- ❌ `LogAssignmentIntent` - Mark assignment done/pending
- ❌ `RequestExtensionIntent` - Ask for deadline extension
- ❌ `ViewGradesIntent` - Check current grades
- ❌ `LogStudySessionIntent` - Track study time
- ❌ `ReflectOnVirtueIntent` - Self-assess character
- ❌ `JoinStudyGroupIntent` - Collaborative learning
- ❌ `AskTeacherQuestionIntent` - Submit questions

**Status:** ⚠️ **INCOMPLETE** - Needs dedicated student intents

---

## 5. ❌ Parent - MISSING ENTIRELY

**Current App:** None  
**Intents:** 0

### What Parents Need:
- ❌ `ViewStudentProgressIntent` - Monitor child's grades
- ❌ `CheckAssignmentsDueIntent` - Help with homework tracking
- ❌ `ScheduleTeacherMeetingIntent` - Request parent-teacher conference
- ❌ `ViewBehaviorReportsIntent` - Check conduct/behavior
- ❌ `UpdateEmergencyContactIntent` - Maintain contact info
- ❌ `ViewAttendanceIntent` - Monitor attendance
- ❌ `ApproveFieldTripIntent` - Permission slips
- ❌ `ViewIEPPlanIntent` - Access child's IEP (if applicable)

**Status:** ❌ **MISSING** - No parent persona at all

---

## 6. ✅ Personal Legal User (Individual) - GOOD

**Current App:** Legal US App  
**Personal Legal Intents:** 5

### What They Have:
1. `CaptureEvidenceIntent` - Photo/video with GPS/timestamp
2. `DocumentIncidentIntent` - Workplace injury, harassment
3. `CreatePersonalCaseIntent` - Start tracking legal matter
4. `LogCommunicationIntent` - Document conversations
5. `SummarizePersonalCaseIntent` - Case overview

### Also Available:
6. `AskLegalQuestionIntent` - General legal info (not advice)
7. `FindLegalAidIntent` - Locate pro-bono services

### Use Cases Covered:
- ✅ Evidence capture
- ✅ Incident documentation
- ✅ Case tracking
- ✅ Communication logging
- ✅ Finding legal help

**Status:** ✅ **GOOD** - Covers personal legal needs

---

## 7. ⚠️ Professional Legal (Attorney/Lawyer) - NEEDS ENHANCEMENT

**Current App:** Legal US App (mixed)  
**Professional Intents:** ~4

### What They Currently Have:
1. `AddTimelineEventIntent` - Court dates, hearings
2. ~~`CaptureEvidenceIntent`~~ - More for individuals
3. ~~`DocumentIncidentIntent`~~ - More for individuals

### Missing Professional Legal Intents:
- ❌ `CreateClientCaseIntent` - Open case for client
- ❌ `RecordBillableTimeIntent` - Track time for billing
- ❌ `ScheduleDepositionIntent` - Schedule depositions
- ❌ `FileCourtDocumentIntent` - Submit filings
- ❌ `RecordClientConsultationIntent` - Attorney-client meetings
- ❌ `GenerateLegalMemoIntent` - AI-assisted legal writing
- ❌ `SearchCaseLawIntent` - Legal research
- ❌ `ManageDiscoveryIntent` - Discovery management
- ❌ `PrepareWitnessIntent` - Witness preparation notes

**Status:** ⚠️ **INCOMPLETE** - Needs professional attorney features

---

## 📊 Summary & Recommendations

### ✅ Complete & Production-Ready:
1. **Personal Health User** (6 intents) - Ship as-is
2. **Clinician** (10 intents) - Ship as-is
3. **Personal Legal User** (5 intents within Legal US) - Ship as-is

### ⚠️ Needs Work Before Launch:
4. **Teacher** - Split from Education app, add 7 missing intents
5. **Student** - Split from Education app, add 7 missing intents
6. **Professional Legal** - Add 9 attorney-specific intents

### ❌ Missing Entirely:
7. **Parent** - Create parent experience (8 intents needed)

---

## 🎯 Recommended Action Plan

### Option A: Ship Current Apps (Fast Track)
**Timeline:** Ready now

Ship 3 complete experiences:
- Personal Health App (for individuals)
- Clinician App (for medical professionals)
- Legal US App (for personal legal needs)

**Delay:**
- Education apps (until teacher/student split is done)
- Professional attorney features

### Option B: Complete All Personas (Comprehensive)
**Timeline:** 2-3 additional days

Create separate experiences:
1. **Teacher App** - 11 intents total
2. **Student App** - 11 intents total
3. **Parent App** - 8 intents
4. **Attorney App** - 13 intents (professional legal)

### Option C: Hybrid Approach (Recommended)
**Timeline:** 1 day

**Phase 1 (Ship Now):**
- Personal Health ✅
- Clinician ✅
- Legal US (Personal) ✅

**Phase 2 (Next Sprint):**
- Teacher App (new)
- Student App (new)
- Parent App (new)

**Phase 3 (Future):**
- Attorney/Professional Legal (enhanced)

---

## 🔨 Implementation Plan for Missing Personas

### If We Add Teacher Intents (11 total):

```swift
// New Teacher-Specific Intents
RecordAttendanceIntent
ScheduleParentMeetingIntent
CreateLessonPlanIntent
GradeAssignmentIntent
SendClassAnnouncementIntent
DocumentBehaviorIncidentIntent
UpdateProgressReportIntent

// Keep existing:
RecordAssignmentIntent
TrackVirtueScoreIntent
CheckIEPAccommodationsIntent
SummarizeStudentProgressIntent (rename from TrackProgress)
```

### If We Add Student Intents (11 total):

```swift
// New Student-Specific Intents
LogAssignmentIntent
RequestExtensionIntent
ViewGradesIntent
LogStudySessionIntent
ReflectOnVirtueIntent
JoinStudyGroupIntent
AskTeacherQuestionIntent

// Keep existing:
CheckScheduleIntent
TrackProgressIntent
RequestTutorSupportIntent
SubmitDocumentIntent
```

### If We Add Parent Intents (8 new):

```swift
// All New Parent Intents
ViewStudentProgressIntent
CheckAssignmentsDueIntent
ScheduleTeacherMeetingIntent
ViewBehaviorReportsIntent
UpdateEmergencyContactIntent
ViewAttendanceIntent
ApproveFieldTripIntent
ViewIEPPlanIntent
```

### If We Enhance Professional Legal (9 new):

```swift
// New Attorney/Professional Intents
CreateClientCaseIntent
RecordBillableTimeIntent
ScheduleDepositionIntent
FileCourtDocumentIntent
RecordClientConsultationIntent
GenerateLegalMemoIntent
SearchCaseLawIntent
ManageDiscoveryIntent
PrepareWitnessIntent

// Keep existing professional ones:
AddTimelineEventIntent
```

---

## 💡 My Recommendation

**Ship the 3 complete apps NOW** (Personal Health, Clinician, Legal US Personal) to TestFlight.

**Then** decide if you want to:
1. Add Teacher/Student/Parent apps for education market
2. Add Professional Attorney features for legal market

This gets you to market fastest with 3 solid, complete experiences while you gather feedback on what other personas users actually want.

---

## 📈 Market Priority

Based on FoT's core value (cryptographic attestation), priority order:

1. **Clinician** - Highest stakes, most legal risk, biggest need ⭐⭐⭐⭐⭐
2. **Professional Legal** - Direct legal use case ⭐⭐⭐⭐⭐
3. **Personal Health** - Individual empowerment ⭐⭐⭐⭐
4. **Teacher** - Education compliance needs ⭐⭐⭐⭐
5. **Personal Legal** - Individual protection ⭐⭐⭐
6. **Student** - Learning accountability ⭐⭐⭐
7. **Parent** - Monitoring/oversight ⭐⭐

---

**What would you like to do?**

A. Ship 3 complete apps now (Health, Clinician, Personal Legal)  
B. Complete all 7 personas first (add 2-3 days)  
C. Add specific missing personas (which ones?)


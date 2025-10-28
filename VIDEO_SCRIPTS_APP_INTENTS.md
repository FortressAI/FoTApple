# 🎬 Video Recording Scripts Driven by App Intents

## How App Intents Drive Video Creation

Each of our 64 App Intents provides a **perfect demo scenario** for video creation. The intents:
- Have clear voice commands
- Show real functionality  
- Generate visible outputs
- Include cryptographic receipts
- Demonstrate AI insights

---

## 🎥 Video Production Framework

### General Structure for Each Video:
1. **Open with voice command** ("Hey Siri...")
2. **Show Siri processing**
3. **Display app response** (dialog + UI updates)
4. **Highlight key features** (cryptographic receipt, AI insight)
5. **Show final state** (data saved, notification sent)

### Technical Setup:
- iOS Simulator with voice control enabled
- Screen recording via `xcrun simctl io booted recordVideo`
- Siri text input for reliable demos
- Post-production audio overlay using macOS `say` command

---

## 📱 PERSONA 1: Personal Health Videos (6 videos)

### Video 1: "Hey Siri, record my health check-in"
```bash
# Script outline:
1. Open Personal Health app
2. Invoke Siri: "Record my health check-in"
3. Siri asks for mood (1-10) → User: "7"
4. Siri asks for symptoms → User: "Mild headache"
5. Siri asks for energy → User: "Good"
6. Show dialog: "Health check-in recorded..."
7. Highlight cryptographic receipt ID
8. Show VQbit AI insight: "Mood stable, trend positive"
9. Pan to health tracking screen showing new entry
```

**Demo highlights:**
- Natural voice interaction
- Multi-parameter input via conversation
- Cryptographic receipt generation
- AI trend analysis

---

### Video 2: "Hey Siri, record my vitals"
```bash
# Script outline:
1. Open Personal Health app (vital signs screen)
2. Invoke Siri: "Record my vitals"
3. Siri: "What's your heart rate?" → User: "72"
4. Siri: "Blood pressure systolic?" → User: "120"
5. Siri: "Blood pressure diastolic?" → User: "80"
6. Siri: "Temperature?" → User: "98.6"
7. Show dialog with all vitals recorded
8. Highlight: "✅ All vitals within normal range"
9. Show cryptographic receipt
10. Display vitals trend graph updating
```

**Demo highlights:**
- Medical data capture
- Real-time validation (normal ranges)
- Trend visualization

---

### Video 3: "Hey Siri, log my mood"
```bash
# Quick demo (30 seconds):
1. Invoke Siri: "Log my mood"
2. Siri: "On a scale of 1-10?" → User: "8"
3. Show dialog: "Mood logged: 8/10 😄"
4. Show cryptographic receipt
5. Brief view of mood tracking calendar
```

**Demo highlights:**
- Ultra-quick logging
- Emoji feedback
- Calendar visualization

---

### Video 4: "Hey Siri, I need crisis support"
```bash
# Sensitive but important demo:
1. Invoke Siri: "I need crisis support"
2. Immediate response (no additional questions)
3. Show dialog with:
   - 988 Suicide & Crisis Lifeline (bold, large)
   - Emergency contacts
   - Crisis text line
   - Local resources
4. Highlight: "Help is available 24/7"
5. Show "Crisis support accessed" logged (for continuity of care)
```

**Demo highlights:**
- Immediate response (no friction)
- Comprehensive resources
- Privacy-respecting logging

---

### Video 5: "Hey Siri, do I need a doctor?"
```bash
# Interactive guidance demo:
1. Invoke Siri: "Do I need a doctor?"
2. Siri: "What symptoms are you experiencing?" → User: "Fever and cough"
3. Siri: "How high is your fever?" → User: "101 degrees"
4. Siri: "How many days?" → User: "3 days"
5. Show AI analysis screen
6. VQbit recommendation: "✅ Schedule doctor visit within 2-3 days"
7. Reasoning: "Fever over 100.4°F for 3+ days warrants evaluation"
8. Show options: "Find urgent care", "Schedule appointment", "Monitor"
```

**Demo highlights:**
- AI-guided triage
- Context-aware recommendations
- Multiple resolution paths

---

### Video 6: "Hey Siri, summarize my health"
```bash
# Analytics demo:
1. Invoke Siri: "Summarize my health this month"
2. Show generating animation
3. Display summary:
   - Average mood: 7.2/10 (stable)
   - Vitals: All within normal ranges
   - Symptoms: 3 headaches logged
   - VQbit insight: "Trending positive overall"
4. Show graphs: mood trend, symptom frequency
5. Highlight cryptographic verification: "All data points validated"
```

**Demo highlights:**
- Comprehensive analytics
- Trend visualization
- AI-powered insights

---

## 👨‍⚕️ PERSONA 2: Clinician Videos (10 videos)

### Video 7: "Hey Siri, start patient encounter"
```bash
# Professional workflow demo:
1. Open Clinician app (patient list)
2. Invoke Siri: "Start patient encounter for John Smith"
3. Show dialog:
   - Encounter ID: ENC-A3F2B891
   - Patient: John Smith (MRN: 12345)
   - Started: [timestamp]
   - Cryptographic session initiated
4. Show encounter screen open with timer
5. Highlight: "All actions will be cryptographically logged"
```

**Demo highlights:**
- Professional workflow initiation
- Unique encounter ID
- Automatic tracking begins

---

### Video 8: "Hey Siri, add patient vitals"
```bash
# Clinical documentation demo:
1. During active encounter
2. Invoke Siri: "Add patient vitals"
3. Rapid fire input:
   - HR: 88
   - BP: 142/95
   - Temp: 98.2
   - RR: 16
   - SpO2: 98%
4. Show dialog with ⚠️ warning: "Elevated blood pressure detected"
5. Vitals added to encounter note
6. Cryptographic signature applied
```

**Demo highlights:**
- Quick clinical data entry
- Real-time abnormality detection
- Automatic EHR integration

---

### Video 9: "Hey Siri, record diagnosis"
```bash
# ICD-10 demo:
1. Invoke Siri: "Record diagnosis"
2. Siri: "ICD-10 code?" → User: "I10"
3. Siri: "Description?" → User: "Essential hypertension"
4. Siri: "Status?" → User: "Chronic"
5. Show validation: "✅ Valid ICD-10 format"
6. Diagnosis added to problem list
7. Show cryptographic signature + timestamp
```

**Demo highlights:**
- Medical coding integration
- Code validation
- Problem list updates

---

### Video 10: "Hey Siri, prescribe medication"
```bash
# e-Prescribe demo:
1. Invoke Siri: "Prescribe medication"
2. Siri: "Medication name?" → User: "Lisinopril"
3. Siri: "Dose?" → User: "10 milligrams"
4. Siri: "Frequency?" → User: "Once daily"
5. Show drug interaction check running
6. Result: "✅ No severe interactions detected"
7. Show prescription ready for e-prescribe
8. Highlight cryptographic signature
```

**Demo highlights:**
- Voice-driven prescribing
- Automatic drug interaction checking
- E-prescribe readiness

---

### Video 11: "Hey Siri, check drug interactions"
```bash
# Safety check demo:
1. Invoke Siri: "Check drug interactions for patient"
2. Show current medication list (5 drugs)
3. VQbit analysis + RxNav API query
4. Results:
   - ⚠️ Moderate interaction: Drug A + Drug B
   - ✅ No interactions: Drug C, D, E
5. Show interaction details panel
6. Recommendation: "Monitor blood pressure closely"
```

**Demo highlights:**
- Patient safety
- External API integration
- Clinical decision support

---

### Video 12: "Hey Siri, generate SOAP note"
```bash
# AI-assisted documentation demo:
1. Invoke Siri: "Generate SOAP note"
2. Show AI processing encounter data
3. Display generated SOAP structure:
   - Subjective: Patient complaints
   - Objective: Vitals, exam findings
   - Assessment: Diagnoses
   - Plan: Medications, follow-up
4. Clinician reviews and signs
5. Ed25519 signature applied
6. Merkle root generated
```

**Demo highlights:**
- AI-powered documentation
- SOAP structure automation
- Cryptographic attestation

---

### Video 13: "Hey Siri, patient summary"
```bash
# Quick reference demo:
1. Invoke Siri: "Patient summary for John Smith"
2. Display comprehensive overview:
   - Active problems (3)
   - Current medications (5)
   - Allergies (2)
   - Recent labs (HbA1c, lipids)
   - VQbit AI insights
3. All data cryptographically verified
```

**Demo highlights:**
- Instant patient overview
- Comprehensive data aggregation
- Quick clinical reference

---

### Video 14: "Hey Siri, end encounter"
```bash
# Finalization demo:
1. Invoke Siri: "End encounter"
2. Show finalization process:
   - Notes signed with Ed25519
   - Merkle root: [32-char hash]
   - SafeAICoin TX: [16-char hash]
   - Blockchain anchor verified
3. Display: "Encounter is now tamper-proof"
4. Show cross-device sync initiated
5. Encounter becomes read-only
```

**Demo highlights:**
- Blockchain attestation
- Tamper-proof finalization
- Legal admissibility

---

## 👪 PERSONA 3: Parent Videos (8 videos)

### Video 15: "Hey Siri, how is my child doing in school?"
```bash
# Comprehensive parent dashboard:
1. Invoke Siri: "How is Emma doing in school this month?"
2. Display progress report:
   - GPA: 3.65 (B+)
   - Math: 92% ↗️
   - English: 88% →
   - Science: 95% ↗️
   - Attendance: 95%
   - Behavior: Excellent (3 positive notes)
   - Virtues: Justice 0.85, Temperance 0.78
3. Show teacher comment
4. All data cryptographically verified
```

**Demo highlights:**
- Comprehensive student overview
- Multi-dimensional tracking
- Character development

---

### Video 16: "Hey Siri, what homework does my child have?"
```bash
# Homework helper demo:
1. Invoke Siri: "What homework does Emma have this week?"
2. Display assignment list:
   - Due today: Math worksheet, English reading
   - Due Wednesday: Science lab report
   - Due Friday: Social Studies essay
   - Upcoming: Book report (Nov 15)
3. Show completion status: 12/15 done
4. Parent tip: "Science fair project needs early planning"
```

**Demo highlights:**
- Homework tracking
- Deadline awareness
- Proactive reminders

---

### Video 17: "Hey Siri, schedule parent-teacher meeting"
```bash
# Meeting request demo:
1. Invoke Siri: "Schedule parent-teacher meeting for Emma"
2. Siri: "Which teacher?" → User: "Ms. Johnson"
3. Siri: "Preferred date?" → User: "Next Tuesday"
4. Siri: "Purpose?" → User: "Discuss math progress"
5. Siri: "Urgency?" → User: "Routine"
6. Show confirmation:
   - Request submitted
   - Teacher will propose times within 2-3 days
   - Calendar invite will be sent
   - Cryptographic timestamp logged
```

**Demo highlights:**
- Easy conference scheduling
- Structured communication
- Automatic calendar integration

---

### Video 18: "Hey Siri, check my child's behavior"
```bash
# Behavior tracking demo:
1. Invoke Siri: "Check Emma's behavior reports"
2. Display report:
   - ✅ Positive notes (this month): 3
     • Helped new student
     • Excellent group leadership
     • Consistently respectful
   - ⚠️ Minor incidents: 1
     • Talking during quiet time (verbal reminder)
   - Overall trend: ↗️ Improving
3. Character virtues displayed
```

**Demo highlights:**
- Positive reinforcement
- Balanced reporting
- Trend analysis

---

### Video 19: "Hey Siri, update emergency contact"
```bash
# Safety information demo:
1. Invoke Siri: "Update emergency contact for Emma"
2. Collect: name, phone, relationship, contact type
3. Show confirmation:
   - Update submitted
   - School will verify within 1 business day
   - Previous contact remains active until verified
   - Cryptographic receipt issued
```

**Demo highlights:**
- Easy information updates
- Verification process
- Security measures

---

### Video 20: "Hey Siri, check my child's attendance"
```bash
# Attendance monitoring demo:
1. Invoke Siri: "Check Emma's attendance this quarter"
2. Display report:
   - Present: 72/75 days (96%)
   - Absent: 3 days (2 excused, 1 pending documentation)
   - Tardies: 1
   - Trend: Good (above 90% threshold)
3. Show policy reminders
4. Impact note: "Good attendance supports learning success"
```

**Demo highlights:**
- Attendance tracking
- Policy awareness
- Academic correlation

---

### Video 21: "Hey Siri, approve field trip"
```bash
# Digital permission slip demo:
1. Invoke Siri: "Approve field trip for Emma"
2. Siri: "Which trip?" → User: "Science museum"
3. Siri: "Date?" → User: "November 10th"
4. Siri: "Medical considerations?" → User: "None"
5. Show permission granted:
   - Trip details displayed
   - Cryptographic receipt: PERM-A3F2B891
   - Legally binding consent recorded
   - Reminders set (day before, departure, return)
```

**Demo highlights:**
- Digital permission slips
- Legally binding consent
- Automatic reminders

---

### Video 22: "Hey Siri, show my child's IEP"
```bash
# IEP access demo:
1. Invoke Siri: "Show Emma's IEP"
2. Display IEP summary:
   - Status: Active
   - Accommodations (6 listed)
   - Progress on goals (75% average)
   - Team members
   - Next review date
3. FERPA compliance indicators
4. Cryptographic access logged
```

**Demo highlights:**
- Easy IEP access
- Progress tracking
- Compliance

---

## 👨‍🏫 PERSONA 4: Teacher Videos (11 videos)

### Video 23: "Hey Siri, record class attendance"
```bash
# Attendance taking demo:
1. Invoke Siri: "Record attendance for Algebra 1"
2. Teacher taps student names (quick select UI)
3. Or: Siri batch mode: "Present: Emma, John, Sarah... Absent: Michael"
4. Show confirmation:
   - 24 present, 1 absent
   - Attendance rate: 96%
   - Parent notification sent to Michael's family
   - Cryptographic record: ATT-A3F2B891
```

**Demo highlights:**
- Quick attendance
- Automatic parent notifications
- Audit trail

---

### Video 24: "Hey Siri, grade student assignment"
```bash
# Grading demo:
1. Invoke Siri: "Grade assignment for Emma"
2. Siri: "Assignment?" → User: "Chapter 5 quiz"
3. Siri: "Score?" → User: "18"
4. Siri: "Out of?" → User: "20"
5. Show calculated results:
   - Score: 18/20
   - Percentage: 90%
   - Letter grade: A-
   - Feedback added
6. Grade recorded with teacher digital signature
7. Student and parent notified
```

**Demo highlights:**
- Voice-driven grading
- Automatic calculations
- Stakeholder notifications

---

### Video 25: "Hey Siri, document behavior incident"
```bash
# Incident reporting demo:
1. Invoke Siri: "Document behavior incident"
2. Collect: student name, incident type, severity, description, witnesses
3. Show incident logged:
   - Notifications sent: Admin, parent, counselor (if serious)
   - Cryptographic receipt
   - Legally admissible record
   - Witness attestation recorded
```

**Demo highlights:**
- Comprehensive incident documentation
- Automatic escalation
- Legal protections

---

### Video 26: "Hey Siri, send class announcement"
```bash
# Communication demo:
1. Invoke Siri: "Send announcement to Algebra 1"
2. Siri: "Message?" → User: "Quiz tomorrow on Chapter 5"
3. Siri: "Priority?" → User: "Important"
4. Siri: "Include parents?" → User: "Yes"
5. Show sent confirmation:
   - Delivered to 25 students (app + email)
   - Delivered to 25 parents (email + SMS)
   - Cryptographic timestamp
   - Read receipts tracked
```

**Demo highlights:**
- Multi-channel communication
- Priority levels
- Delivery confirmation

---

### Video 27: "Hey Siri, create lesson plan"
```bash
# Lesson planning demo:
1. Invoke Siri: "Create lesson plan"
2. Collect: subject, topic, date, duration, objectives
3. Show AI suggestions:
   - Incorporate group activities
   - Formative assessment checkpoints
   - State standards alignment
   - Differentiation strategies
4. Lesson plan saved with version control
5. Share option: co-teachers, admin
```

**Demo highlights:**
- AI-assisted planning
- Standards alignment
- Collaboration ready

---

### Video 28: "Hey Siri, update progress report"
```bash
# Report card demo:
1. Invoke Siri: "Update progress report for Emma"
2. Collect: academic summary, behavior summary, recommendations
3. Show report:
   - Teacher digital signature applied
   - Cryptographic receipt
   - Available to: student, parent, admin, IEP team
4. Report becomes legally binding documentation
```

**Demo highlights:**
- Comprehensive reporting
- Digital signatures
- Multi-stakeholder access

---

## 🎓 PERSONA 5: Student Videos (11 videos)

### Video 29: "Hey Siri, what's my schedule?"
```bash
# Student dashboard demo:
1. Invoke Siri: "What's my schedule today?"
2. Display:
   - Classes: Math (Period 2), Science (Period 4), English (Period 6)
   - Due today: Math homework, Science lab report
   - Events: Student council meeting 3:30 PM
3. Quick view of week ahead
```

**Demo highlights:**
- Student-friendly interface
- Integrated schedule + assignments
- Upcoming events

---

### Video 30: "Hey Siri, how am I doing?"
```bash
# Student progress demo:
1. Invoke Siri: "How am I doing this month?"
2. Display dashboard:
   - GPA: 3.65 (B+)
   - Assignments: 12/15 completed (80%)
   - Grades trending: Up (+3%)
   - Virtues: Justice 0.82, Temperance 0.78, Prudence 0.85
   - VQbit AI insight: "Strong improvement in time management"
3. Focus areas highlighted
```

**Demo highlights:**
- Student self-awareness
- Character tracking
- AI-powered insights

---

### Video 31: "Hey Siri, I need help with math"
```bash
# Tutoring request demo:
1. Invoke Siri: "I need help with math"
2. Siri: "What's the urgency?" → User: "Urgent - stuck on homework"
3. Show response:
   - Teacher notified immediately
   - Peer tutor available tomorrow 3:30 PM
   - Online tutoring available now
   - Request logged with cryptographic timestamp
```

**Demo highlights:**
- Easy help requests
- Multiple support options
- Urgency awareness

---

### Video 32: "Hey Siri, submit my homework"
```bash
# Assignment submission demo:
1. Invoke Siri: "Submit my homework for Chapter 5"
2. Siri: "Document type?" → User: "Photo"
3. Open camera to capture homework
4. Show submission confirmation:
   - Cryptographic receipt: SUBM-A3F2B891
   - Timestamp proof
   - Teacher notified
   - Tamper-proof submission record
```

**Demo highlights:**
- Multi-modal submission
- Proof of submission
- Academic integrity

---

### Video 33: "Hey Siri, log assignment status"
```bash
# Homework tracking demo:
1. Invoke Siri: "Log assignment status"
2. Siri: "Which assignment?" → User: "Chapter 5 homework"
3. Siri: "Status?" → User: "Need help"
4. Show result:
   - Status updated to "🆘 Need Help"
   - Teacher notified
   - Tutor matching in progress
   - Logged with timestamp
```

**Demo highlights:**
- Self-advocacy
- Proactive help
- Teacher awareness

---

### Video 34: "Hey Siri, request assignment extension"
```bash
# Extension request demo:
1. Invoke Siri: "Request assignment extension for science project"
2. Siri collects: current due date, requested date, reason
3. Show submission:
   - Request sent to teacher
   - Logged with cryptographic proof
   - Notification when teacher responds
   - Tip: "Continue working while waiting for approval"
```

**Demo highlights:**
- Formal extension process
- Accountability
- Continued effort encouraged

---

### Video 35: "Hey Siri, view my grades"
```bash
# Grades dashboard demo:
1. Invoke Siri: "View my grades"
2. Display comprehensive report:
   - Overall GPA: 3.65
   - Subject breakdown with percentages
   - Recent assignments with scores
   - Trending analysis
   - Strengths and focus areas
3. All grades cryptographically verified by teachers
```

**Demo highlights:**
- Real-time grade access
- Trend analysis
- Verified accuracy

---

### Video 36: "Hey Siri, log study session"
```bash
# Study tracking demo:
1. Invoke Siri: "Log study session"
2. Collect: subject, duration, topics, effectiveness
3. Show statistics:
   - Session logged
   - Total study time today/week
   - Most studied subjects
   - VQbit AI insight: "Consistent habits detected!"
   - Suggestion: "Take 10-min breaks every 50 minutes"
```

**Demo highlights:**
- Study habit tracking
- Time management
- AI-powered study tips

---

### Video 37: "Hey Siri, reflect on virtue"
```bash
# Character development demo:
1. Invoke Siri: "Reflect on virtue"
2. Siri: "Which virtue?" → User: "Fortitude"
3. Siri: "Self-assessment (0-1)?" → User: "0.85"
4. Siri: "Reflection notes?" → User: [personal thoughts]
5. Show confirmation:
   - Reflection logged privately
   - Option to share with teacher/parent
   - Cryptographic timestamp
   - Privacy protected
```

**Demo highlights:**
- Personal growth tracking
- Optional sharing
- Privacy respected

---

### Video 38: "Hey Siri, ask teacher a question"
```bash
# Student-teacher communication demo:
1. Invoke Siri: "Ask teacher a question"
2. Collect: subject, question, assignment (optional), urgency
3. Show submission:
   - Question sent
   - Expected response time shown
   - Cryptographic log
   - Tips while waiting: "Review notes, check resources"
```

**Demo highlights:**
- Easy teacher communication
- Urgency levels
- Self-help encouraged

---

## ⚖️ PERSONA 6: Personal Legal User Videos (9 videos)

### Video 39: "Hey Siri, capture legal evidence"
```bash
# Evidence capture demo:
1. Invoke Siri: "Capture legal evidence for my case"
2. Open camera with enhanced capture
3. Show result:
   - Photo/video captured
   - GPS coordinates: [lat, lon]
   - Timestamp: [precise time]
   - Cryptographic hash: [SHA-256]
   - Receipt ID: EVID-A3F2B891
   - Legally admissible proof
```

**Demo highlights:**
- GPS + timestamp
- Cryptographic hashing
- Court admissibility

---

### Video 40: "Hey Siri, document incident"
```bash
# Incident documentation demo:
1. Invoke Siri: "Document incident"
2. Collect: type (workplace injury/harassment/etc.), date, location, description, witnesses
3. Show incident report:
   - Comprehensive documentation
   - Witness list
   - Cryptographic receipt
   - Legally admissible
   - Tamper-proof timestamp
```

**Demo highlights:**
- Comprehensive incident capture
- Witness documentation
- Legal protection

---

### Video 41: "Hey Siri, add case event"
```bash
# Timeline management demo:
1. Invoke Siri: "Add case event for my tenant dispute"
2. Collect: event type (court date/hearing/deadline), date, notes
3. Show timeline updated:
   - Event added
   - Reminders set (1 week, 1 day before)
   - Case timeline visualization
   - Cryptographic log
```

**Demo highlights:**
- Case organization
- Deadline tracking
- Automated reminders

---

### Video 42: "Hey Siri, ask legal question"
```bash
# Legal information demo:
1. Invoke Siri: "Ask legal question about tenant rights"
2. Show AI response:
   - General information on tenant rights
   - Common questions answered
   - Relevant statutes cited
   - ⚠️ Disclaimer: "This is general info, not legal advice"
   - Suggestion: "Consult licensed attorney for your situation"
3. Query logged with cryptographic timestamp
```

**Demo highlights:**
- Legal information access
- Clear disclaimers
- Attorney referral encouraged

---

### Video 43: "Hey Siri, find legal aid"
```bash
# Legal aid search demo:
1. Invoke Siri: "Find legal aid for housing dispute"
2. Show results based on location:
   - Legal Aid Society (2.3 miles)
   - Pro Bono Project (4.1 miles)
   - Public Defender (1.8 miles, criminal only)
   - National hotlines
3. Privacy note: "Minimal location data logged (city only)"
```

**Demo highlights:**
- Geolocation services
- Multiple resources
- Privacy protection

---

### Video 44: "Hey Siri, log communication"
```bash
# Communication tracking demo:
1. Invoke Siri: "Log communication with landlord"
2. Collect: party name, method (phone/email/in-person), summary
3. Show logged:
   - Communication documented
   - Method, date/time, summary
   - Cryptographic receipt
   - Legally admissible documentation
   - Attached to active case
```

**Demo highlights:**
- Communication documentation
- Multiple methods tracked
- Case linkage

---

### Video 45: "Hey Siri, summarize my case"
```bash
# Case summary demo:
1. Invoke Siri: "Summarize my tenant dispute case"
2. Display comprehensive overview:
   - Case type, status, timeline
   - Evidence: 12 photos, 3 videos, 8 documents
   - Communications: 5 calls, 8 emails, 2 meetings
   - Timeline with key dates
   - Next steps
   - VQbit AI analysis: "Strong case based on evidence quality"
   - Export options: PDF, encrypted archive, court-ready package
```

**Demo highlights:**
- Comprehensive case view
- Evidence inventory
- AI assessment
- Export options

---

### Video 46: "Hey Siri, create personal case"
```bash
# Case creation demo:
1. Invoke Siri: "Create personal case"
2. Collect: title, case type, opposing party (optional)
3. Show case node created:
   - Case ID: CASE-A3F2B891
   - Cryptographic ID assigned
   - Secure evidence storage initialized
   - Timeline tracking started
   - Communication logging enabled
   - Automatic reminders configured
```

**Demo highlights:**
- Easy case initiation
- Secure infrastructure
- Comprehensive features

---

## ⚖️ PERSONA 7: Professional Attorney Videos (9 videos)

### Video 47: "Hey Siri, create client case"
```bash
# Professional case management demo:
1. Invoke Siri: "Create client case"
2. Collect: client name, case type, title, opposing party, billing rate
3. Show case created:
   - Case ID: CASE-A3F2B891
   - Client confidentiality encryption
   - Conflict check logged
   - Retainer agreement template ready
   - Evidence vault created
   - Billing tracker activated
   - Statute of limitations calculator initialized
```

**Demo highlights:**
- Professional case setup
- Ethical compliance
- Comprehensive infrastructure

---

### Video 48: "Hey Siri, record billable time"
```bash
# Billing demo:
1. Invoke Siri: "Record billable time"
2. Collect: case, activity description, duration, rate (optional)
3. Show time entry:
   - Duration calculated in hours
   - Amount: $[calculated]
   - Cryptographic timestamp
   - Attorney digital signature
   - Tamper-proof audit trail
   - Today's totals updated
   - Client invoice updated automatically
```

**Demo highlights:**
- Ethical billing
- Automatic calculations
- Audit trail

---

### Video 49: "Hey Siri, schedule deposition"
```bash
# Deposition scheduling demo:
1. Invoke Siri: "Schedule deposition"
2. Collect: case, witness name, date, location, court reporter needed
3. Show scheduled:
   - Notifications sent: witness, opposing counsel, court reporter, client
   - Documents prepared: notice, subpoena, oath form
   - Reminders set: 7 days, 3 days, 1 day before
   - Logged with cryptographic proof
```

**Demo highlights:**
- Complex scheduling
- Document automation
- Procedural compliance

---

### Video 50: "Hey Siri, file court document"
```bash
# E-filing demo:
1. Invoke Siri: "File court document"
2. Collect: case number, document type, court
3. Show filed:
   - E-Filing ID: EFIL-A3F2B891...
   - Status: ✅ Accepted by clerk
   - Service completed: opposing counsel, court, client
   - Cryptographic proof: document hash, filing timestamp, service certificate
   - Deadlines calculated: response due in 30 days
```

**Demo highlights:**
- E-filing integration
- Service of process
- Deadline tracking

---

### Video 51: "Hey Siri, record client consultation"
```bash
# Attorney-client meeting demo:
1. Invoke Siri: "Record client consultation"
2. Collect: client name, case (optional), consultation type, duration, notes
3. Show documented:
   - Attorney-client privilege: ✅ Protected
   - Confidentiality: ✅ Encrypted
   - Cryptographic timestamp
   - Work product protection
   - Billable time logged
   - Case timeline updated
```

**Demo highlights:**
- Privilege protection
- Secure storage
- Billing integration

---

### Video 52: "Hey Siri, generate legal memo"
```bash
# AI legal research demo:
1. Invoke Siri: "Generate legal memo"
2. Collect: case, legal issue, jurisdiction
3. Show AI processing
4. Display memo:
   - Structure: Question, Answer, Facts, Analysis, Conclusion
   - Relevant case law cited
   - Statutes referenced
   - Confidence score: 0.87 (High)
   - ⚠️ Attorney review required
   - Work product protection applied
```

**Demo highlights:**
- AI-assisted research
- Professional memo structure
- Attorney review emphasized

---

### Video 53: "Hey Siri, search case law"
```bash
# Legal research demo:
1. Invoke Siri: "Search case law for qualified immunity"
2. Collect: jurisdiction (optional), date range (optional)
3. Show results:
   - Top 3 cases with citations and relevance scores
   - Related statutes
   - VQbit AI analysis: "Strong precedent in your jurisdiction"
   - All citations verified and Shepardized
   - Export options
```

**Demo highlights:**
- Comprehensive legal research
- Relevance scoring
- Citation verification

---

### Video 54: "Hey Siri, manage discovery"
```bash
# Discovery tracking demo:
1. Invoke Siri: "Manage discovery"
2. Collect: case, action (send/receive/deadline/objection), discovery type
3. Show discovery status:
   - Sent/received count
   - Outstanding objections
   - Upcoming depositions
   - Key deadlines
   - Procedural compliance verified
   - Cryptographic timestamps
```

**Demo highlights:**
- Discovery management
- Deadline tracking
- Procedural protection

---

### Video 55: "Hey Siri, prepare witness"
```bash
# Witness preparation demo:
1. Invoke Siri: "Prepare witness"
2. Collect: case, witness name, testimony type, preparation notes
3. Show documented:
   - Key topics covered listed
   - Exhibits reviewed count
   - Practice Q&A completed
   - Witness confidence: High
   - Work product protection: ✅ Applied
   - Attorney-client privilege extended (if applicable)
   - Session logged with receipt
```

**Demo highlights:**
- Comprehensive witness prep
- Work product protection
- Documentation standards

---

## 🎬 Video Production Checklist

### Pre-Production:
- [ ] Install Xcode and build all apps
- [ ] Configure iOS Simulator with Siri enabled
- [ ] Test all App Intents individually
- [ ] Prepare sample data for demos
- [ ] Script exact voice commands and responses

### Production:
- [ ] Record screen with `xcrun simctl io booted recordVideo output.mov`
- [ ] Use Siri text input for reliability
- [ ] Capture key moments: command, processing, result, receipt
- [ ] Record multiple takes for each scenario
- [ ] Ensure UI is clean and professional

### Post-Production:
- [ ] Generate audio narration with `say -v Samantha -o audio.aiff "script"`
- [ ] Combine video + audio with FFmpeg
- [ ] Add title cards for each persona
- [ ] Highlight key features with annotations
- [ ] Export in 1080p or 4K

### Publishing:
- [ ] Upload to marketing website
- [ ] Create YouTube playlist
- [ ] Share on social media
- [ ] Embed in TestFlight onboarding

---

## 📊 Video Series Summary

### Total Videos: 55
- Personal Health: 6 videos
- Clinician: 10 videos
- Parent: 8 videos
- Teacher: 11 videos
- Student: 11 videos
- Personal Legal: 9 videos
- Attorney: 9 videos

### Estimated Production Time:
- Pre-production: 8 hours
- Recording: 20 hours (22 minutes per video)
- Post-production: 27 hours (30 minutes per video)
- **Total: ~55 hours** for complete video suite

### Key Themes Across All Videos:
- ✅ Voice-first interaction
- ✅ Cryptographic receipts
- ✅ VQbit AI insights
- ✅ Legal admissibility
- ✅ Privacy protection
- ✅ Multi-stakeholder benefits

---

**These 64 App Intents provide natural, demo-ready scenarios that showcase the full power of the Field of Truth platform!**


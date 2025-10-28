# FoT Education K-18 - Complete User Guide

**FERPA-compliant educational platform with character development tracking**

---

## Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Student Management](#student-management)
4. [Assignments & Homework](#assignments--homework)
5. [Assessments & Grading](#assessments--grading)
6. [Virtue Development](#virtue-development)
7. [Learning Profiles](#learning-profiles)
8. [Standards Tracking](#standards-tracking)
9. [Compliance & Privacy](#compliance--privacy)
10. [Tips & Best Practices](#tips--best-practices)

---

## Overview

### What is FoT Education K-18?

FoT Education K-18 is a FERPA-compliant educational platform that combines:

- **Student Information System** - Demographics, grades, accommodations
- **Assignment Tracking** - Homework, projects, submissions
- **Assessment Management** - Tests, quizzes, mastery-based grading
- **Virtue Development** - Character education tracking (Aristotelian virtues)
- **Learning Profiles** - IEP/504 support, learning styles
- **Standards Alignment** - Common Core, state standards
- **VQbit Optimization** - Personalized learning recommendations

### Key Features

| Feature | Description | FERPA Compliant |
|---------|-------------|------------------|
| **Student Profiles** | Demographics, guardian consent | ✅ Yes |
| **Assignment Tracking** | Due dates, submissions, grading | ✅ Yes |
| **Mastery-Based Grading** | Beginning → Advanced progression | ✅ Yes |
| **Virtue Tracking** | Character development scores | ✅ Yes |
| **Learning Accommodations** | IEP/504 support | ✅ Yes |
| **Standards Reporting** | Progress toward standards | ✅ Yes |
| **Guardian Portal** | (Future) Parent access | ✅ Yes |

### Platform Support

- **iOS 17.0+** - iPhone and iPad (optimized for iPad)
- **macOS 14.0+** - Mac desktop for teachers
- **watchOS 10.0+** - Apple Watch for quick attendance

---

## Getting Started

### First Launch

When you first launch FoT Education K-18:

1. **Welcome Screen** with guardian consent reminder
2. VQbit engine initializes (512-8096 dimensions based on device)
3. Database created
4. Sample students loaded for demonstration

**Sample Students Included:**

#### Student 1: Alice Johnson
- **Grade:** 5th Grade
- **Age:** 10 years
- **Learning Style:** Visual
- **Strengths:** Mathematics, Science
- **Challenges:** Reading comprehension
- **Accommodations:** Extended time on tests
- **Assignments:**
  - Math Worksheet - Fractions (In Progress)
  - Science Project - Solar System (Assigned)
- **Recent Assessment:**
  - Math Quiz - Chapter 5: 45/50 (90%, Proficient)

#### Student 2: Bob Smith
- **Grade:** 8th Grade
- **Age:** 13 years
- **Learning Style:** Auditory
- **Strengths:** English, History
- **Challenges:** Mathematics
- **Assignments:**
  - Essay - American Revolution (In Progress)

### Main Interface

```
┌─────────────────────────────────┐
│  FoT Education K-18             │
├─────────────────────────────────┤
│  [Student List]                 │
│                                 │
│  Alice Johnson - 5th Grade      │
│  2 assignments, 1 overdue       │
│                                 │
│  Bob Smith - 8th Grade          │
│  1 assignment                   │
│                                 │
└─────────────────────────────────┘
```

---

## Student Management

### Student Profile Components

Each student profile includes:

#### 1. Demographics
- Full name
- Student ID
- Date of birth
- Grade level (K-12)
- Guardian contact information

#### 2. Guardian Consent

**FERPA Requirement:** Must have signed consent before:
- Collecting personally identifiable information
- Sharing data with other educators
- Using educational software

**Consent Status:**
- ✅ **Granted** - Can use all features
- ⚠️ **Pending** - Limited functionality
- ❌ **Denied** - Cannot collect PII

#### 3. Learning Profile

```
Learning Profile: Alice Johnson
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Strengths:
  • Mathematics
  • Science

Challenges:
  • Reading comprehension

Learning Style: Visual Learner
  • Prefers charts, diagrams, images
  • Benefits from graphic organizers
  • Strong spatial reasoning

Accommodations:
  • Extended time on tests (1.5x)
  • Preferential seating (front of class)
  • Reduced distraction environment
  • Read-aloud for complex passages

IEP/504: Yes (Extended time)
Last Updated: August 15, 2025
```

### Grade Levels

| Code | Description |
|------|-------------|
| **K** | Kindergarten (ages 5-6) |
| **1-5** | Elementary School |
| **6-8** | Middle School |
| **9-12** | High School |

---

## Assignments & Homework

### Assignment Types

FoT Education supports various assignment types:

1. **Worksheets** - Practice problems
2. **Essays** - Written compositions
3. **Projects** - Long-term research/creation
4. **Reading** - Book reports, comprehension
5. **Labs** - Science experiments
6. **Presentations** - Oral reports

### Assignment Status Workflow

```
Assigned → In Progress → Submitted → Graded → Completed
```

**Status Meanings:**
- **Assigned** - Student notified, not started
- **In Progress** - Student working on it
- **Submitted** - Waiting for teacher review
- **Graded** - Teacher provided score/feedback
- **Completed** - Graded and reviewed with student

### Creating Assignments

*Future Feature - Currently uses sample data*

Planned workflow:
1. Select subject area
2. Enter title and description
3. Set due date
4. Attach resources (PDFs, links)
5. Set point value
6. Align to standards
7. Assign to students

### Assignment Details View

```
┌─────────────────────────────────────────┐
│  Math Worksheet - Fractions            │
│  Subject: Mathematics                   │
│  Due: October 30, 2025                  │
│  Status: In Progress                    │
├─────────────────────────────────────────┤
│  Description:                           │
│  Complete problems 1-20 on page 45.     │
│  Show all work. Focus on reducing       │
│  fractions to lowest terms.             │
├─────────────────────────────────────────┤
│  Standards:                             │
│  • 5.NF.A.1: Add and subtract fractions │
│  • 5.NF.A.2: Solve word problems        │
├─────────────────────────────────────────┤
│  Attachments:                           │
│  📄 Fraction_Worksheet.pdf              │
│  🔗 Khan Academy: Fractions             │
└─────────────────────────────────────────┘
```

### Overdue Assignments

Overdue assignments are highlighted in **red**:

```
⚠️ OVERDUE: Science Project - Solar System
Due: October 25, 2025 (2 days ago)
Status: Assigned (not started)

Action: Contact student/guardian
```

---

## Assessments & Grading

### Mastery-Based Assessment

FoT Education uses **4-level mastery** instead of traditional letter grades:

| Level | Description | Traditional Equivalent |
|-------|-------------|------------------------|
| **Beginning** | Just starting to learn | D or below |
| **Developing** | Making progress, needs support | C |
| **Proficient** | Meets grade-level expectations | B |
| **Advanced** | Exceeds expectations | A |

### Assessment Record

```
Assessment: Math Quiz - Chapter 5
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Student: Alice Johnson
Subject: Mathematics
Date: October 27, 2025

Score: 45 / 50 (90%)
Letter Grade: A
Mastery Level: Proficient

Standards Assessed:
  ✅ 5.NF.A.1: Add/subtract fractions ......... 95%
  ✅ 5.NF.A.2: Word problems .................. 85%
  ⚠️  5.NF.B.3: Interpret fractions ........... 70%

Feedback:
  Excellent work on computation! Focus more on
  interpreting fraction word problems. Practice
  identifying when to add vs. multiply fractions.

Virtue Analysis:
  • Fortitude (persistence): 0.85
  • Prudence (checking work): 0.90
  • Temperance (pacing): 0.75
```

### Standards-Based Reporting

Each assessment links to educational standards:

**Common Core Math - Grade 5:**
- `5.NF.A.1` - Add and subtract fractions with unlike denominators
- `5.NF.A.2` - Solve word problems involving addition and subtraction of fractions
- `5.NF.B.3` - Interpret a fraction as division

**Progress Tracking:**
```
Standard 5.NF.A.1: Add/Subtract Fractions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sep  Oct  Nov  Dec  Jan  Feb  Mar  Apr
░░░  ███  ███  ███  ███  ███  ███  ███
60%  85%  90%  95%  98%  ✅   ✅   ✅
Beginning → Developing → Proficient
```

---

## Virtue Development

### Aristotelian Cardinal Virtues

FoT Education tracks **four cardinal virtues** based on Aristotle's ethics:

#### 1. Justice (Fairness & Collaboration)

**What it measures:**
- Fair play with peers
- Sharing resources
- Taking turns
- Respecting others' ideas

**Example behaviors:**
- ✅ Includes all group members
- ✅ Shares materials willingly
- ❌ Dominates group discussions
- ❌ Excludes certain students

#### 2. Temperance (Self-Control & Patience)

**What it measures:**
- Emotional regulation
- Impulse control
- Waiting turn to speak
- Managing frustration

**Example behaviors:**
- ✅ Waits to be called on
- ✅ Stays calm when challenged
- ❌ Interrupts frequently
- ❌ Gives up easily

#### 3. Prudence (Planning & Foresight)

**What it measures:**
- Planning ahead
- Organization skills
- Thinking before acting
- Anticipating consequences

**Example behaviors:**
- ✅ Starts assignments early
- ✅ Brings necessary materials
- ❌ Rushes through work
- ❌ Unprepared for class

#### 4. Fortitude (Courage & Persistence)

**What it measures:**
- Perseverance on hard tasks
- Trying new challenges
- Resilience after failure
- Growth mindset

**Example behaviors:**
- ✅ Attempts challenging problems
- ✅ Asks for help when stuck
- ❌ Avoids difficult tasks
- ❌ Gives up after first failure

### Virtue Score Dashboard

```
Alice Johnson - Virtue Development
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Justice:     ████████░░  0.80  (Strong)
Temperance:  ███████░░░  0.70  (Developing)
Prudence:    █████████░  0.90  (Excellent)
Fortitude:   ████████░░  0.85  (Strong)

Average:     ████████░░  0.81  (Strong)

Trends:
  Justice:    ↗ Improving (was 0.75 last month)
  Temperance: → Steady
  Prudence:   → Steady (consistently high)
  Fortitude:  ↗ Improving (was 0.80 last month)

Teacher Notes:
  Alice shows excellent planning skills (prudence)
  and strong persistence (fortitude). Continue
  working on patience during group activities
  (temperance). Overall excellent character
  development.
```

### How Virtue Scores Are Calculated

**Automated Factors:**
- Assignment completion rate
- Time to start assignments
- Revision patterns
- Help-seeking behavior
- Collaboration metrics (if using collaborative tools)

**Manual Teacher Input:**
- Classroom observations
- Behavioral notes
- Peer feedback
- Self-assessment surveys

**VQbit Enhancement:**
The VQbit engine analyzes patterns and provides **contextualized scores**:
- Adjusts for age/grade level
- Compares to developmental norms
- Identifies growth trends
- Flags concerns early

---

## Learning Profiles

### Learning Styles

FoT Education recognizes four primary learning styles:

#### 1. Visual Learners

**Characteristics:**
- Learn best from images, diagrams, charts
- Remember faces better than names
- Prefer written instructions
- Think in pictures

**Recommended Strategies:**
- Use graphic organizers
- Provide visual aids
- Color-coding systems
- Mind maps and concept maps

#### 2. Auditory Learners

**Characteristics:**
- Learn best from lectures and discussions
- Remember what they hear
- Prefer verbal instructions
- Think in words

**Recommended Strategies:**
- Read instructions aloud
- Use mnemonic devices
- Encourage verbal explanations
- Group discussions

#### 3. Kinesthetic Learners

**Characteristics:**
- Learn best by doing
- Need hands-on activities
- Remember what they do
- May struggle sitting still

**Recommended Strategies:**
- Lab experiments
- Role-playing
- Building models
- Movement breaks

#### 4. Balanced Learners

**Characteristics:**
- Use combination of styles
- Adapt to different situations
- No strong preference

**Recommended Strategies:**
- Multi-modal approach
- Variety of activities
- Student choice in assignments

### Accommodations & Modifications

#### Common Accommodations (Section 504)

```
Student: Alice Johnson
Plan Type: 504 Accommodation Plan
Start Date: August 15, 2025
Review Date: May 31, 2026

Accommodations:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Extended Time
   • Tests: 1.5x standard time
   • Assignments: Extra day if needed
   • Rationale: Processing speed

2. Preferential Seating
   • Front of classroom
   • Away from distractions
   • Near teacher's desk
   • Rationale: Attention maintenance

3. Reduced Distractions
   • Quiet testing location
   • Individual workspace option
   • Noise-canceling headphones allowed
   • Rationale: Sensory sensitivities

4. Read-Aloud Support
   • Test questions read aloud
   • Complex passages pre-read
   • Audio versions of textbooks
   • Rationale: Reading comprehension

Guardian Consent: ✅ Granted
Last Updated: October 1, 2025
```

#### IEP (Individualized Education Program)

*Future Feature - Full IEP management*

Planned features:
- Annual goals tracking
- Progress monitoring
- Service minutes logging
- Related services coordination
- Meeting scheduling
- Compliance reporting

---

## Standards Tracking

### Supported Standards

FoT Education K-18 supports major educational standards:

1. **Common Core State Standards (CCSS)**
   - Mathematics
   - English Language Arts
2. **Next Generation Science Standards (NGSS)**
3. **State-specific standards** (configurable)
4. **College & Career Readiness Standards**

### Standard Format

```
Standard Code: 5.NF.A.1

Full Description:
Add and subtract fractions with unlike denominators
(including mixed numbers) by replacing given fractions
with equivalent fractions in such a way as to produce
an equivalent sum or difference of fractions with like
denominators.

Grade Level: 5
Subject: Mathematics - Number & Operations—Fractions
Domain: Operations with Fractions
```

### Progress Reports

```
Alice Johnson - Standards Report
Quarter 1: August-October 2025
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Mathematics:
━━━━━━━━━━━━
5.NF.A.1: Add/subtract fractions ........... ✅ Proficient (95%)
5.NF.A.2: Word problems .................... ✅ Proficient (88%)
5.NF.B.3: Interpret fractions .............. ⚠️ Developing (72%)
5.NF.B.4: Multiply fractions ............... ⏳ Not yet assessed

English Language Arts:
━━━━━━━━━━━━━━━━━━━━━
RL.5.1: Quote text evidence ................ ✅ Proficient (90%)
RL.5.2: Determine theme .................... ⚠️ Developing (75%)
W.5.1: Write opinion pieces ................ ✅ Proficient (85%)
W.5.3: Write narratives .................... ✅ Advanced (96%)

Science:
━━━━━━━━
5-PS1-1: Matter properties ................. ✅ Proficient (88%)
5-PS1-2: Measure matter .................... ✅ Proficient (82%)
5-LS1-1: Plant/animal structures ........... ⏳ Not yet assessed

Overall: On track for grade-level promotion
```

---

## Compliance & Privacy

### FERPA Compliance

**Family Educational Rights and Privacy Act** protects student education records.

#### What FERPA Covers

1. **Directory Information**
   - Name, address, phone
   - Dates of attendance
   - Grade level
   - Awards received
   - ⚠️ Requires opt-out option

2. **Non-Directory Information**
   - Grades, test scores
   - Disciplinary records
   - Special education status
   - 🔒 Requires written consent to share

#### Guardian Rights Under FERPA

Parents/Guardians have the right to:
- ✅ Inspect student records
- ✅ Request corrections
- ✅ Control disclosure
- ✅ File complaints with US Dept of Education

#### FoT Education K-18 Compliance

| Requirement | Implementation |
|-------------|----------------|
| **Consent Tracking** | Digital consent forms with timestamps |
| **Access Logs** | Every record access logged with cryptographic receipt |
| **Disclosure Control** | No sharing without explicit consent |
| **Data Security** | Encrypted storage, secure transmission |
| **Retention Policy** | Configurable retention periods |
| **Parental Access** | Guardian portal (future feature) |

### Data Security

#### Encryption

- **At Rest:** SQLite database encrypted with iOS Data Protection
- **In Transit:** TLS 1.3 for all network communications
- **Backups:** Encrypted device backups

#### Access Controls

- **Device Lock:** PIN/biometric required
- **App Lock:** Additional passcode option
- **Session Timeout:** Auto-lock after 5 minutes inactivity
- **Multi-User:** Separate teacher accounts (future)

#### Audit Trails

Every operation generates a cryptographic receipt:

```json
{
  "id": "01HGKPQRSTUVWXYZ...",
  "timestamp": "2025-10-27T10:00:00Z",
  "operation": "view_student_grades",
  "actor": "Teacher ID: T12345",
  "student_id": "STU001",
  "data_accessed": ["grades", "attendance"],
  "purpose": "parent_conference",
  "hash": "blake3_hash...",
  "signature": "crypto_signature..."
}
```

---

## Tips & Best Practices

### For Teachers

#### Daily Workflow

1. **Morning (5 min)**
   - Review today's schedule
   - Check for assignment submissions
   - Note students with accommodations

2. **During Class**
   - Take attendance quickly
   - Note behavioral observations
   - Document virtue moments

3. **End of Day (10 min)**
   - Grade completed assignments
   - Update virtue scores
   - Plan tomorrow's lessons

#### Effective Virtue Tracking

**DO:**
- ✅ Focus on specific behaviors
- ✅ Document positive moments
- ✅ Be consistent across students
- ✅ Share progress with students
- ✅ Involve students in self-assessment

**DON'T:**
- ❌ Use as punishment
- ❌ Compare students publicly
- ❌ Make it competitive
- ❌ Ignore growth over time
- ❌ Rush judgments

#### Communicating with Guardians

**Virtue Progress Report Template:**

```
Dear Mr. and Mrs. Johnson,

I wanted to share Alice's character development
progress this quarter. She's showing excellent
growth in several areas:

STRENGTHS:
• Prudence (planning): Alice consistently starts
  assignments early and comes prepared to class.
  This is reflected in her high score of 0.90.

• Fortitude (persistence): She attempts challenging
  problems and asks for help when needed. Her score
  of 0.85 shows strong resilience.

AREAS FOR GROWTH:
• Temperance (patience): During group work, Alice
  sometimes interrupts peers. We're working on
  waiting for her turn to speak. Her score of 0.70
  shows she's developing this skill.

Alice is a wonderful student and these virtue scores
help us provide personalized support. Please let me
know if you'd like to discuss further.

Best regards,
Ms. Thompson
```

### For Students

#### How to Improve Your Virtue Scores

**Justice (Being Fair):**
- Include everyone in group work
- Share materials with classmates
- Listen to others' ideas
- Take turns fairly

**Temperance (Self-Control):**
- Wait your turn to speak
- Stay calm when frustrated
- Count to 10 before responding
- Take deep breaths

**Prudence (Planning Ahead):**
- Use a planner for assignments
- Start homework early
- Pack backpack the night before
- Check your work before submitting

**Fortitude (Persistence):**
- Try challenging problems
- Ask for help when stuck
- Learn from mistakes
- Don't give up easily

---

## Keyboard Shortcuts (macOS)

| Shortcut | Action |
|----------|--------|
| `Cmd+N` | New student |
| `Cmd+F` | Search students |
| `Cmd+G` | Grade assignment |
| `Cmd+V` | View virtue scores |
| `Cmd+R` | Generate report |

---

## Future Features

### Planned Enhancements

1. **Guardian Portal** (Q1 2026)
   - View student progress
   - Sign permission slips
   - Message teachers
   - Download report cards

2. **Collaborative Learning** (Q2 2026)
   - Student collaboration tools
   - Peer review system
   - Group project management

3. **AI Tutoring** (Q3 2026)
   - Personalized practice problems
   - Adaptive difficulty
   - Immediate feedback

4. **Extended Reporting** (Q4 2026)
   - Custom report builder
   - Data visualization
   - Export to SIS systems

---

## Support

- **Documentation:** https://github.com/FortressAI/FoTApple/wiki/Education-K18-App
- **FERPA Compliance Guide:** https://github.com/FortressAI/FoTApple/wiki/FERPA-Compliance
- **Video Tutorials:** Coming soon

---

**Empowering students with virtue-guided education! 📚**


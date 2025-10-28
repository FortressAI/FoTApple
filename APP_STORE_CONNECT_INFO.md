# App Store Connect Setup Information

Use these details when creating apps in [App Store Connect](https://appstoreconnect.apple.com/)

---

## 1. Personal Health Monitor

**Name:** Personal Health Monitor  
**Bundle ID:** `com.fot.PersonalHealth`  
**SKU:** `FOTH-001` or `com.fot.PersonalHealth`  
**Primary Language:** English (U.S.)  
**Platform:** iOS  

**Description (for later):**  
Personal health monitoring app with AI-powered guidance, crisis support, and health tracking features.

---

## 2. Field of Truth Clinician

**Name:** Field of Truth Clinician  
**Bundle ID:** `com.fot.ClinicianApp`  
**SKU:** `FOTC-002` or `com.fot.ClinicianApp`  
**Primary Language:** English (U.S.)  
**Platform:** iOS  

**Description (for later):**  
Professional medical app for clinicians to manage patient encounters, record SOAP notes, and track medications.

---

## 3. Field of Truth Parent

**Name:** Field of Truth Parent  
**Bundle ID:** `com.fot.ParentApp`  
**SKU:** `FOTP-003` or `com.fot.ParentApp`  
**Primary Language:** English (U.S.)  
**Platform:** iOS  

**Description (for later):**  
Parent and guardian app for monitoring student progress, attendance, behavior, and communicating with teachers.

---

## 4. Field of Truth Education

**Name:** Field of Truth Education  
**Bundle ID:** `com.fot.EducationApp`  
**SKU:** `FOTE-004` or `com.fot.EducationApp`  
**Primary Language:** English (U.S.)  
**Platform:** iOS  

**Description (for later):**  
Educational app for teachers and students to manage assignments, track progress, and foster virtue development.

---

## 5. Field of Truth Legal

**Name:** Field of Truth Legal  
**Bundle ID:** `com.fot.LegalApp`  
**SKU:** `FOTL-005` or `com.fot.LegalApp`  
**Primary Language:** English (U.S.)  
**Platform:** iOS  

**Description (for later):**  
Legal assistance app for both personal legal matters and professional attorneys, with case management and research tools.

---

## Quick Reference Table

| App Name | Bundle ID | SKU | Version |
|----------|-----------|-----|---------|
| Personal Health Monitor | com.fot.PersonalHealth | FOTH-001 | 1.0.0 |
| Field of Truth Clinician | com.fot.ClinicianApp | FOTC-002 | 1.0.0 |
| Field of Truth Parent | com.fot.ParentApp | FOTP-003 | 1.0.0 |
| Field of Truth Education | com.fot.EducationApp | FOTE-004 | 1.0.0 |
| Field of Truth Legal | com.fot.LegalApp | FOTL-005 | 1.0.0 |

---

## Team Information

**Team ID:** WWQQB728U5  
**Program:** Apple Developer Program (Individual)  
**Platform:** iOS 17.0+  

---

## App Store Connect Creation Steps

For each app:

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Click "My Apps"
3. Click the "+" button → "New App"
4. Fill in the form:
   - **Platforms:** iOS
   - **Name:** [Use name from table above]
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** Select from dropdown OR create new [Use Bundle ID from table]
   - **SKU:** [Use SKU from table above]
   - **User Access:** Full Access
5. Click "Create"
6. Repeat for all 5 apps

---

## Notes

- **SKU** can be any unique string - it's for your internal tracking
- **Bundle ID** must match what's in the Xcode project (already configured)
- You don't need to fill in screenshots/descriptions yet
- Just creating the app record is enough for TestFlight
- Detailed App Store submission comes later

---

## After Creating Apps

Once all 5 apps are created in App Store Connect:

### Option A: CLI Deployment
```bash
./scripts/testflight_cli.sh
```

### Option B: Xcode Archive
```bash
open apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj
# Product → Archive → Distribute
```

The system will now recognize your apps and create provisioning profiles automatically.


# Quick App Creation - Copy/Paste Ready

App Store Connect is now open in your browser. Create each app using this info:

## App 1: Personal Health Monitor

```
Platform: iOS
Name: Personal Health Monitor
Primary Language: English (U.S.)
Bundle ID: com.fot.PersonalHealth
SKU: FOTH-001
```

## App 2: Field of Truth Clinician

```
Platform: iOS
Name: Field of Truth Clinician
Primary Language: English (U.S.)
Bundle ID: com.fot.ClinicianApp
SKU: FOTC-002
```

## App 3: Field of Truth Parent

```
Platform: iOS
Name: Field of Truth Parent
Primary Language: English (U.S.)
Bundle ID: com.fot.ParentApp
SKU: FOTP-003
```

## App 4: Field of Truth Education

```
Platform: iOS
Name: Field of Truth Education
Primary Language: English (U.S.)
Bundle ID: com.fot.EducationApp
SKU: FOTE-004
```

## App 5: Field of Truth Legal

```
Platform: iOS
Name: Field of Truth Legal
Primary Language: English (U.S.)
Bundle ID: com.fot.LegalApp
SKU: FOTL-005
```

---

## After Creating All 5 Apps

Run this command to deploy them all:

```bash
cd /Users/richardgillespie/Documents/FoTApple

# Deploy all 5 apps automatically
./scripts/deploy_all_testflight.sh
```

Or deploy one at a time:

```bash
# Personal Health
./scripts/testflight_cli.sh

# Then manually change APP_NAME in the script for each app
```

---

**This takes ~5 minutes total to create all 5 apps.**  
**Then CLI deployment works automatically!**


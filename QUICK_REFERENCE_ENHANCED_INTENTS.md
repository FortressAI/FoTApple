# 🎯 Quick Reference: Enhanced App Intents with QFOT Domain Services

## 🎤 **Siri Commands Cheat Sheet**

### **Clinician App** 🏥

| Command | What It Does | API Endpoint |
|---------|--------------|--------------|
| "Calculate dosing for metformin for 70kg patient" | Patient-specific drug dosing (FDA guidelines) | `/medical/calculate-dosing` |
| "Check interactions for aspirin and warfarin" | Drug-drug interaction analysis | `/medical/check-interactions` |
| "Check FDA alerts for metformin" | Current MedWatch safety alerts | `/medical/fda-alerts` |
| "Lookup ICD-10 for hypertension" | Billing codes for diagnosis | `/medical/icd10-lookup/{query}` |

### **Legal App** ⚖️

| Command | What It Does | API Endpoint |
|---------|--------------|--------------|
| "Search case law for Fourth Amendment" | SCOTUS/Circuit/State case search | `/legal/case-law` |
| "Search federal statutes for civil rights" | USC/State code section search | `/legal/statutes` |
| "Calculate deadline for answer to complaint" | FRCP/FRAP deadline calculation | `/legal/calculate-deadline` |

---

## 🔧 **Developer Quick Commands**

### **Check Build Status:**
```bash
cd /Users/richardgillespie/Documents/FoTApple
tail -f build/logs/build_all_master.log
```

### **Check Individual App Builds:**
```bash
tail -50 build/logs/PersonalHealthApp_enhanced.log
tail -50 build/logs/FoTClinicianApp_enhanced.log
tail -50 build/logs/FoTLegalApp_enhanced.log
tail -50 build/logs/FoTEducationApp_enhanced.log
tail -50 build/logs/FoTParentApp_enhanced.log
```

### **Test Domain Services API:**
```bash
# Test Medical API
curl -X POST https://safeaicoin.org/domain-api/medical/calculate-dosing \
  -H 'Content-Type: application/json' \
  -d '{"drug_name": "metformin", "patient_weight_kg": 70, "patient_age_years": 45}' | jq

# Test Legal API
curl -X POST https://safeaicoin.org/domain-api/legal/case-law \
  -H 'Content-Type: application/json' \
  -d '{"query": "Fourth Amendment", "jurisdiction": "federal"}' | jq
```

---

## 📱 **App Bundle IDs**

| App | Bundle ID |
|-----|-----------|
| PersonalHealth | `com.akashic.PersonalHealth` |
| Clinician | `com.akashic.FoTClinician` |
| Legal | `com.akashic.FoTLegal` |
| Education | `com.akashic.FoTEducation` |
| Parent | `com.akashic.FoTParent` |

---

## 🔑 **API Keys & Credentials**

| Purpose | File | ID |
|---------|------|-----|
| App Store Connect API | `ApiKey_706IRVGBDV3B.p8` | `706IRVGBDV3B` |
| Issuer ID | - | `69a6de95-fd71-47e3-e053-5b8c7c11a4d1` |
| Team ID | - | `WWQQB728U5` |
| Developer ID | - | `0be0b98b-ed15-45d9-a644-9a1a26b22d31` |

---

## 🛠️ **Upload to TestFlight (Xcode Organizer)**

1. Open Xcode Organizer:
   ```bash
   open -a Xcode
   # Window > Organizer > Archives
   ```

2. For each app:
   - Select archive
   - Click "Distribute App"
   - Choose "TestFlight & App Store"
   - Select "Upload"
   - Choose "Automatically manage signing"
   - Click "Upload"

---

## 🔍 **Validation Checklist**

Before deploying, ensure:

- [ ] All 5 apps build successfully
- [ ] Unique icons for each app (heart, caduceus, scales, books, family)
- [ ] Version numbers incremented (PersonalHealth & Legal = 13)
- [ ] No simulation flags in API responses (`simulation: false`)
- [ ] HTTPS endpoints (`https://safeaicoin.org/domain-api`)
- [ ] Cryptographic receipts generated for all actions
- [ ] App Intents descriptions don't contain "Siri"

---

## 🚨 **Troubleshooting**

### **Build Fails with "scheme not found":**
```bash
# List available schemes:
xcodebuild -project apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj -list
```

### **Xcode export fails with "exportOptionsPlist" error:**
- **Solution:** Use Xcode Organizer GUI (Xcode 26 CLI has known bug)

### **App Intent returns simulation data:**
- **Check:** API response has `"simulation": false`
- **Fix:** Deploy real Domain Services API to mainnet
- **Test:** `curl https://safeaicoin.org/domain-api/medical/calculate-dosing`

---

## 📚 **Documentation Files**

| File | Purpose |
|------|---------|
| `APP_INTENTS_ENHANCED_DOMAIN_SERVICES.md` | Complete intent documentation |
| `DEPLOYMENT_READY_WITH_DOMAIN_SERVICES.md` | Deployment status & next steps |
| `ENHANCED_DOMAIN_SERVICES_COMPLETE.md` | Domain services architecture |
| `QUICK_REFERENCE_ENHANCED_INTENTS.md` | This file (quick reference) |

---

**All systems ready for LIVE mainnet deployment! 🚀**


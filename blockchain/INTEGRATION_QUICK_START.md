# 🚀 QFOT Domain Services - Quick Start

## **What You Now Have**

Complete domain-specific functionality for all your iOS/Mac apps:
- **Drug dosing calculator** for Clinician app
- **Case law search** for Legal app  
- **Standards lookup** for Education app
- **ArangoDB graph queries** for all apps

**All connected to QFOT mainnet - ZERO SIMULATIONS!**

---

## **⚡ 60-Second Deploy**

```bash
cd /Users/richardgillespie/Documents/FoTApple/blockchain
./deploy_enhanced_apis.sh
```

That's it! Two APIs will be live on your mainnet.

---

## **📱 iOS Integration (Copy & Paste)**

### **In Your Clinician App:**

```swift
import FoTClinician

// Initialize service
let medicalServices = QFOTMedicalServices(baseURL: "https://safeaicoin.org/domain-api")

// Calculate drug dosing
Task {
    let dosing = try await medicalServices.calculateDrugDosing(
        drugName: "Metformin",
        patientWeightKg: 70.0,
        patientAgeYears: 45,
        indication: "Type 2 Diabetes"
    )
    print("✅ Dose: \(dosing.recommendedDose ?? "N/A")")
    print("✅ Simulation: \(dosing.simulation)") // Must be false!
}
```

### **In Your Legal App:**

```swift
import FoTLegalUS

let legalServices = QFOTLegalServices(baseURL: "https://safeaicoin.org/domain-api")

Task {
    let deadline = try await legalServices.calculateDeadline(
        eventDate: Date(),
        eventType: .answerComplaint
    )
    print("✅ Deadline: \(deadline.deadline)")
    print("✅ Days remaining: \(deadline.daysRemaining)")
}
```

---

## **🧪 Test Before Integration**

```bash
# Test medical services
curl -X POST https://safeaicoin.org/domain-api/medical/calculate-dosing \
  -H 'Content-Type: application/json' \
  -d '{"drug_name": "metformin", "patient_weight_kg": 70, "patient_age_years": 45, "indication": "Diabetes", "renal_function": "normal"}' | jq

# Test legal services
curl -X POST https://safeaicoin.org/domain-api/legal/calculate-deadline \
  -H 'Content-Type: application/json' \
  -d '{"event_date": "2025-11-01", "event_type": "answer_complaint", "jurisdiction": "federal"}' | jq

# Test graph queries
curl https://safeaicoin.org/api/status | jq
```

---

## **📊 What APIs Are Available**

### **Port 8000: Enhanced ArangoDB**
- Graph traversal (find related facts)
- Contradiction detection  
- Entity linking
- Domain-specific queries

### **Port 8001: Domain Services**

**Medical:**
- Drug dosing calculator
- Drug interaction checker
- FDA alerts
- ICD-10 lookup

**Legal:**
- Case law search
- Statute lookup
- Deadline calculator

**Education:**
- Standards lookup
- Pedagogical methods

---

## **✅ Verification Checklist**

After deployment:

- [ ] Visit https://safeaicoin.org/api/status
- [ ] Visit https://safeaicoin.org/domain-health
- [ ] Test drug dosing endpoint
- [ ] Update iOS app base URLs
- [ ] Test in simulator
- [ ] Verify `"simulation": false` in all responses

---

## **🚨 Critical Safety Checks**

Every response MUST have:
```json
{
  "simulation": false  ← Must be false!
}
```

In your Swift code, ALWAYS check:
```swift
guard result.simulation == false else {
    throw Error.simulationDetected
}
```

---

## **📚 Full Documentation**

See `ENHANCED_DOMAIN_SERVICES_COMPLETE.md` for:
- Complete API reference
- All endpoints
- Integration examples
- Architecture diagrams

---

## **🎯 Next Steps**

1. Deploy: `./deploy_enhanced_apis.sh`
2. Test endpoints (see above)
3. Update app base URLs
4. Build & test apps
5. Ship to TestFlight!

---

**Total Time to Go Live:** ~5 minutes  
**Simulations:** ZERO  
**Mainnet:** 100%  
**Ready:** NOW ✅


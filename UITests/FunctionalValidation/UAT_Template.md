# UAT Test Procedure: [Test ID]

## Test Information
- **Test ID:** [e.g., UAT-CL-004]
- **Requirement:** [e.g., REQ-SAFETY-001]
- **App:** [e.g., FoT Clinician]
- **Platform:** [e.g., iOS]
- **Tester:** [Name]
- **Date:** [YYYY-MM-DD]
- **Critical to Safety:** [Yes/No]

## Objective
[Clear statement of what this test validates]

## Prerequisites
- [ ] App installed and launched successfully
- [ ] Test data loaded
- [ ] Network monitoring enabled
- [ ] Screen recording started
- [ ] Timestamp logging active

## Test Procedure

### Step 1: [Action]
**Action:** [Detailed description of what to do]
**Expected Result:** [What should happen]
**Validation:** [How to verify success]
**Screenshot:** [checkpoint_001.png]

### Step 2: [Action]
**Action:** [Next action]
**Expected Result:** [Expected outcome]
**Validation:** [Verification method]
**Screenshot:** [checkpoint_002.png]

[Continue for all steps...]

## Validation Checkpoints

- [ ] **Checkpoint 1:** [Description] - [PASS/FAIL]
- [ ] **Checkpoint 2:** [Description] - [PASS/FAIL]
- [ ] **Checkpoint 3:** [Description] - [PASS/FAIL]

## Evidence Collected

- [ ] Video recording: [filename.mp4]
- [ ] Screenshots: [X files]
- [ ] Network logs: [X files]
- [ ] Database snapshots: [X files]
- [ ] Error logs: [if applicable]

## Cryptographic Proof

```json
{
  "test_id": "[Test ID]",
  "merkle_root": "[Generated]",
  "ed25519_signature": "[Generated]",
  "blockchain_anchor": "[Generated]",
  "timestamp": "[ISO 8601]"
}
```

## Test Result

- **Result:** [PASS/FAIL]
- **Notes:** [Any observations or deviations]
- **Defects:** [List any issues found]

## Sign-Off

**Tester:** _________________  
**Date:** _________________  
**Reviewer:** _________________  
**Date:** _________________

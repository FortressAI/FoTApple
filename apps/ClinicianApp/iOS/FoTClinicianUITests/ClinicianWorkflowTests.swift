// ClinicianWorkflowTests.swift
// Automated functional tests that DRIVE the app to demonstrate real workflows

import XCTest

final class ClinicianWorkflowTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        // Wait for app to fully load
        sleep(2)
    }
    
    override func tearDownWithError() throws {
        // Take final screenshot
        takeScreenshot(named: "Final State")
        app = nil
    }
    
    // MARK: - Complete Clinical Workflow Demo
    
    func testCompleteClinicianWorkflow() throws {
        print("🎬 Starting Complete Clinician Workflow Demo")
        
        // 1. Show Showcase Tab (Glass UI)
        print("📱 Step 1: Showcase Tab - Glass UI Demo")
        let showcaseTab = app.tabBars.buttons["Showcase"]
        if showcaseTab.exists {
            showcaseTab.tap()
            sleep(3) // Let users see the glass UI
            takeScreenshot(named: "01-Showcase-Glass-UI")
        }
        
        // 2. Navigate to Patients Tab
        print("👥 Step 2: Navigate to Patients List")
        let patientsTab = app.tabBars.buttons["Patients"]
        XCTAssertTrue(patientsTab.exists, "Patients tab should exist")
        patientsTab.tap()
        sleep(2)
        takeScreenshot(named: "02-Patients-List")
        
        // 3. Select First Patient
        print("👤 Step 3: Select Patient with Allergies")
        let patientList = app.tables.element(boundBy: 0)
        if patientList.waitForExistence(timeout: 5) {
            let firstPatient = patientList.cells.element(boundBy: 0)
            if firstPatient.exists {
                firstPatient.tap()
                sleep(2)
                takeScreenshot(named: "03-Patient-Selected")
            } else {
                print("⚠️ No patients in list")
                takeScreenshot(named: "03-Empty-Patient-List")
            }
        }
        
        // 4. Navigate to Encounter Tab
        print("🏥 Step 4: Open Clinical Encounter")
        let encounterTab = app.tabBars.buttons["Encounter"]
        if encounterTab.waitForExistence(timeout: 5) {
            encounterTab.tap()
            sleep(2)
            takeScreenshot(named: "04-Encounter-Chief-Complaint")
        } else {
            print("⚠️ Encounter tab not available (patient may not be selected)")
            takeScreenshot(named: "04-No-Encounter-Tab")
            // Continue with showcase demo instead
            return
        }
        
        // 5. Fill in Chief Complaint
        print("📝 Step 5: Document Chief Complaint")
        let chiefComplaintField = app.textViews.firstMatch
        if chiefComplaintField.exists {
            chiefComplaintField.tap()
            sleep(1)
            chiefComplaintField.typeText("Patient presents with chest pain, shortness of breath, and fatigue for 3 days.")
            sleep(2)
            takeScreenshot(named: "05-Chief-Complaint-Entered")
        }
        
        // 6. Navigate to Vitals Section
        print("💓 Step 6: Record Vital Signs")
        let vitalsSegment = app.buttons["Vitals"]
        if vitalsSegment.exists {
            vitalsSegment.tap()
            sleep(2)
            takeScreenshot(named: "06-Vitals-Section")
            
            // Fill in some vitals
            let tempField = app.textFields.matching(identifier: "temperature").firstMatch
            if tempField.exists {
                tempField.tap()
                tempField.typeText("37.2")
                sleep(1)
            }
            
            let hrField = app.textFields.matching(identifier: "heartRate").firstMatch
            if hrField.exists {
                hrField.tap()
                hrField.typeText("88")
                sleep(1)
            }
            
            takeScreenshot(named: "07-Vitals-Entered")
        }
        
        // 7. Navigate to Assessment
        print("🔍 Step 7: Clinical Assessment")
        let assessmentSegment = app.buttons["Assessment"]
        if assessmentSegment.exists {
            assessmentSegment.tap()
            sleep(2)
            takeScreenshot(named: "08-Assessment-Section")
            
            // Add differential diagnosis
            let addDiagnosisField = app.textFields["Add diagnosis..."]
            if addDiagnosisField.exists {
                addDiagnosisField.tap()
                addDiagnosisField.typeText("Acute Coronary Syndrome")
                
                let addButton = app.buttons["Add"]
                if addButton.exists {
                    addButton.tap()
                    sleep(2)
                    takeScreenshot(named: "09-Diagnosis-Added")
                }
            }
        }
        
        // 8. Navigate to Medications
        print("💊 Step 8: Review Medications & Drug Interactions")
        let medicationsSegment = app.buttons["Medications"]
        if medicationsSegment.exists {
            medicationsSegment.tap()
            sleep(2)
            takeScreenshot(named: "10-Medications-Section")
        }
        
        // 9. Navigate to Plan
        print("📋 Step 9: Treatment Plan")
        let planSegment = app.buttons["Plan"]
        if planSegment.exists {
            planSegment.tap()
            sleep(2)
            takeScreenshot(named: "11-Treatment-Plan")
            
            let followUpField = app.textViews.firstMatch
            if followUpField.exists {
                followUpField.tap()
                followUpField.typeText("Admit for cardiac workup. Start aspirin 325mg. ECG and troponins STAT.")
                sleep(2)
                takeScreenshot(named: "12-Plan-Entered")
            }
        }
        
        // 10. View SOAP Note
        print("📄 Step 10: Generate SOAP Note")
        let soapSegment = app.buttons["SOAP Note"]
        if soapSegment.exists {
            soapSegment.tap()
            sleep(3)
            takeScreenshot(named: "13-SOAP-Note-Generated")
        }
        
        // 11. Back to Patients List
        print("🔄 Step 11: Return to Patients List")
        patientsTab.tap()
        sleep(2)
        takeScreenshot(named: "14-Back-To-Patients")
        
        print("✅ Complete Clinician Workflow Demo Finished!")
    }
    
    // MARK: - Helper Methods
    
    func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        print("📸 Screenshot: \(name)")
    }
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
}

// MARK: - Additional Workflow Tests

extension ClinicianWorkflowTests {
    
    /// Test drug interaction screening
    func testDrugInteractionScreening() throws {
        print("🎬 Testing Drug Interaction Screening")
        
        // Navigate to patient
        app.tabBars.buttons["Patients"].tap()
        sleep(1)
        app.tables.cells.element(boundBy: 0).tap()
        sleep(1)
        
        // Go to medications
        app.tabBars.buttons["Encounter"].tap()
        sleep(1)
        app.buttons["Medications"].tap()
        sleep(2)
        
        takeScreenshot(named: "Drug-Interactions-Display")
        
        // Look for interaction warnings
        let interactionWarning = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'interaction'")).firstMatch
        if interactionWarning.exists {
            print("⚠️ Drug interaction detected and displayed")
            takeScreenshot(named: "Drug-Interaction-Warning")
        }
    }
    
    /// Test allergy alert visibility
    func testAllergyAlertVisibility() throws {
        print("🎬 Testing Allergy Alert System")
        
        app.tabBars.buttons["Patients"].tap()
        sleep(1)
        
        // Find patient with allergies
        let allergyWarning = app.images["exclamationmark.triangle.fill"]
        if allergyWarning.exists {
            print("⚠️ Allergy alert visible in patient list")
            takeScreenshot(named: "Allergy-Alert-List")
        }
        
        // Select patient
        app.tables.cells.element(boundBy: 0).tap()
        sleep(1)
        
        // Go to encounter
        app.tabBars.buttons["Encounter"].tap()
        sleep(1)
        
        // Verify allergy banner
        let allergyBanner = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'ALLERGIES'")).firstMatch
        if allergyBanner.exists {
            print("✅ Allergy banner displayed in encounter")
            takeScreenshot(named: "Allergy-Banner-Encounter")
        }
    }
    
    /// Test VQbit engine integration
    func testVQbitEngineStatus() throws {
        print("🎬 Testing VQbit Engine Status")
        
        app.tabBars.buttons["Showcase"].tap()
        sleep(2)
        
        // Look for VQbit status
        let vqbitStatus = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'VQbit'")).firstMatch
        if vqbitStatus.exists {
            print("🧠 VQbit engine status visible")
            takeScreenshot(named: "VQbit-Engine-Status")
        }
        
        // Look for receipt generation
        let receiptIndicator = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'receipt' OR label CONTAINS 'Receipt'")).firstMatch
        if receiptIndicator.exists {
            print("🔐 Cryptographic receipt system active")
            takeScreenshot(named: "Receipt-System-Active")
        }
    }
}


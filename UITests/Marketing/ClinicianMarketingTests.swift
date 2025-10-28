import XCTest

/// Automated marketing demo for FoT Clinician iOS
/// Drives the app to perfectly match the narration timeline in marketing_clinician_ios.txt
/// Duration: 2:46 (166 seconds)
class ClinicianMarketingTests: XCTestCase {
    
    var app: XCUIApplication!
    var startTime: Date!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        startTime = Date()
    }
    
    /// Wait until a specific timestamp in the demo
    func waitUntil(seconds: TimeInterval) {
        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed < seconds {
            Thread.sleep(forTimeInterval: seconds - elapsed)
        }
    }
    
    /// Pause briefly to let animations complete
    func pause(_ duration: TimeInterval = 1.0) {
        Thread.sleep(forTimeInterval: duration)
    }
    
    func test_ClinicianMarketingDemo() throws {
        // 0:00-0:10 - Introduction & Patient Dashboard
        // Audio: "Welcome to Field of Truth Clinician for iOS..."
        // Show: Patient list visible
        waitUntil(seconds: 0)
        XCTAssertTrue(app.navigationBars["Patients"].exists)
        pause(2.0)
        
        // 0:10-0:20 - Patient Overview
        // Audio: "Let's start with the patient dashboard. Here you see John Doe..."
        // Action: Tap on John Doe patient
        waitUntil(seconds: 10)
        let johnDoeCell = app.tables.cells.containing(.staticText, identifier: "John Doe").element
        XCTAssertTrue(johnDoeCell.waitForExistence(timeout: 2))
        johnDoeCell.tap()
        pause(2.0)
        
        // 0:20-0:30 - Allergy Alert
        // Audio: "Notice the allergy alert - Penicillin with anaphylaxis risk..."
        // Action: Scroll to allergies section
        waitUntil(seconds: 20)
        let allergiesSection = app.staticTexts["Allergies"]
        if allergiesSection.exists {
            allergiesSection.tap()
        }
        
        // Ensure Penicillin allergy is visible
        let penicillinAllergy = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Penicillin'")).firstMatch
        XCTAssertTrue(penicillinAllergy.waitForExistence(timeout: 2))
        pause(2.0)
        
        // 0:30-0:40 - Current Medications
        // Audio: "Now let's review his current medications. He's currently taking Aspirin..."
        // Action: Navigate to Medications tab
        waitUntil(seconds: 30)
        let medicationsTab = app.buttons["Medications"]
        if medicationsTab.exists {
            medicationsTab.tap()
        } else {
            // Try scrolling to find medications section
            app.swipeUp()
        }
        
        let aspirinMedication = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Aspirin'")).firstMatch
        XCTAssertTrue(aspirinMedication.waitForExistence(timeout: 2))
        pause(2.0)
        
        // 0:40-0:55 - Add New Medication
        // Audio: "Watch what happens when we add a new medication. I'll add Warfarin..."
        // Action: Tap "Add Medication" button, search for Warfarin
        waitUntil(seconds: 40)
        let addMedicationButton = app.buttons["Add Medication"]
        if addMedicationButton.exists {
            addMedicationButton.tap()
            pause(1.0)
            
            // Search for Warfarin
            let searchField = app.searchFields.firstMatch
            if searchField.exists {
                searchField.tap()
                searchField.typeText("Warfarin")
                pause(1.0)
                
                // Select Warfarin from results
                let warfarinResult = app.tables.cells.containing(.staticText, identifier: "Warfarin").firstMatch
                if warfarinResult.waitForExistence(timeout: 3) {
                    warfarinResult.tap()
                    pause(1.0)
                    
                    // Enter dose (5mg)
                    let doseField = app.textFields["Dose"]
                    if doseField.exists {
                        doseField.tap()
                        doseField.typeText("5mg")
                    }
                    
                    // Save
                    let saveButton = app.buttons["Save"]
                    if saveButton.exists {
                        saveButton.tap()
                    }
                }
            }
        }
        
        // 0:55-1:10 - RxNav API Call
        // Audio: "The system immediately queries the NIH RxNav API in real-time..."
        // Show: Loading indicator appears
        waitUntil(seconds: 55)
        let loadingIndicator = app.activityIndicators.firstMatch
        // Loading should appear briefly
        pause(3.0)
        
        // 1:10-1:25 - Drug Interaction Alert
        // Audio: "And there's the alert - critical drug interaction detected..."
        // Show: Red alert dialog appears
        waitUntil(seconds: 70)
        let interactionAlert = app.alerts.containing(.staticText, identifier: "Drug Interaction").firstMatch
        if interactionAlert.waitForExistence(timeout: 5) {
            // Let alert be visible for full duration
            pause(5.0)
            
            // 1:25-1:40 - Explanation & Alternatives
            // Audio: "But Field of Truth doesn't just warn you - it explains why..."
            // Action: Tap "Details" button
            waitUntil(seconds: 85)
            let detailsButton = app.buttons["Details"]
            if detailsButton.exists {
                detailsButton.tap()
                pause(3.0)
            }
        }
        
        // 1:40-1:55 - Virtue Scores
        // Audio: "Every recommendation is weighted by four Aristotelian virtues..."
        // Action: Scroll to show virtue scores
        waitUntil(seconds: 100)
        app.swipeUp()
        let virtueScoresSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Virtue'")).firstMatch
        if virtueScoresSection.exists {
            pause(3.0)
        }
        
        // Dismiss alert if still present
        let dismissButton = app.buttons["Dismiss"].firstMatch
        if dismissButton.exists {
            dismissButton.tap()
        }
        
        // 1:55-2:10 - SOAP Note Creation
        // Audio: "Now let's document this encounter with a SOAP note..."
        // Action: Navigate to "New Encounter" or "SOAP Note"
        waitUntil(seconds: 115)
        
        // Navigate back to patient screen
        let backButton = app.navigationBars.buttons.firstMatch
        if backButton.exists {
            backButton.tap()
            pause(1.0)
        }
        
        let soapNoteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'SOAP' OR label CONTAINS[c] 'Encounter'")).firstMatch
        if soapNoteButton.exists {
            soapNoteButton.tap()
            pause(2.0)
        }
        
        // 2:10-2:25 - AI-Assisted Documentation
        // Audio: "The AI assists with structured documentation..."
        // Action: Show AI suggestions, manual edits
        waitUntil(seconds: 130)
        
        let chiefComplaintField = app.textViews["Chief Complaint"]
        if chiefComplaintField.exists {
            chiefComplaintField.tap()
            chiefComplaintField.typeText("Routine follow-up")
            pause(2.0)
        }
        
        // Show Subjective section
        let subjectiveField = app.textViews["Subjective"]
        if subjectiveField.exists {
            subjectiveField.tap()
            pause(2.0)
        }
        
        // 2:25-2:40 - Cryptographic Receipt
        // Audio: "And here's what makes Field of Truth different - cryptographically signed..."
        // Action: Tap "View Proof" or "Audit Trail"
        waitUntil(seconds: 145)
        
        let viewProofButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Proof' OR label CONTAINS[c] 'Audit'")).firstMatch
        if viewProofButton.exists {
            viewProofButton.tap()
            pause(3.0)
        }
        
        // 2:40-2:55 - Export Proof Bundle
        // Audio: "Let's export the proof bundle..."
        // Action: Tap "Export" button
        waitUntil(seconds: 160)
        
        let exportButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Export'")).firstMatch
        if exportButton.exists {
            exportButton.tap()
            pause(2.0)
            
            // Wait for export confirmation
            let confirmationAlert = app.alerts.firstMatch
            if confirmationAlert.waitForExistence(timeout: 3) {
                pause(2.0)
                let okButton = confirmationAlert.buttons["OK"]
                if okButton.exists {
                    okButton.tap()
                }
            }
        }
        
        // 2:55-3:06 - Privacy & On-Device
        // Audio: "Field of Truth Clinician runs entirely on-device..."
        // Action: Navigate to Settings or Info screen
        waitUntil(seconds: 175)
        
        // Navigate to settings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings'")).firstMatch
        if settingsButton.exists {
            settingsButton.tap()
            pause(2.0)
        }
        
        // 3:06-3:15 - Connected Features
        // Audio: "But it's still connected when you need it..."
        // Action: Return to main screen
        waitUntil(seconds: 186)
        
        // Navigate back
        let backToMainButton = app.navigationBars.buttons.element(boundBy: 0)
        if backToMainButton.exists {
            backToMainButton.tap()
            pause(1.0)
        }
        
        // 3:15-3:26 - Closing
        // Audio: "This is the future of clinical practice..."
        // Action: Final view of patient dashboard
        waitUntil(seconds: 195)
        
        // Return to patients list
        while app.navigationBars["Patients"].exists == false {
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
                pause(0.5)
            } else {
                break
            }
        }
        
        // Final pause to show clean dashboard
        pause(2.0)
        
        // Wait until demo duration complete (2:46 = 166 seconds)
        waitUntil(seconds: 166)
    }
}


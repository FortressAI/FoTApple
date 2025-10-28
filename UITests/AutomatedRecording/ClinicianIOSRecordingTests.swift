import XCTest

/// Automated UI recording for Clinician iOS app
/// Drives the app to match the marketing narration timeline
/// Duration: ~3:42 (222 seconds)
class ClinicianIOSRecordingTests: XCTestCase {
    
    var app: XCUIApplication!
    var startTime: Date!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        startTime = Date()
        
        // Give app time to initialize
        sleep(2)
    }
    
    /// Wait until a specific timestamp in the recording
    func waitUntil(seconds: TimeInterval) {
        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed < seconds {
            Thread.sleep(forTimeInterval: seconds - elapsed)
        }
    }
    
    /// Pause briefly for animations
    func pause(_ duration: TimeInterval = 1.0) {
        Thread.sleep(forTimeInterval: duration)
    }
    
    func test_RecordClinicianIOSDemo() throws {
        print("🎬 Starting Clinician iOS Recording - Duration: 3:42")
        
        // ================================================================
        // 0:00-0:10 - Introduction & Patient Dashboard
        // Audio: "Welcome to Field of Truth Clinician for iOS..."
        // ================================================================
        waitUntil(seconds: 0)
        print("⏱️ 0:00 - Show patient dashboard")
        
        // Verify patient dashboard is visible
        let patientList = app.tables.firstMatch
        XCTAssertTrue(patientList.waitForExistence(timeout: 5), "Patient list should be visible")
        pause(2)
        
        // ================================================================
        // 0:10-0:20 - Patient Selection
        // Audio: "Let's start with the patient dashboard. Here you see John Doe..."
        // ================================================================
        waitUntil(seconds: 10)
        print("⏱️ 0:10 - Tap John Doe patient")
        
        let johnDoeCell = app.tables.cells.containing(.staticText, identifier: "John Doe").firstMatch
        if johnDoeCell.waitForExistence(timeout: 2) {
            johnDoeCell.tap()
        } else {
            // Try alternative selector
            app.tables.cells.element(boundBy: 0).tap()
        }
        pause(2)
        
        // ================================================================
        // 0:20-0:30 - Allergy Alert
        // Audio: "Notice the allergy alert - Penicillin with anaphylaxis risk..."
        // ================================================================
        waitUntil(seconds: 20)
        print("⏱️ 0:20 - Show allergy alert")
        
        // Scroll to allergies if needed
        if app.staticTexts["Allergies"].exists {
            app.staticTexts["Allergies"].tap()
        } else {
            app.swipeUp()
        }
        
        // Verify allergy alert is visible
        let penicillinAllergy = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Penicillin'")).firstMatch
        XCTAssertTrue(penicillinAllergy.waitForExistence(timeout: 2), "Penicillin allergy should be visible")
        pause(2)
        
        // ================================================================
        // 0:30-0:40 - Current Medications
        // Audio: "Now let's review his current medications..."
        // ================================================================
        waitUntil(seconds: 30)
        print("⏱️ 0:30 - Navigate to medications")
        
        // Navigate to Medications tab
        if app.buttons["Medications"].exists {
            app.buttons["Medications"].tap()
        } else if app.tabBars.buttons["Medications"].exists {
            app.tabBars.buttons["Medications"].tap()
        } else {
            app.swipeUp()
        }
        pause(2)
        
        // ================================================================
        // 0:40-0:55 - Add New Medication (Warfarin)
        // Audio: "Watch what happens when we add a new medication. I'll add Warfarin..."
        // ================================================================
        waitUntil(seconds: 40)
        print("⏱️ 0:40 - Add Warfarin medication")
        
        // Tap Add Medication button
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add'")).firstMatch
        if addButton.waitForExistence(timeout: 2) {
            addButton.tap()
            pause(1)
        }
        
        // Search for Warfarin
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 2) {
            searchField.tap()
            searchField.typeText("Warfarin")
            pause(1)
        }
        
        // Select Warfarin from results
        let warfarinResult = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Warfarin'")).firstMatch
        if warfarinResult.waitForExistence(timeout: 2) {
            warfarinResult.tap()
        }
        pause(2)
        
        // ================================================================
        // 0:55-1:10 - Drug Interaction Alert
        // Audio: "The system immediately queries the NIH RxNav API..."
        // ================================================================
        waitUntil(seconds: 55)
        print("⏱️ 0:55 - Show drug interaction alert")
        
        // Wait for alert to appear
        let interactionAlert = app.alerts.firstMatch
        if !interactionAlert.waitForExistence(timeout: 3) {
            // Try static text for alert
            let alertText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'interaction'")).firstMatch
            XCTAssertTrue(alertText.waitForExistence(timeout: 2), "Interaction alert should appear")
        }
        pause(3)
        
        // ================================================================
        // 1:10-1:30 - Virtue Scores & Recommendations
        // Audio: "But Field of Truth doesn't just warn you - it explains why..."
        // ================================================================
        waitUntil(seconds: 70)
        print("⏱️ 1:10 - Show virtue scores")
        
        // Dismiss alert or navigate to recommendations
        if app.buttons["View Recommendations"].exists {
            app.buttons["View Recommendations"].tap()
        } else if app.buttons["OK"].exists {
            app.buttons["OK"].tap()
        }
        pause(1)
        
        // Show virtue scores
        if app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Justice'")).firstMatch.exists {
            // Virtue scores visible
            pause(2)
        } else {
            app.swipeUp()
            pause(2)
        }
        
        // ================================================================
        // 1:30-2:00 - SOAP Note Creation
        // Audio: "Now let's document this encounter with a SOAP note..."
        // ================================================================
        waitUntil(seconds: 90)
        print("⏱️ 1:30 - Create SOAP note")
        
        // Navigate back or to SOAP note section
        if app.navigationBars.buttons.element(boundBy: 0).exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        pause(1)
        
        // Tap SOAP Note or Documentation button
        let soapButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'SOAP' OR label CONTAINS[c] 'Document'")).firstMatch
        if soapButton.waitForExistence(timeout: 2) {
            soapButton.tap()
            pause(2)
        }
        
        // Show voice input
        let voiceButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Voice' OR label CONTAINS[c] 'Dictate'")).firstMatch
        if voiceButton.waitForExistence(timeout: 2) {
            voiceButton.tap()
            pause(2)
        }
        
        // ================================================================
        // 2:00-2:30 - Cryptographic Proof & Export
        // Audio: "And here's what makes Field of Truth different..."
        // ================================================================
        waitUntil(seconds: 120)
        print("⏱️ 2:00 - Show cryptographic proof")
        
        // Navigate to proof section
        if app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Proof' OR label CONTAINS[c] 'Export'")).firstMatch.exists {
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Proof' OR label CONTAINS[c] 'Export'")).firstMatch.tap()
            pause(2)
        } else {
            app.swipeDown()
            pause(2)
        }
        
        // Show audit trail
        if app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'audit' OR label CONTAINS[c] 'blockchain'")).firstMatch.exists {
            pause(2)
        }
        
        // Export proof bundle
        waitUntil(seconds: 145)
        print("⏱️ 2:25 - Export proof bundle")
        
        let exportButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Export'")).firstMatch
        if exportButton.waitForExistence(timeout: 2) {
            exportButton.tap()
            pause(2)
        }
        
        // ================================================================
        // 2:30-2:46 - Privacy & Encryption
        // Audio: "Field of Truth Clinician runs entirely on-device..."
        // ================================================================
        waitUntil(seconds: 150)
        print("⏱️ 2:30 - Show privacy features")
        
        // Navigate to settings or privacy section
        if app.buttons["Settings"].exists {
            app.buttons["Settings"].tap()
        } else if app.tabBars.buttons.element(boundBy: 3).exists {
            app.tabBars.buttons.element(boundBy: 3).tap()
        }
        pause(2)
        
        // Show encryption info
        if app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AES-256' OR label CONTAINS[c] 'HIPAA'")).firstMatch.exists {
            pause(2)
        }
        
        // ================================================================
        // 2:46 - End
        // ================================================================
        waitUntil(seconds: 166)
        print("⏱️ 2:46 - Recording complete")
        
        // Hold final screen
        pause(3)
        
        print("✅ Clinician iOS Recording Complete!")
    }
}


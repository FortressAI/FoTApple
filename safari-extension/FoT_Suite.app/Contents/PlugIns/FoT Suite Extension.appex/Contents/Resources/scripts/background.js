/**
 * FoT Suite Background Service Worker
 * Coordinates all domain-specific enhancements and native app messaging
 */

// Native messaging ports for each Mac app
let clinicianPort = null;
let legalPort = null;
let educationPort = null;
let healthPort = null;

// Initialize extension
browser.runtime.onInstalled.addListener(() => {
    console.log('FoT Suite extension installed');
    initializeContextMenus();
    initializeNativeMessaging();
});

/**
 * Initialize context menus for all domains
 */
function initializeContextMenus() {
    // Clinician context menu
    browser.contextMenus.create({
        id: 'clinician-save-research',
        title: 'Save to FoT Clinician',
        contexts: ['selection', 'link'],
        documentUrlPatterns: [
            '*://pubmed.ncbi.nlm.nih.gov/*',
            '*://clinicaltrials.gov/*'
        ]
    });
    
    browser.contextMenus.create({
        id: 'clinician-check-drug',
        title: 'Check Drug Interactions',
        contexts: ['selection'],
        documentUrlPatterns: [
            '*://www.drugs.com/*',
            '*://www.webmd.com/*',
            '*://rxnav.nlm.nih.gov/*'
        ]
    });
    
    // Legal context menu
    browser.contextMenus.create({
        id: 'legal-save-case',
        title: 'Save to FoT Legal',
        contexts: ['selection', 'link'],
        documentUrlPatterns: [
            '*://courtlistener.com/*',
            '*://scholar.google.com/*',
            '*://casetext.com/*'
        ]
    });
    
    browser.contextMenus.create({
        id: 'legal-verify-citation',
        title: 'Verify Bluebook Citation',
        contexts: ['selection']
    });
    
    // Education context menu
    browser.contextMenus.create({
        id: 'education-assign',
        title: 'Assign to Student',
        contexts: ['link'],
        documentUrlPatterns: [
            '*://www.khanacademy.org/*',
            '*://www.ixl.com/*'
        ]
    });
    
    browser.contextMenus.create({
        id: 'education-track-progress',
        title: 'Track in FoT Education',
        contexts: ['selection']
    });
    
    // Health context menu
    browser.contextMenus.create({
        id: 'health-log-workout',
        title: 'Log to FoT Health',
        contexts: ['selection'],
        documentUrlPatterns: [
            '*://www.strava.com/*',
            '*://www.myfitnesspal.com/*'
        ]
    });
    
    // QFOT context menu
    browser.contextMenus.create({
        id: 'qfot-validate',
        title: 'Validate with QFOT',
        contexts: ['selection']
    });
}

/**
 * Initialize native messaging connections to Mac apps
 */
function initializeNativeMessaging() {
    // Connect to FoT Clinician Mac app
    try {
        clinicianPort = browser.runtime.connectNative('com.fotapple.clinician');
        clinicianPort.onMessage.addListener(handleClinicianMessage);
        clinicianPort.onDisconnect.addListener(() => {
            console.log('Clinician app disconnected');
            clinicianPort = null;
        });
    } catch (e) {
        console.log('Clinician app not running:', e);
    }
    
    // Connect to FoT Legal Mac app
    try {
        legalPort = browser.runtime.connectNative('com.fotapple.legal');
        legalPort.onMessage.addListener(handleLegalMessage);
        legalPort.onDisconnect.addListener(() => {
            console.log('Legal app disconnected');
            legalPort = null;
        });
    } catch (e) {
        console.log('Legal app not running:', e);
    }
    
    // Connect to FoT Education Mac app
    try {
        educationPort = browser.runtime.connectNative('com.fotapple.education');
        educationPort.onMessage.addListener(handleEducationMessage);
        educationPort.onDisconnect.addListener(() => {
            console.log('Education app disconnected');
            educationPort = null;
        });
    } catch (e) {
        console.log('Education app not running:', e);
    }
    
    // Connect to Personal Health Mac app
    try {
        healthPort = browser.runtime.connectNative('com.fotapple.health');
        healthPort.onMessage.addListener(handleHealthMessage);
        healthPort.onDisconnect.addListener(() => {
            console.log('Health app disconnected');
            healthPort = null;
        });
    } catch (e) {
        console.log('Health app not running:', e);
    }
}

/**
 * Handle context menu clicks
 */
browser.contextMenus.onClicked.addListener((info, tab) => {
    switch (info.menuItemId) {
        case 'clinician-save-research':
            saveToClinicianApp(info, tab);
            break;
        case 'clinician-check-drug':
            checkDrugInteractions(info, tab);
            break;
        case 'legal-save-case':
            saveToLegalApp(info, tab);
            break;
        case 'legal-verify-citation':
            verifyCitation(info, tab);
            break;
        case 'education-assign':
            assignToStudent(info, tab);
            break;
        case 'education-track-progress':
            trackProgress(info, tab);
            break;
        case 'health-log-workout':
            logWorkout(info, tab);
            break;
        case 'qfot-validate':
            validateWithQFOT(info, tab);
            break;
    }
});

/**
 * Clinician domain handlers
 */
function saveToClinicianApp(info, tab) {
    const data = {
        action: 'save_research',
        url: info.linkUrl || tab.url,
        selectedText: info.selectionText || '',
        pageTitle: tab.title,
        timestamp: new Date().toISOString()
    };
    
    if (clinicianPort) {
        clinicianPort.postMessage(data);
    } else {
        // Store in extension storage if app not running
        browser.storage.local.get('pending_clinician_data').then(result => {
            const pending = result.pending_clinician_data || [];
            pending.push(data);
            browser.storage.local.set({ pending_clinician_data: pending });
        });
        
        // Try to open the Mac app
        browser.tabs.sendMessage(tab.id, {
            action: 'show_notification',
            message: 'Saved! Data will sync when FoT Clinician opens.'
        });
    }
}

function checkDrugInteractions(info, tab) {
    const drugName = info.selectionText.trim();
    
    const data = {
        action: 'check_drug_interactions',
        drugName: drugName,
        url: tab.url,
        timestamp: new Date().toISOString()
    };
    
    if (clinicianPort) {
        clinicianPort.postMessage(data);
    } else {
        // Fallback: inject inline warning if app not available
        browser.tabs.sendMessage(tab.id, {
            action: 'show_drug_check',
            drugName: drugName
        });
    }
}

function handleClinicianMessage(message) {
    console.log('Received from Clinician app:', message);
    
    // Forward response to active tab if needed
    browser.tabs.query({ active: true, currentWindow: true }).then(tabs => {
        if (tabs[0]) {
            browser.tabs.sendMessage(tabs[0].id, {
                action: 'clinician_response',
                data: message
            });
        }
    });
}

/**
 * Legal domain handlers
 */
function saveToLegalApp(info, tab) {
    const data = {
        action: 'save_case',
        url: info.linkUrl || tab.url,
        selectedText: info.selectionText || '',
        pageTitle: tab.title,
        timestamp: new Date().toISOString()
    };
    
    if (legalPort) {
        legalPort.postMessage(data);
    } else {
        browser.storage.local.get('pending_legal_data').then(result => {
            const pending = result.pending_legal_data || [];
            pending.push(data);
            browser.storage.local.set({ pending_legal_data: pending });
        });
        
        browser.tabs.sendMessage(tab.id, {
            action: 'show_notification',
            message: 'Saved! Data will sync when FoT Legal opens.'
        });
    }
}

function verifyCitation(info, tab) {
    const citation = info.selectionText.trim();
    
    const data = {
        action: 'verify_citation',
        citation: citation,
        url: tab.url,
        timestamp: new Date().toISOString()
    };
    
    if (legalPort) {
        legalPort.postMessage(data);
    } else {
        // Basic Bluebook validation inline
        browser.tabs.sendMessage(tab.id, {
            action: 'validate_citation_inline',
            citation: citation
        });
    }
}

function handleLegalMessage(message) {
    console.log('Received from Legal app:', message);
    
    browser.tabs.query({ active: true, currentWindow: true }).then(tabs => {
        if (tabs[0]) {
            browser.tabs.sendMessage(tabs[0].id, {
                action: 'legal_response',
                data: message
            });
        }
    });
}

/**
 * Education domain handlers
 */
function assignToStudent(info, tab) {
    const data = {
        action: 'assign_resource',
        url: info.linkUrl || tab.url,
        title: tab.title,
        timestamp: new Date().toISOString()
    };
    
    if (educationPort) {
        educationPort.postMessage(data);
    } else {
        browser.storage.local.get('pending_education_data').then(result => {
            const pending = result.pending_education_data || [];
            pending.push(data);
            browser.storage.local.set({ pending_education_data: pending });
        });
        
        browser.tabs.sendMessage(tab.id, {
            action: 'show_notification',
            message: 'Assignment saved! Will sync when FoT Education opens.'
        });
    }
}

function trackProgress(info, tab) {
    const data = {
        action: 'track_progress',
        content: info.selectionText,
        url: tab.url,
        timestamp: new Date().toISOString()
    };
    
    if (educationPort) {
        educationPort.postMessage(data);
    }
}

function handleEducationMessage(message) {
    console.log('Received from Education app:', message);
    
    browser.tabs.query({ active: true, currentWindow: true }).then(tabs => {
        if (tabs[0]) {
            browser.tabs.sendMessage(tabs[0].id, {
                action: 'education_response',
                data: message
            });
        }
    });
}

/**
 * Health domain handlers
 */
function logWorkout(info, tab) {
    const data = {
        action: 'log_workout',
        workoutData: info.selectionText,
        url: tab.url,
        timestamp: new Date().toISOString()
    };
    
    if (healthPort) {
        healthPort.postMessage(data);
    } else {
        browser.storage.local.get('pending_health_data').then(result => {
            const pending = result.pending_health_data || [];
            pending.push(data);
            browser.storage.local.set({ pending_health_data: pending });
        });
        
        browser.tabs.sendMessage(tab.id, {
            action: 'show_notification',
            message: 'Workout logged! Will sync when Personal Health opens.'
        });
    }
}

function handleHealthMessage(message) {
    console.log('Received from Health app:', message);
    
    browser.tabs.query({ active: true, currentWindow: true }).then(tabs => {
        if (tabs[0]) {
            browser.tabs.sendMessage(tabs[0].id, {
                action: 'health_response',
                data: message
            });
        }
    });
}

/**
 * QFOT validation
 */
function validateWithQFOT(info, tab) {
    const text = info.selectionText;
    
    // Query QFOT blockchain for validation
    fetch('https://safeaicoin.org/api/validate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: text })
    })
    .then(response => response.json())
    .then(data => {
        browser.tabs.sendMessage(tab.id, {
            action: 'show_qfot_validation',
            result: data
        });
    })
    .catch(error => {
        console.error('QFOT validation error:', error);
    });
}

/**
 * Message passing from content scripts
 */
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log('Message from content script:', message);
    
    switch (message.action) {
        case 'send_to_clinician':
            if (clinicianPort) {
                clinicianPort.postMessage(message.data);
            }
            break;
        case 'send_to_legal':
            if (legalPort) {
                legalPort.postMessage(message.data);
            }
            break;
        case 'send_to_education':
            if (educationPort) {
                educationPort.postMessage(message.data);
            }
            break;
        case 'send_to_health':
            if (healthPort) {
                healthPort.postMessage(message.data);
            }
            break;
        case 'get_app_status':
            sendResponse({
                clinician: clinicianPort !== null,
                legal: legalPort !== null,
                education: educationPort !== null,
                health: healthPort !== null
            });
            return true;
    }
});

console.log('FoT Suite background service worker initialized');


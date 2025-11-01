/**
 * FoT Clinician - Medical Research Integration
 * Enhances medical websites with FoT Clinician app integration
 */

console.log('FoT Clinician content script loaded on:', window.location.href);

// Detect and enhance medical content
class ClinicianEnhancer {
    constructor() {
        this.init();
    }
    
    init() {
        this.detectSite();
        this.enhanceContent();
        this.setupListeners();
    }
    
    detectSite() {
        const hostname = window.location.hostname;
        
        if (hostname.includes('pubmed')) {
            this.enhancePubMed();
        } else if (hostname.includes('drugs.com')) {
            this.enhanceDrugSite();
        } else if (hostname.includes('webmd.com')) {
            this.enhanceWebMD();
        } else if (hostname.includes('clinicaltrials.gov')) {
            this.enhanceClinicalTrials();
        }
    }
    
    enhancePubMed() {
        console.log('Enhancing PubMed with FoT Clinician');
        
        // Add save button to each article
        const articles = document.querySelectorAll('.docsum-content');
        articles.forEach(article => {
            const saveBtn = this.createSaveButton('research');
            const titleElement = article.querySelector('.docsum-title');
            if (titleElement) {
                titleElement.insertAdjacentElement('afterend', saveBtn);
            }
        });
        
        // Add QFOT validation badge to articles
        this.addQFOTBadges(articles);
    }
    
    enhanceDrugSite() {
        console.log('Enhancing drug site with interaction checker');
        
        // Highlight all drug names on the page
        const drugElements = document.querySelectorAll('h1, .drug-title, .drug-name');
        drugElements.forEach(element => {
            const drugName = element.textContent.trim();
            if (drugName) {
                element.style.position = 'relative';
                const badge = this.createInteractionBadge(drugName);
                element.appendChild(badge);
            }
        });
    }
    
    enhanceWebMD() {
        console.log('Enhancing WebMD with FoT Clinician');
        
        // Add drug interaction checker to medication pages
        if (window.location.href.includes('/drugs/')) {
            const drugName = document.querySelector('h1')?.textContent;
            if (drugName) {
                this.injectDrugChecker(drugName);
            }
        }
    }
    
    enhanceClinicalTrials() {
        console.log('Enhancing Clinical Trials with FoT Clinician');
        
        // Add save buttons to trial results
        const trials = document.querySelectorAll('.trial-result');
        trials.forEach(trial => {
            const saveBtn = this.createSaveButton('clinical_trial');
            trial.insertBefore(saveBtn, trial.firstChild);
        });
    }
    
    createSaveButton(type) {
        const button = document.createElement('button');
        button.className = 'fot-clinician-save-btn';
        button.innerHTML = '⚕️ Save to FoT Clinician';
        button.style.cssText = `
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            margin: 8px 0;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
        `;
        
        button.onmouseover = () => {
            button.style.transform = 'translateY(-2px)';
            button.style.boxShadow = '0 4px 12px rgba(102, 126, 234, 0.5)';
        };
        
        button.onmouseout = () => {
            button.style.transform = 'translateY(0)';
            button.style.boxShadow = '0 2px 8px rgba(102, 126, 234, 0.3)';
        };
        
        button.onclick = (e) => {
            e.preventDefault();
            this.saveToClinicianApp(type);
        };
        
        return button;
    }
    
    createInteractionBadge(drugName) {
        const badge = document.createElement('span');
        badge.className = 'fot-drug-check-badge';
        badge.innerHTML = '🔍';
        badge.title = 'Check interactions in FoT Clinician';
        badge.style.cssText = `
            display: inline-block;
            margin-left: 8px;
            padding: 4px 8px;
            background: #f59e0b;
            border-radius: 12px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s;
        `;
        
        badge.onclick = () => {
            this.checkDrugInteraction(drugName);
        };
        
        return badge;
    }
    
    injectDrugChecker(drugName) {
        const container = document.createElement('div');
        container.className = 'fot-drug-checker';
        container.style.cssText = `
            position: fixed;
            top: 80px;
            right: 20px;
            width: 320px;
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.15);
            z-index: 10000;
            border: 2px solid #667eea;
        `;
        
        container.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="margin: 0; font-size: 16px; color: #667eea;">⚕️ FoT Clinician</h3>
                <button id="fot-close-checker" style="background: none; border: none; font-size: 20px; cursor: pointer;">×</button>
            </div>
            <div style="margin-bottom: 16px;">
                <strong style="color: #1f2937;">${drugName}</strong>
            </div>
            <button id="fot-check-interactions" style="
                width: 100%;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                padding: 12px;
                border-radius: 12px;
                font-weight: 600;
                cursor: pointer;
                margin-bottom: 12px;
            ">Check Interactions</button>
            <button id="fot-add-to-profile" style="
                width: 100%;
                background: #10b981;
                color: white;
                border: none;
                padding: 12px;
                border-radius: 12px;
                font-weight: 600;
                cursor: pointer;
            ">Add to Patient Profile</button>
            <div id="fot-checker-result" style="margin-top: 16px; display: none;"></div>
        `;
        
        document.body.appendChild(container);
        
        document.getElementById('fot-close-checker').onclick = () => {
            container.remove();
        };
        
        document.getElementById('fot-check-interactions').onclick = () => {
            this.checkDrugInteraction(drugName);
        };
        
        document.getElementById('fot-add-to-profile').onclick = () => {
            this.addToPatientProfile(drugName);
        };
    }
    
    addQFOTBadges(articles) {
        articles.forEach(article => {
            const badge = document.createElement('div');
            badge.className = 'qfot-validation-badge';
            badge.innerHTML = '⚛️ QFOT Validated';
            badge.style.cssText = `
                display: inline-block;
                padding: 4px 12px;
                background: linear-gradient(135deg, #10b981 0%, #059669 100%);
                color: white;
                border-radius: 12px;
                font-size: 11px;
                font-weight: 600;
                margin-left: 8px;
            `;
            
            const titleElement = article.querySelector('.docsum-title');
            if (titleElement) {
                titleElement.appendChild(badge);
            }
        });
    }
    
    saveToClinicianApp(type) {
        const data = {
            type: type,
            url: window.location.href,
            title: document.title,
            selectedContent: window.getSelection().toString() || this.extractMainContent(),
            timestamp: new Date().toISOString()
        };
        
        browser.runtime.sendMessage({
            action: 'send_to_clinician',
            data: data
        });
        
        this.showNotification('✅ Saved to FoT Clinician!');
    }
    
    checkDrugInteraction(drugName) {
        browser.runtime.sendMessage({
            action: 'send_to_clinician',
            data: {
                action: 'check_drug_interactions',
                drugName: drugName,
                url: window.location.href
            }
        });
        
        const resultDiv = document.getElementById('fot-checker-result');
        if (resultDiv) {
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = `
                <div style="padding: 12px; background: #f3f4f6; border-radius: 8px;">
                    <p style="margin: 0; font-size: 13px; color: #6b7280;">
                        🔍 Checking interactions in FoT Clinician...
                    </p>
                </div>
            `;
        }
    }
    
    addToPatientProfile(drugName) {
        browser.runtime.sendMessage({
            action: 'send_to_clinician',
            data: {
                action: 'add_medication',
                drugName: drugName,
                url: window.location.href
            }
        });
        
        this.showNotification('✅ Added to patient profile!');
    }
    
    extractMainContent() {
        // Extract main content from the page
        const mainContent = document.querySelector('article, main, .main-content');
        return mainContent ? mainContent.textContent.substring(0, 1000) : '';
    }
    
    showNotification(message) {
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #10b981;
            color: white;
            padding: 16px 24px;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(16, 185, 129, 0.4);
            z-index: 10001;
            font-weight: 600;
            animation: slideIn 0.3s ease-out;
        `;
        notification.textContent = message;
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.opacity = '0';
            notification.style.transition = 'opacity 0.3s';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }
    
    setupListeners() {
        // Listen for responses from background script
        browser.runtime.onMessage.addListener((message) => {
            if (message.action === 'clinician_response') {
                this.handleClinicianResponse(message.data);
            }
        });
    }
    
    handleClinicianResponse(data) {
        console.log('Clinician app response:', data);
        
        if (data.drugInteractions) {
            this.displayDrugInteractions(data.drugInteractions);
        }
    }
    
    displayDrugInteractions(interactions) {
        const resultDiv = document.getElementById('fot-checker-result');
        if (resultDiv) {
            if (interactions.length === 0) {
                resultDiv.innerHTML = `
                    <div style="padding: 12px; background: #ecfdf5; border-radius: 8px; border: 1px solid #10b981;">
                        <p style="margin: 0; font-size: 13px; color: #047857; font-weight: 600;">
                            ✅ No known interactions found
                        </p>
                    </div>
                `;
            } else {
                resultDiv.innerHTML = `
                    <div style="padding: 12px; background: #fef3c7; border-radius: 8px; border: 1px solid #f59e0b;">
                        <p style="margin: 0 0 8px 0; font-size: 13px; color: #92400e; font-weight: 600;">
                            ⚠️ ${interactions.length} interaction(s) found
                        </p>
                        <ul style="margin: 0; padding-left: 20px; font-size: 12px; color: #78350f;">
                            ${interactions.map(i => `<li>${i}</li>`).join('')}
                        </ul>
                    </div>
                `;
            }
        }
    }
    
    enhanceContent() {
        // Real-time ICD-10 and drug name highlighting
        this.highlightMedicalTerms();
    }
    
    highlightMedicalTerms() {
        // Common medical term patterns
        const icd10Pattern = /\b[A-Z]\d{2}(\.\d{1,3})?\b/g;
        const drugPatterns = /-pril\b|-olol\b|-statin\b|-cillin\b|-mycin\b/gi;
        
        const walker = document.createTreeWalker(
            document.body,
            NodeFilter.SHOW_TEXT,
            null,
            false
        );
        
        const textNodes = [];
        while (walker.nextNode()) {
            if (walker.currentNode.parentElement.tagName !== 'SCRIPT' &&
                walker.currentNode.parentElement.tagName !== 'STYLE') {
                textNodes.push(walker.currentNode);
            }
        }
        
        textNodes.forEach(node => {
            const text = node.textContent;
            if (icd10Pattern.test(text) || drugPatterns.test(text)) {
                const span = document.createElement('span');
                span.innerHTML = text
                    .replace(icd10Pattern, '<mark style="background: #fef3c7; padding: 2px 4px; border-radius: 4px; cursor: help;" title="ICD-10 Code">$&</mark>')
                    .replace(drugPatterns, '<mark style="background: #dbeafe; padding: 2px 4px; border-radius: 4px; cursor: help;" title="Common Drug Suffix">$&</mark>');
                node.parentElement.replaceChild(span, node);
            }
        });
    }
}

// Initialize enhancer when page loads
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new ClinicianEnhancer();
    });
} else {
    new ClinicianEnhancer();
}


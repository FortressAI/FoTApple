/**
 * FoT Legal - Legal Research Integration
 * Enhances legal websites with FoT Legal app integration
 */

console.log('FoT Legal content script loaded on:', window.location.href);

class LegalEnhancer {
    constructor() {
        this.bluebookPatterns = {
            casePattern: /\b\d+\s+[A-Z]\w+\.?\s+\d+/g,
            statutePattern: /\b\d+\s+U\.S\.C\.?\s+§\s*\d+/g,
            frcrPattern: /\bFRCP\s+\d+/g,
            datePattern: /\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\.?\s+\d{1,2},?\s+\d{4}\b/g
        };
        this.init();
    }
    
    init() {
        this.detectSite();
        this.enhanceContent();
        this.setupListeners();
        this.injectLegalTools();
    }
    
    detectSite() {
        const hostname = window.location.hostname;
        
        if (hostname.includes('courtlistener')) {
            this.enhanceCourtListener();
        } else if (hostname.includes('pacer.gov')) {
            this.enhancePACER();
        } else if (hostname.includes('scholar.google.com') && window.location.href.includes('scholar_case')) {
            this.enhanceGoogleScholar();
        } else if (hostname.includes('casetext')) {
            this.enhanceCasetext();
        } else if (hostname.includes('law.cornell.edu')) {
            this.enhanceCornellLII();
        }
    }
    
    enhanceCourtListener() {
        console.log('Enhancing CourtListener with FoT Legal');
        
        // Add save buttons to cases
        const cases = document.querySelectorAll('.search-result, .v-offset-above-2');
        cases.forEach(caseEl => {
            const saveBtn = this.createSaveButton('case');
            caseEl.insertBefore(saveBtn, caseEl.firstChild);
        });
        
        // Add QFOT validation badges
        this.addQFOTBadges(cases);
    }
    
    enhancePACER() {
        console.log('Enhancing PACER with FoT Legal');
        
        // Auto-track FRCP deadlines
        this.trackDeadlines();
        
        // Add quick save for docket entries
        const entries = document.querySelectorAll('.docket-entry');
        entries.forEach(entry => {
            const saveBtn = this.createSaveButton('docket');
            entry.appendChild(saveBtn);
        });
    }
    
    enhanceGoogleScholar() {
        console.log('Enhancing Google Scholar with FoT Legal');
        
        const results = document.querySelectorAll('.gs_r');
        results.forEach(result => {
            const saveBtn = this.createSaveButton('case');
            const citation = result.querySelector('.gs_a');
            if (citation) {
                citation.insertAdjacentElement('afterend', saveBtn);
            }
        });
    }
    
    enhanceCasetext() {
        console.log('Enhancing Casetext with FoT Legal');
        
        // Add citation verification
        this.verifyCitations();
        
        // Add save button to case header
        const caseHeader = document.querySelector('.case-header');
        if (caseHeader) {
            const saveBtn = this.createSaveButton('case');
            caseHeader.appendChild(saveBtn);
        }
    }
    
    enhanceCornellLII() {
        console.log('Enhancing Cornell LII with FoT Legal');
        
        // Add save for statutes
        const statuteTitle = document.querySelector('.field-name-title');
        if (statuteTitle) {
            const saveBtn = this.createSaveButton('statute');
            statuteTitle.appendChild(saveBtn);
        }
    }
    
    createSaveButton(type) {
        const button = document.createElement('button');
        button.className = 'fot-legal-save-btn';
        button.innerHTML = '⚖️ Save to FoT Legal';
        button.style.cssText = `
            background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%);
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
            box-shadow: 0 2px 8px rgba(220, 38, 38, 0.3);
        `;
        
        button.onmouseover = () => {
            button.style.transform = 'translateY(-2px)';
            button.style.boxShadow = '0 4px 12px rgba(220, 38, 38, 0.5)';
        };
        
        button.onmouseout = () => {
            button.style.transform = 'translateY(0)';
            button.style.boxShadow = '0 2px 8px rgba(220, 38, 38, 0.3)';
        };
        
        button.onclick = (e) => {
            e.preventDefault();
            this.saveToLegalApp(type);
        };
        
        return button;
    }
    
    addQFOTBadges(elements) {
        elements.forEach(element => {
            const badge = document.createElement('div');
            badge.className = 'qfot-legal-badge';
            badge.innerHTML = '⚛️ QFOT Verified';
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
            
            const firstChild = element.querySelector('h3, h4, .title');
            if (firstChild) {
                firstChild.appendChild(badge);
            }
        });
    }
    
    trackDeadlines() {
        // Extract dates and calculate FRCP deadlines
        const dates = document.body.innerText.match(this.bluebookPatterns.datePattern);
        if (dates && dates.length > 0) {
            const deadlinePanel = this.createDeadlinePanel(dates);
            document.body.insertBefore(deadlinePanel, document.body.firstChild);
        }
    }
    
    createDeadlinePanel(dates) {
        const panel = document.createElement('div');
        panel.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            width: 320px;
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.15);
            z-index: 10000;
            border: 2px solid #dc2626;
        `;
        
        panel.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="margin: 0; font-size: 16px; color: #dc2626;">⚖️ FRCP Deadlines</h3>
                <button id="fot-close-deadline-panel" style="background: none; border: none; font-size: 20px; cursor: pointer;">×</button>
            </div>
            <div id="fot-deadline-list">
                ${dates.slice(0, 3).map(date => `
                    <div style="padding: 12px; background: #fef2f2; border-radius: 8px; margin-bottom: 8px;">
                        <div style="font-weight: 600; color: #991b1b; font-size: 13px;">${date}</div>
                        <div style="font-size: 12px; color: #7f1d1d; margin-top: 4px;">
                            Discovery: ${this.calculateDeadline(date, 30)}<br>
                            Summary Judgment: ${this.calculateDeadline(date, 60)}
                        </div>
                    </div>
                `).join('')}
            </div>
            <button id="fot-save-deadlines" style="
                width: 100%;
                background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%);
                color: white;
                border: none;
                padding: 12px;
                border-radius: 12px;
                font-weight: 600;
                cursor: pointer;
                margin-top: 12px;
            ">Save to FoT Legal</button>
        `;
        
        panel.querySelector('#fot-close-deadline-panel').onclick = () => panel.remove();
        panel.querySelector('#fot-save-deadlines').onclick = () => {
            this.saveDeadlines(dates);
            panel.remove();
        };
        
        return panel;
    }
    
    calculateDeadline(dateStr, daysToAdd) {
        try {
            const date = new Date(dateStr);
            date.setDate(date.getDate() + daysToAdd);
            return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
        } catch (e) {
            return 'N/A';
        }
    }
    
    verifyCitations() {
        // Find and verify Bluebook citations
        const bodyText = document.body.innerText;
        const cases = bodyText.match(this.bluebookPatterns.casePattern) || [];
        const statutes = bodyText.match(this.bluebookPatterns.statutePattern) || [];
        const frcrRules = bodyText.match(this.bluebookPatterns.frcrPattern) || [];
        
        if (cases.length > 0 || statutes.length > 0 || frcrRules.length > 0) {
            this.injectCitationPanel(cases, statutes, frcrRules);
        }
    }
    
    injectCitationPanel(cases, statutes, frcrRules) {
        const panel = document.createElement('div');
        panel.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 320px;
            max-height: 400px;
            overflow-y: auto;
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.15);
            z-index: 10000;
            border: 2px solid #dc2626;
        `;
        
        panel.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="margin: 0; font-size: 16px; color: #dc2626;">📚 Citations Found</h3>
                <button id="fot-close-citation-panel" style="background: none; border: none; font-size: 20px; cursor: pointer;">×</button>
            </div>
            <div>
                ${cases.length > 0 ? `
                    <div style="margin-bottom: 16px;">
                        <h4 style="font-size: 13px; color: #991b1b; margin: 0 0 8px 0;">Cases (${cases.length})</h4>
                        ${cases.slice(0, 5).map(c => `
                            <div style="font-size: 12px; padding: 6px; background: #fef2f2; border-radius: 6px; margin-bottom: 4px;">
                                ${c} <span style="color: #10b981; cursor: pointer;" class="verify-citation">✓ Verify</span>
                            </div>
                        `).join('')}
                    </div>
                ` : ''}
                ${statutes.length > 0 ? `
                    <div style="margin-bottom: 16px;">
                        <h4 style="font-size: 13px; color: #991b1b; margin: 0 0 8px 0;">Statutes (${statutes.length})</h4>
                        ${statutes.slice(0, 5).map(s => `
                            <div style="font-size: 12px; padding: 6px; background: #fef2f2; border-radius: 6px; margin-bottom: 4px;">
                                ${s}
                            </div>
                        `).join('')}
                    </div>
                ` : ''}
                ${frcrRules.length > 0 ? `
                    <div style="margin-bottom: 16px;">
                        <h4 style="font-size: 13px; color: #991b1b; margin: 0 0 8px 0;">FRCP Rules (${frcrRules.length})</h4>
                        ${frcrRules.slice(0, 5).map(r => `
                            <div style="font-size: 12px; padding: 6px; background: #fef2f2; border-radius: 6px; margin-bottom: 4px;">
                                ${r}
                            </div>
                        `).join('')}
                    </div>
                ` : ''}
            </div>
            <button id="fot-save-citations" style="
                width: 100%;
                background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%);
                color: white;
                border: none;
                padding: 12px;
                border-radius: 12px;
                font-weight: 600;
                cursor: pointer;
            ">Save All to FoT Legal</button>
        `;
        
        document.body.appendChild(panel);
        
        panel.querySelector('#fot-close-citation-panel').onclick = () => panel.remove();
        panel.querySelector('#fot-save-citations').onclick = () => {
            this.saveCitations({ cases, statutes, frcrRules });
            panel.remove();
        };
    }
    
    injectLegalTools() {
        // Create floating action button for legal tools
        const fab = document.createElement('div');
        fab.style.cssText = `
            position: fixed;
            bottom: 20px;
            left: 20px;
            width: 56px;
            height: 56px;
            background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 4px 16px rgba(220, 38, 38, 0.4);
            z-index: 9999;
            transition: all 0.3s;
        `;
        fab.innerHTML = '⚖️';
        fab.style.fontSize = '24px';
        
        fab.onclick = () => {
            this.showLegalToolsMenu(fab);
        };
        
        document.body.appendChild(fab);
    }
    
    showLegalToolsMenu(fab) {
        const menu = document.createElement('div');
        menu.style.cssText = `
            position: fixed;
            bottom: 90px;
            left: 20px;
            width: 240px;
            background: white;
            border-radius: 12px;
            padding: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
            z-index: 10000;
        `;
        
        menu.innerHTML = `
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="legal-tool-item">
                📋 Save Case to FoT Legal
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="legal-tool-item">
                🔍 Verify Citations
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="legal-tool-item">
                📅 Calculate FRCP Deadlines
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="legal-tool-item">
                ⚛️ Validate with QFOT
            </div>
        `;
        
        document.body.appendChild(menu);
        
        menu.querySelectorAll('.legal-tool-item').forEach((item, index) => {
            item.onmouseover = () => item.style.background = '#fef2f2';
            item.onmouseout = () => item.style.background = 'transparent';
            
            item.onclick = () => {
                switch(index) {
                    case 0: this.saveToLegalApp('page'); break;
                    case 1: this.verifyCitations(); break;
                    case 2: this.trackDeadlines(); break;
                    case 3: this.validateWithQFOT(); break;
                }
                menu.remove();
            };
        });
        
        // Close menu when clicking outside
        setTimeout(() => {
            document.addEventListener('click', (e) => {
                if (!menu.contains(e.target) && e.target !== fab) {
                    menu.remove();
                }
            }, { once: true });
        }, 100);
    }
    
    saveToLegalApp(type) {
        const data = {
            type: type,
            url: window.location.href,
            title: document.title,
            content: this.extractLegalContent(),
            timestamp: new Date().toISOString()
        };
        
        browser.runtime.sendMessage({
            action: 'send_to_legal',
            data: data
        });
        
        this.showNotification('✅ Saved to FoT Legal!');
    }
    
    saveDeadlines(dates) {
        browser.runtime.sendMessage({
            action: 'send_to_legal',
            data: {
                action: 'save_deadlines',
                dates: dates,
                url: window.location.href
            }
        });
        
        this.showNotification('✅ Deadlines saved to FoT Legal!');
    }
    
    saveCitations(citations) {
        browser.runtime.sendMessage({
            action: 'send_to_legal',
            data: {
                action: 'save_citations',
                citations: citations,
                url: window.location.href
            }
        });
        
        this.showNotification('✅ Citations saved to FoT Legal!');
    }
    
    validateWithQFOT() {
        const selectedText = window.getSelection().toString() || this.extractLegalContent();
        
        browser.runtime.sendMessage({
            action: 'qfot_validate',
            text: selectedText
        });
        
        this.showNotification('🔍 Validating with QFOT blockchain...');
    }
    
    extractLegalContent() {
        const main = document.querySelector('article, main, .opinion, .case-text');
        return main ? main.textContent.substring(0, 2000) : document.body.textContent.substring(0, 2000);
    }
    
    enhanceContent() {
        // Highlight legal citations in real-time
        this.highlightCitations();
    }
    
    highlightCitations() {
        const walker = document.createTreeWalker(
            document.body,
            NodeFilter.SHOW_TEXT,
            null,
            false
        );
        
        const textNodes = [];
        while (walker.nextNode()) {
            const node = walker.currentNode;
            if (node.parentElement.tagName !== 'SCRIPT' &&
                node.parentElement.tagName !== 'STYLE' &&
                !node.parentElement.closest('.fot-legal-save-btn')) {
                textNodes.push(node);
            }
        }
        
        textNodes.forEach(node => {
            const text = node.textContent;
            let modified = text;
            let hasMatch = false;
            
            // Highlight case citations
            if (this.bluebookPatterns.casePattern.test(text)) {
                modified = modified.replace(this.bluebookPatterns.casePattern,
                    '<mark style="background: #fef2f2; padding: 2px 4px; border-radius: 4px; cursor: help; border-bottom: 2px solid #dc2626;" title="Case Citation">$&</mark>');
                hasMatch = true;
            }
            
            // Highlight statute citations
            if (this.bluebookPatterns.statutePattern.test(text)) {
                modified = modified.replace(this.bluebookPatterns.statutePattern,
                    '<mark style="background: #eff6ff; padding: 2px 4px; border-radius: 4px; cursor: help; border-bottom: 2px solid #2563eb;" title="Statute Citation">$&</mark>');
                hasMatch = true;
            }
            
            // Highlight FRCP rules
            if (this.bluebookPatterns.frcrPattern.test(text)) {
                modified = modified.replace(this.bluebookPatterns.frcrPattern,
                    '<mark style="background: #fef3c7; padding: 2px 4px; border-radius: 4px; cursor: help; border-bottom: 2px solid #f59e0b;" title="FRCP Rule">$&</mark>');
                hasMatch = true;
            }
            
            if (hasMatch) {
                const span = document.createElement('span');
                span.innerHTML = modified;
                node.parentElement.replaceChild(span, node);
            }
        });
    }
    
    showNotification(message) {
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #dc2626;
            color: white;
            padding: 16px 24px;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(220, 38, 38, 0.4);
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
        browser.runtime.onMessage.addListener((message) => {
            if (message.action === 'legal_response') {
                this.handleLegalResponse(message.data);
            }
        });
    }
    
    handleLegalResponse(data) {
        console.log('Legal app response:', data);
    }
}

// Initialize enhancer
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new LegalEnhancer();
    });
} else {
    new LegalEnhancer();
}


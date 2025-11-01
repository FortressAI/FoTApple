/**
 * FoT Education - Classroom Integration
 * Enhances educational websites with FoT Education app integration
 */

console.log('FoT Education content script loaded on:', window.location.href);

class EducationEnhancer {
    constructor() {
        this.standardsPatterns = {
            ccss: /\bCCSS\.([A-Z]+)\.(\d+)\.([A-Za-z]+)\.(\d+)\b/g,
            ngss: /\b(MS|HS|K)-([A-Z]+)-\d+-\d+\b/g
        };
        this.init();
    }
    
    init() {
        this.detectSite();
        this.enhanceContent();
        this.setupListeners();
        this.injectEducationTools();
    }
    
    detectSite() {
        const hostname = window.location.hostname;
        
        if (hostname.includes('khanacademy')) {
            this.enhanceKhanAcademy();
        } else if (hostname.includes('classroom.google.com')) {
            this.enhanceGoogleClassroom();
        } else if (hostname.includes('ixl.com')) {
            this.enhanceIXL();
        } else if (hostname.includes('pearsonrealize.com')) {
            this.enhancePearsonRealize();
        }
    }
    
    enhanceKhanAcademy() {
        console.log('Enhancing Khan Academy with FoT Education');
        
        // Add assign button to videos and exercises
        const exercises = document.querySelectorAll('[class*="exercise"], [class*="video"]');
        exercises.forEach(exercise => {
            const assignBtn = this.createAssignButton();
            const header = exercise.querySelector('h1, h2, h3');
            if (header) {
                header.insertAdjacentElement('afterend', assignBtn);
            }
        });
    }
    
    enhanceGoogleClassroom() {
        console.log('Enhancing Google Classroom with FoT Education');
        
        // Track assignments
        const assignments = document.querySelectorAll('.JYKBtd, .asQXV');
        assignments.forEach(assignment => {
            const syncBtn = this.createSyncButton('assignment');
            assignment.appendChild(syncBtn);
        });
        
        // Add student roster sync
        this.addRosterSync();
    }
    
    enhanceIXL() {
        console.log('Enhancing IXL with FoT Education');
        
        // Track skill progress
        const skills = document.querySelectorAll('.skill-card');
        skills.forEach(skill => {
            const trackBtn = this.createTrackButton();
            skill.appendChild(trackBtn);
        });
    }
    
    enhancePearsonRealize() {
        console.log('Enhancing Pearson Realize with FoT Education');
        
        // Sync assessments
        const assessments = document.querySelectorAll('.assessment-item');
        assessments.forEach(assessment => {
            const syncBtn = this.createSyncButton('assessment');
            assessment.appendChild(syncBtn);
        });
    }
    
    createAssignButton() {
        const button = document.createElement('button');
        button.className = 'fot-education-assign-btn';
        button.innerHTML = '📚 Assign in FoT Education';
        button.style.cssText = `
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
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
            box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
        `;
        
        button.onmouseover = () => {
            button.style.transform = 'translateY(-2px)';
            button.style.boxShadow = '0 4px 12px rgba(59, 130, 246, 0.5)';
        };
        
        button.onmouseout = () => {
            button.style.transform = 'translateY(0)';
            button.style.boxShadow = '0 2px 8px rgba(59, 130, 246, 0.3)';
        };
        
        button.onclick = (e) => {
            e.preventDefault();
            this.showAssignmentDialog();
        };
        
        return button;
    }
    
    createSyncButton(type) {
        const button = document.createElement('button');
        button.className = 'fot-education-sync-btn';
        button.innerHTML = '🔄 Sync';
        button.style.cssText = `
            background: #3b82f6;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            margin: 4px;
        `;
        
        button.onclick = (e) => {
            e.preventDefault();
            this.syncToEducationApp(type);
        };
        
        return button;
    }
    
    createTrackButton() {
        const button = document.createElement('button');
        button.className = 'fot-education-track-btn';
        button.innerHTML = '📊 Track Progress';
        button.style.cssText = `
            background: #10b981;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            margin: 4px;
        `;
        
        button.onclick = (e) => {
            e.preventDefault();
            this.trackProgress();
        };
        
        return button;
    }
    
    showAssignmentDialog() {
        const dialog = document.createElement('div');
        dialog.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 400px;
            background: white;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 16px 48px rgba(0,0,0,0.2);
            z-index: 10000;
            border: 2px solid #3b82f6;
        `;
        
        dialog.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 style="margin: 0; font-size: 18px; color: #3b82f6;">📚 Assign to Students</h3>
                <button id="fot-close-assign-dialog" style="background: none; border: none; font-size: 24px; cursor: pointer;">×</button>
            </div>
            <div style="margin-bottom: 16px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 14px; color: #374151;">
                    Resource Title
                </label>
                <input type="text" id="fot-assign-title" value="${document.title}" style="
                    width: 100%;
                    padding: 12px;
                    border: 2px solid #e5e7eb;
                    border-radius: 8px;
                    font-size: 14px;
                ">
            </div>
            <div style="margin-bottom: 16px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 14px; color: #374151;">
                    Grade Level
                </label>
                <select id="fot-assign-grade" style="
                    width: 100%;
                    padding: 12px;
                    border: 2px solid #e5e7eb;
                    border-radius: 8px;
                    font-size: 14px;
                ">
                    <option>K-2</option>
                    <option>3-5</option>
                    <option>6-8</option>
                    <option selected>9-12</option>
                </select>
            </div>
            <div style="margin-bottom: 16px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 14px; color: #374151;">
                    Subject
                </label>
                <select id="fot-assign-subject" style="
                    width: 100%;
                    padding: 12px;
                    border: 2px solid #e5e7eb;
                    border-radius: 8px;
                    font-size: 14px;
                ">
                    <option>Math</option>
                    <option>Science</option>
                    <option>English Language Arts</option>
                    <option>Social Studies</option>
                    <option>Computer Science</option>
                </select>
            </div>
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 14px; color: #374151;">
                    Assign to
                </label>
                <div style="padding: 12px; background: #f3f4f6; border-radius: 8px;">
                    <label style="display: flex; align-items: center; margin-bottom: 8px;">
                        <input type="radio" name="assign-to" value="all" checked style="margin-right: 8px;">
                        All Students
                    </label>
                    <label style="display: flex; align-items: center;">
                        <input type="radio" name="assign-to" value="select" style="margin-right: 8px;">
                        Select Students
                    </label>
                </div>
            </div>
            <div style="display: flex; gap: 12px;">
                <button id="fot-cancel-assign" style="
                    flex: 1;
                    background: #e5e7eb;
                    color: #374151;
                    border: none;
                    padding: 12px;
                    border-radius: 12px;
                    font-weight: 600;
                    cursor: pointer;
                ">Cancel</button>
                <button id="fot-confirm-assign" style="
                    flex: 1;
                    background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
                    color: white;
                    border: none;
                    padding: 12px;
                    border-radius: 12px;
                    font-weight: 600;
                    cursor: pointer;
                ">Assign</button>
            </div>
        `;
        
        document.body.appendChild(dialog);
        
        const overlay = document.createElement('div');
        overlay.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 9999;
        `;
        document.body.appendChild(overlay);
        
        const closeDialog = () => {
            dialog.remove();
            overlay.remove();
        };
        
        dialog.querySelector('#fot-close-assign-dialog').onclick = closeDialog;
        dialog.querySelector('#fot-cancel-assign').onclick = closeDialog;
        overlay.onclick = closeDialog;
        
        dialog.querySelector('#fot-confirm-assign').onclick = () => {
            const data = {
                title: dialog.querySelector('#fot-assign-title').value,
                grade: dialog.querySelector('#fot-assign-grade').value,
                subject: dialog.querySelector('#fot-assign-subject').value,
                assignTo: dialog.querySelector('input[name="assign-to"]:checked').value,
                url: window.location.href,
                timestamp: new Date().toISOString()
            };
            
            this.assignToEducationApp(data);
            closeDialog();
        };
    }
    
    addRosterSync() {
        const syncBtn = document.createElement('button');
        syncBtn.innerHTML = '📋 Sync Roster to FoT Education';
        syncBtn.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 24px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 4px 16px rgba(59, 130, 246, 0.4);
            z-index: 9999;
        `;
        
        syncBtn.onclick = () => {
            this.syncRoster();
        };
        
        document.body.appendChild(syncBtn);
    }
    
    injectEducationTools() {
        const fab = document.createElement('div');
        fab.style.cssText = `
            position: fixed;
            bottom: 20px;
            left: 20px;
            width: 56px;
            height: 56px;
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 4px 16px rgba(59, 130, 246, 0.4);
            z-index: 9999;
            transition: all 0.3s;
        `;
        fab.innerHTML = '📚';
        fab.style.fontSize = '24px';
        
        fab.onclick = () => {
            this.showEducationToolsMenu(fab);
        };
        
        document.body.appendChild(fab);
    }
    
    showEducationToolsMenu(fab) {
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
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="education-tool-item">
                📝 Assign to Students
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="education-tool-item">
                📊 Track Progress
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="education-tool-item">
                🎯 Identify Standards
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="education-tool-item">
                ⚛️ Validate with QFOT
            </div>
        `;
        
        document.body.appendChild(menu);
        
        menu.querySelectorAll('.education-tool-item').forEach((item, index) => {
            item.onmouseover = () => item.style.background = '#eff6ff';
            item.onmouseout = () => item.style.background = 'transparent';
            
            item.onclick = () => {
                switch(index) {
                    case 0: this.showAssignmentDialog(); break;
                    case 1: this.trackProgress(); break;
                    case 2: this.identifyStandards(); break;
                    case 3: this.validateWithQFOT(); break;
                }
                menu.remove();
            };
        });
        
        setTimeout(() => {
            document.addEventListener('click', (e) => {
                if (!menu.contains(e.target) && e.target !== fab) {
                    menu.remove();
                }
            }, { once: true });
        }, 100);
    }
    
    assignToEducationApp(data) {
        browser.runtime.sendMessage({
            action: 'send_to_education',
            data: {
                action: 'assign_resource',
                ...data
            }
        });
        
        this.showNotification('✅ Assignment created in FoT Education!');
    }
    
    syncToEducationApp(type) {
        const data = {
            type: type,
            url: window.location.href,
            title: document.title,
            timestamp: new Date().toISOString()
        };
        
        browser.runtime.sendMessage({
            action: 'send_to_education',
            data: data
        });
        
        this.showNotification('✅ Synced to FoT Education!');
    }
    
    syncRoster() {
        browser.runtime.sendMessage({
            action: 'send_to_education',
            data: {
                action: 'sync_roster',
                url: window.location.href
            }
        });
        
        this.showNotification('🔄 Syncing roster to FoT Education...');
    }
    
    trackProgress() {
        const selectedText = window.getSelection().toString();
        
        browser.runtime.sendMessage({
            action: 'send_to_education',
            data: {
                action: 'track_progress',
                content: selectedText || this.extractContent(),
                url: window.location.href
            }
        });
        
        this.showNotification('📊 Tracking progress in FoT Education!');
    }
    
    identifyStandards() {
        const content = document.body.innerText;
        const ccssMatches = content.match(this.standardsPatterns.ccss) || [];
        const ngssMatches = content.match(this.standardsPatterns.ngss) || [];
        
        if (ccssMatches.length > 0 || ngssMatches.length > 0) {
            this.showStandardsPanel(ccssMatches, ngssMatches);
        } else {
            this.showNotification('ℹ️ No standards found on this page');
        }
    }
    
    showStandardsPanel(ccss, ngss) {
        const panel = document.createElement('div');
        panel.style.cssText = `
            position: fixed;
            top: 50%;
            right: 20px;
            transform: translateY(-50%);
            width: 320px;
            max-height: 500px;
            overflow-y: auto;
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.15);
            z-index: 10000;
            border: 2px solid #3b82f6;
        `;
        
        panel.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="margin: 0; font-size: 16px; color: #3b82f6;">🎯 Standards Found</h3>
                <button id="fot-close-standards-panel" style="background: none; border: none; font-size: 20px; cursor: pointer;">×</button>
            </div>
            ${ccss.length > 0 ? `
                <div style="margin-bottom: 16px;">
                    <h4 style="font-size: 13px; color: #1d4ed8; margin: 0 0 8px 0;">CCSS (${ccss.length})</h4>
                    ${ccss.slice(0, 10).map(s => `
                        <div style="font-size: 12px; padding: 8px; background: #eff6ff; border-radius: 6px; margin-bottom: 6px; border-left: 3px solid #3b82f6;">
                            ${s}
                        </div>
                    `).join('')}
                </div>
            ` : ''}
            ${ngss.length > 0 ? `
                <div style="margin-bottom: 16px;">
                    <h4 style="font-size: 13px; color: #1d4ed8; margin: 0 0 8px 0;">NGSS (${ngss.length})</h4>
                    ${ngss.slice(0, 10).map(s => `
                        <div style="font-size: 12px; padding: 8px; background: #eff6ff; border-radius: 6px; margin-bottom: 6px; border-left: 3px solid #3b82f6;">
                            ${s}
                        </div>
                    `).join('')}
                </div>
            ` : ''}
            <button id="fot-save-standards" style="
                width: 100%;
                background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
                color: white;
                border: none;
                padding: 12px;
                border-radius: 12px;
                font-weight: 600;
                cursor: pointer;
            ">Save to FoT Education</button>
        `;
        
        document.body.appendChild(panel);
        
        panel.querySelector('#fot-close-standards-panel').onclick = () => panel.remove();
        panel.querySelector('#fot-save-standards').onclick = () => {
            this.saveStandards({ ccss, ngss });
            panel.remove();
        };
    }
    
    saveStandards(standards) {
        browser.runtime.sendMessage({
            action: 'send_to_education',
            data: {
                action: 'save_standards',
                standards: standards,
                url: window.location.href
            }
        });
        
        this.showNotification('✅ Standards saved to FoT Education!');
    }
    
    validateWithQFOT() {
        const selectedText = window.getSelection().toString() || this.extractContent();
        
        browser.runtime.sendMessage({
            action: 'qfot_validate',
            text: selectedText
        });
        
        this.showNotification('🔍 Validating with QFOT blockchain...');
    }
    
    extractContent() {
        const main = document.querySelector('article, main, .content');
        return main ? main.textContent.substring(0, 1000) : '';
    }
    
    enhanceContent() {
        // Highlight educational standards
        this.highlightStandards();
    }
    
    highlightStandards() {
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
                node.parentElement.tagName !== 'STYLE') {
                textNodes.push(node);
            }
        }
        
        textNodes.forEach(node => {
            const text = node.textContent;
            let modified = text;
            let hasMatch = false;
            
            if (this.standardsPatterns.ccss.test(text)) {
                modified = modified.replace(this.standardsPatterns.ccss,
                    '<mark style="background: #dbeafe; padding: 2px 6px; border-radius: 4px; cursor: help; font-weight: 600;" title="Common Core State Standard">$&</mark>');
                hasMatch = true;
            }
            
            if (this.standardsPatterns.ngss.test(text)) {
                modified = modified.replace(this.standardsPatterns.ngss,
                    '<mark style="background: #d1fae5; padding: 2px 6px; border-radius: 4px; cursor: help; font-weight: 600;" title="Next Generation Science Standard">$&</mark>');
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
            background: #3b82f6;
            color: white;
            padding: 16px 24px;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(59, 130, 246, 0.4);
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
            if (message.action === 'education_response') {
                this.handleEducationResponse(message.data);
            }
        });
    }
    
    handleEducationResponse(data) {
        console.log('Education app response:', data);
    }
}

// Initialize enhancer
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new EducationEnhancer();
    });
} else {
    new EducationEnhancer();
}


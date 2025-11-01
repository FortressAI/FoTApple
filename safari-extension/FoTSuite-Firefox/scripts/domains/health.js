/**
 * FoT Personal Health - Fitness Integration
 * Enhances health and fitness websites with Personal Health app integration
 */

console.log('FoT Personal Health content script loaded on:', window.location.href);

class HealthEnhancer {
    constructor() {
        this.init();
    }
    
    init() {
        this.detectSite();
        this.enhanceContent();
        this.setupListeners();
        this.injectHealthTools();
    }
    
    detectSite() {
        const hostname = window.location.hostname;
        
        if (hostname.includes('myfitnesspal')) {
            this.enhanceMyFitnessPal();
        } else if (hostname.includes('strava')) {
            this.enhanceStrava();
        } else if (hostname.includes('fitbit')) {
            this.enhanceFitbit();
        }
    }
    
    enhanceMyFitnessPal() {
        console.log('Enhancing MyFitnessPal with Personal Health');
        
        // Add log buttons to meals
        const meals = document.querySelectorAll('[class*="meal"], [class*="food"]');
        meals.forEach(meal => {
            const logBtn = this.createLogButton('meal');
            meal.appendChild(logBtn);
        });
    }
    
    enhanceStrava() {
        console.log('Enhancing Strava with Personal Health');
        
        // Add sync button to activities
        const activities = document.querySelectorAll('.activity, [class*="Activity"]');
        activities.forEach(activity => {
            const syncBtn = this.createSyncButton('workout');
            const header = activity.querySelector('.activity-name, h2, h3');
            if (header) {
                header.insertAdjacentElement('afterend', syncBtn);
            }
        });
        
        // Add QFOT validation for achievements
        this.addQFOTBadges();
    }
    
    enhanceFitbit() {
        console.log('Enhancing Fitbit with Personal Health');
        
        // Sync vitals data
        const vitals = document.querySelectorAll('[class*="stat"], [class*="metric"]');
        vitals.forEach(vital => {
            const syncBtn = this.createSyncButton('vitals');
            vital.appendChild(syncBtn);
        });
    }
    
    createLogButton(type) {
        const button = document.createElement('button');
        button.className = 'fot-health-log-btn';
        button.innerHTML = '💪 Log to Personal Health';
        button.style.cssText = `
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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
            box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
        `;
        
        button.onmouseover = () => {
            button.style.transform = 'translateY(-2px)';
            button.style.boxShadow = '0 4px 12px rgba(16, 185, 129, 0.5)';
        };
        
        button.onmouseout = () => {
            button.style.transform = 'translateY(0)';
            button.style.boxShadow = '0 2px 8px rgba(16, 185, 129, 0.3)';
        };
        
        button.onclick = (e) => {
            e.preventDefault();
            this.logToHealthApp(type);
        };
        
        return button;
    }
    
    createSyncButton(type) {
        const button = document.createElement('button');
        button.className = 'fot-health-sync-btn';
        button.innerHTML = '🔄 Sync';
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
            this.syncToHealthApp(type);
        };
        
        return button;
    }
    
    addQFOTBadges() {
        const achievements = document.querySelectorAll('.achievement, [class*="Achievement"]');
        achievements.forEach(achievement => {
            const badge = document.createElement('div');
            badge.className = 'qfot-health-badge';
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
            achievement.appendChild(badge);
        });
    }
    
    injectHealthTools() {
        const fab = document.createElement('div');
        fab.style.cssText = `
            position: fixed;
            bottom: 20px;
            left: 20px;
            width: 56px;
            height: 56px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 4px 16px rgba(16, 185, 129, 0.4);
            z-index: 9999;
            transition: all 0.3s;
        `;
        fab.innerHTML = '💪';
        fab.style.fontSize = '24px';
        
        fab.onclick = () => {
            this.showHealthToolsMenu(fab);
        };
        
        document.body.appendChild(fab);
    }
    
    showHealthToolsMenu(fab) {
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
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="health-tool-item">
                🍎 Log Meal
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="health-tool-item">
                🏃 Log Workout
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="health-tool-item">
                💊 Log Medication
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="health-tool-item">
                😊 Log Mood
            </div>
            <div style="padding: 12px; cursor: pointer; border-radius: 8px; transition: background 0.2s;" class="health-tool-item">
                ⚛️ Validate with QFOT
            </div>
        `;
        
        document.body.appendChild(menu);
        
        menu.querySelectorAll('.health-tool-item').forEach((item, index) => {
            item.onmouseover = () => item.style.background = '#ecfdf5';
            item.onmouseout = () => item.style.background = 'transparent';
            
            item.onclick = () => {
                switch(index) {
                    case 0: this.showLogDialog('meal'); break;
                    case 1: this.showLogDialog('workout'); break;
                    case 2: this.showLogDialog('medication'); break;
                    case 3: this.showLogDialog('mood'); break;
                    case 4: this.validateWithQFOT(); break;
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
    
    showLogDialog(type) {
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
            border: 2px solid #10b981;
        `;
        
        const typeConfig = {
            meal: { icon: '🍎', title: 'Log Meal', fields: ['Food Name', 'Calories', 'Notes'] },
            workout: { icon: '🏃', title: 'Log Workout', fields: ['Activity', 'Duration (min)', 'Distance'] },
            medication: { icon: '💊', title: 'Log Medication', fields: ['Medication', 'Dosage', 'Time'] },
            mood: { icon: '😊', title: 'Log Mood', fields: ['Mood', 'Energy Level', 'Notes'] }
        };
        
        const config = typeConfig[type];
        
        dialog.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 style="margin: 0; font-size: 18px; color: #10b981;">${config.icon} ${config.title}</h3>
                <button id="fot-close-log-dialog" style="background: none; border: none; font-size: 24px; cursor: pointer;">×</button>
            </div>
            ${config.fields.map((field, i) => `
                <div style="margin-bottom: 16px;">
                    <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 14px; color: #374151;">
                        ${field}
                    </label>
                    <input type="text" id="fot-log-field-${i}" style="
                        width: 100%;
                        padding: 12px;
                        border: 2px solid #e5e7eb;
                        border-radius: 8px;
                        font-size: 14px;
                    ">
                </div>
            `).join('')}
            <div style="display: flex; gap: 12px; margin-top: 20px;">
                <button id="fot-cancel-log" style="
                    flex: 1;
                    background: #e5e7eb;
                    color: #374151;
                    border: none;
                    padding: 12px;
                    border-radius: 12px;
                    font-weight: 600;
                    cursor: pointer;
                ">Cancel</button>
                <button id="fot-confirm-log" style="
                    flex: 1;
                    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
                    color: white;
                    border: none;
                    padding: 12px;
                    border-radius: 12px;
                    font-weight: 600;
                    cursor: pointer;
                ">Log Entry</button>
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
        
        dialog.querySelector('#fot-close-log-dialog').onclick = closeDialog;
        dialog.querySelector('#fot-cancel-log').onclick = closeDialog;
        overlay.onclick = closeDialog;
        
        dialog.querySelector('#fot-confirm-log').onclick = () => {
            const data = {
                type: type,
                fields: config.fields.map((field, i) => ({
                    name: field,
                    value: dialog.querySelector(`#fot-log-field-${i}`).value
                })),
                url: window.location.href,
                timestamp: new Date().toISOString()
            };
            
            this.logToHealthApp(type, data);
            closeDialog();
        };
    }
    
    logToHealthApp(type, data = null) {
        const logData = data || {
            type: type,
            selectedContent: window.getSelection().toString() || this.extractContent(),
            url: window.location.href,
            timestamp: new Date().toISOString()
        };
        
        browser.runtime.sendMessage({
            action: 'send_to_health',
            data: logData
        });
        
        this.showNotification('✅ Logged to Personal Health!');
    }
    
    syncToHealthApp(type) {
        const data = {
            action: 'sync_data',
            type: type,
            url: window.location.href,
            content: this.extractContent(),
            timestamp: new Date().toISOString()
        };
        
        browser.runtime.sendMessage({
            action: 'send_to_health',
            data: data
        });
        
        this.showNotification('🔄 Syncing to Personal Health...');
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
        return window.getSelection().toString() || 
               document.querySelector('main, article, .content')?.textContent.substring(0, 500) || '';
    }
    
    enhanceContent() {
        // Highlight health metrics on the page
        this.highlightHealthMetrics();
    }
    
    highlightHealthMetrics() {
        // Common health metric patterns
        const patterns = {
            heartRate: /\b\d{2,3}\s*bpm\b/gi,
            weight: /\b\d{2,3}(\.\d)?\s*(lbs?|kg)\b/gi,
            calories: /\b\d{3,4}\s*(cal|kcal|calories)\b/gi,
            distance: /\b\d+(\.\d+)?\s*(mi|km|miles|kilometers)\b/gi,
            duration: /\b\d+:\d{2}(:\d{2})?\b/g
        };
        
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
                !node.parentElement.closest('.fot-health-log-btn')) {
                textNodes.push(node);
            }
        }
        
        textNodes.forEach(node => {
            const text = node.textContent;
            let modified = text;
            let hasMatch = false;
            
            for (const [type, pattern] of Object.entries(patterns)) {
                if (pattern.test(text)) {
                    const color = {
                        heartRate: '#ef4444',
                        weight: '#3b82f6',
                        calories: '#f59e0b',
                        distance: '#10b981',
                        duration: '#8b5cf6'
                    }[type];
                    
                    modified = modified.replace(pattern,
                        `<mark style="background: ${color}20; padding: 2px 6px; border-radius: 4px; cursor: help; font-weight: 600; color: ${color};" title="${type}">$&</mark>`);
                    hasMatch = true;
                }
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
        browser.runtime.onMessage.addListener((message) => {
            if (message.action === 'health_response') {
                this.handleHealthResponse(message.data);
            }
        });
    }
    
    handleHealthResponse(data) {
        console.log('Health app response:', data);
    }
}

// Initialize enhancer
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new HealthEnhancer();
    });
} else {
    new HealthEnhancer();
}


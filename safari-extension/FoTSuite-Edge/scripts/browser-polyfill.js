/**
 * Browser API Polyfill
 * Provides cross-browser compatibility for Chrome, Firefox, Edge, and Safari
 */

// Chrome uses 'chrome', Firefox/Safari use 'browser'
// This makes them interchangeable
if (typeof browser === 'undefined') {
    var browser = chrome;
}

// Polyfill for browsers that don't support certain APIs
(function() {
    'use strict';
    
    // Ensure browser object exists
    if (typeof browser === 'undefined' && typeof chrome !== 'undefined') {
        window.browser = chrome;
    }
    
    // Polyfill for browser.runtime.sendMessage to return a Promise in Chrome
    if (typeof browser !== 'undefined' && browser.runtime && !browser.runtime.sendMessage.then) {
        const originalSendMessage = browser.runtime.sendMessage;
        browser.runtime.sendMessage = function(...args) {
            return new Promise((resolve, reject) => {
                originalSendMessage(...args, (response) => {
                    if (browser.runtime.lastError) {
                        reject(browser.runtime.lastError);
                    } else {
                        resolve(response);
                    }
                });
            });
        };
    }
    
    // Polyfill for browser.tabs.sendMessage to return a Promise in Chrome
    if (typeof browser !== 'undefined' && browser.tabs && !browser.tabs.sendMessage.then) {
        const originalTabsSendMessage = browser.tabs.sendMessage;
        browser.tabs.sendMessage = function(...args) {
            return new Promise((resolve, reject) => {
                originalTabsSendMessage(...args, (response) => {
                    if (browser.runtime.lastError) {
                        reject(browser.runtime.lastError);
                    } else {
                        resolve(response);
                    }
                });
            });
        };
    }
    
    // Polyfill for browser.storage.local.get to return a Promise in Chrome
    if (typeof browser !== 'undefined' && browser.storage && browser.storage.local && !browser.storage.local.get.then) {
        const originalGet = browser.storage.local.get;
        browser.storage.local.get = function(...args) {
            return new Promise((resolve, reject) => {
                originalGet(...args, (result) => {
                    if (browser.runtime.lastError) {
                        reject(browser.runtime.lastError);
                    } else {
                        resolve(result);
                    }
                });
            });
        };
        
        const originalSet = browser.storage.local.set;
        browser.storage.local.set = function(...args) {
            return new Promise((resolve, reject) => {
                originalSet(...args, () => {
                    if (browser.runtime.lastError) {
                        reject(browser.runtime.lastError);
                    } else {
                        resolve();
                    }
                });
            });
        };
    }
    
    console.log('Browser API polyfill loaded for:', 
        typeof chrome !== 'undefined' ? 'Chrome/Edge' : 'Firefox/Safari');
})();


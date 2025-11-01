/**
 * QFOT Wallet - Content Script
 * Injects into safeaicoin.org to enable wallet integration
 */

console.log('🦊 QFOT Wallet content script loaded');

// Inject wallet detection
const script = document.createElement('script');
script.src = browser.runtime.getURL('Resources/scripts/injected.js');
script.onload = function() {
    this.remove();
};
(document.head || document.documentElement).appendChild(script);

// Listen for messages from injected script
window.addEventListener('message', async (event) => {
    // Only accept messages from our window
    if (event.source !== window) return;
    
    if (event.data.type && event.data.type.startsWith('QFOT_')) {
        console.log('Content script received:', event.data.type);
        
        // Forward to background script
        const response = await browser.runtime.sendMessage({
            type: event.data.type.replace('QFOT_', ''),
            data: event.data.payload
        });
        
        // Send response back to page
        window.postMessage({
            type: event.data.type + '_RESPONSE',
            requestId: event.data.requestId,
            payload: response
        }, '*');
    }
});

// Add visual indicator that wallet is connected
function addWalletIndicator() {
    const indicator = document.createElement('div');
    indicator.id = 'qfot-wallet-indicator';
    indicator.style.cssText = `
        position: fixed;
        top: 10px;
        right: 10px;
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
        padding: 8px 16px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        z-index: 10000;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        display: flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
    `;
    indicator.innerHTML = '⚛️ QFOT Wallet Connected';
    
    indicator.addEventListener('click', () => {
        // Open wallet popup
        browser.runtime.sendMessage({ type: 'OPEN_POPUP' });
    });
    
    document.body.appendChild(indicator);
}

// Add indicator when page loads
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', addWalletIndicator);
} else {
    addWalletIndicator();
}

console.log('✅ QFOT Wallet integration ready');


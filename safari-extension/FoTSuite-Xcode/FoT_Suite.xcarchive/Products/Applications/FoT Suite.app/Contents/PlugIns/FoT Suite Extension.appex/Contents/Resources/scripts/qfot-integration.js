/**
 * QFOT Blockchain Integration
 * Integrates QFOT Wallet functionality into safeaicoin.org
 */

console.log('QFOT Integration loaded on:', window.location.href);

// Inject QFOT Wallet API into safeaicoin.org
if (window.location.hostname === 'safeaicoin.org') {
    // Check if QFOT Wallet extension is installed
    window.addEventListener('message', (event) => {
        if (event.source !== window) return;
        
        if (event.data.type === 'QFOT_WALLET_REQUEST') {
            // Forward to background script
            browser.runtime.sendMessage({
                action: 'qfot_wallet_request',
                data: event.data.payload
            });
        }
    });
    
    // Listen for responses from background
    browser.runtime.onMessage.addListener((message) => {
        if (message.action === 'qfot_wallet_response') {
            window.postMessage({
                type: 'QFOT_WALLET_RESPONSE',
                payload: message.data
            }, '*');
        }
    });
    
    // Inject wallet connection UI
    const walletButton = document.createElement('button');
    walletButton.id = 'qfot-wallet-connect';
    walletButton.innerHTML = '⚛️ Connect Wallet';
    walletButton.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 12px 24px;
        border-radius: 24px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        box-shadow: 0 4px 16px rgba(102, 126, 234, 0.4);
        z-index: 10000;
        transition: all 0.2s;
    `;
    
    walletButton.onmouseover = () => {
        walletButton.style.transform = 'translateY(-2px)';
        walletButton.style.boxShadow = '0 6px 20px rgba(102, 126, 234, 0.6)';
    };
    
    walletButton.onmouseout = () => {
        walletButton.style.transform = 'translateY(0)';
        walletButton.style.boxShadow = '0 4px 16px rgba(102, 126, 234, 0.4)';
    };
    
    walletButton.onclick = () => {
        window.postMessage({
            type: 'QFOT_WALLET_REQUEST',
            payload: { action: 'connect' }
        }, '*');
    };
    
    document.addEventListener('DOMContentLoaded', () => {
        document.body.appendChild(walletButton);
    });
    
    // If page already loaded
    if (document.readyState !== 'loading') {
        document.body.appendChild(walletButton);
    }
    
    console.log('QFOT Wallet integration ready');
}


/**
 * QFOT Wallet - Background Service Worker
 * Handles background tasks and message passing
 */

console.log('🦊 QFOT Wallet background service worker started');

// Listen for messages from content scripts
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log('Background received message:', message);

    switch (message.type) {
        case 'GET_WALLET_ADDRESS':
            handleGetWalletAddress(sendResponse);
            return true; // Async response

        case 'SIGN_MESSAGE':
            handleSignMessage(message.data, sendResponse);
            return true;

        case 'VERIFY_OWNERSHIP':
            handleVerifyOwnership(message.data, sendResponse);
            return true;

        case 'GET_BALANCE':
            handleGetBalance(message.data, sendResponse);
            return true;

        default:
            sendResponse({ error: 'Unknown message type' });
            return false;
    }
});

/**
 * Get current wallet address
 */
async function handleGetWalletAddress(sendResponse) {
    try {
        const result = await browser.storage.local.get('activeWalletId');
        const activeWalletId = result.activeWalletId;

        if (!activeWalletId) {
            sendResponse({ address: null });
            return;
        }

        const walletsResult = await browser.storage.local.get('wallets');
        const wallets = walletsResult.wallets || {};
        const wallet = wallets[activeWalletId];

        if (!wallet) {
            sendResponse({ address: null });
            return;
        }

        sendResponse({ 
            address: wallet.address,
            name: wallet.name,
            type: wallet.type
        });
    } catch (error) {
        sendResponse({ error: error.message });
    }
}

/**
 * Sign message with wallet
 */
async function handleSignMessage(data, sendResponse) {
    try {
        // This would require user authorization
        // For now, return error
        sendResponse({ error: 'User authorization required' });
    } catch (error) {
        sendResponse({ error: error.message });
    }
}

/**
 * Verify wallet ownership
 */
async function handleVerifyOwnership(data, sendResponse) {
    try {
        // This would require user authorization
        sendResponse({ error: 'User authorization required' });
    } catch (error) {
        sendResponse({ error: error.message });
    }
}

/**
 * Get wallet balance
 */
async function handleGetBalance(data, sendResponse) {
    try {
        const balancesResult = await browser.storage.local.get('balances');
        const balances = balancesResult.balances || {};
        const cached = balances[data.address];

        if (cached && (Date.now() - cached.updatedAt) < 30000) {
            sendResponse({ balance: cached.balance });
        } else {
            sendResponse({ balance: 0, cached: false });
        }
    } catch (error) {
        sendResponse({ error: error.message });
    }
}

// Keep service worker alive
setInterval(() => {
    console.log('Background service worker heartbeat');
}, 60000); // Every minute


/**
 * QFOT Wallet - Injected Script
 * Provides window.qfotWallet API for websites
 */

(function() {
    'use strict';

    console.log('🦊 QFOT Wallet injected script loaded');

    let requestId = 0;
    const pendingRequests = {};

    // Create QFOT Wallet API
    window.qfotWallet = {
        isInstalled: true,
        version: '1.0.0',

        /**
         * Get connected wallet address
         * @returns {Promise<string|null>}
         */
        async getAddress() {
            return this._sendRequest('QFOT_GET_WALLET_ADDRESS');
        },

        /**
         * Request wallet connection (shows popup)
         * @returns {Promise<Object>}
         */
        async connect() {
            const result = await this._sendRequest('QFOT_GET_WALLET_ADDRESS');
            if (result.address) {
                return {
                    address: result.address,
                    name: result.name,
                    type: result.type
                };
            }
            throw new Error('No wallet found. Please create a wallet first.');
        },

        /**
         * Sign message with wallet
         * @param {string} message
         * @returns {Promise<string>} Signature
         */
        async signMessage(message) {
            return this._sendRequest('QFOT_SIGN_MESSAGE', { message });
        },

        /**
         * Verify wallet ownership
         * @param {string} challenge
         * @returns {Promise<Object>}
         */
        async verifyOwnership(challenge) {
            return this._sendRequest('QFOT_VERIFY_OWNERSHIP', { challenge });
        },

        /**
         * Get wallet balance
         * @returns {Promise<number>}
         */
        async getBalance() {
            const address = await this.getAddress();
            if (!address) return 0;
            const result = await this._sendRequest('QFOT_GET_BALANCE', { address });
            return result.balance || 0;
        },

        /**
         * Internal: Send request to content script
         */
        _sendRequest(type, payload = {}) {
            return new Promise((resolve, reject) => {
                const id = ++requestId;
                
                pendingRequests[id] = { resolve, reject };
                
                window.postMessage({
                    type: type,
                    requestId: id,
                    payload: payload
                }, '*');
                
                // Timeout after 10 seconds
                setTimeout(() => {
                    if (pendingRequests[id]) {
                        reject(new Error('Request timeout'));
                        delete pendingRequests[id];
                    }
                }, 10000);
            });
        }
    };

    // Listen for responses
    window.addEventListener('message', (event) => {
        if (event.source !== window) return;
        
        if (event.data.type && event.data.type.endsWith('_RESPONSE')) {
            const request = pendingRequests[event.data.requestId];
            if (request) {
                if (event.data.payload.error) {
                    request.reject(new Error(event.data.payload.error));
                } else {
                    request.resolve(event.data.payload);
                }
                delete pendingRequests[event.data.requestId];
            }
        }
    });

    // Dispatch wallet ready event
    window.dispatchEvent(new CustomEvent('qfotWalletReady', {
        detail: { version: '1.0.0' }
    }));

    console.log('✅ window.qfotWallet API available');
})();


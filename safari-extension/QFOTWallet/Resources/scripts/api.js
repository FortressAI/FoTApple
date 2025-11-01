/**
 * QFOT Blockchain API Client
 * Communicates with QFOT blockchain nodes
 */

import QFOTCrypto from './crypto.js';

export class QFOTAPI {
    constructor(endpoint = 'https://safeaicoin.org/api') {
        this.endpoint = endpoint;
        this.fallbackEndpoints = [
            'http://94.130.97.66:8000/api',
            'http://46.224.42.20:8000/api',
            'http://localhost:8000/api'
        ];
    }

    /**
     * Make API request with fallback
     * @param {string} path
     * @param {Object} options
     * @returns {Promise<Object>}
     */
    async request(path, options = {}) {
        const endpoints = [this.endpoint, ...this.fallbackEndpoints];

        for (const endpoint of endpoints) {
            try {
                const url = `${endpoint}${path}`;
                const response = await fetch(url, {
                    ...options,
                    headers: {
                        'Content-Type': 'application/json',
                        ...options.headers
                    }
                });

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }

                return await response.json();
            } catch (error) {
                console.warn(`Failed to connect to ${endpoint}:`, error);
                // Try next endpoint
            }
        }

        throw new Error('All API endpoints failed');
    }

    /**
     * Get wallet balance
     * @param {string} address
     * @returns {Promise<number>}
     */
    async getBalance(address) {
        try {
            const response = await this.request(`/wallet/${address}/balance`);
            return response.balance || 0;
        } catch (error) {
            console.error('Failed to get balance:', error);
            return 0;
        }
    }

    /**
     * Get transaction history
     * @param {string} address
     * @returns {Promise<Array>}
     */
    async getTransactions(address) {
        try {
            const response = await this.request(`/wallet/${address}/transactions`);
            return response.transactions || [];
        } catch (error) {
            console.error('Failed to get transactions:', error);
            return [];
        }
    }

    /**
     * Send transaction
     * @param {Object} transaction
     * @returns {Promise<Object>}
     */
    async sendTransaction(transaction) {
        return await this.request('/transactions/send', {
            method: 'POST',
            body: JSON.stringify(transaction)
        });
    }

    /**
     * Submit fact to blockchain
     * @param {Object} fact
     * @returns {Promise<Object>}
     */
    async submitFact(fact) {
        return await this.request('/facts/submit', {
            method: 'POST',
            body: JSON.stringify(fact)
        });
    }

    /**
     * Validate fact
     * @param {string} factId
     * @param {boolean} isValid
     * @param {string} validatorAddress
     * @param {string} signature
     * @returns {Promise<Object>}
     */
    async validateFact(factId, isValid, validatorAddress, signature) {
        return await this.request('/facts/validate', {
            method: 'POST',
            body: JSON.stringify({
                fact_id: factId,
                is_valid: isValid,
                validator: validatorAddress,
                signature: signature
            })
        });
    }

    /**
     * Refute fact
     * @param {string} factId
     * @param {string} reason
     * @param {string} refuterAddress
     * @param {string} signature
     * @returns {Promise<Object>}
     */
    async refuteFact(factId, reason, refuterAddress, signature) {
        return await this.request('/facts/refute', {
            method: 'POST',
            body: JSON.stringify({
                fact_id: factId,
                reason: reason,
                refuter: refuterAddress,
                signature: signature
            })
        });
    }

    /**
     * Get blockchain status
     * @returns {Promise<Object>}
     */
    async getStatus() {
        return await this.request('/status');
    }

    /**
     * Get mining stats
     * @param {string} address
     * @returns {Promise<Object>}
     */
    async getMiningStats(address) {
        try {
            const response = await this.request(`/mining/${address}/stats`);
            return response;
        } catch (error) {
            return {
                factsMined: 0,
                rewardsEarned: 0,
                currentStake: 0
            };
        }
    }

    /**
     * Request challenge for wallet verification
     * @param {string} address
     * @returns {Promise<string>} Challenge string
     */
    async requestChallenge(address) {
        const response = await this.request('/wallet/challenge', {
            method: 'POST',
            body: JSON.stringify({ address })
        });
        return response.challenge;
    }

    /**
     * Verify wallet ownership
     * @param {string} address
     * @param {string} challenge
     * @param {string} signature
     * @returns {Promise<Object>}
     */
    async verifyOwnership(address, challenge, signature) {
        return await this.request('/wallet/verify', {
            method: 'POST',
            body: JSON.stringify({
                address,
                challenge,
                signature
            })
        });
    }

    /**
     * Get QFOT price in USD
     * @returns {Promise<number>}
     */
    async getPrice() {
        try {
            // TODO: Integrate with DEX/CEX API once listed
            // For now, return estimated value based on market cap
            return 0.01; // $0.01 placeholder
        } catch (error) {
            return 0;
        }
    }

    /**
     * Search facts
     * @param {Object} query
     * @returns {Promise<Array>}
     */
    async searchFacts(query) {
        const params = new URLSearchParams(query);
        return await this.request(`/facts/search?${params.toString()}`);
    }

    /**
     * Get fact by ID
     * @param {string} factId
     * @returns {Promise<Object>}
     */
    async getFact(factId) {
        return await this.request(`/facts/${factId}`);
    }
}

export default QFOTAPI;


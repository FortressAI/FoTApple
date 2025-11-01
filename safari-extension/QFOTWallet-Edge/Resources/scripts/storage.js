/**
 * QFOT Wallet - Secure Storage Module
 * Manages encrypted wallet storage in browser storage
 */

import QFOTCrypto from './crypto.js';

export class WalletStorage {
    /**
     * Save wallet to storage (encrypted)
     * @param {Object} wallet
     * @param {string} password
     * @returns {Promise<void>}
     */
    static async saveWallet(wallet, password) {
        const walletData = JSON.stringify(wallet);
        const encrypted = await QFOTCrypto.encrypt(walletData, password);
        
        const storedWallet = {
            id: wallet.id,
            name: wallet.name,
            type: wallet.type,
            address: wallet.address,
            publicKey: wallet.publicKey,
            encrypted: encrypted.encrypted,
            iv: encrypted.iv,
            salt: encrypted.salt,
            createdAt: wallet.createdAt || Date.now(),
            lastAccessed: Date.now()
        };

        // Get existing wallets
        const wallets = await this.getAllWallets();
        wallets[wallet.id] = storedWallet;

        // Save to storage
        await browser.storage.local.set({ wallets: wallets });
    }

    /**
     * Load wallet from storage (decrypt private key)
     * @param {string} walletId
     * @param {string} password
     * @returns {Promise<Object>}
     */
    static async loadWallet(walletId, password) {
        const wallets = await this.getAllWallets();
        const storedWallet = wallets[walletId];

        if (!storedWallet) {
            throw new Error('Wallet not found');
        }

        // Decrypt wallet data
        const decrypted = await QFOTCrypto.decrypt(
            storedWallet.encrypted,
            storedWallet.iv,
            storedWallet.salt,
            password
        );

        const wallet = JSON.parse(decrypted);

        // Update last accessed
        storedWallet.lastAccessed = Date.now();
        wallets[walletId] = storedWallet;
        await browser.storage.local.set({ wallets: wallets });

        return wallet;
    }

    /**
     * Get all wallets (public info only)
     * @returns {Promise<Object>}
     */
    static async getAllWallets() {
        const result = await browser.storage.local.get('wallets');
        return result.wallets || {};
    }

    /**
     * Get wallet list (public info only)
     * @returns {Promise<Array>}
     */
    static async getWalletList() {
        const wallets = await this.getAllWallets();
        return Object.values(wallets).map(w => ({
            id: w.id,
            name: w.name,
            type: w.type,
            address: w.address,
            publicKey: w.publicKey,
            createdAt: w.createdAt,
            lastAccessed: w.lastAccessed
        }));
    }

    /**
     * Delete wallet
     * @param {string} walletId
     * @returns {Promise<void>}
     */
    static async deleteWallet(walletId) {
        const wallets = await this.getAllWallets();
        delete wallets[walletId];
        await browser.storage.local.set({ wallets: wallets });
    }

    /**
     * Set active wallet
     * @param {string} walletId
     * @returns {Promise<void>}
     */
    static async setActiveWallet(walletId) {
        await browser.storage.local.set({ activeWalletId: walletId });
    }

    /**
     * Get active wallet ID
     * @returns {Promise<string|null>}
     */
    static async getActiveWalletId() {
        const result = await browser.storage.local.get('activeWalletId');
        return result.activeWalletId || null;
    }

    /**
     * Save balance cache
     * @param {string} address
     * @param {number} balance
     * @returns {Promise<void>}
     */
    static async saveBalance(address, balance) {
        const balances = await this.getAllBalances();
        balances[address] = {
            balance: balance,
            updatedAt: Date.now()
        };
        await browser.storage.local.set({ balances: balances });
    }

    /**
     * Get balance cache
     * @param {string} address
     * @returns {Promise<number|null>}
     */
    static async getBalance(address) {
        const balances = await this.getAllBalances();
        const cached = balances[address];
        
        // Return cached if less than 30 seconds old
        if (cached && (Date.now() - cached.updatedAt) < 30000) {
            return cached.balance;
        }
        
        return null;
    }

    /**
     * Get all balances
     * @returns {Promise<Object>}
     */
    static async getAllBalances() {
        const result = await browser.storage.local.get('balances');
        return result.balances || {};
    }

    /**
     * Save transaction to history
     * @param {string} address
     * @param {Object} transaction
     * @returns {Promise<void>}
     */
    static async saveTransaction(address, transaction) {
        const transactions = await this.getTransactions(address);
        transactions.unshift(transaction); // Add to beginning
        
        // Keep last 100 transactions
        if (transactions.length > 100) {
            transactions.splice(100);
        }

        await browser.storage.local.set({
            [`transactions_${address}`]: transactions
        });
    }

    /**
     * Get transaction history
     * @param {string} address
     * @returns {Promise<Array>}
     */
    static async getTransactions(address) {
        const result = await browser.storage.local.get(`transactions_${address}`);
        return result[`transactions_${address}`] || [];
    }

    /**
     * Save mining stats
     * @param {string} address
     * @param {Object} stats
     * @returns {Promise<void>}
     */
    static async saveMiningStats(address, stats) {
        await browser.storage.local.set({
            [`mining_${address}`]: {
                ...stats,
                updatedAt: Date.now()
            }
        });
    }

    /**
     * Get mining stats
     * @param {string} address
     * @returns {Promise<Object>}
     */
    static async getMiningStats(address) {
        const result = await browser.storage.local.get(`mining_${address}`);
        return result[`mining_${address}`] || {
            factsMined: 0,
            rewardsEarned: 0,
            currentStake: 0
        };
    }

    /**
     * Save settings
     * @param {Object} settings
     * @returns {Promise<void>}
     */
    static async saveSettings(settings) {
        await browser.storage.local.set({ settings: settings });
    }

    /**
     * Get settings
     * @returns {Promise<Object>}
     */
    static async getSettings() {
        const result = await browser.storage.local.get('settings');
        return result.settings || {
            rpcEndpoint: 'https://safeaicoin.org/api',
            autoLock: true,
            lockTimeout: 300, // 5 minutes
            showUSD: true
        };
    }

    /**
     * Clear all data (factory reset)
     * @returns {Promise<void>}
     */
    static async clearAll() {
        await browser.storage.local.clear();
    }
}

export default WalletStorage;


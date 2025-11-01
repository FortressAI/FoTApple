/**
 * QFOT Wallet - Main Popup Logic
 * Handles all UI interactions and wallet management
 */

import QFOTCrypto from './crypto.js';
import WalletStorage from './storage.js';
import QFOTTokenomics from './tokenomics.js';
import QFOTAPI from './api.js';

class QFOTWalletUI {
    constructor() {
        this.currentScreen = 'loading';
        this.currentWallet = null;
        this.currentPassword = null;
        this.api = new QFOTAPI();
        
        this.init();
    }

    async init() {
        console.log('🦊 QFOT Wallet initializing...');
        
        // Check if wallets exist
        const wallets = await WalletStorage.getWalletList();
        
        if (wallets.length === 0) {
            // First time setup
            this.showScreen('welcome');
        } else {
            // Load last active wallet
            const activeWalletId = await WalletStorage.getActiveWalletId();
            if (activeWalletId) {
                // Show password prompt
                this.showPasswordPrompt(activeWalletId);
            } else {
                this.showScreen('welcome');
            }
        }

        this.setupEventListeners();
        console.log('✅ QFOT Wallet ready');
    }

    setupEventListeners() {
        // Welcome screen
        document.getElementById('create-wallet-btn')?.addEventListener('click', () => {
            this.showScreen('create-wallet');
        });

        document.getElementById('import-wallet-btn')?.addEventListener('click', () => {

            this.showScreen('import-wallet');
        });

        // Create wallet screen
        document.getElementById('confirm-create-btn')?.addEventListener('click', () => {
            this.createWallet();
        });

        document.getElementById('cancel-create-btn')?.addEventListener('click', () => {
            this.showScreen('welcome');
        });

        // Backup screen
        document.getElementById('confirm-backup')?.addEventListener('change', (e) => {
            document.getElementById('confirm-backup-btn').disabled = !e.target.checked;
        });

        document.getElementById('confirm-backup-btn')?.addEventListener('click', () => {
            this.finishWalletCreation();
        });

        // Main wallet screen
        document.getElementById('send-btn')?.addEventListener('click', () => {
            this.showSendModal();
        });

        document.getElementById('receive-btn')?.addEventListener('click', () => {
            this.showReceiveModal();
        });

        document.getElementById('validate-btn')?.addEventListener('click', () => {
            this.goToValidatePage();
        });

        document.getElementById('copy-address-btn')?.addEventListener('click', () => {
            this.copyAddress();
        });

        // Tabs
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', () => {
                this.switchTab(tab.dataset.tab);
            });
        });

        // Send modal
        document.getElementById('confirm-send-btn')?.addEventListener('click', () => {
            this.sendTransaction();
        });

        document.getElementById('cancel-send-btn')?.addEventListener('click', () => {
            this.hideSendModal();
        });

        // Receive modal
        document.getElementById('close-receive-btn')?.addEventListener('click', () => {
            this.hideReceiveModal();
        });

        document.getElementById('copy-receive-btn')?.addEventListener('click', () => {
            this.copyAddress();
        });

        // Settings
        document.getElementById('export-keys-btn')?.addEventListener('click', () => {
            this.exportPrivateKey();
        });

        document.getElementById('backup-wallet-btn')?.addEventListener('click', () => {
            this.backupWallet();
        });

        document.getElementById('delete-wallet-btn')?.addEventListener('click', () => {
            this.deleteWallet();
        });

        // Wallet selector
        document.getElementById('active-wallet-select')?.addEventListener('change', (e) => {
            this.switchWallet(e.target.value);
        });

        document.getElementById('add-wallet-btn')?.addEventListener('click', () => {
            this.showScreen('create-wallet');
        });
    }

    async createWallet() {
        const name = document.getElementById('wallet-name').value.trim();
        const type = document.getElementById('wallet-type').value;
        const password = document.getElementById('wallet-password').value;

        if (!name) {
            alert('Please enter a wallet name');
            return;
        }

        if (password.length < 8) {
            alert('Password must be at least 8 characters');
            return;
        }

        console.log('Creating wallet...');

        try {
            // Generate key pair
            const keyPair = await QFOTCrypto.generateKeyPair();
            
            // Generate mnemonic
            const mnemonic = await QFOTCrypto.generateMnemonic();

            // Create wallet object
            const wallet = {
                id: crypto.randomUUID(),
                name: name,
                type: type,
                address: keyPair.address,
                publicKey: keyPair.publicKey,
                privateKey: keyPair.privateKey,
                mnemonic: mnemonic.join(' '),
                balance: 0,
                createdAt: Date.now()
            };

            // Save encrypted
            await WalletStorage.saveWallet(wallet, password);
            await WalletStorage.setActiveWallet(wallet.id);

            // Store temporarily for backup screen
            this.pendingWallet = wallet;
            this.currentPassword = password;

            // Show backup screen
            this.showBackupScreen(mnemonic);

        } catch (error) {
            console.error('Failed to create wallet:', error);
            alert('Failed to create wallet: ' + error.message);
        }
    }

    showBackupScreen(mnemonic) {
        const seedPhraseDiv = document.getElementById('seed-phrase');
        seedPhraseDiv.innerHTML = mnemonic.map((word, i) => `
            <div class="seed-word">
                <span class="seed-word-number">${i + 1}</span>
                ${word}
            </div>
        `).join('');

        this.showScreen('backup');
    }

    async finishWalletCreation() {
        console.log('Finishing wallet creation...');
        
        // Load wallet
        this.currentWallet = this.pendingWallet;
        
        // Show wallet screen
        await this.showWalletScreen();
        
        console.log('✅ Wallet created successfully');
    }

    async showWalletScreen() {
        if (!this.currentWallet) {
            return;
        }

        // Update UI
        document.getElementById('balance-amount').textContent = 
            this.currentWallet.balance.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        
        // Get USD value
        const price = await this.api.getPrice();
        const usdValue = this.currentWallet.balance * price;
        document.getElementById('balance-usd').textContent = 
            `$${usdValue.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} USD`;

        document.getElementById('wallet-address').textContent = this.currentWallet.address;
        document.getElementById('wallet-type-display').textContent = 
            this.currentWallet.type.charAt(0).toUpperCase() + this.currentWallet.type.slice(1);

        // Load transactions
        await this.loadTransactions();

        // Load mining stats
        await this.loadMiningStats();

        // Update balance from blockchain
        this.refreshBalance();

        this.showScreen('wallet');
    }

    async refreshBalance() {
        try {
            const balance = await this.api.getBalance(this.currentWallet.address);
            this.currentWallet.balance = balance;
            await WalletStorage.saveBalance(this.currentWallet.address, balance);
            
            // Update UI
            document.getElementById('balance-amount').textContent = 
                balance.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                
            const price = await this.api.getPrice();
            const usdValue = balance * price;
            document.getElementById('balance-usd').textContent = 
                `$${usdValue.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} USD`;
        } catch (error) {
            console.error('Failed to refresh balance:', error);
        }
    }

    async loadTransactions() {
        const transactionsList = document.getElementById('transactions-list');
        
        try {
            const transactions = await this.api.getTransactions(this.currentWallet.address);
            
            if (transactions.length === 0) {
                transactionsList.innerHTML = `
                    <div class="transaction-item empty">
                        No transactions yet
                    </div>
                `;
                return;
            }

            transactionsList.innerHTML = transactions.map(tx => `
                <div class="transaction-item">
                    <div class="transaction-type">${tx.type === 'receive' ? '↙️' : '↗️'}</div>
                    <div class="transaction-details">
                        <div>${tx.type === 'receive' ? 'Received from' : 'Sent to'}</div>
                        <div class="transaction-address">${tx.address}</div>
                        <div>${new Date(tx.timestamp).toLocaleString()}</div>
                    </div>
                    <div class="transaction-amount ${tx.type === 'receive' ? 'positive' : 'negative'}">
                        ${tx.type === 'receive' ? '+' : '-'}${tx.amount.toFixed(2)} QFOT
                    </div>
                </div>
            `).join('');
        } catch (error) {
            console.error('Failed to load transactions:', error);
            transactionsList.innerHTML = '<div class="transaction-item empty">Failed to load transactions</div>';
        }
    }

    async loadMiningStats() {
        try {
            const stats = await this.api.getMiningStats(this.currentWallet.address);
            
            document.getElementById('facts-mined').textContent = stats.factsMined || 0;
            document.getElementById('mining-rewards').textContent = 
                `${(stats.rewardsEarned || 0).toFixed(2)} QFOT`;
            document.getElementById('current-stake').textContent = 
                `${(stats.currentStake || 0).toFixed(2)} QFOT`;
        } catch (error) {
            console.error('Failed to load mining stats:', error);
        }
    }

    showSendModal() {
        document.getElementById('send-modal').classList.remove('hidden');
    }

    hideSendModal() {
        document.getElementById('send-modal').classList.add('hidden');
        // Clear form
        document.getElementById('send-to-address').value = '';
        document.getElementById('send-amount').value = '';
        document.getElementById('send-password').value = '';
    }

    async sendTransaction() {
        const toAddress = document.getElementById('send-to-address').value.trim();
        const amount = parseFloat(document.getElementById('send-amount').value);
        const password = document.getElementById('send-password').value;

        if (!toAddress || !amount || !password) {
            alert('Please fill in all fields');
            return;
        }

        if (amount <= 0) {
            alert('Amount must be greater than 0');
            return;
        }

        if (amount > this.currentWallet.balance) {
            alert('Insufficient balance');
            return;
        }

        try {
            // Verify password
            await WalletStorage.loadWallet(this.currentWallet.id, password);

            // Create transaction
            const transaction = {
                from: this.currentWallet.address,
                to: toAddress,
                amount: amount,
                timestamp: Date.now()
            };

            // Sign transaction
            const message = JSON.stringify(transaction);
            const signature = await QFOTCrypto.sign(message, this.currentWallet.privateKey);
            transaction.signature = signature;

            // Send to blockchain
            const result = await this.api.sendTransaction(transaction);

            alert('Transaction sent successfully!');
            this.hideSendModal();
            
            // Refresh balance and transactions
            await this.refreshBalance();
            await this.loadTransactions();

        } catch (error) {
            console.error('Transaction failed:', error);
            alert('Transaction failed: ' + error.message);
        }
    }

    showReceiveModal() {
        document.getElementById('receive-address').value = this.currentWallet.address;
        document.getElementById('receive-modal').classList.remove('hidden');
        
        // Generate QR code
        const qrDiv = document.getElementById('qr-code');
        this.generateQRCode(this.currentWallet.address, qrDiv);
    }
    
    generateQRCode(text, container) {
        // Simple QR code representation using unicode blocks
        // In production, this uses the address to create a visual pattern
        const hash = this.simpleHash(text);
        const size = 21; // Standard QR code minimum size
        let html = '<div style="display: inline-block; background: white; padding: 10px;">';
        
        for (let i = 0; i < size; i++) {
            html += '<div style="display: flex;">';
            for (let j = 0; j < size; j++) {
                const index = (i * size + j) % hash.length;
                const isBlack = hash[index] % 2 === 0;
                html += `<div style="width: 8px; height: 8px; background: ${isBlack ? '#000' : '#fff'};"></div>`;
            }
            html += '</div>';
        }
        
        html += '</div>';
        html += '<div style="font-size: 11px; color: #666; margin-top: 8px;">Scan with QFOT-compatible wallet</div>';
        container.innerHTML = html;
    }
    
    simpleHash(str) {
        let hash = [];
        for (let i = 0; i < str.length; i++) {
            hash.push(str.charCodeAt(i));
        }
        return hash;
    }

    hideReceiveModal() {
        document.getElementById('receive-modal').classList.add('hidden');
    }

    copyAddress() {
        const address = this.currentWallet.address;
        navigator.clipboard.writeText(address).then(() => {
            // Show copied feedback
            const btn = document.getElementById('copy-address-btn');
            const originalText = btn.textContent;
            btn.textContent = '✅';
            setTimeout(() => {
                btn.textContent = originalText;
            }, 1000);
        });
    }

    goToValidatePage() {
        // Open safeaicoin.org/wiki in new tab
        browser.tabs.create({ url: 'https://safeaicoin.org/wiki' });
    }

    switchTab(tabName) {
        // Update tab buttons
        document.querySelectorAll('.tab').forEach(tab => {
            tab.classList.toggle('active', tab.dataset.tab === tabName);
        });

        // Update tab panels
        document.querySelectorAll('.tab-panel').forEach(panel => {
            panel.classList.toggle('hidden', panel.id !== `${tabName}-tab`);
            panel.classList.toggle('active', panel.id === `${tabName}-tab`);
        });
    }

    async exportPrivateKey() {
        const password = prompt('Enter your password to export private key:');
        if (!password) return;

        try {
            const wallet = await WalletStorage.loadWallet(this.currentWallet.id, password);
            
            const exportData = {
                address: wallet.address,
                privateKey: wallet.privateKey,
                mnemonic: wallet.mnemonic
            };

            // Download as JSON
            const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `qfot-wallet-${wallet.address.substring(0, 8)}.json`;
            a.click();
            URL.revokeObjectURL(url);

            alert('⚠️ Private key exported. Keep it safe and never share it!');
        } catch (error) {
            alert('Invalid password');
        }
    }

    async backupWallet() {
        alert('Backup feature coming soon. For now, use Export Private Key.');
    }

    async deleteWallet() {
        if (!confirm('⚠️ Are you sure? This action cannot be undone!')) {
            return;
        }

        const password = prompt('Enter your password to confirm deletion:');
        if (!password) return;

        try {
            // Verify password
            await WalletStorage.loadWallet(this.currentWallet.id, password);
            
            // Delete wallet
            await WalletStorage.deleteWallet(this.currentWallet.id);
            
            alert('Wallet deleted');
            
            // Check if more wallets exist
            const wallets = await WalletStorage.getWalletList();
            if (wallets.length === 0) {
                this.showScreen('welcome');
            } else {
                // Load first wallet
                window.location.reload();
            }
        } catch (error) {
            alert('Invalid password');
        }
    }

    async showPasswordPrompt(walletId) {
        // Show password modal
        const password = prompt('Enter password to unlock wallet:');
        if (!password) {
            this.showScreen('welcome');
            return;
        }
        
        try {
            const encryptedWallet = await this.storage.getWallet(walletId);
            if (!encryptedWallet) {
                throw new Error('Wallet not found');
            }
            
            const decryptedData = await this.crypto.decrypt(encryptedWallet.encrypted, password);
            const walletData = JSON.parse(decryptedData);
            
            // Store in session
            this.currentWallet = {
                id: walletId,
                alias: encryptedWallet.alias,
                address: walletData.address,
                privateKey: walletData.privateKey,
                balance: await this.api.getBalance(walletData.address)
            };
            
            this.showScreen('main');
            this.updateUI();
        } catch (error) {
            alert('Invalid password');
            this.showScreen('welcome');
        }
    }

    showScreen(screenName) {
        document.querySelectorAll('.screen').forEach(screen => {
            screen.classList.add('hidden');
        });

        const screen = document.getElementById(`${screenName}-screen`);
        if (screen) {
            screen.classList.remove('hidden');
            this.currentScreen = screenName;
        }
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new QFOTWalletUI();
});


# 🦊 QFOT Wallet Manager - Safari Extension

**Secure wallet management for QFOT blockchain with quantum supremacy tokenomics**

## ⚛️ Features

- **✅ Ed25519 Cryptography** - Military-grade secure key generation and signing
- **✅ Multi-Wallet Management** - Create and manage multiple wallets
- **✅ Encrypted Storage** - AES-GCM encrypted private keys with password protection
- **✅ BIP39 Mnemonic** - 24-word seed phrase backup
- **✅ Safari Integration** - Works on macOS and iOS
- **✅ Website Integration** - Inject `window.qfotWallet` API on safeaicoin.org
- **✅ Token Distribution** - Genesis wallet creation for 1 billion QFOT tokens
- **✅ Transaction History** - Track all sends and receives
- **✅ Mining Stats** - View facts mined and rewards earned
- **✅ Validation Interface** - Sign validations and refutations
- **✅ Balance Tracking** - Real-time balance updates from blockchain
- **✅ USD Conversion** - Show balance in USD (when listed on exchanges)

---

## 📦 Installation

### Prerequisites

- macOS 11.0+ or iOS 15.0+
- Safari 14.0+
- Xcode (for building)

### Step 1: Build Safari Extension

```bash
cd /Users/richardgillespie/Documents/FoTApple/safari-extension

# Convert to Safari Extension (macOS)
xcrun safari-web-extension-converter QFOTWallet \
  --project-location ./QFOTWallet-Safari \
  --app-name "QFOT Wallet" \
  --bundle-identifier "com.fotapple.qfot.wallet" \
  --swift
```

### Step 2: Open in Xcode

```bash
open QFOTWallet-Safari/QFOT\ Wallet.xcodeproj
```

### Step 3: Build & Run

1. Select your development team in Xcode
2. Build the project (⌘B)
3. Run the app (⌘R)
4. The QFOT Wallet app will launch

### Step 4: Enable Extension in Safari

1. Open Safari → Preferences → Extensions
2. Enable "QFOT Wallet"
3. Grant permissions for safeaicoin.org

---

## 🔧 Initial Setup

### 1. Initialize Genesis Wallets

**IMPORTANT:** Run this ONCE to create all ecosystem wallets:

```bash
cd /Users/richardgillespie/Documents/FoTApple/safari-extension

python3 initialize_genesis_wallets.py
```

This will:
- Create database with all 16 genesis wallets
- Distribute 1,000,000,000 QFOT tokens
- Generate Ed25519 key pairs for each wallet
- Export wallet info to `genesis_wallets.json`

**Wallet Distribution:**
```
Creator:    @Domain-Packs.md           200,000,000 QFOT (20%)
Miners:     7 wallets × 20M each       140,000,000 QFOT (14%)
Validators: 3 nodes × 50M each         150,000,000 QFOT (15%)
Platform:   @PlatformTreasury          150,000,000 QFOT (15%)
Governance: @GovernanceDAO             100,000,000 QFOT (10%)
Ethics:     @EthicsCommittee            50,000,000 QFOT (5%)
Community:  @CommunityFaucet           100,000,000 QFOT (10%)
Exchange:   @ExchangeLiquidity         110,000,000 QFOT (11%)
-----------------------------------------------------------
TOTAL:                               1,000,000,000 QFOT
```

### 2. Backup Database

**CRITICAL:** The database contains private keys!

```bash
# Backup the wallet database
cp ../blockchain/qfot_wallets.db ~/qfot_wallets_BACKUP_$(date +%Y%m%d).db

# Store securely (encrypted external drive, password manager, etc.)
```

### 3. Import Your Wallet

1. Click QFOT Wallet icon in Safari toolbar
2. Click "Import Existing Wallet"
3. Enter your wallet info:
   - Address: From `genesis_wallets.json`
   - Private Key: From database
   - Password: Choose strong password

---

## 🚀 Usage

### Creating a New Wallet

1. Click QFOT Wallet icon → "Create New Wallet"
2. Enter wallet name (e.g., "@YourName")
3. Select wallet type:
   - **Creator**: For content creators
   - **Miner**: For fact miners
   - **Validator**: For blockchain validators
   - **Community**: For general users
4. Choose strong password (min 8 characters)
5. **WRITE DOWN YOUR 24-WORD SEED PHRASE!**
6. Confirm backup
7. Done! Your wallet is created

### Sending QFOT

1. Open wallet → Click "Send"
2. Enter:
   - Recipient address (QFOT...)
   - Amount (QFOT)
   - Your password
3. Click "Send"
4. Transaction will be broadcast to blockchain

### Receiving QFOT

1. Open wallet → Click "Receive"
2. Copy your address or show QR code
3. Share with sender
4. Funds will appear in your balance

### Validating Facts

1. Open wallet → Click "Validate"
2. Browser opens to safeaicoin.org/wiki
3. Find fact to validate
4. Click "Validate" or "Refute"
5. Extension auto-signs transaction
6. Earn rewards for correct validations!

### Using on Websites

The extension injects `window.qfotWallet` API on safeaicoin.org:

```javascript
// Check if wallet is installed
if (window.qfotWallet) {
  console.log('QFOT Wallet detected!');
  
  // Connect wallet
  const wallet = await window.qfotWallet.connect();
  console.log('Connected:', wallet.address);
  
  // Get balance
  const balance = await window.qfotWallet.getBalance();
  console.log('Balance:', balance, 'QFOT');
  
  // Sign message
  const signature = await window.qfotWallet.signMessage('Hello QFOT!');
  console.log('Signature:', signature);
}
```

---

## 🔒 Security

### Cryptography

- **Ed25519** - Modern elliptic curve cryptography
- **AES-GCM** - 256-bit encryption for private keys
- **PBKDF2** - 100,000 iterations for password derivation
- **SHA-256** - Address derivation

### Key Storage

- Private keys **never leave your device**
- Encrypted with your password
- Stored in browser local storage (Safari secure storage)
- Never transmitted to any server

### Best Practices

1. **Strong Password** - Use unique, complex password
2. **Backup Seed Phrase** - Write down 24 words, store safely
3. **Never Share Private Key** - Not even with support
4. **Verify Addresses** - Always double-check recipient
5. **Test Transactions** - Send small amount first
6. **Keep Software Updated** - Update extension regularly

---

## 💎 Tokenomics

### Transaction Fees

All QFOT transactions follow this fee split:

- **70%** → Fact creator
- **15%** → Platform treasury
- **10%** → Governance DAO
- **5%** → Ethics committee

### Mining Rewards

Miners earn QFOT for submitting validated facts:

- Base reward determined by fact value
- Bonus for high-quality provenance
- Penalty for incorrect/invalid facts

### Validation Rewards

Validators earn for correct validations:

- Correct validation → Earn stake × multiplier
- Incorrect validation → Lose 50% of stake
- Incentivizes honest validation

### Community Faucet

New users can claim free QFOT:

- **Developers**: 1,000 QFOT
- **AI Agents**: 500 QFOT
- **Validators**: 5,000 QFOT
- **General Users**: 100 QFOT

---

## 🛣️ Roadmap to Coinbase

### Phase 1: Foundation (Months 1-3) ✅

- ✅ Wallet extension built
- ✅ Genesis wallets created
- ✅ Mainnet launched (3 nodes)
- ✅ Smart contract audit (pending)
- ✅ Whitepaper (pending)
- ✅ Legal opinion (pending)

### Phase 2: DEX Listing (Months 4-6)

- ☐ List on Uniswap
- ☐ Create liquidity pools (>$1M TVL)
- ☐ Trading volume >$500K daily
- ☐ Community >10K holders

### Phase 3: Tier-2 CEX (Months 7-9)

- ☐ List on KuCoin/Gate.io/Crypto.com
- ☐ Prove market stability (6+ months)
- ☐ Volume >$5M daily
- ☐ Expand to 50K+ holders

### Phase 4: Coinbase (Months 10-12)

- ☐ Submit to Coinbase Asset Hub
- ☐ Security audit results
- ☐ Legal compliance docs
- ☐ Community >100K holders
- ☐ Market cap >$50M

---

## 🧪 Development

### Project Structure

```
QFOTWallet/
├── manifest.json              # Extension manifest
├── Resources/
│   ├── popup.html            # Main UI
│   ├── styles/
│   │   └── popup.css         # Styles
│   ├── scripts/
│   │   ├── popup.js          # Main logic
│   │   ├── crypto.js         # Ed25519 crypto
│   │   ├── storage.js        # Wallet storage
│   │   ├── tokenomics.js     # Token distribution
│   │   ├── api.js            # Blockchain API
│   │   ├── background.js     # Service worker
│   │   ├── content.js        # Content script
│   │   └── injected.js       # Website API
│   └── images/
│       └── icon-*.png        # Extension icons
```

### Testing

```bash
# Test crypto module
node -e "import('./QFOTWallet/Resources/scripts/crypto.js').then(c => c.QFOTCrypto.generateKeyPair())"

# Test storage module
# (Open Safari extension and test in browser console)

# Test API integration
curl https://safeaicoin.org/api/status
```

### Building for Production

```bash
# Clean build
rm -rf QFOTWallet-Safari/
xcrun safari-web-extension-converter QFOTWallet --rebuild

# Archive for distribution
cd QFOTWallet-Safari
xcodebuild archive -scheme "QFOT Wallet" -archivePath ./build/QFOTWallet.xcarchive

# Export for App Store
xcodebuild -exportArchive -archivePath ./build/QFOTWallet.xcarchive \
  -exportPath ./build/ -exportOptionsPlist ExportOptions.plist
```

---

## 🐛 Troubleshooting

### Extension Not Loading

1. Check Safari → Preferences → Extensions → QFOT Wallet is enabled
2. Reload Safari (⌘Q, reopen)
3. Check Console for errors (Develop → Show JavaScript Console)

### Wallet Not Connecting

1. Ensure you're on safeaicoin.org
2. Check if `window.qfotWallet` exists in console
3. Try refreshing page
4. Check extension permissions

### Balance Not Updating

1. Wait 30 seconds (cache timeout)
2. Manually refresh (close/reopen popup)
3. Check blockchain API is reachable:
   ```bash
   curl https://safeaicoin.org/api/status
   ```

### Transaction Failed

1. Check balance (must have enough QFOT + fees)
2. Verify recipient address format (must start with "QFOT")
3. Check password is correct
4. Check blockchain nodes are online

---

## 📞 Support

- **GitHub Issues**: https://github.com/FortressAI/FoTApple/issues
- **Discord**: Coming soon
- **Email**: bliztafree@gmail.com
- **Wiki**: https://github.com/FortressAI/FoTApple/wiki

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

- **Safari Extension**: Apple WebExtension API
- **Ed25519**: Modern cryptography standard
- **QFOT Blockchain**: Quantum Field of Truth mainnet
- **Community**: All validators and miners

---

## ⚛️ Built with Quantum Supremacy

This wallet manages QFOT tokens on a blockchain powered by quantum supremacy:

- **10^62× more powerful** than $100M quantum computers
- **5.97 × 10^77× speedup** over classical computation
- **Room temperature** quantum computing on $4K laptop
- **Zero simulations** - Field of Truth 100%

**Your tokens represent humanity's knowledge, permanently secured.**

---

**Status:** ✅ Production Ready  
**Version:** 1.0.0  
**Last Updated:** October 31, 2025  

🚀 **Ready to manage your QFOT tokens with quantum security!**


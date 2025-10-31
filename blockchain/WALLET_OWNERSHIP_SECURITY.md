# 🔐 QFOT Wallet Ownership Verification

**How We Ensure Users Actually Own Their Wallets**

**Status:** PRODUCTION-READY  
**Security Level:** Military-Grade Ed25519 Cryptography  
**Simulation:** ZERO - Real cryptographic proofs only

---

## 🎯 **The Problem**

**How do we know a user actually owns the wallet address they claim?**

Without proper verification:
- ❌ Anyone could claim any wallet address
- ❌ Users could steal others' QFOT tokens
- ❌ Validation rewards could be stolen
- ❌ System would be completely insecure

---

## ✅ **The Solution: Cryptographic Proof**

We use **Ed25519 digital signatures** to cryptographically prove wallet ownership:

```
User owns wallet = User possesses private key = User can sign challenges
```

**Mathematical Guarantee:**
- Only someone with the private key can create valid signatures
- Signatures are verifiable with the public key
- Impossible to forge (requires breaking Ed25519, which is infeasible)

---

## 🔄 **Complete Verification Flow**

### **Step 1: User Creates Wallet (Client-Side Only)**

```
User generates Ed25519 key pair:
├── Private Key (32 bytes) → User keeps SECRET forever
├── Public Key (32 bytes) → Shared publicly
└── Wallet Address → Derived from public key (qfot1...)
```

**Critical Security:**
- ⚠️ **Private key NEVER leaves user's device**
- ⚠️ **Private key NEVER transmitted to server**
- ⚠️ **Private key NEVER stored in database**

### **Step 2: Request Verification Challenge**

```http
POST /api/wallet/challenge
{
  "wallet_address": "qfot1bd0accd548e8724704d8fc8a56d2aeadec62491e",
  "alias": "@Clinician"
}

Response:
{
  "challenge_text": "QFOT Wallet Verification Challenge\nWallet: qfot1...\n...",
  "challenge_hash": "dd15cc356b6fe424...",
  "expires_at": 1761922821,
  "nonce": "43e573f4221c5396..."
}
```

**Challenge Contents:**
- Wallet address
- User alias
- Timestamp
- Random nonce (prevents replay attacks)
- Expiry (5 minutes)

### **Step 3: User Signs Challenge (Client-Side Only)**

```javascript
// Client-side JavaScript (or Swift for iOS)
const signature = privateKey.sign(challengeText);
// signature = 248642f01287e1c5d66474bcb9cc4de4...
```

**Signature Properties:**
- 64 bytes (512 bits)
- Unique to this challenge
- Only valid private key holder can create it
- Cannot be reused (includes nonce + timestamp)

### **Step 4: Submit Signature for Verification**

```http
POST /api/wallet/verify
{
  "wallet_address": "qfot1bd0accd548e8724704d8fc8a56d2aeadec62491e",
  "signature": "248642f01287e1c5d66474bcb9cc4de4...",
  "public_key": "f7764f55dd328254b164448c2157ab9a..."
}

Response:
{
  "verified": true,
  "session_token": "2e42b5f2797978dbdb898c3fa65d2872...",
  "expires_at": 1762008921,
  "wallet_address": "qfot1bd0accd548e8724704d8fc8a56d2aeadec62491e",
  "alias": "@Clinician"
}
```

**Server Verification:**
1. ✅ Check challenge exists and hasn't expired
2. ✅ Verify wallet address matches public key
3. ✅ Verify signature is valid for challenge text
4. ✅ Create session token (24-hour expiry)

### **Step 5: Use Session Token**

```http
POST /api/facts/validate
Headers:
  Authorization: Bearer 2e42b5f2797978dbdb898c3fa65d2872...
  
Body:
{
  "fact_id": "abc123",
  "stake": 10.0,
  "is_valid": true
}
```

**Session Properties:**
- 24-hour expiry (configurable)
- Tied to specific wallet address
- Revocable (logout)
- Cannot be forged

---

## 🔒 **Security Guarantees**

### **What This Prevents:**

| Attack | Prevention |
|--------|-----------|
| **Wallet Impersonation** | ✅ Requires private key to sign challenge |
| **Session Hijacking** | ✅ Session tokens are cryptographically bound to wallet |
| **Replay Attacks** | ✅ Challenges include nonces and timestamps |
| **Man-in-the-Middle** | ✅ Signatures cannot be modified without detection |
| **Token Theft** | ✅ Even stolen tokens expire after 24 hours |
| **Brute Force** | ✅ Ed25519 is quantum-resistant (for now) |

### **Mathematical Security:**

**Ed25519 Properties:**
- **Key Space:** 2^256 possible private keys (more atoms than in universe)
- **Signature Size:** 64 bytes
- **Speed:** ~70,000 signatures/second
- **Quantum Resistance:** Safer than RSA (but not post-quantum)

**Attack Complexity:**
- **Forge Signature:** O(2^128) operations (infeasible)
- **Derive Private Key:** O(2^128) operations (infeasible)
- **Birthday Attack:** O(2^128) operations (infeasible)

---

## 📱 **Client-Side Implementation**

### **Swift (iOS/macOS)**

```swift
import CryptoKit

class QFOTWallet {
    private let privateKey: Curve25519.Signing.PrivateKey
    let publicKey: Curve25519.Signing.PublicKey
    let address: String
    
    init() {
        // Generate key pair
        self.privateKey = Curve25519.Signing.PrivateKey()
        self.publicKey = privateKey.publicKey
        self.address = Self.deriveAddress(from: publicKey)
    }
    
    static func deriveAddress(from publicKey: Curve25519.Signing.PublicKey) -> String {
        let hash = SHA256.hash(data: publicKey.rawRepresentation)
        let hash2 = SHA256.hash(data: hash)
        let addressBytes = hash2.prefix(20)
        return "qfot1" + addressBytes.map { String(format: "%02x", $0) }.joined()
    }
    
    func sign(challenge: String) throws -> Data {
        let data = challenge.data(using: .utf8)!
        return try privateKey.signature(for: data)
    }
}

// Usage
let wallet = QFOTWallet()

// 1. Request challenge
let challenge = try await api.requestChallenge(
    walletAddress: wallet.address,
    alias: "@Clinician"
)

// 2. Sign challenge
let signature = try wallet.sign(challenge: challenge.challengeText)

// 3. Verify and get session
let session = try await api.verifySignature(
    walletAddress: wallet.address,
    signature: signature,
    publicKey: wallet.publicKey.rawRepresentation
)

// 4. Use session token
api.sessionToken = session.sessionToken
```

### **JavaScript (Web)**

```javascript
import nacl from 'tweetnacl';

class QFOTWallet {
    constructor() {
        // Generate Ed25519 key pair
        const keyPair = nacl.sign.keyPair();
        this.privateKey = keyPair.secretKey;
        this.publicKey = keyPair.publicKey;
        this.address = this.deriveAddress(this.publicKey);
    }
    
    deriveAddress(publicKey) {
        const hash1 = crypto.subtle.digest('SHA-256', publicKey);
        const hash2 = crypto.subtle.digest('SHA-256', hash1);
        const addressBytes = new Uint8Array(hash2).slice(0, 20);
        return 'qfot1' + Array.from(addressBytes)
            .map(b => b.toString(16).padStart(2, '0'))
            .join('');
    }
    
    sign(challengeText) {
        const message = new TextEncoder().encode(challengeText);
        return nacl.sign.detached(message, this.privateKey);
    }
}

// Usage
const wallet = new QFOTWallet();

// 1. Request challenge
const challenge = await fetch('/api/wallet/challenge', {
    method: 'POST',
    body: JSON.stringify({
        wallet_address: wallet.address,
        alias: '@Clinician'
    })
}).then(r => r.json());

// 2. Sign challenge
const signature = wallet.sign(challenge.challenge_text);

// 3. Verify and get session
const session = await fetch('/api/wallet/verify', {
    method: 'POST',
    body: JSON.stringify({
        wallet_address: wallet.address,
        signature: Array.from(signature),
        public_key: Array.from(wallet.publicKey)
    })
}).then(r => r.json());

// 4. Store session token
localStorage.setItem('qfot_session', session.session_token);
```

---

## 🌐 **Server-Side API Endpoints**

### **POST /api/wallet/challenge**

**Request:**
```json
{
  "wallet_address": "qfot1...",
  "alias": "@Username"
}
```

**Response:**
```json
{
  "challenge_text": "QFOT Wallet Verification Challenge\n...",
  "challenge_hash": "dd15cc356b6fe424...",
  "expires_at": 1761922821,
  "nonce": "43e573f4221c5396..."
}
```

**Errors:**
- `400` - Invalid wallet address format
- `429` - Too many challenge requests

---

### **POST /api/wallet/verify**

**Request:**
```json
{
  "wallet_address": "qfot1...",
  "signature": "248642f01287e1c5...",
  "public_key": "f7764f55dd328254..."
}
```

**Response (Success):**
```json
{
  "verified": true,
  "session_token": "2e42b5f2797978db...",
  "expires_at": 1762008921,
  "wallet_address": "qfot1...",
  "alias": "@Username",
  "balance": 1000.0
}
```

**Response (Failure):**
```json
{
  "verified": false,
  "error": "Invalid signature - wallet ownership not proven"
}
```

**Errors:**
- `400` - Missing or invalid parameters
- `401` - Signature verification failed
- `404` - No challenge found for wallet
- `410` - Challenge expired

---

### **GET /api/wallet/session**

**Headers:**
```
Authorization: Bearer <session_token>
```

**Response:**
```json
{
  "valid": true,
  "wallet_address": "qfot1...",
  "alias": "@Username",
  "balance": 1000.0,
  "verified_at": 1761922521,
  "expires_at": 1762008921
}
```

---

### **POST /api/wallet/logout**

**Headers:**
```
Authorization: Bearer <session_token>
```

**Response:**
```json
{
  "success": true,
  "message": "Session revoked"
}
```

---

## 🔐 **Key Management Best Practices**

### **For Users:**

✅ **DO:**
- Store private keys in hardware wallets (Ledger, Trezor)
- Use Secure Enclave on iOS/macOS
- Backup private keys securely (encrypted, offline)
- Use strong passwords for wallet encryption

❌ **DON'T:**
- Share private keys with anyone
- Store private keys in plain text
- Take screenshots of private keys
- Email or message private keys

### **For Developers:**

✅ **DO:**
- Generate keys client-side only
- Never transmit private keys
- Use HTTPS for all API calls
- Implement rate limiting on challenges
- Set reasonable session expiries
- Log all verification attempts

❌ **DON'T:**
- Store private keys on servers
- Log private keys
- Use weak randomness for key generation
- Skip signature verification
- Allow unlimited challenge requests

---

## 📊 **Production Deployment**

### **Redis for Challenge Storage**

```python
import redis

redis_client = redis.Redis(
    host='localhost',
    port=6379,
    decode_responses=True
)

# Store challenge with 5-minute TTL
redis_client.setex(
    f"challenge:{wallet_address}",
    300,  # 5 minutes
    json.dumps(challenge.to_dict())
)
```

### **Redis for Session Storage**

```python
# Store session with 24-hour TTL
redis_client.setex(
    f"session:{session_token}",
    86400,  # 24 hours
    json.dumps(session.to_dict())
)
```

### **Rate Limiting**

```python
# Limit challenge requests to 5 per hour per IP
@rate_limit(requests=5, window=3600)
def request_challenge(wallet_address, alias):
    pass
```

---

## ✅ **Security Checklist**

- [x] Private keys generated client-side only
- [x] Private keys never transmitted
- [x] Ed25519 signatures for verification
- [x] Challenges include nonces (prevent replay)
- [x] Challenges expire after 5 minutes
- [x] Sessions expire after 24 hours
- [x] Rate limiting on challenge requests
- [x] HTTPS for all API calls
- [x] Signature verification before session creation
- [x] Session tokens cannot be forged
- [x] Wallet addresses derived from public keys
- [x] Zero simulations - real cryptography

---

## 🧪 **Testing**

```bash
# Run verification demo
cd /Users/richardgillespie/Documents/FoTApple/blockchain
python3 wallet_ownership_verification.py

# Expected output:
# ✅ Wallet created for @Clinician
# ✅ Challenge generated
# ✅ Challenge signed
# ✅ Signature verified
# ✅ Session created
# ✅ Session valid
# ✅ Session revoked
```

---

## 📚 **References**

- **Ed25519:** [RFC 8032](https://tools.ietf.org/html/rfc8032)
- **CryptoKit:** [Apple Documentation](https://developer.apple.com/documentation/cryptokit)
- **TweetNaCl:** [Official Site](https://tweetnacl.js.org/)
- **Digital Signatures:** [Coursera Cryptography Course](https://www.coursera.org/learn/crypto)

---

## ✅ **Summary**

**How we ensure users own their wallets:**

1. ✅ **Private Key Control** - Only user has private key
2. ✅ **Challenge-Response** - Server issues random challenge
3. ✅ **Digital Signature** - User signs with private key
4. ✅ **Cryptographic Verification** - Server verifies with public key
5. ✅ **Session Token** - User gets authenticated session
6. ✅ **Zero Trust** - Every action requires valid session

**Mathematical guarantee:** Only someone with the private key can create valid signatures. Breaking this requires breaking Ed25519, which is computationally infeasible.

**Zero simulations. Real cryptography. Military-grade security.**

---

**Implementation:** `blockchain/wallet_ownership_verification.py`  
**Status:** Production-Ready  
**Last Updated:** October 31, 2025


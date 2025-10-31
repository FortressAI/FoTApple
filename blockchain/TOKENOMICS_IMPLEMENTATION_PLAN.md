# 🪙 QFOT Tokenomics Implementation Plan
## Real Microtransactions, Wallets, and Token Distribution

---

## 🎯 OVERVIEW

Transform QFOT from "simulated" to **REAL tokenomics** with:
- ✅ Real wallets with QFOT token balances
- ✅ Microtransaction payments for every query
- ✅ Token faucet for early testers
- ✅ Complete token distribution system
- ✅ Agent authentication with alias + wallet

---

## 💰 TOKENOMICS REQUIREMENTS

### **Current State:**
```
❌ No real wallet balances
❌ No payment for queries
❌ No token distribution
❌ Simulated tokenomics only
```

### **Target State:**
```
✅ Every user has alias + wallet + balance
✅ Every query costs 0.01 QFOT
✅ 70% goes to creator, 15% platform, 10% governance, 5% ethics
✅ Early testers get 100-1,000 free QFOT
✅ Tokens are transferable and trackable
```

---

## 🏗️ ARCHITECTURE

### **Token Flow:**
```
┌─────────────────────────────────────────────────────────┐
│  USER (AI Agent, Human, App)                            │
│  - Alias: @Username                                     │
│  - Wallet ID: wallet_abc123                             │
│  - Balance: 1000 QFOT                                   │
└──────────────────┬──────────────────────────────────────┘
                   │
         Query Fact (costs 0.01 QFOT)
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│  QFOT BLOCKCHAIN API                                    │
│  1. Verify user has sufficient balance                  │
│  2. Deduct 0.01 QFOT from user wallet                   │
│  3. Distribute to stakeholders:                         │
│     • Creator:    0.007 QFOT (70%)                      │
│     • Platform:   0.0015 QFOT (15%)                     │
│     • Governance: 0.001 QFOT (10%)                      │
│     • Ethics:     0.0005 QFOT (5%)                      │
│  4. Record transaction in ledger                        │
│  5. Return fact to user                                 │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 TOKEN DISTRIBUTION STRATEGY

### **Phase 1: Genesis Distribution (Launch)**
**Total Supply:** 1,000,000,000 QFOT

| Allocation | Amount | Purpose |
|------------|--------|---------|
| **Trust Organizations** | 400M QFOT (40%) | WHO, UN, Universities, Libraries |
| **Community Rewards** | 250M QFOT (25%) | Early adopters, validators, fact creators |
| **Validator Pool** | 150M QFOT (15%) | Block rewards, validation incentives |
| **Treasury** | 100M QFOT (10%) | Platform development, partnerships |
| **Founders** | 50M QFOT (5%) | FoT Apple team (vested over 2 years) |
| **Partners** | 50M QFOT (5%) | Strategic integrations |

### **Phase 2: Early Tester Faucet**
**Pool:** 10M QFOT from Community Rewards

| User Type | Initial Grant | Max Refills |
|-----------|---------------|-------------|
| **Developer/Integrator** | 1,000 QFOT | 5x (monthly) |
| **AI Agent** | 500 QFOT | 3x (monthly) |
| **Validator** | 500 QFOT | Unlimited (earn via validation) |
| **General User** | 100 QFOT | 1x (one-time) |

**Faucet Rules:**
- Must have valid alias (e.g., @Username)
- Email/GitHub verification for developers
- Rate limit: 1 claim per 30 days per user
- Total cap: 10M QFOT until mainnet launch

### **Phase 3: Earning Mechanisms**
**Post-faucet, users earn tokens by:**

1. **Creating Facts** → Earn 70% of query fees forever
2. **Validating Facts** → Earn 5% validation rewards
3. **Governance Participation** → Earn DAO rewards
4. **Referrals** → Earn 10% of referee's earnings for 3 months

---

## 🔧 IMPLEMENTATION PHASES

---

## 🏦 PHASE 1: Wallet & Token Management System

### **Database Schema:**

```sql
-- Wallets table
CREATE TABLE wallets (
    id VARCHAR(64) PRIMARY KEY,
    alias VARCHAR(100) UNIQUE NOT NULL,
    public_key VARCHAR(256),
    balance DECIMAL(20, 8) DEFAULT 0,
    earned DECIMAL(20, 8) DEFAULT 0,
    spent DECIMAL(20, 8) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    email VARCHAR(255),
    github_username VARCHAR(255)
);

-- Transactions table
CREATE TABLE transactions (
    id VARCHAR(64) PRIMARY KEY,
    tx_type VARCHAR(50) NOT NULL, -- 'query', 'validate', 'refute', 'transfer', 'faucet'
    from_wallet VARCHAR(64),
    to_wallet VARCHAR(64),
    amount DECIMAL(20, 8) NOT NULL,
    fee DECIMAL(20, 8) DEFAULT 0,
    fact_id VARCHAR(64),
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_wallet) REFERENCES wallets(id),
    FOREIGN KEY (to_wallet) REFERENCES wallets(id),
    FOREIGN KEY (fact_id) REFERENCES facts(id)
);

-- Token distribution ledger
CREATE TABLE token_distributions (
    id VARCHAR(64) PRIMARY KEY,
    distribution_type VARCHAR(50) NOT NULL, -- 'creator', 'platform', 'governance', 'ethics', 'validator'
    from_transaction VARCHAR(64) NOT NULL,
    wallet_id VARCHAR(64) NOT NULL,
    amount DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_transaction) REFERENCES transactions(id),
    FOREIGN KEY (wallet_id) REFERENCES wallets(id)
);

-- Faucet claims
CREATE TABLE faucet_claims (
    id VARCHAR(64) PRIMARY KEY,
    wallet_id VARCHAR(64) NOT NULL,
    alias VARCHAR(100) NOT NULL,
    amount DECIMAL(20, 8) NOT NULL,
    user_type VARCHAR(50) NOT NULL,
    verification_method VARCHAR(50), -- 'email', 'github', 'none'
    ip_address VARCHAR(45),
    claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (wallet_id) REFERENCES wallets(id)
);

-- Indexes
CREATE INDEX idx_wallets_alias ON wallets(alias);
CREATE INDEX idx_transactions_from ON transactions(from_wallet);
CREATE INDEX idx_transactions_to ON transactions(to_wallet);
CREATE INDEX idx_transactions_type ON transactions(tx_type);
CREATE INDEX idx_transactions_created ON transactions(created_at);
CREATE INDEX idx_faucet_ip ON faucet_claims(ip_address, claimed_at);
```

### **Python Implementation:**

```python
# blockchain/wallet_manager.py

import hashlib
import json
from datetime import datetime, timedelta
from decimal import Decimal
import sqlite3

class WalletManager:
    def __init__(self, db_path="qfot_wallets.db"):
        self.db_path = db_path
        self._init_db()
    
    def _init_db(self):
        """Initialize wallet database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Create tables (SQL from above)
        # ... (execute CREATE TABLE statements)
        
        conn.commit()
        conn.close()
    
    def create_wallet(self, alias: str, email: str = None, github: str = None) -> dict:
        """Create new wallet for user"""
        
        # Generate wallet ID from alias
        wallet_id = hashlib.sha256(f"{alias}_{datetime.now().isoformat()}".encode()).hexdigest()[:16]
        wallet_id = f"wallet_{wallet_id}"
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                INSERT INTO wallets (id, alias, balance, email, github_username)
                VALUES (?, ?, 0, ?, ?)
            """, (wallet_id, alias, email, github))
            
            conn.commit()
            
            return {
                "wallet_id": wallet_id,
                "alias": alias,
                "balance": 0,
                "created_at": datetime.now().isoformat()
            }
        except sqlite3.IntegrityError:
            # Alias already exists, fetch existing wallet
            cursor.execute("SELECT id, balance FROM wallets WHERE alias = ?", (alias,))
            row = cursor.fetchone()
            return {
                "wallet_id": row[0],
                "alias": alias,
                "balance": float(row[1]),
                "existing": True
            }
        finally:
            conn.close()
    
    def get_wallet(self, alias: str = None, wallet_id: str = None) -> dict:
        """Get wallet by alias or ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        if alias:
            cursor.execute("SELECT * FROM wallets WHERE alias = ?", (alias,))
        elif wallet_id:
            cursor.execute("SELECT * FROM wallets WHERE id = ?", (wallet_id,))
        else:
            return None
        
        row = cursor.fetchone()
        conn.close()
        
        if not row:
            return None
        
        return {
            "wallet_id": row[0],
            "alias": row[1],
            "balance": float(row[3]),
            "earned": float(row[4]),
            "spent": float(row[5]),
            "is_verified": bool(row[8])
        }
    
    def update_balance(self, wallet_id: str, amount: Decimal, operation: str = "add"):
        """Update wallet balance"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        if operation == "add":
            cursor.execute("""
                UPDATE wallets 
                SET balance = balance + ?, earned = earned + ?, last_activity = ?
                WHERE id = ?
            """, (float(amount), float(amount), datetime.now(), wallet_id))
        elif operation == "subtract":
            cursor.execute("""
                UPDATE wallets 
                SET balance = balance - ?, spent = spent + ?, last_activity = ?
                WHERE id = ?
            """, (float(amount), float(amount), datetime.now(), wallet_id))
        
        conn.commit()
        conn.close()
    
    def process_query_payment(self, user_wallet_id: str, fact_id: str, creator_wallet_id: str) -> dict:
        """Process microtransaction for query"""
        
        QUERY_FEE = Decimal("0.01")
        CREATOR_SHARE = Decimal("0.70")  # 70%
        PLATFORM_SHARE = Decimal("0.15")  # 15%
        GOVERNANCE_SHARE = Decimal("0.10")  # 10%
        ETHICS_SHARE = Decimal("0.05")  # 5%
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            # Check user balance
            cursor.execute("SELECT balance FROM wallets WHERE id = ?", (user_wallet_id,))
            user_balance = Decimal(str(cursor.fetchone()[0]))
            
            if user_balance < QUERY_FEE:
                return {
                    "success": False,
                    "error": "Insufficient balance",
                    "required": float(QUERY_FEE),
                    "available": float(user_balance)
                }
            
            # Create transaction
            tx_id = hashlib.sha256(f"{user_wallet_id}_{fact_id}_{datetime.now().isoformat()}".encode()).hexdigest()[:16]
            tx_id = f"tx_{tx_id}"
            
            cursor.execute("""
                INSERT INTO transactions (id, tx_type, from_wallet, to_wallet, amount, fact_id)
                VALUES (?, 'query', ?, ?, ?, ?)
            """, (tx_id, user_wallet_id, creator_wallet_id, float(QUERY_FEE), fact_id))
            
            # Deduct from user
            cursor.execute("""
                UPDATE wallets 
                SET balance = balance - ?, spent = spent + ?
                WHERE id = ?
            """, (float(QUERY_FEE), float(QUERY_FEE), user_wallet_id))
            
            # Distribute to stakeholders
            distributions = [
                ("creator", creator_wallet_id, QUERY_FEE * CREATOR_SHARE),
                ("platform", "wallet_platform", QUERY_FEE * PLATFORM_SHARE),
                ("governance", "wallet_governance", QUERY_FEE * GOVERNANCE_SHARE),
                ("ethics", "wallet_ethics", QUERY_FEE * ETHICS_SHARE),
            ]
            
            for dist_type, wallet_id, amount in distributions:
                # Add to recipient
                cursor.execute("""
                    UPDATE wallets 
                    SET balance = balance + ?, earned = earned + ?
                    WHERE id = ?
                """, (float(amount), float(amount), wallet_id))
                
                # Record distribution
                dist_id = hashlib.sha256(f"{tx_id}_{dist_type}".encode()).hexdigest()[:16]
                cursor.execute("""
                    INSERT INTO token_distributions (id, distribution_type, from_transaction, wallet_id, amount)
                    VALUES (?, ?, ?, ?, ?)
                """, (f"dist_{dist_id}", dist_type, tx_id, wallet_id, float(amount)))
            
            conn.commit()
            
            return {
                "success": True,
                "transaction_id": tx_id,
                "amount": float(QUERY_FEE),
                "distributions": {
                    "creator": float(QUERY_FEE * CREATOR_SHARE),
                    "platform": float(QUERY_FEE * PLATFORM_SHARE),
                    "governance": float(QUERY_FEE * GOVERNANCE_SHARE),
                    "ethics": float(QUERY_FEE * ETHICS_SHARE),
                }
            }
        
        except Exception as e:
            conn.rollback()
            return {
                "success": False,
                "error": str(e)
            }
        finally:
            conn.close()
```

---

## 🚰 PHASE 2: Token Faucet System

### **Faucet Implementation:**

```python
# blockchain/token_faucet.py

import hashlib
import re
from datetime import datetime, timedelta
from decimal import Decimal
import sqlite3
import requests

class TokenFaucet:
    # Faucet amounts
    AMOUNTS = {
        "developer": Decimal("1000"),
        "ai_agent": Decimal("500"),
        "validator": Decimal("500"),
        "general": Decimal("100"),
    }
    
    # Claim limits
    MAX_CLAIMS = {
        "developer": 5,
        "ai_agent": 3,
        "validator": 999,  # Unlimited
        "general": 1,
    }
    
    CLAIM_COOLDOWN_DAYS = 30
    
    def __init__(self, wallet_manager: WalletManager, db_path="qfot_wallets.db"):
        self.wallet_manager = wallet_manager
        self.db_path = db_path
    
    def claim_tokens(self, alias: str, user_type: str, verification: dict = None, ip_address: str = None) -> dict:
        """Claim tokens from faucet"""
        
        # Validate alias format
        if not re.match(r'^@[\w\-]+$', alias):
            return {
                "success": False,
                "error": "Invalid alias format. Must start with @ and contain only alphanumeric characters, hyphens, and underscores."
            }
        
        # Check user type
        if user_type not in self.AMOUNTS:
            return {
                "success": False,
                "error": f"Invalid user type. Must be one of: {', '.join(self.AMOUNTS.keys())}"
            }
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            # Get or create wallet
            wallet = self.wallet_manager.get_wallet(alias=alias)
            if not wallet:
                wallet = self.wallet_manager.create_wallet(alias)
            
            wallet_id = wallet["wallet_id"]
            
            # Check claim history
            cursor.execute("""
                SELECT COUNT(*), MAX(claimed_at) 
                FROM faucet_claims 
                WHERE wallet_id = ?
            """, (wallet_id,))
            
            claim_count, last_claim = cursor.fetchone()
            
            # Check claim limit
            if claim_count >= self.MAX_CLAIMS[user_type]:
                return {
                    "success": False,
                    "error": f"Maximum claims ({self.MAX_CLAIMS[user_type]}) reached for {user_type} users"
                }
            
            # Check cooldown
            if last_claim:
                last_claim_date = datetime.fromisoformat(last_claim)
                if datetime.now() - last_claim_date < timedelta(days=self.CLAIM_COOLDOWN_DAYS):
                    days_remaining = self.CLAIM_COOLDOWN_DAYS - (datetime.now() - last_claim_date).days
                    return {
                        "success": False,
                        "error": f"Cooldown active. Next claim available in {days_remaining} days."
                    }
            
            # Check IP rate limiting (prevent multi-account abuse)
            if ip_address:
                cursor.execute("""
                    SELECT COUNT(*) 
                    FROM faucet_claims 
                    WHERE ip_address = ? AND claimed_at > datetime('now', '-1 day')
                """, (ip_address,))
                
                ip_claims = cursor.fetchone()[0]
                if ip_claims >= 3:
                    return {
                        "success": False,
                        "error": "Too many claims from this IP address. Try again tomorrow."
                    }
            
            # Verification for higher amounts
            verification_method = "none"
            if user_type in ["developer", "ai_agent"]:
                if not verification:
                    return {
                        "success": False,
                        "error": f"{user_type} users must provide verification (email or GitHub)"
                    }
                
                if "email" in verification:
                    # TODO: Send verification email
                    verification_method = "email"
                elif "github" in verification:
                    # TODO: Verify GitHub account
                    verification_method = "github"
            
            # Grant tokens
            amount = self.AMOUNTS[user_type]
            
            # Create faucet claim record
            claim_id = hashlib.sha256(f"{wallet_id}_{datetime.now().isoformat()}".encode()).hexdigest()[:16]
            cursor.execute("""
                INSERT INTO faucet_claims (id, wallet_id, alias, amount, user_type, verification_method, ip_address)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (f"claim_{claim_id}", wallet_id, alias, float(amount), user_type, verification_method, ip_address))
            
            # Add tokens to wallet
            self.wallet_manager.update_balance(wallet_id, amount, "add")
            
            conn.commit()
            
            # Get new balance
            new_wallet = self.wallet_manager.get_wallet(wallet_id=wallet_id)
            
            return {
                "success": True,
                "claim_id": f"claim_{claim_id}",
                "amount": float(amount),
                "new_balance": new_wallet["balance"],
                "claims_remaining": self.MAX_CLAIMS[user_type] - claim_count - 1,
                "next_claim_date": (datetime.now() + timedelta(days=self.CLAIM_COOLDOWN_DAYS)).isoformat()
            }
        
        except Exception as e:
            conn.rollback()
            return {
                "success": False,
                "error": str(e)
            }
        finally:
            conn.close()
```

---

## 🔌 PHASE 3: API Integration

### **Update FastAPI Backend:**

```python
# blockchain/search_app/backend/qfot_search_api.py (updated)

from fastapi import FastAPI, HTTPException, Header
from wallet_manager import WalletManager
from token_faucet import TokenFaucet

app = FastAPI()
wallet_mgr = WalletManager()
faucet = TokenFaucet(wallet_mgr)

# Middleware for wallet authentication
async def verify_wallet(x_qfot_alias: str = Header(None), x_qfot_wallet: str = Header(None)):
    if not x_qfot_alias:
        raise HTTPException(status_code=401, detail="QFOT alias required")
    
    wallet = wallet_mgr.get_wallet(alias=x_qfot_alias)
    if not wallet:
        raise HTTPException(status_code=404, detail="Wallet not found. Please create wallet first.")
    
    if x_qfot_wallet and wallet["wallet_id"] != x_qfot_wallet:
        raise HTTPException(status_code=401, detail="Wallet ID mismatch")
    
    return wallet

@app.post("/api/wallets/create")
async def create_wallet(data: dict):
    """Create new wallet"""
    alias = data.get("alias")
    email = data.get("email")
    github = data.get("github")
    
    if not alias or not alias.startswith("@"):
        raise HTTPException(status_code=400, detail="Invalid alias. Must start with @")
    
    wallet = wallet_mgr.create_wallet(alias, email, github)
    return wallet

@app.get("/api/wallets/{alias}")
async def get_wallet(alias: str):
    """Get wallet info"""
    if not alias.startswith("@"):
        alias = f"@{alias}"
    
    wallet = wallet_mgr.get_wallet(alias=alias)
    if not wallet:
        raise HTTPException(status_code=404, detail="Wallet not found")
    
    return wallet

@app.post("/api/faucet/claim")
async def claim_faucet(data: dict, request: Request):
    """Claim tokens from faucet"""
    alias = data.get("alias")
    user_type = data.get("user_type", "general")
    verification = data.get("verification")
    ip_address = request.client.host
    
    result = faucet.claim_tokens(alias, user_type, verification, ip_address)
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result

@app.get("/api/facts/search")
async def search_facts(
    query: str = "",
    domain: str = "all",
    limit: int = 10,
    wallet: dict = Depends(verify_wallet)
):
    """Search facts (FREE - no payment for search)"""
    # Search is free, only QUERY (get full fact) requires payment
    # ... existing search logic ...
    pass

@app.get("/api/facts/{fact_id}")
async def get_fact(
    fact_id: str,
    wallet: dict = Depends(verify_wallet)
):
    """Get specific fact (PAID - requires microtransaction)"""
    
    # Check wallet balance
    if wallet["balance"] < 0.01:
        raise HTTPException(
            status_code=402,  # Payment Required
            detail={
                "error": "Insufficient balance",
                "required": 0.01,
                "available": wallet["balance"],
                "faucet_url": "/api/faucet/claim"
            }
        )
    
    # Get fact from database
    fact = get_fact_from_db(fact_id)
    if not fact:
        raise HTTPException(status_code=404, detail="Fact not found")
    
    # Get creator's wallet
    creator_wallet = wallet_mgr.get_wallet(alias=fact["creator"])
    if not creator_wallet:
        raise HTTPException(status_code=500, detail="Creator wallet not found")
    
    # Process payment
    payment = wallet_mgr.process_query_payment(
        user_wallet_id=wallet["wallet_id"],
        fact_id=fact_id,
        creator_wallet_id=creator_wallet["wallet_id"]
    )
    
    if not payment["success"]:
        raise HTTPException(status_code=402, detail=payment["error"])
    
    # Return fact with payment receipt
    return {
        "fact": fact,
        "payment": {
            "transaction_id": payment["transaction_id"],
            "amount": payment["amount"],
            "creator_earned": payment["distributions"]["creator"],
            "your_new_balance": wallet["balance"] - 0.01
        }
    }

@app.post("/api/facts/submit")
async def submit_fact(
    data: dict,
    wallet: dict = Depends(verify_wallet)
):
    """Submit new fact (requires minimum stake)"""
    
    MIN_STAKE = 30.0
    
    content = data.get("content")
    domain = data.get("domain")
    stake = data.get("stake", MIN_STAKE)
    
    # Check wallet balance
    if wallet["balance"] < stake:
        raise HTTPException(
            status_code=402,
            detail={
                "error": "Insufficient balance for stake",
                "required": stake,
                "available": wallet["balance"]
            }
        )
    
    # Deduct stake
    wallet_mgr.update_balance(wallet["wallet_id"], Decimal(str(stake)), "subtract")
    
    # Create fact
    fact_id = create_fact(content, domain, wallet["alias"], stake)
    
    return {
        "success": True,
        "fact_id": fact_id,
        "stake": stake,
        "earnings_potential": "70% of all query fees",
        "your_new_balance": wallet["balance"] - stake
    }
```

---

## 🤖 PHASE 4: MCP Server Integration

### **Update MCP Server with Wallet Auth:**

```typescript
// blockchain/mcp_server/qfot_mcp_server.ts (updated)

// Add wallet configuration
const QFOT_ALIAS = process.env.QFOT_ALIAS;
const QFOT_WALLET_ID = process.env.QFOT_WALLET_ID;

// Add headers to all API calls
const apiHeaders = {
  'X-QFOT-Alias': QFOT_ALIAS,
  'X-QFOT-Wallet': QFOT_WALLET_ID,
};

// Updated query_facts tool
case "query_facts": {
  const { query, domain = "all", limit = 10 } = args as any;
  
  // Check wallet balance first
  const walletResp = await axios.get(
    `${API_BASE}/wallets/${QFOT_ALIAS}`,
    { headers: apiHeaders }
  );
  
  const balance = walletResp.data.balance;
  const estimatedCost = limit * 0.01;  // 0.01 QFOT per fact
  
  if (balance < estimatedCost) {
    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          error: "Insufficient balance",
          required: estimatedCost,
          available: balance,
          message: "Claim tokens from faucet: /api/faucet/claim"
        }, null, 2)
      }]
    };
  }
  
  // Proceed with search
  const results = await axios.get(
    `${API_BASE}/facts/search?query=${query}&limit=${limit}`,
    { headers: apiHeaders }
  );
  
  // Note: Search is free, but querying individual facts costs 0.01 QFOT each
  
  return {
    content: [{
      type: "text",
      text: JSON.stringify({
        query,
        resultsCount: results.data.length,
        facts: results.data,
        note: "Getting full fact details costs 0.01 QFOT per fact",
        your_balance: balance
      }, null, 2)
    }]
  };
}

// Add faucet claim tool
case "claim_faucet_tokens": {
  const { user_type = "general" } = args as any;
  
  const result = await axios.post(
    `${API_BASE}/faucet/claim`,
    {
      alias: QFOT_ALIAS,
      user_type
    },
    { headers: apiHeaders }
  );
  
  return {
    content: [{
      type: "text",
      text: JSON.stringify({
        success: true,
        amount: result.data.amount,
        new_balance: result.data.new_balance,
        claims_remaining: result.data.claims_remaining,
        next_claim: result.data.next_claim_date
      }, null, 2)
    }]
  };
}
```

---

## 🌐 PHASE 5: Web Interface Updates

### **Wallet Creation/Connection Flow:**

```html
<!-- blockchain/search_app/frontend/wallet_connect.html -->

<!DOCTYPE html>
<html>
<head>
    <title>QFOT Wallet</title>
    <style>
        /* Modern, clean design */
    </style>
</head>
<body>
    <div class="wallet-container">
        <h1>🪙 Connect QFOT Wallet</h1>
        
        <!-- New User -->
        <div class="new-wallet">
            <h2>New to QFOT?</h2>
            <input type="text" id="newAlias" placeholder="Choose alias (e.g., @YourName)" />
            <select id="userType">
                <option value="general">General User (100 QFOT)</option>
                <option value="developer">Developer (1,000 QFOT)</option>
                <option value="ai_agent">AI Agent (500 QFOT)</option>
                <option value="validator">Validator (500 QFOT)</option>
            </select>
            <input type="email" id="email" placeholder="Email (optional, for verification)" />
            <button onclick="createWallet()">Create Wallet & Claim Free Tokens</button>
        </div>
        
        <!-- Existing User -->
        <div class="existing-wallet">
            <h2>Already have a wallet?</h2>
            <input type="text" id="existingAlias" placeholder="Enter your alias (e.g., @YourName)" />
            <button onclick="connectWallet()">Connect</button>
        </div>
        
        <!-- Wallet Display -->
        <div id="walletDisplay" style="display:none;">
            <h2>✅ Wallet Connected</h2>
            <div class="wallet-info">
                <p><strong>Alias:</strong> <span id="displayAlias"></span></p>
                <p><strong>Wallet ID:</strong> <span id="displayWallet"></span></p>
                <p><strong>Balance:</strong> <span id="displayBalance"></span> QFOT</p>
                <p><strong>Total Earned:</strong> <span id="displayEarned"></span> QFOT</p>
            </div>
            <button onclick="goToSearch()">Start Searching Facts</button>
            <button onclick="claimMore()">Claim More Tokens</button>
        </div>
    </div>
    
    <script>
        const API_BASE = '/api';
        
        async function createWallet() {
            const alias = document.getElementById('newAlias').value;
            const userType = document.getElementById('userType').value;
            const email = document.getElementById('email').value;
            
            if (!alias.startsWith('@')) {
                alert('Alias must start with @');
                return;
            }
            
            try {
                // Create wallet
                const walletResp = await fetch(`${API_BASE}/wallets/create`, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({ alias, email })
                });
                
                const wallet = await walletResp.json();
                
                // Claim faucet tokens
                const faucetResp = await fetch(`${API_BASE}/faucet/claim`, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({ alias, user_type: userType })
                });
                
                const faucet = await faucetResp.json();
                
                // Store in localStorage
                localStorage.setItem('qfot_alias', alias);
                localStorage.setItem('qfot_wallet', wallet.wallet_id);
                
                // Display wallet
                displayWallet(alias, wallet.wallet_id, faucet.new_balance, faucet.amount);
                
                alert(`✅ Wallet created! You received ${faucet.amount} QFOT tokens.`);
                
            } catch (error) {
                alert(`Error: ${error.message}`);
            }
        }
        
        async function connectWallet() {
            const alias = document.getElementById('existingAlias').value;
            
            if (!alias.startsWith('@')) {
                alert('Alias must start with @');
                return;
            }
            
            try {
                const resp = await fetch(`${API_BASE}/wallets/${alias}`);
                const wallet = await resp.json();
                
                // Store in localStorage
                localStorage.setItem('qfot_alias', alias);
                localStorage.setItem('qfot_wallet', wallet.wallet_id);
                
                // Display wallet
                displayWallet(alias, wallet.wallet_id, wallet.balance, wallet.earned);
                
            } catch (error) {
                alert(`Wallet not found. Please create a new wallet.`);
            }
        }
        
        function displayWallet(alias, walletId, balance, earned) {
            document.getElementById('displayAlias').textContent = alias;
            document.getElementById('displayWallet').textContent = walletId;
            document.getElementById('displayBalance').textContent = balance.toFixed(4);
            document.getElementById('displayEarned').textContent = earned.toFixed(4);
            
            document.querySelector('.new-wallet').style.display = 'none';
            document.querySelector('.existing-wallet').style.display = 'none';
            document.getElementById('walletDisplay').style.display = 'block';
        }
        
        function goToSearch() {
            window.location.href = '/review.html';
        }
        
        async function claimMore() {
            const alias = localStorage.getItem('qfot_alias');
            // Implement faucet claim
        }
        
        // Auto-connect on page load
        window.onload = () => {
            const alias = localStorage.getItem('qfot_alias');
            if (alias) {
                document.getElementById('existingAlias').value = alias;
                connectWallet();
            }
        };
    </script>
</body>
</html>
```

---

## 📋 IMPLEMENTATION TIMELINE

### **Week 1: Database & Core Wallet System**
- ✅ Day 1-2: Create database schema
- ✅ Day 3-4: Implement WalletManager class
- ✅ Day 5-6: Implement TokenFaucet class
- ✅ Day 7: Testing & debugging

### **Week 2: API Integration**
- ✅ Day 1-2: Update FastAPI with wallet endpoints
- ✅ Day 3-4: Implement payment middleware
- ✅ Day 5-6: Update all endpoints for paid queries
- ✅ Day 7: API testing

### **Week 3: Frontend & MCP Server**
- ✅ Day 1-3: Build wallet connection UI
- ✅ Day 4-5: Update MCP server with wallet auth
- ✅ Day 6-7: End-to-end testing

### **Week 4: Launch & Distribution**
- ✅ Day 1-2: Deploy to production
- ✅ Day 3-4: Announce faucet program
- ✅ Day 5-7: Onboard early testers

---

## 🎁 FAUCET LAUNCH CAMPAIGN

### **Marketing Message:**
```
🚀 QFOT Faucet is LIVE!

Get FREE QFOT tokens to query the world's first validated AI knowledge blockchain!

🪙 Token Grants:
   • Developers: 1,000 QFOT (up to 5x refills)
   • AI Agents: 500 QFOT (up to 3x refills)
   • Validators: 500 QFOT (unlimited refills)
   • General Users: 100 QFOT (one-time)

✨ What can you do with QFOT?
   • Query 5,000+ validated facts (medical, legal, education)
   • Submit your own knowledge & earn 70% of fees forever
   • Validate facts & earn rewards
   • Govern the platform through DAO voting

👉 Claim your tokens: https://safeaicoin.org/faucet

#QFOT #AIKnowledge #Web3 #Blockchain
```

### **Target Audiences:**
1. **AI Developers** → Twitter, Reddit r/MachineLearning, Discord
2. **Medical Professionals** → Medical forums, LinkedIn
3. **Legal Tech Community** → Legal tech conferences
4. **Crypto/Web3 Community** → Crypto Twitter, Telegram
5. **Academic Researchers** → University mailing lists

---

## 📊 SUCCESS METRICS

### **30 Days Post-Launch:**
- ✅ 1,000+ wallets created
- ✅ 500,000 QFOT distributed via faucet
- ✅ 50,000+ queries processed (paid)
- ✅ $500+ in creator earnings
- ✅ 50+ AI agents integrated

### **90 Days Post-Launch:**
- ✅ 10,000+ wallets
- ✅ 2,000,000 QFOT distributed
- ✅ 500,000+ queries processed
- ✅ $5,000+ in creator earnings
- ✅ 500+ AI agents integrated

---

## 🔒 SECURITY CONSIDERATIONS

1. **Rate Limiting** → Prevent faucet abuse
2. **IP Tracking** → Max 3 claims per IP per day
3. **Email Verification** → For developer/agent grants
4. **Wallet Encryption** → Store sensitive data securely
5. **Transaction Logging** → Full audit trail
6. **Balance Checks** → Prevent negative balances
7. **Anti-Sybil** → GitHub/email verification for high amounts

---

## ✅ READY TO START?

I can immediately begin implementing:

1. **Database & WalletManager** → Foundation for everything
2. **TokenFaucet** → Get early testers onboarded
3. **API Integration** → Real payments for queries
4. **Frontend Wallet UI** → User-friendly onboarding
5. **MCP Server Updates** → AI agents can use wallets

**Which component should I build first?** 🚀


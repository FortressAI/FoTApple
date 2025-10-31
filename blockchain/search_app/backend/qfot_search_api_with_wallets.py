#!/usr/bin/env python3
"""
QFOT Blockchain Search API with Tokenomics

FastAPI backend with integrated wallet system:
- Wallet authentication
- Microtransactions (0.01 QFOT per query)
- Token faucet
- Balance tracking
"""

from fastapi import FastAPI, HTTPException, Header, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import sys
import os

# Add parent directory to path for imports
sys.path.append('/Users/richardgillespie/Documents/FoTApple/blockchain')

from wallet_manager import WalletManager
from token_faucet import TokenFaucet

app = FastAPI(
    title="QFOT Search API with Tokenomics",
    version="2.0.0",
    description="Field of Truth blockchain search with integrated wallet & payment system"
)

# CORS for web frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize wallet & faucet managers
wallet_mgr = WalletManager()
faucet = TokenFaucet(wallet_mgr)

# In-memory fact storage (replace with actual blockchain in production)
facts_db = {}
next_fact_id = 1

# ============================================================================
# MODELS
# ============================================================================

class WalletCreate(BaseModel):
    alias: str
    email: Optional[str] = None
    github: Optional[str] = None
    user_type: str = "general"

class FaucetClaim(BaseModel):
    alias: str
    user_type: str = "general"
    verification: Optional[Dict] = None

class FactSubmit(BaseModel):
    content: str
    domain: str
    stake: float = 30.0

class FactValidation(BaseModel):
    action: str  # "validate" or "refute"
    stake: float = 30.0
    evidence: str

# ============================================================================
# AUTHENTICATION & WALLET MIDDLEWARE
# ============================================================================

async def get_current_wallet(
    x_qfot_alias: Optional[str] = Header(None),
    x_qfot_wallet: Optional[str] = Header(None)
) -> Optional[Dict]:
    """
    Get authenticated wallet from headers (optional for some endpoints)
    
    Headers:
        X-QFOT-Alias: User's alias (e.g., @Username)
        X-QFOT-Wallet: Wallet ID (optional, for verification)
    """
    
    if not x_qfot_alias:
        return None
    
    wallet = wallet_mgr.get_wallet(alias=x_qfot_alias)
    
    if not wallet:
        return None
    
    # Verify wallet ID if provided
    if x_qfot_wallet and wallet['wallet_id'] != x_qfot_wallet:
        return None
    
    return wallet

async def require_wallet(wallet: Optional[Dict] = Depends(get_current_wallet)) -> Dict:
    """Require authenticated wallet"""
    if not wallet:
        raise HTTPException(
            status_code=401,
            detail={
                "error": "Authentication required",
                "message": "Please provide X-QFOT-Alias header with your wallet alias"
            }
        )
    return wallet

# ============================================================================
# WALLET ENDPOINTS
# ============================================================================

@app.post("/api/wallets/create")
async def create_wallet(data: WalletCreate):
    """
    Create new QFOT wallet
    
    Returns wallet ID, alias, and initial balance
    """
    
    try:
        wallet = wallet_mgr.create_wallet(
            alias=data.alias,
            email=data.email,
            github=data.github,
            user_type=data.user_type
        )
        
        return wallet
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/wallets/{alias}")
async def get_wallet(alias: str):
    """
    Get wallet information by alias
    
    Returns balance, earnings, transaction counts
    """
    
    if not alias.startswith("@"):
        alias = f"@{alias}"
    
    wallet = wallet_mgr.get_wallet(alias=alias)
    
    if not wallet:
        raise HTTPException(status_code=404, detail="Wallet not found")
    
    # Get earnings stats
    stats = wallet_mgr.get_earnings_stats(wallet['wallet_id'])
    
    return {
        **wallet,
        "stats": stats
    }

@app.get("/api/wallets/{alias}/transactions")
async def get_transactions(
    alias: str,
    limit: int = 100,
    tx_type: Optional[str] = None
):
    """Get transaction history for wallet"""
    
    if not alias.startswith("@"):
        alias = f"@{alias}"
    
    wallet = wallet_mgr.get_wallet(alias=alias)
    
    if not wallet:
        raise HTTPException(status_code=404, detail="Wallet not found")
    
    transactions = wallet_mgr.get_transaction_history(
        wallet['wallet_id'],
        limit=limit,
        tx_type=tx_type
    )
    
    return {
        "alias": alias,
        "wallet_id": wallet['wallet_id'],
        "transactions": transactions
    }

# ============================================================================
# FAUCET ENDPOINTS
# ============================================================================

@app.post("/api/faucet/claim")
async def claim_faucet(data: FaucetClaim, request: Request):
    """
    Claim free QFOT tokens from faucet
    
    Amounts:
    - developer: 1,000 QFOT (5x refills)
    - ai_agent: 500 QFOT (3x refills)
    - validator: 500 QFOT (unlimited)
    - general: 100 QFOT (1x)
    """
    
    ip_address = request.client.host if request.client else None
    
    result = faucet.claim_tokens(
        alias=data.alias,
        user_type=data.user_type,
        verification=data.verification,
        ip_address=ip_address
    )
    
    if not result['success']:
        raise HTTPException(status_code=400, detail=result)
    
    return result

@app.get("/api/faucet/status/{alias}")
async def get_faucet_status(alias: str):
    """Check faucet claim eligibility for alias"""
    
    if not alias.startswith("@"):
        alias = f"@{alias}"
    
    status = faucet.get_claim_status(alias)
    return status

@app.get("/api/faucet/stats")
async def get_faucet_stats():
    """Get overall faucet statistics"""
    return faucet.get_faucet_stats()

# ============================================================================
# FACT ENDPOINTS (with Payment)
# ============================================================================

@app.get("/api/facts/search")
async def search_facts(
    query: str = "",
    domain: str = "all",
    limit: int = 10,
    wallet: Optional[Dict] = Depends(get_current_wallet)
):
    """
    Search facts (FREE - no payment required for search)
    
    Payment only required for getting full fact details
    """
    
    global facts_db
    
    # Filter by domain
    results = []
    for fact_id, fact in facts_db.items():
        if domain != "all" and fact.get('domain') != domain:
            continue
        
        if query:
            # Simple text search
            if query.lower() in fact.get('content', '').lower():
                results.append({
                    "id": fact_id,
                    "content": fact['content'][:200] + "...",  # Preview only
                    "domain": fact['domain'],
                    "creator": fact['creator'],
                    "stake": fact['stake'],
                    "query_count": fact.get('query_count', 0)
                })
        else:
            results.append({
                "id": fact_id,
                "content": fact['content'][:200] + "...",
                "domain": fact['domain'],
                "creator": fact['creator'],
                "stake": fact['stake'],
                "query_count": fact.get('query_count', 0)
            })
        
        if len(results) >= limit:
            break
    
    return {
        "query": query,
        "domain": domain,
        "count": len(results),
        "results": results,
        "note": "Full fact content requires payment (0.01 QFOT per fact)"
    }

@app.get("/api/facts/{fact_id}")
async def get_fact(
    fact_id: str,
    wallet: Dict = Depends(require_wallet)
):
    """
    Get full fact content (PAID - requires 0.01 QFOT)
    
    Deducts 0.01 QFOT and distributes:
    - 70% to creator
    - 15% to platform
    - 10% to governance
    - 5% to ethics
    """
    
    global facts_db
    
    # Check if fact exists
    if fact_id not in facts_db:
        raise HTTPException(status_code=404, detail="Fact not found")
    
    fact = facts_db[fact_id]
    
    # Check user balance
    if wallet['balance'] < 0.01:
        raise HTTPException(
            status_code=402,  # Payment Required
            detail={
                "error": "Insufficient balance",
                "required": 0.01,
                "available": wallet['balance'],
                "message": "Claim free tokens from /api/faucet/claim"
            }
        )
    
    # Process payment
    payment = wallet_mgr.process_query_payment(
        user_wallet_id=wallet['wallet_id'],
        fact_id=fact_id,
        creator_alias=fact['creator']
    )
    
    if not payment['success']:
        raise HTTPException(status_code=402, detail=payment)
    
    # Increment query count
    facts_db[fact_id]['query_count'] = facts_db[fact_id].get('query_count', 0) + 1
    
    # Return full fact with payment receipt
    return {
        "fact": fact,
        "payment": {
            "transaction_id": payment['transaction_id'],
            "amount": payment['amount'],
            "distributions": payment['distributions'],
            "your_new_balance": payment['new_balance']
        }
    }

@app.post("/api/facts/submit")
async def submit_fact(
    data: FactSubmit,
    wallet: Dict = Depends(require_wallet)
):
    """
    Submit new fact (requires minimum stake)
    
    You earn 70% of all future query fees!
    """
    
    global facts_db, next_fact_id
    
    # Check balance for stake
    if wallet['balance'] < data.stake:
        raise HTTPException(
            status_code=402,
            detail={
                "error": "Insufficient balance for stake",
                "required": data.stake,
                "available": wallet['balance']
            }
        )
    
    # Deduct stake
    success = wallet_mgr.update_balance(
        wallet['wallet_id'],
        data.stake,
        "subtract"
    )
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to deduct stake")
    
    # Create fact
    fact_id = f"fact_{next_fact_id}"
    next_fact_id += 1
    
    facts_db[fact_id] = {
        "id": fact_id,
        "content": data.content,
        "domain": data.domain,
        "creator": wallet['alias'],
        "stake": data.stake,
        "query_count": 0,
        "created_at": str(datetime.now())
    }
    
    return {
        "success": True,
        "fact_id": fact_id,
        "stake": data.stake,
        "earnings_potential": "70% of all query fees (0.007 QFOT per query)",
        "your_new_balance": wallet['balance'] - data.stake
    }

# ============================================================================
# NETWORK STATS
# ============================================================================

@app.get("/api/stats/network")
async def get_network_stats():
    """Get network statistics"""
    
    global facts_db
    
    # Count by domain
    domains = {}
    total_queries = 0
    total_stakes = 0.0
    
    for fact in facts_db.values():
        domain = fact.get('domain', 'unknown')
        domains[domain] = domains.get(domain, 0) + 1
        total_queries += fact.get('query_count', 0)
        total_stakes += fact.get('stake', 0)
    
    # Calculate fees
    total_fees = total_queries * 0.01
    
    return {
        "total_facts": len(facts_db),
        "domain_distribution": domains,
        "total_queries": total_queries,
        "total_fees_generated": total_fees,
        "total_staked": total_stakes,
        "fee_distribution": {
            "creators": total_fees * 0.70,
            "platform": total_fees * 0.15,
            "governance": total_fees * 0.10,
            "ethics": total_fees * 0.05
        }
    }

@app.get("/api/stats/top-facts")
async def get_top_facts(
    limit: int = 10,
    sort_by: str = "queries"  # "queries" or "earnings"
):
    """Get top facts by queries or earnings"""
    
    global facts_db
    
    facts_list = list(facts_db.values())
    
    if sort_by == "queries":
        facts_list.sort(key=lambda f: f.get('query_count', 0), reverse=True)
    elif sort_by == "earnings":
        facts_list.sort(key=lambda f: f.get('query_count', 0) * 0.007, reverse=True)
    
    top_facts = []
    for fact in facts_list[:limit]:
        queries = fact.get('query_count', 0)
        earnings = queries * 0.007
        
        top_facts.append({
            "id": fact['id'],
            "content": fact['content'][:100] + "...",
            "domain": fact['domain'],
            "creator": fact['creator'],
            "queries": queries,
            "earnings": earnings
        })
    
    return {
        "sort_by": sort_by,
        "count": len(top_facts),
        "facts": top_facts
    }

# ============================================================================
# HEALTH & INFO
# ============================================================================

@app.get("/")
async def root():
    """API information"""
    return {
        "name": "QFOT Search API with Tokenomics",
        "version": "2.0.0",
        "features": [
            "Wallet management",
            "Token faucet",
            "Microtransactions (0.01 QFOT per query)",
            "Automatic fee distribution (70/15/10/5)",
            "Fact search & submission",
            "Transaction history"
        ],
        "endpoints": {
            "wallets": "/api/wallets",
            "faucet": "/api/faucet",
            "facts": "/api/facts",
            "stats": "/api/stats",
            "docs": "/docs"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "wallet_system": "operational",
        "faucet": "operational",
        "facts_db": len(facts_db)
    }

if __name__ == "__main__":
    import uvicorn
    
    print("🚀 Starting QFOT Search API with Tokenomics...")
    print("📁 Wallet DB: /Users/richardgillespie/Documents/FoTApple/blockchain/qfot_wallets.db")
    print("🌐 API: http://localhost:8000")
    print("📚 Docs: http://localhost:8000/docs")
    
    uvicorn.run(app, host="0.0.0.0", port=8000)


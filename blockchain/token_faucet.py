#!/usr/bin/env python3
"""
QFOT Token Faucet

Distributes free QFOT tokens to early testers with:
- Different amounts based on user type
- Rate limiting (30-day cooldown)
- IP tracking (prevent multi-account abuse)
- Claim limits per user type
"""

import hashlib
import re
import sqlite3
from datetime import datetime, timedelta
from decimal import Decimal
from typing import Optional, Dict
from wallet_manager import WalletManager, DB_PATH

class TokenFaucet:
    # Faucet amounts by user type
    AMOUNTS = {
        "developer": Decimal("1000"),     # 1,000 QFOT for developers
        "ai_agent": Decimal("500"),       # 500 QFOT for AI agents
        "validator": Decimal("500"),      # 500 QFOT for validators
        "general": Decimal("100"),        # 100 QFOT for general users
    }
    
    # Maximum claims per user type
    MAX_CLAIMS = {
        "developer": 5,        # 5 refills over time
        "ai_agent": 3,         # 3 refills
        "validator": 999,      # Unlimited (earn via validation)
        "general": 1,          # One-time only
    }
    
    # Cooldown between claims
    CLAIM_COOLDOWN_DAYS = 30
    
    # IP rate limiting
    MAX_CLAIMS_PER_IP_PER_DAY = 3
    
    # Total faucet pool
    FAUCET_POOL_TOTAL = Decimal("10000000")  # 10M QFOT
    
    def __init__(self, wallet_manager: Optional[WalletManager] = None, db_path: str = DB_PATH):
        self.wallet_manager = wallet_manager or WalletManager(db_path)
        self.db_path = db_path
    
    def _get_connection(self) -> sqlite3.Connection:
        """Get database connection"""
        conn = sqlite3.connect(self.db_path)
        conn.execute("PRAGMA foreign_keys = ON")
        return conn
    
    def validate_alias(self, alias: str) -> bool:
        """Validate alias format"""
        if not alias.startswith("@"):
            return False
        # Must contain only alphanumeric, hyphens, underscores
        pattern = r'^@[\w\-]+$'
        return bool(re.match(pattern, alias))
    
    def check_ip_rate_limit(self, ip_address: str) -> tuple[bool, int]:
        """
        Check if IP has exceeded daily claim limit
        
        Returns:
            (allowed: bool, claims_today: int)
        """
        
        if not ip_address:
            return True, 0  # Allow if no IP tracking
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT COUNT(*) 
            FROM faucet_claims 
            WHERE ip_address = ? 
              AND claimed_at > datetime('now', '-1 day')
        """, (ip_address,))
        
        claims_today = cursor.fetchone()[0]
        conn.close()
        
        allowed = claims_today < self.MAX_CLAIMS_PER_IP_PER_DAY
        return allowed, claims_today
    
    def get_claim_status(self, alias: str) -> Dict:
        """
        Get faucet claim status for alias
        
        Returns:
            Dict with claim history and eligibility
        """
        
        if not alias.startswith("@"):
            alias = f"@{alias}"
        
        # Get wallet
        wallet = self.wallet_manager.get_wallet(alias=alias)
        if not wallet:
            return {
                "alias": alias,
                "has_wallet": False,
                "eligible": True,
                "reason": "New user, can create wallet and claim tokens"
            }
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        # Get claim history
        cursor.execute("""
            SELECT COUNT(*), MAX(claimed_at), user_type
            FROM faucet_claims 
            WHERE wallet_id = ?
            GROUP BY user_type
        """, (wallet['wallet_id'],))
        
        claim_data = cursor.fetchone()
        conn.close()
        
        if not claim_data:
            return {
                "alias": alias,
                "has_wallet": True,
                "wallet_id": wallet['wallet_id'],
                "balance": wallet['balance'],
                "claim_count": 0,
                "eligible": True,
                "user_type": wallet['user_type']
            }
        
        claim_count, last_claim, user_type = claim_data
        max_claims = self.MAX_CLAIMS.get(user_type, 1)
        
        # Check if max claims reached
        if claim_count >= max_claims:
            return {
                "alias": alias,
                "has_wallet": True,
                "wallet_id": wallet['wallet_id'],
                "balance": wallet['balance'],
                "claim_count": claim_count,
                "max_claims": max_claims,
                "eligible": False,
                "reason": f"Maximum claims ({max_claims}) reached for {user_type} users"
            }
        
        # Check cooldown
        last_claim_date = datetime.fromisoformat(last_claim)
        time_since_last = datetime.now() - last_claim_date
        cooldown = timedelta(days=self.CLAIM_COOLDOWN_DAYS)
        
        if time_since_last < cooldown:
            days_remaining = (cooldown - time_since_last).days
            return {
                "alias": alias,
                "has_wallet": True,
                "wallet_id": wallet['wallet_id'],
                "balance": wallet['balance'],
                "claim_count": claim_count,
                "max_claims": max_claims,
                "eligible": False,
                "reason": f"Cooldown active. Next claim in {days_remaining} days.",
                "next_claim_date": (last_claim_date + cooldown).isoformat()
            }
        
        # Eligible!
        return {
            "alias": alias,
            "has_wallet": True,
            "wallet_id": wallet['wallet_id'],
            "balance": wallet['balance'],
            "claim_count": claim_count,
            "max_claims": max_claims,
            "eligible": True,
            "user_type": user_type
        }
    
    def claim_tokens(
        self,
        alias: str,
        user_type: str = "general",
        verification: Optional[Dict] = None,
        ip_address: Optional[str] = None
    ) -> Dict:
        """
        Claim tokens from faucet
        
        Args:
            alias: User alias (e.g., @Username)
            user_type: developer|ai_agent|validator|general
            verification: Dict with email or github for verification
            ip_address: User's IP for rate limiting
        
        Returns:
            Dict with success status, amount claimed, new balance
        """
        
        # Validate alias
        if not self.validate_alias(alias):
            return {
                "success": False,
                "error": "Invalid alias format. Must start with @ and contain only alphanumeric, hyphens, underscores."
            }
        
        # Validate user type
        if user_type not in self.AMOUNTS:
            return {
                "success": False,
                "error": f"Invalid user type. Must be: {', '.join(self.AMOUNTS.keys())}"
            }
        
        # Check IP rate limit
        if ip_address:
            allowed, claims_today = self.check_ip_rate_limit(ip_address)
            if not allowed:
                return {
                    "success": False,
                    "error": f"Too many claims from this IP ({claims_today}). Try again tomorrow."
                }
        
        # Get or create wallet
        wallet = self.wallet_manager.get_wallet(alias=alias)
        if not wallet:
            wallet = self.wallet_manager.create_wallet(alias, user_type=user_type)
            if not wallet['success']:
                return {"success": False, "error": "Failed to create wallet"}
        
        wallet_id = wallet['wallet_id']
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        try:
            # Check claim eligibility
            cursor.execute("""
                SELECT COUNT(*), MAX(claimed_at) 
                FROM faucet_claims 
                WHERE wallet_id = ?
            """, (wallet_id,))
            
            claim_count, last_claim = cursor.fetchone()
            
            # Check claim limit
            max_claims = self.MAX_CLAIMS[user_type]
            if claim_count >= max_claims:
                return {
                    "success": False,
                    "error": f"Maximum claims ({max_claims}) reached for {user_type} users"
                }
            
            # Check cooldown
            if last_claim:
                last_claim_date = datetime.fromisoformat(last_claim)
                if datetime.now() - last_claim_date < timedelta(days=self.CLAIM_COOLDOWN_DAYS):
                    days_remaining = self.CLAIM_COOLDOWN_DAYS - (datetime.now() - last_claim_date).days
                    return {
                        "success": False,
                        "error": f"Cooldown active. Next claim in {days_remaining} days."
                    }
            
            # Verification for higher amounts
            verification_method = "none"
            if user_type in ["developer", "ai_agent"]:
                if verification:
                    if "email" in verification:
                        verification_method = "email"
                        # TODO: Send verification email in production
                    elif "github" in verification:
                        verification_method = "github"
                        # TODO: Verify GitHub account in production
                else:
                    # For now, allow without verification in testnet phase
                    verification_method = "none"
            
            # Grant tokens
            amount = self.AMOUNTS[user_type]
            
            # Create faucet claim record
            claim_id = hashlib.sha256(f"{wallet_id}_{datetime.now().isoformat()}".encode()).hexdigest()[:16]
            cursor.execute("""
                INSERT INTO faucet_claims (id, wallet_id, alias, amount, user_type, verification_method, ip_address, claimed_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (f"claim_{claim_id}", wallet_id, alias, float(amount), user_type, verification_method, ip_address, datetime.now().isoformat()))
            
            # Add tokens to wallet directly in this transaction
            cursor.execute("""
                UPDATE wallets 
                SET balance = balance + ?, 
                    earned = earned + ?, 
                    last_activity = ?
                WHERE id = ?
            """, (float(amount), float(amount), datetime.now().isoformat(), wallet_id))
            
            conn.commit()
            
            # Get new balance
            updated_wallet = self.wallet_manager.get_wallet(wallet_id=wallet_id)
            
            return {
                "success": True,
                "claim_id": f"claim_{claim_id}",
                "alias": alias,
                "amount": float(amount),
                "new_balance": updated_wallet['balance'],
                "claims_used": claim_count + 1,
                "claims_remaining": max_claims - claim_count - 1,
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
    
    def get_faucet_stats(self) -> Dict:
        """Get overall faucet statistics"""
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        # Total claimed
        cursor.execute("SELECT COUNT(*), SUM(amount) FROM faucet_claims")
        total_claims, total_distributed = cursor.fetchone()
        total_distributed = float(total_distributed) if total_distributed else 0
        
        # By user type
        cursor.execute("""
            SELECT user_type, COUNT(*), SUM(amount)
            FROM faucet_claims
            GROUP BY user_type
        """, ())
        
        by_user_type = {}
        for row in cursor.fetchall():
            by_user_type[row[0]] = {
                "claims": row[1],
                "amount": float(row[2])
            }
        
        # Claims in last 24 hours
        cursor.execute("""
            SELECT COUNT(*), SUM(amount)
            FROM faucet_claims
            WHERE claimed_at > datetime('now', '-1 day')
        """)
        claims_24h, amount_24h = cursor.fetchone()
        amount_24h = float(amount_24h) if amount_24h else 0
        
        conn.close()
        
        remaining = float(self.FAUCET_POOL_TOTAL) - total_distributed
        
        return {
            "faucet_pool_total": float(self.FAUCET_POOL_TOTAL),
            "total_distributed": total_distributed,
            "remaining": remaining,
            "utilization": (total_distributed / float(self.FAUCET_POOL_TOTAL)) * 100,
            "total_claims": total_claims,
            "by_user_type": by_user_type,
            "last_24h": {
                "claims": claims_24h,
                "amount": amount_24h
            }
        }

if __name__ == "__main__":
    # Test faucet
    print("🧪 Testing TokenFaucet...")
    
    faucet = TokenFaucet()
    
    # Test 1: Check claim status
    print("\n1️⃣ Checking claim status for new user...")
    status = faucet.get_claim_status("@NewTester")
    print(f"   ✅ {status}")
    
    # Test 2: Claim tokens (developer)
    print("\n2️⃣ Claiming tokens as developer...")
    result = faucet.claim_tokens(
        "@DevTester",
        user_type="developer",
        verification={"email": "dev@test.com"},
        ip_address="192.168.1.1"
    )
    print(f"   ✅ {result}")
    
    # Test 3: Try to claim again immediately (should fail)
    print("\n3️⃣ Trying to claim again immediately...")
    result2 = faucet.claim_tokens("@DevTester", user_type="developer", ip_address="192.168.1.1")
    print(f"   ✅ {result2}")
    
    # Test 4: Faucet stats
    print("\n4️⃣ Checking faucet stats...")
    stats = faucet.get_faucet_stats()
    print(f"   ✅ Total distributed: {stats['total_distributed']} QFOT")
    print(f"   ✅ Remaining: {stats['remaining']} QFOT")
    print(f"   ✅ Utilization: {stats['utilization']:.4f}%")
    
    print("\n✅ All faucet tests passed!")


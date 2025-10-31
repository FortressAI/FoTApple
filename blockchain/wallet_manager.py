#!/usr/bin/env python3
"""
QFOT Wallet Manager

Manages wallets, balances, and microtransactions for QFOT blockchain.

Features:
- Create wallets from aliases
- Track QFOT balances
- Process query payments (0.01 QFOT)
- Distribute fees: 70% creator, 15% platform, 10% governance, 5% ethics
- Full transaction history
"""

import hashlib
import json
import sqlite3
from datetime import datetime
from decimal import Decimal
from typing import Optional, Dict, List, Tuple

DB_PATH = "/Users/richardgillespie/Documents/FoTApple/blockchain/qfot_wallets.db"

class WalletManager:
    # Fee structure (as per tokenomics)
    QUERY_FEE = Decimal("0.01")
    CREATOR_SHARE = Decimal("0.70")   # 70%
    PLATFORM_SHARE = Decimal("0.15")  # 15%
    GOVERNANCE_SHARE = Decimal("0.10") # 10%
    ETHICS_SHARE = Decimal("0.05")    # 5%
    
    def __init__(self, db_path: str = DB_PATH):
        self.db_path = db_path
    
    def _get_connection(self) -> sqlite3.Connection:
        """Get database connection"""
        conn = sqlite3.connect(self.db_path)
        conn.execute("PRAGMA foreign_keys = ON")
        return conn
    
    def create_wallet(
        self, 
        alias: str, 
        email: Optional[str] = None, 
        github: Optional[str] = None,
        user_type: str = "general"
    ) -> Dict:
        """
        Create new wallet for user
        
        Args:
            alias: User alias (e.g., @Username)
            email: Optional email for verification
            github: Optional GitHub username
            user_type: general|developer|ai_agent|validator|founder
        
        Returns:
            Dict with wallet_id, alias, balance, created_at
        """
        
        # Validate alias format
        if not alias.startswith("@"):
            alias = f"@{alias}"
        
        # Generate deterministic wallet ID from alias
        wallet_id = hashlib.sha256(f"{alias}_{datetime.now().isoformat()}".encode()).hexdigest()[:16]
        wallet_id = f"wallet_{wallet_id}"
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                INSERT INTO wallets (id, alias, balance, email, github_username, user_type, created_at, last_activity)
                VALUES (?, ?, 0, ?, ?, ?, ?, ?)
            """, (wallet_id, alias, email, github, user_type, datetime.now().isoformat(), datetime.now().isoformat()))
            
            conn.commit()
            
            return {
                "success": True,
                "wallet_id": wallet_id,
                "alias": alias,
                "balance": 0.0,
                "user_type": user_type,
                "created_at": datetime.now().isoformat()
            }
        
        except sqlite3.IntegrityError:
            # Alias already exists, fetch existing wallet
            cursor.execute("SELECT id, balance, user_type, created_at FROM wallets WHERE alias = ?", (alias,))
            row = cursor.fetchone()
            
            return {
                "success": True,
                "wallet_id": row[0],
                "alias": alias,
                "balance": float(row[1]),
                "user_type": row[2],
                "created_at": row[3],
                "existing": True
            }
        
        finally:
            conn.close()
    
    def get_wallet(self, alias: Optional[str] = None, wallet_id: Optional[str] = None) -> Optional[Dict]:
        """
        Get wallet by alias or ID
        
        Args:
            alias: User alias (e.g., @Username)
            wallet_id: Wallet ID (e.g., wallet_abc123)
        
        Returns:
            Dict with wallet info or None if not found
        """
        
        if not alias and not wallet_id:
            return None
        
        if alias and not alias.startswith("@"):
            alias = f"@{alias}"
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        if alias:
            cursor.execute("SELECT * FROM wallets WHERE alias = ?", (alias,))
        else:
            cursor.execute("SELECT * FROM wallets WHERE id = ?", (wallet_id,))
        
        row = cursor.fetchone()
        conn.close()
        
        if not row:
            return None
        
        return {
            "wallet_id": row[0],
            "alias": row[1],
            "public_key": row[2],
            "balance": float(row[3]),
            "earned": float(row[4]),
            "spent": float(row[5]),
            "created_at": row[6],
            "last_activity": row[7],
            "is_verified": bool(row[8]),
            "email": row[9],
            "github": row[10],
            "user_type": row[11]
        }
    
    def update_balance(
        self, 
        wallet_id: str, 
        amount: Decimal, 
        operation: str = "add"
    ) -> bool:
        """
        Update wallet balance
        
        Args:
            wallet_id: Wallet ID
            amount: Amount to add/subtract
            operation: 'add' or 'subtract'
        
        Returns:
            True if successful
        """
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        try:
            if operation == "add":
                cursor.execute("""
                    UPDATE wallets 
                    SET balance = balance + ?, 
                        earned = earned + ?, 
                        last_activity = ?
                    WHERE id = ?
                """, (float(amount), float(amount), datetime.now().isoformat(), wallet_id))
            
            elif operation == "subtract":
                # Check sufficient balance first
                cursor.execute("SELECT balance FROM wallets WHERE id = ?", (wallet_id,))
                current_balance = Decimal(str(cursor.fetchone()[0]))
                
                if current_balance < amount:
                    return False
                
                cursor.execute("""
                    UPDATE wallets 
                    SET balance = balance - ?, 
                        spent = spent + ?, 
                        last_activity = ?
                    WHERE id = ?
                """, (float(amount), float(amount), datetime.now().isoformat(), wallet_id))
            
            conn.commit()
            return True
        
        except Exception as e:
            conn.rollback()
            print(f"Error updating balance: {e}")
            return False
        
        finally:
            conn.close()
    
    def process_query_payment(
        self, 
        user_wallet_id: str, 
        fact_id: str, 
        creator_alias: str
    ) -> Dict:
        """
        Process microtransaction for fact query
        
        Deducts 0.01 QFOT from user and distributes:
        - 70% to fact creator
        - 15% to platform
        - 10% to governance
        - 5% to ethics
        
        Args:
            user_wallet_id: User's wallet ID
            fact_id: Fact being queried
            creator_alias: Creator's alias
        
        Returns:
            Dict with success status, transaction details
        """
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        try:
            # Check user balance
            cursor.execute("SELECT balance, alias FROM wallets WHERE id = ?", (user_wallet_id,))
            result = cursor.fetchone()
            if not result:
                return {"success": False, "error": "User wallet not found"}
            
            user_balance = Decimal(str(result[0]))
            user_alias = result[1]
            
            if user_balance < self.QUERY_FEE:
                return {
                    "success": False,
                    "error": "Insufficient balance",
                    "required": float(self.QUERY_FEE),
                    "available": float(user_balance)
                }
            
            # Get creator's wallet
            if not creator_alias.startswith("@"):
                creator_alias = f"@{creator_alias}"
            
            cursor.execute("SELECT id FROM wallets WHERE alias = ?", (creator_alias,))
            creator_result = cursor.fetchone()
            if not creator_result:
                return {"success": False, "error": f"Creator wallet not found for {creator_alias}"}
            
            creator_wallet_id = creator_result[0]
            
            # Create transaction
            tx_id = hashlib.sha256(
                f"{user_wallet_id}_{fact_id}_{datetime.now().isoformat()}".encode()
            ).hexdigest()[:16]
            tx_id = f"tx_{tx_id}"
            
            metadata = json.dumps({
                "user_alias": user_alias,
                "creator_alias": creator_alias,
                "fact_id": fact_id,
                "query_fee": float(self.QUERY_FEE)
            })
            
            cursor.execute("""
                INSERT INTO transactions (id, tx_type, from_wallet, to_wallet, amount, fact_id, metadata, created_at)
                VALUES (?, 'query', ?, ?, ?, ?, ?, ?)
            """, (tx_id, user_wallet_id, creator_wallet_id, float(self.QUERY_FEE), fact_id, metadata, datetime.now().isoformat()))
            
            # Deduct from user
            cursor.execute("""
                UPDATE wallets 
                SET balance = balance - ?, spent = spent + ?, last_activity = ?
                WHERE id = ?
            """, (float(self.QUERY_FEE), float(self.QUERY_FEE), datetime.now().isoformat(), user_wallet_id))
            
            # Distribute to stakeholders
            distributions = [
                ("creator", creator_wallet_id, self.QUERY_FEE * self.CREATOR_SHARE),
                ("platform", "wallet_platform", self.QUERY_FEE * self.PLATFORM_SHARE),
                ("governance", "wallet_governance", self.QUERY_FEE * self.GOVERNANCE_SHARE),
                ("ethics", "wallet_ethics", self.QUERY_FEE * self.ETHICS_SHARE),
            ]
            
            distribution_details = {}
            
            for dist_type, wallet_id, amount in distributions:
                # Add to recipient
                cursor.execute("""
                    UPDATE wallets 
                    SET balance = balance + ?, earned = earned + ?, last_activity = ?
                    WHERE id = ?
                """, (float(amount), float(amount), datetime.now().isoformat(), wallet_id))
                
                # Record distribution
                dist_id = hashlib.sha256(f"{tx_id}_{dist_type}".encode()).hexdigest()[:16]
                cursor.execute("""
                    INSERT INTO token_distributions (id, distribution_type, from_transaction, wallet_id, amount, created_at)
                    VALUES (?, ?, ?, ?, ?, ?)
                """, (f"dist_{dist_id}", dist_type, tx_id, wallet_id, float(amount), datetime.now().isoformat()))
                
                distribution_details[dist_type] = float(amount)
            
            conn.commit()
            
            # Get new user balance
            cursor.execute("SELECT balance FROM wallets WHERE id = ?", (user_wallet_id,))
            new_balance = float(cursor.fetchone()[0])
            
            return {
                "success": True,
                "transaction_id": tx_id,
                "amount": float(self.QUERY_FEE),
                "distributions": distribution_details,
                "new_balance": new_balance,
                "creator": creator_alias
            }
        
        except Exception as e:
            conn.rollback()
            return {
                "success": False,
                "error": str(e)
            }
        
        finally:
            conn.close()
    
    def get_transaction_history(
        self, 
        wallet_id: str, 
        limit: int = 100,
        tx_type: Optional[str] = None
    ) -> List[Dict]:
        """
        Get transaction history for wallet
        
        Args:
            wallet_id: Wallet ID
            limit: Max transactions to return
            tx_type: Filter by type (query, validate, refute, transfer, faucet)
        
        Returns:
            List of transaction dicts
        """
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        if tx_type:
            cursor.execute("""
                SELECT * FROM transactions 
                WHERE (from_wallet = ? OR to_wallet = ?) AND tx_type = ?
                ORDER BY created_at DESC 
                LIMIT ?
            """, (wallet_id, wallet_id, tx_type, limit))
        else:
            cursor.execute("""
                SELECT * FROM transactions 
                WHERE from_wallet = ? OR to_wallet = ?
                ORDER BY created_at DESC 
                LIMIT ?
            """, (wallet_id, wallet_id, limit))
        
        rows = cursor.fetchall()
        conn.close()
        
        transactions = []
        for row in rows:
            transactions.append({
                "id": row[0],
                "type": row[1],
                "from_wallet": row[2],
                "to_wallet": row[3],
                "amount": float(row[4]),
                "fee": float(row[5]),
                "fact_id": row[6],
                "metadata": json.loads(row[7]) if row[7] else {},
                "created_at": row[8]
            })
        
        return transactions
    
    def get_earnings_stats(self, wallet_id: str) -> Dict:
        """
        Get earning statistics for wallet
        
        Args:
            wallet_id: Wallet ID
        
        Returns:
            Dict with earnings breakdown
        """
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        # Get wallet info
        cursor.execute("""
            SELECT alias, balance, earned, spent 
            FROM wallets WHERE id = ?
        """, (wallet_id,))
        wallet_row = cursor.fetchone()
        
        if not wallet_row:
            return {"error": "Wallet not found"}
        
        # Get earnings by type
        cursor.execute("""
            SELECT distribution_type, SUM(amount) 
            FROM token_distributions 
            WHERE wallet_id = ?
            GROUP BY distribution_type
        """, (wallet_id,))
        
        earnings_by_type = {row[0]: float(row[1]) for row in cursor.fetchall()}
        
        # Get transaction counts
        cursor.execute("""
            SELECT tx_type, COUNT(*) 
            FROM transactions 
            WHERE from_wallet = ? OR to_wallet = ?
            GROUP BY tx_type
        """, (wallet_id, wallet_id))
        
        tx_counts = {row[0]: row[1] for row in cursor.fetchall()}
        
        conn.close()
        
        return {
            "alias": wallet_row[0],
            "balance": float(wallet_row[1]),
            "total_earned": float(wallet_row[2]),
            "total_spent": float(wallet_row[3]),
            "net": float(wallet_row[2]) - float(wallet_row[3]),
            "earnings_by_type": earnings_by_type,
            "transaction_counts": tx_counts
        }

if __name__ == "__main__":
    # Test wallet manager
    print("🧪 Testing WalletManager...")
    
    manager = WalletManager()
    
    # Test 1: Create wallet
    print("\n1️⃣ Creating test wallet...")
    wallet = manager.create_wallet("@TestUser", user_type="general")
    print(f"   ✅ {wallet}")
    
    # Test 2: Get wallet
    print("\n2️⃣ Retrieving wallet...")
    fetched = manager.get_wallet(alias="@TestUser")
    print(f"   ✅ Balance: {fetched['balance']} QFOT")
    
    # Test 3: Add balance
    print("\n3️⃣ Adding 100 QFOT...")
    manager.update_balance(fetched['wallet_id'], Decimal("100"), "add")
    updated = manager.get_wallet(alias="@TestUser")
    print(f"   ✅ New balance: {updated['balance']} QFOT")
    
    # Test 4: Process query payment
    print("\n4️⃣ Processing query payment...")
    payment = manager.process_query_payment(
        updated['wallet_id'],
        "fact_test_123",
        "@Domain-Packs.md"
    )
    print(f"   ✅ Payment: {payment}")
    
    # Test 5: Check earnings
    print("\n5️⃣ Checking earnings...")
    founder_stats = manager.get_earnings_stats("wallet_founder")
    print(f"   ✅ @Domain-Packs.md earned: {founder_stats['total_earned']} QFOT")
    
    print("\n✅ All tests passed!")


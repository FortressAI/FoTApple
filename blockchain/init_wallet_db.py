#!/usr/bin/env python3
"""
QFOT Wallet Database Initialization

Creates SQLite database with schema for:
- Wallets (users, balances, aliases)
- Transactions (payments, transfers)
- Token distributions (fee splits)
- Faucet claims (free token grants)
"""

import sqlite3
import os
from datetime import datetime

DB_PATH = "/Users/richardgillespie/Documents/FoTApple/blockchain/qfot_wallets.db"

def init_database():
    """Initialize QFOT wallet database with complete schema"""
    
    print("🏗️  Initializing QFOT Wallet Database...")
    print(f"📁 Location: {DB_PATH}")
    
    # Remove existing database if present (for clean slate)
    if os.path.exists(DB_PATH):
        backup_path = f"{DB_PATH}.backup.{int(datetime.now().timestamp())}"
        os.rename(DB_PATH, backup_path)
        print(f"📦 Backed up existing database to: {backup_path}")
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Enable foreign keys
    cursor.execute("PRAGMA foreign_keys = ON")
    
    print("\n📊 Creating tables...")
    
    # Wallets table
    print("   ✅ wallets")
    cursor.execute("""
        CREATE TABLE wallets (
            id VARCHAR(64) PRIMARY KEY,
            alias VARCHAR(100) UNIQUE NOT NULL,
            public_key VARCHAR(256),
            balance DECIMAL(20, 8) DEFAULT 0,
            earned DECIMAL(20, 8) DEFAULT 0,
            spent DECIMAL(20, 8) DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_activity TIMESTAMP,
            is_verified BOOLEAN DEFAULT 0,
            email VARCHAR(255),
            github_username VARCHAR(255),
            user_type VARCHAR(50) DEFAULT 'general'
        )
    """)
    
    # Transactions table
    print("   ✅ transactions")
    cursor.execute("""
        CREATE TABLE transactions (
            id VARCHAR(64) PRIMARY KEY,
            tx_type VARCHAR(50) NOT NULL,
            from_wallet VARCHAR(64),
            to_wallet VARCHAR(64),
            amount DECIMAL(20, 8) NOT NULL,
            fee DECIMAL(20, 8) DEFAULT 0,
            fact_id VARCHAR(64),
            metadata TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (from_wallet) REFERENCES wallets(id),
            FOREIGN KEY (to_wallet) REFERENCES wallets(id)
        )
    """)
    
    # Token distribution ledger
    print("   ✅ token_distributions")
    cursor.execute("""
        CREATE TABLE token_distributions (
            id VARCHAR(64) PRIMARY KEY,
            distribution_type VARCHAR(50) NOT NULL,
            from_transaction VARCHAR(64) NOT NULL,
            wallet_id VARCHAR(64) NOT NULL,
            amount DECIMAL(20, 8) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (from_transaction) REFERENCES transactions(id),
            FOREIGN KEY (wallet_id) REFERENCES wallets(id)
        )
    """)
    
    # Faucet claims
    print("   ✅ faucet_claims")
    cursor.execute("""
        CREATE TABLE faucet_claims (
            id VARCHAR(64) PRIMARY KEY,
            wallet_id VARCHAR(64) NOT NULL,
            alias VARCHAR(100) NOT NULL,
            amount DECIMAL(20, 8) NOT NULL,
            user_type VARCHAR(50) NOT NULL,
            verification_method VARCHAR(50),
            ip_address VARCHAR(45),
            claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (wallet_id) REFERENCES wallets(id)
        )
    """)
    
    print("\n🔍 Creating indexes...")
    
    # Indexes for performance
    cursor.execute("CREATE INDEX idx_wallets_alias ON wallets(alias)")
    cursor.execute("CREATE INDEX idx_transactions_from ON transactions(from_wallet)")
    cursor.execute("CREATE INDEX idx_transactions_to ON transactions(to_wallet)")
    cursor.execute("CREATE INDEX idx_transactions_type ON transactions(tx_type)")
    cursor.execute("CREATE INDEX idx_transactions_created ON transactions(created_at)")
    cursor.execute("CREATE INDEX idx_transactions_fact ON transactions(fact_id)")
    cursor.execute("CREATE INDEX idx_faucet_ip ON faucet_claims(ip_address, claimed_at)")
    cursor.execute("CREATE INDEX idx_faucet_wallet ON faucet_claims(wallet_id)")
    
    print("   ✅ 8 indexes created")
    
    print("\n🏦 Creating system wallets...")
    
    # Create system wallets for fee distribution
    system_wallets = [
        ("wallet_platform", "@QFOT-Platform", "platform"),
        ("wallet_governance", "@QFOT-Governance", "governance"),
        ("wallet_ethics", "@QFOT-Ethics", "ethics"),
        ("wallet_treasury", "@QFOT-Treasury", "treasury"),
    ]
    
    for wallet_id, alias, user_type in system_wallets:
        cursor.execute("""
            INSERT INTO wallets (id, alias, balance, user_type, created_at)
            VALUES (?, ?, 0, ?, ?)
        """, (wallet_id, alias, user_type, datetime.now().isoformat()))
        print(f"   ✅ {alias} ({wallet_id})")
    
    # Create founder wallet
    cursor.execute("""
        INSERT INTO wallets (id, alias, balance, user_type, created_at)
        VALUES ('wallet_founder', '@Domain-Packs.md', 10000, 'founder', ?)
    """, (datetime.now().isoformat(),))
    print(f"   ✅ @Domain-Packs.md (wallet_founder) - 10,000 QFOT initial balance")
    
    conn.commit()
    
    print("\n📊 Database Statistics:")
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = cursor.fetchall()
    print(f"   Tables: {len(tables)}")
    
    cursor.execute("SELECT name FROM sqlite_master WHERE type='index'")
    indexes = cursor.fetchall()
    print(f"   Indexes: {len(indexes)}")
    
    cursor.execute("SELECT COUNT(*) FROM wallets")
    wallet_count = cursor.fetchone()[0]
    print(f"   Initial wallets: {wallet_count}")
    
    conn.close()
    
    print("\n✅ Database initialized successfully!")
    print(f"📁 {DB_PATH}")
    print("\n🎯 Ready for tokenomics!")

if __name__ == "__main__":
    init_database()


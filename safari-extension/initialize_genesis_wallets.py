#!/usr/bin/env python3
"""
QFOT Genesis Wallet Initialization
Creates all genesis wallets and distributes initial 1 billion QFOT tokens
"""

import sqlite3
import hashlib
import json
from datetime import datetime
import secrets

# Database path (update to match your blockchain setup)
DB_PATH = "../blockchain/qfot_wallets.db"

# Total supply: 1 billion QFOT
TOTAL_SUPPLY = 1_000_000_000

# Genesis wallet definitions
GENESIS_WALLETS = [
    # Creator
    ("@Domain-Packs.md", "creator", 200_000_000, "Creator & Founder wallet"),
    
    # Miners (7 total, 20M each)
    ("@MegaPublicFlourishingBot", "miner", 20_000_000, "Public flourishing fact miner (hourly)"),
    ("@PublicFlourishingBot", "miner", 20_000_000, "Original public flourishing miner"),
    ("@QuantumFoTECBot", "miner", 20_000_000, "Quantum supremacy research miner (weekly)"),
    ("@K18EducationBot", "miner", 20_000_000, "K-18 education fact miner"),
    ("@MedicalSpecBot", "miner", 20_000_000, "Medical specializations miner"),
    ("@LegalJurisdictionsBot", "miner", 20_000_000, "Legal jurisdictions miner"),
    ("@LiveResearchBot", "miner", 20_000_000, "Live research integration miner"),
    
    # Validators (3 nodes, 50M each)
    ("node1@94.130.97.66", "validator", 50_000_000, "Primary validator node (Hetzner)"),
    ("node2@46.224.42.20", "validator", 50_000_000, "Secondary validator node (Hetzner)"),
    ("local@validator", "validator", 50_000_000, "Local validator node (Mac)"),
    
    # Platform
    ("@PlatformTreasury", "platform", 150_000_000, "Platform treasury (15% of all transactions)"),
    ("@GovernanceDAO", "governance", 100_000_000, "Governance DAO (10% of all transactions)"),
    ("@EthicsCommittee", "ethics", 50_000_000, "Ethics Committee (5% of all transactions)"),
    ("@CommunityFaucet", "community", 100_000_000, "Community faucet for new users"),
    ("@ExchangeLiquidity", "exchange", 110_000_000, "Exchange liquidity pool (Coinbase, etc.)")
]

def generate_ed25519_keypair():
    """Generate Ed25519 key pair (simplified for demo)"""
    # In production, use proper Ed25519 library
    private_key = secrets.token_hex(32)
    public_key = hashlib.sha256(private_key.encode()).hexdigest()
    return public_key, private_key

def derive_address(public_key):
    """Derive QFOT address from public key"""
    hash_result = hashlib.sha256(public_key.encode()).hexdigest()
    return "QFOT" + hash_result[:40]

def initialize_database():
    """Create wallet database schema"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    # Create wallets table
    c.execute('''
        CREATE TABLE IF NOT EXISTS wallets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            alias TEXT UNIQUE NOT NULL,
            wallet_type TEXT NOT NULL,
            address TEXT UNIQUE NOT NULL,
            public_key TEXT NOT NULL,
            private_key TEXT NOT NULL,
            balance REAL DEFAULT 0,
            created_at INTEGER NOT NULL,
            last_accessed INTEGER,
            email TEXT,
            phone TEXT,
            name TEXT,
            kyc_status TEXT DEFAULT 'unverified',
            is_admin BOOLEAN DEFAULT 0,
            is_validator BOOLEAN DEFAULT 0,
            is_faucet_eligible BOOLEAN DEFAULT 1,
            last_faucet_claim INTEGER
        )
    ''')
    
    # Create transactions table
    c.execute('''
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tx_hash TEXT UNIQUE NOT NULL,
            from_address TEXT NOT NULL,
            to_address TEXT NOT NULL,
            amount REAL NOT NULL,
            fee REAL NOT NULL,
            timestamp INTEGER NOT NULL,
            block_number INTEGER,
            status TEXT DEFAULT 'pending',
            signature TEXT NOT NULL
        )
    ''')
    
    conn.commit()
    conn.close()
    print("✅ Database schema created")

def create_genesis_wallets():
    """Create all genesis wallets and distribute tokens"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    total_allocated = 0
    created_wallets = []
    
    print("\n📦 Creating Genesis Wallets...")
    print("=" * 80)
    
    for alias, wallet_type, balance, description in GENESIS_WALLETS:
        # Generate keys
        public_key, private_key = generate_ed25519_keypair()
        address = derive_address(public_key)
        
        # Set validator flag
        is_validator = 1 if wallet_type == "validator" else 0
        is_admin = 1 if alias == "@Domain-Packs.md" else 0
        
        # Insert wallet
        c.execute('''
            INSERT INTO wallets (
                alias, wallet_type, address, public_key, private_key, 
                balance, created_at, is_admin, is_validator
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            alias, wallet_type, address, public_key, private_key,
            balance, int(datetime.now().timestamp()), is_admin, is_validator
        ))
        
        total_allocated += balance
        created_wallets.append({
            'alias': alias,
            'type': wallet_type,
            'address': address,
            'balance': balance,
            'description': description
        })
        
        icon = {
            'creator': '👤',
            'miner': '⛏️',
            'validator': '✅',
            'platform': '🏛️',
            'governance': '🗳️',
            'ethics': '⚖️',
            'community': '❤️',
            'exchange': '💱'
        }.get(wallet_type, '💼')
        
        print(f"{icon} {alias:30s} {balance:>15,} QFOT  ({wallet_type})")
        print(f"   Address: {address}")
        print(f"   {description}")
        print()
    
    conn.commit()
    conn.close()
    
    print("=" * 80)
    print(f"✅ Created {len(created_wallets)} genesis wallets")
    print(f"💰 Total allocated: {total_allocated:,} QFOT")
    print(f"📊 Total supply: {TOTAL_SUPPLY:,} QFOT")
    
    if total_allocated == TOTAL_SUPPLY:
        print("✅ Distribution matches total supply!")
    else:
        print(f"⚠️  Difference: {TOTAL_SUPPLY - total_allocated:,} QFOT")
    
    # Export wallet information (public keys only)
    export_data = {
        'total_supply': TOTAL_SUPPLY,
        'genesis_timestamp': int(datetime.now().timestamp()),
        'wallets': [
            {
                'alias': w['alias'],
                'type': w['type'],
                'address': w['address'],
                'balance': w['balance'],
                'description': w['description']
            }
            for w in created_wallets
        ]
    }
    
    with open('genesis_wallets.json', 'w') as f:
        json.dump(export_data, f, indent=2)
    
    print(f"\n📄 Genesis wallet info exported to: genesis_wallets.json")
    print("\n⚠️  SECURITY WARNING:")
    print("   Private keys are stored in the database.")
    print("   Keep the database file secure and backed up!")
    print("   Never share private keys with anyone!")

def display_distribution_summary():
    """Display token distribution summary"""
    print("\n📊 QFOT Token Distribution Summary")
    print("=" * 80)
    
    by_type = {}
    for alias, wallet_type, balance, desc in GENESIS_WALLETS:
        if wallet_type not in by_type:
            by_type[wallet_type] = {'count': 0, 'total': 0, 'wallets': []}
        by_type[wallet_type]['count'] += 1
        by_type[wallet_type]['total'] += balance
        by_type[wallet_type]['wallets'].append(alias)
    
    for wallet_type, data in sorted(by_type.items()):
        percent = (data['total'] / TOTAL_SUPPLY) * 100
        print(f"\n{wallet_type.upper()}:")
        print(f"  Count: {data['count']} wallets")
        print(f"  Total: {data['total']:,} QFOT ({percent:.1f}%)")
        for wallet in data['wallets']:
            print(f"    • {wallet}")

if __name__ == "__main__":
    print("=" * 80)
    print("⚛️  QFOT GENESIS WALLET INITIALIZATION")
    print("=" * 80)
    print(f"Total Supply: {TOTAL_SUPPLY:,} QFOT (1 billion)")
    print(f"Database: {DB_PATH}")
    print("=" * 80)
    
    response = input("\n⚠️  This will create genesis wallets. Continue? (yes/no): ")
    if response.lower() != 'yes':
        print("Cancelled.")
        exit()
    
    # Initialize database
    initialize_database()
    
    # Display distribution summary
    display_distribution_summary()
    
    # Create wallets
    create_genesis_wallets()
    
    print("\n" + "=" * 80)
    print("✅ GENESIS WALLET INITIALIZATION COMPLETE!")
    print("=" * 80)
    print("\nNext steps:")
    print("  1. Backup qfot_wallets.db (contains private keys!)")
    print("  2. Install QFOT Wallet Safari extension")
    print("  3. Import creator wallet (@Domain-Packs.md)")
    print("  4. Start miners and validators")
    print("  5. Deploy to production nodes")
    print("\n🚀 Ready to launch QFOT mainnet!")
    print("=" * 80)


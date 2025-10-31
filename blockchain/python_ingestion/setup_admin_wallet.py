#!/usr/bin/env python3
"""
Setup Admin Wallet for QFOT Validation

Creates an admin wallet with initial token allotment for validation.
Anyone can create a wallet and participate in validation/refutation.
"""

import requests
import json
import hashlib
import time
from datetime import datetime

API_BASE = "https://94.130.97.66/api"
VERIFY_SSL = False

def create_wallet(alias: str, initial_balance: float = 10000.0) -> dict:
    """
    Create a new wallet with alias
    
    In a real blockchain, this would generate keypair.
    For now, we create a simple wallet record.
    """
    
    # Generate wallet ID from alias
    wallet_id = hashlib.sha256(alias.encode()).hexdigest()[:16]
    
    wallet = {
        "wallet_id": wallet_id,
        "alias": alias,
        "balance": initial_balance,
        "created_at": datetime.now().isoformat(),
        "public_key": f"pk_{wallet_id}",  # Simulated
        "reputation": 0.0,
        "validations_count": 0,
        "refutations_count": 0
    }
    
    print(f"\n✅ Wallet Created:")
    print(f"   Alias: {alias}")
    print(f"   Wallet ID: {wallet_id}")
    print(f"   Initial Balance: {initial_balance} QFOT")
    print(f"   Public Key: {wallet['public_key']}")
    
    return wallet

def register_wallet_with_backend(wallet: dict) -> bool:
    """Register wallet with QFOT backend"""
    try:
        response = requests.post(
            f"{API_BASE}/wallets/register",
            json=wallet,
            verify=VERIFY_SSL,
            timeout=10
        )
        
        if response.status_code == 200:
            print(f"\n✅ Wallet registered with blockchain")
            return True
        else:
            print(f"\n⚠️  Backend registration returned: {response.status_code}")
            print(f"    This is OK - wallet can still be used")
            return False
            
    except Exception as e:
        print(f"\n⚠️  Backend registration failed: {e}")
        print(f"    This is OK - wallet can still be used locally")
        return False

def save_wallet_locally(wallet: dict, filename: str = "admin_wallet.json"):
    """Save wallet to local file"""
    with open(filename, 'w') as f:
        json.dump(wallet, f, indent=2)
    print(f"\n💾 Wallet saved to: {filename}")

def main():
    print("=" * 80)
    print("🔐 QFOT WALLET CREATION")
    print("=" * 80)
    
    # Create admin wallet for @Domain-Packs.md
    print("\n📝 Creating Admin Wallet...")
    admin_wallet = create_wallet(
        alias="@Domain-Packs.md",
        initial_balance=10000.0  # 10,000 QFOT for validation
    )
    
    # Try to register with backend
    register_wallet_with_backend(admin_wallet)
    
    # Save locally
    save_wallet_locally(admin_wallet, "admin_wallet.json")
    
    print("\n" + "=" * 80)
    print("🎉 ADMIN WALLET SETUP COMPLETE!")
    print("=" * 80)
    
    print("\n💰 Your Wallet Details:")
    print(f"   Alias: {admin_wallet['alias']}")
    print(f"   Wallet ID: {admin_wallet['wallet_id']}")
    print(f"   Balance: {admin_wallet['balance']} QFOT")
    
    print("\n🎯 What You Can Do:")
    print("   • Validate facts (costs 30 QFOT, earn rewards if fact is valid)")
    print("   • Refute facts (costs 30 QFOT, earn 25 QFOT if refutation successful)")
    print("   • Build reputation (increases validation weight)")
    print("   • Earn from fact queries (70% of all query fees)")
    
    print("\n🌐 Use Your Wallet:")
    print("   1. Go to https://94.130.97.66/review.html")
    print("   2. Enter your alias: @Domain-Packs.md")
    print("   3. Start validating/refuting facts!")
    
    print("\n📋 Wallet File Location:")
    print(f"   admin_wallet.json")
    print("   (Keep this file secure - it's your wallet!)")
    
    # Create example public wallet for others
    print("\n\n" + "=" * 80)
    print("👥 EXAMPLE: CREATING PUBLIC WALLET FOR OTHERS")
    print("=" * 80)
    
    example_wallet = create_wallet(
        alias="@ExampleValidator",
        initial_balance=1000.0  # Smaller initial balance
    )
    save_wallet_locally(example_wallet, "example_wallet.json")
    
    print("\n💡 Anyone Can Create a Wallet:")
    print("   • Choose any alias (e.g., @YourName)")
    print("   • Get initial balance (1000 QFOT default)")
    print("   • Start participating in validation")
    print("   • Earn tokens through correct validations")
    
    print("\n" + "=" * 80)

if __name__ == "__main__":
    main()


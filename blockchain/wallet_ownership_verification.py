#!/usr/bin/env python3
"""
QFOT Wallet Ownership Verification System

Ensures users actually own/control the wallet addresses they claim.
Uses Ed25519 digital signatures for cryptographic proof.

NO SIMULATIONS - Real cryptographic verification only.
"""

import hashlib
import json
import time
import secrets
from datetime import datetime, timedelta
from typing import Dict, Optional, Tuple
from dataclasses import dataclass
from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization
from cryptography.exceptions import InvalidSignature

@dataclass
class WalletChallenge:
    """Challenge issued to prove wallet ownership"""
    wallet_address: str
    challenge_text: str
    challenge_hash: str
    issued_at: float
    expires_at: float
    nonce: str
    
    def is_expired(self) -> bool:
        """Check if challenge has expired"""
        return time.time() > self.expires_at
    
    def to_dict(self) -> dict:
        """Convert to dictionary"""
        return {
            "wallet_address": self.wallet_address,
            "challenge_text": self.challenge_text,
            "challenge_hash": self.challenge_hash,
            "issued_at": self.issued_at,
            "expires_at": self.expires_at,
            "nonce": self.nonce
        }


@dataclass
class VerifiedSession:
    """Verified wallet session"""
    wallet_address: str
    alias: str
    public_key: bytes
    verified_at: float
    expires_at: float
    session_token: str
    
    def is_expired(self) -> bool:
        """Check if session has expired"""
        return time.time() > self.expires_at
    
    def to_dict(self) -> dict:
        """Convert to dictionary"""
        return {
            "wallet_address": self.wallet_address,
            "alias": self.alias,
            "public_key": self.public_key.hex(),
            "verified_at": self.verified_at,
            "expires_at": self.expires_at,
            "session_token": self.session_token
        }


class WalletOwnershipVerifier:
    """
    Cryptographic wallet ownership verification
    
    Process:
    1. User claims wallet address
    2. System generates random challenge
    3. User signs challenge with private key
    4. System verifies signature with public key
    5. If valid, create verified session
    """
    
    def __init__(self, challenge_expiry_seconds: int = 300, session_expiry_seconds: int = 86400):
        """
        Initialize verifier
        
        Args:
            challenge_expiry_seconds: How long challenges are valid (default: 5 minutes)
            session_expiry_seconds: How long sessions last (default: 24 hours)
        """
        self.challenge_expiry_seconds = challenge_expiry_seconds
        self.session_expiry_seconds = session_expiry_seconds
        
        # Active challenges (in production, store in Redis/database)
        self.challenges: Dict[str, WalletChallenge] = {}
        
        # Active sessions (in production, store in Redis/database)
        self.sessions: Dict[str, VerifiedSession] = {}
    
    def generate_challenge(self, wallet_address: str, alias: str) -> WalletChallenge:
        """
        Generate a challenge to prove wallet ownership
        
        Args:
            wallet_address: The wallet address to verify
            alias: User's alias (e.g., "@Clinician")
        
        Returns:
            WalletChallenge object
        """
        # Generate random nonce
        nonce = secrets.token_hex(32)
        
        # Create challenge text
        timestamp = int(time.time())
        challenge_text = (
            f"QFOT Wallet Verification Challenge\n"
            f"Wallet: {wallet_address}\n"
            f"Alias: {alias}\n"
            f"Timestamp: {timestamp}\n"
            f"Nonce: {nonce}\n"
            f"\n"
            f"By signing this message, I prove ownership of this wallet."
        )
        
        # Hash the challenge
        challenge_hash = hashlib.sha256(challenge_text.encode()).hexdigest()
        
        # Create challenge object
        now = time.time()
        challenge = WalletChallenge(
            wallet_address=wallet_address,
            challenge_text=challenge_text,
            challenge_hash=challenge_hash,
            issued_at=now,
            expires_at=now + self.challenge_expiry_seconds,
            nonce=nonce
        )
        
        # Store challenge (in production: Redis with TTL)
        self.challenges[wallet_address] = challenge
        
        print(f"✅ Challenge generated for {wallet_address}")
        print(f"   Nonce: {nonce[:16]}...")
        print(f"   Expires in: {self.challenge_expiry_seconds} seconds")
        
        return challenge
    
    def verify_signature(
        self,
        wallet_address: str,
        signature: bytes,
        public_key_bytes: bytes
    ) -> Tuple[bool, Optional[str]]:
        """
        Verify the signature proves wallet ownership
        
        Args:
            wallet_address: Claimed wallet address
            signature: Ed25519 signature bytes
            public_key_bytes: Ed25519 public key bytes
        
        Returns:
            (success: bool, error_message: Optional[str])
        """
        # Get challenge
        challenge = self.challenges.get(wallet_address)
        if not challenge:
            return False, "No challenge found for this wallet"
        
        # Check expiry
        if challenge.is_expired():
            del self.challenges[wallet_address]
            return False, "Challenge has expired"
        
        # Verify wallet address matches public key
        # In a real system, wallet address would be derived from public key
        derived_address = self._derive_wallet_address(public_key_bytes)
        if derived_address != wallet_address:
            return False, f"Public key does not match wallet address"
        
        try:
            # Load public key
            public_key = ed25519.Ed25519PublicKey.from_public_bytes(public_key_bytes)
            
            # Verify signature
            public_key.verify(signature, challenge.challenge_text.encode())
            
            print(f"✅ Signature verified for {wallet_address}")
            print(f"   Challenge: {challenge.challenge_hash[:16]}...")
            print(f"   Signature: {signature.hex()[:32]}...")
            
            # Remove used challenge
            del self.challenges[wallet_address]
            
            return True, None
            
        except InvalidSignature:
            return False, "Invalid signature - wallet ownership not proven"
        except Exception as e:
            return False, f"Verification error: {str(e)}"
    
    def create_verified_session(
        self,
        wallet_address: str,
        alias: str,
        public_key_bytes: bytes
    ) -> VerifiedSession:
        """
        Create a verified session after successful signature verification
        
        Args:
            wallet_address: Verified wallet address
            alias: User's alias
            public_key_bytes: Verified public key
        
        Returns:
            VerifiedSession object
        """
        # Generate session token
        session_data = f"{wallet_address}:{alias}:{time.time()}:{secrets.token_hex(32)}"
        session_token = hashlib.sha256(session_data.encode()).hexdigest()
        
        # Create session
        now = time.time()
        session = VerifiedSession(
            wallet_address=wallet_address,
            alias=alias,
            public_key=public_key_bytes,
            verified_at=now,
            expires_at=now + self.session_expiry_seconds,
            session_token=session_token
        )
        
        # Store session (in production: Redis with TTL)
        self.sessions[session_token] = session
        
        print(f"✅ Verified session created for {alias}")
        print(f"   Wallet: {wallet_address}")
        print(f"   Token: {session_token[:32]}...")
        print(f"   Expires: {datetime.fromtimestamp(session.expires_at)}")
        
        return session
    
    def verify_session(self, session_token: str) -> Tuple[bool, Optional[VerifiedSession]]:
        """
        Verify a session token is valid
        
        Args:
            session_token: Session token to verify
        
        Returns:
            (valid: bool, session: Optional[VerifiedSession])
        """
        session = self.sessions.get(session_token)
        
        if not session:
            return False, None
        
        if session.is_expired():
            del self.sessions[session_token]
            return False, None
        
        return True, session
    
    def revoke_session(self, session_token: str) -> bool:
        """
        Revoke a session (logout)
        
        Args:
            session_token: Token to revoke
        
        Returns:
            True if session was found and revoked
        """
        if session_token in self.sessions:
            session = self.sessions[session_token]
            del self.sessions[session_token]
            print(f"✅ Session revoked for {session.alias}")
            return True
        return False
    
    def _derive_wallet_address(self, public_key_bytes: bytes) -> str:
        """
        Derive wallet address from public key
        
        In a real system, this would use proper address derivation (e.g., Bitcoin bech32)
        For QFOT, we use SHA256 + hex encoding
        
        Args:
            public_key_bytes: Ed25519 public key bytes
        
        Returns:
            Wallet address string
        """
        # Hash public key
        hash1 = hashlib.sha256(public_key_bytes).digest()
        hash2 = hashlib.sha256(hash1).digest()
        
        # Take first 20 bytes and encode as hex with prefix
        address_bytes = hash2[:20]
        address = "qfot1" + address_bytes.hex()
        
        return address


class WalletManager:
    """
    Manage wallet creation and key storage
    
    In production, private keys should NEVER be stored on server.
    Users should manage their own keys via:
    - Hardware wallets (Ledger, Trezor)
    - Software wallets (MetaMask-style browser extension)
    - Mobile wallets with Secure Enclave
    """
    
    @staticmethod
    def create_wallet(alias: str) -> Dict[str, str]:
        """
        Create a new Ed25519 wallet
        
        ⚠️ WARNING: In production, this should ONLY run client-side.
        Private keys must NEVER be transmitted or stored on servers.
        
        Args:
            alias: User's alias
        
        Returns:
            Dictionary with wallet info (excluding private key in production)
        """
        # Generate Ed25519 key pair
        private_key = ed25519.Ed25519PrivateKey.generate()
        public_key = private_key.public_key()
        
        # Serialize keys
        private_key_bytes = private_key.private_bytes(
            encoding=serialization.Encoding.Raw,
            format=serialization.PrivateFormat.Raw,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        public_key_bytes = public_key.public_bytes(
            encoding=serialization.Encoding.Raw,
            format=serialization.PublicFormat.Raw
        )
        
        # Derive wallet address
        verifier = WalletOwnershipVerifier()
        wallet_address = verifier._derive_wallet_address(public_key_bytes)
        
        print(f"✅ Wallet created for {alias}")
        print(f"   Address: {wallet_address}")
        print(f"   Public Key: {public_key_bytes.hex()[:32]}...")
        print(f"   ⚠️  KEEP PRIVATE KEY SECURE!")
        
        return {
            "alias": alias,
            "wallet_address": wallet_address,
            "public_key": public_key_bytes.hex(),
            "private_key": private_key_bytes.hex(),  # ⚠️ NEVER send to server in production!
            "created_at": datetime.now().isoformat()
        }
    
    @staticmethod
    def sign_challenge(private_key_hex: str, challenge_text: str) -> bytes:
        """
        Sign a challenge with private key
        
        ⚠️ This should ONLY run client-side in production
        
        Args:
            private_key_hex: Private key as hex string
            challenge_text: Challenge text to sign
        
        Returns:
            Signature bytes
        """
        # Load private key
        private_key_bytes = bytes.fromhex(private_key_hex)
        private_key = ed25519.Ed25519PrivateKey.from_private_bytes(private_key_bytes)
        
        # Sign challenge
        signature = private_key.sign(challenge_text.encode())
        
        print(f"✅ Challenge signed")
        print(f"   Signature: {signature.hex()[:32]}...")
        
        return signature


def demo_wallet_ownership_flow():
    """
    Demonstrate complete wallet ownership verification flow
    """
    print("=" * 80)
    print("QFOT WALLET OWNERSHIP VERIFICATION DEMO")
    print("=" * 80)
    print()
    
    # Step 1: User creates wallet (CLIENT-SIDE ONLY in production)
    print("📱 STEP 1: User creates wallet (client-side)")
    print("-" * 80)
    wallet = WalletManager.create_wallet("@Clinician")
    wallet_address = wallet["wallet_address"]
    private_key_hex = wallet["private_key"]
    public_key_hex = wallet["public_key"]
    print()
    
    # Step 2: User requests challenge from server
    print("🌐 STEP 2: User requests verification challenge")
    print("-" * 80)
    verifier = WalletOwnershipVerifier()
    challenge = verifier.generate_challenge(wallet_address, "@Clinician")
    print(f"\n📋 Challenge text:\n{challenge.challenge_text}\n")
    
    # Step 3: User signs challenge (CLIENT-SIDE ONLY in production)
    print("📱 STEP 3: User signs challenge (client-side)")
    print("-" * 80)
    signature = WalletManager.sign_challenge(private_key_hex, challenge.challenge_text)
    print()
    
    # Step 4: User submits signature to server for verification
    print("🌐 STEP 4: Server verifies signature")
    print("-" * 80)
    success, error = verifier.verify_signature(
        wallet_address,
        signature,
        bytes.fromhex(public_key_hex)
    )
    
    if success:
        print("✅ SIGNATURE VALID - Wallet ownership proven!")
        print()
        
        # Step 5: Create verified session
        print("🌐 STEP 5: Create verified session")
        print("-" * 80)
        session = verifier.create_verified_session(
            wallet_address,
            "@Clinician",
            bytes.fromhex(public_key_hex)
        )
        print()
        
        # Step 6: Use session token for authenticated requests
        print("📱 STEP 6: Make authenticated requests")
        print("-" * 80)
        valid, verified_session = verifier.verify_session(session.session_token)
        if valid:
            print(f"✅ Session valid for {verified_session.alias}")
            print(f"   Wallet: {verified_session.wallet_address}")
            print()
        
        # Step 7: Logout (revoke session)
        print("📱 STEP 7: User logs out")
        print("-" * 80)
        verifier.revoke_session(session.session_token)
        print()
        
    else:
        print(f"❌ SIGNATURE INVALID: {error}")
        print()
    
    print("=" * 80)
    print("✅ DEMO COMPLETE - Zero simulations, real cryptography!")
    print("=" * 80)


if __name__ == "__main__":
    demo_wallet_ownership_flow()


#!/usr/bin/env python3
"""
Chemical Ingestion Pipeline for QFOT Blockchain
Ingests unique chemical compounds with deduplication
Submits to blockchain via Knowledge Graph + Ethics Node validation
"""

import hashlib
import json
import asyncio
import aiohttp
from typing import List, Dict, Optional, Set
from dataclasses import dataclass, asdict
import sys

# Blockchain configuration  
BLOCKCHAIN_NODES = [
    "http://78.46.149.125:9944",
    "http://91.99.156.64:9944",
    "http://65.109.15.3:9944",
]

# Deduplication cache
seen_smiles: Set[str] = set()
seen_inchi_keys: Set[str] = set()
submitted_chemicals: Dict[str, str] = {}  # smiles_hash -> fact_id

@dataclass
class ChemicalEntry:
    """Chemical compound entry for blockchain submission"""
    smiles: str
    name: Optional[str] = None
    formula: Optional[str] = None
    molecular_weight: Optional[float] = None
    inchi: Optional[str] = None
    inchi_key: Optional[str] = None
    cas_number: Optional[str] = None
    pubchem_cid: Optional[int] = None
    binding_targets: List[str] = None
    confidence: float = 0.85
    source: str = "manual"
    
    def __post_init__(self):
        if self.binding_targets is None:
            self.binding_targets = []
    
    def smiles_hash(self) -> str:
        """Compute hash of canonical SMILES"""
        # In production, would canonicalize SMILES first
        canonical_smiles = self.smiles.upper().replace(" ", "")
        return hashlib.sha256(canonical_smiles.encode()).hexdigest()
    
    def content_hash(self) -> str:
        """Compute full content hash"""
        content = {
            "smiles": self.smiles,
            "formula": self.formula,
            "molecular_weight": self.molecular_weight
        }
        canonical = json.dumps(content, sort_keys=True)
        return hashlib.sha256(canonical.encode()).hexdigest()
    
    def is_valid(self) -> tuple[bool, Optional[str]]:
        """Validate chemical entry"""
        # Basic SMILES validation
        if not self.smiles or len(self.smiles) < 2:
            return False, "SMILES too short"
        
        # Check molecular weight
        if self.molecular_weight and (self.molecular_weight <= 0 or self.molecular_weight > 100000):
            return False, f"Invalid molecular weight: {self.molecular_weight}"
        
        return True, None
    
    def is_duplicate(self) -> tuple[bool, Optional[str]]:
        """Check if this chemical is a duplicate"""
        smiles_hash = self.smiles_hash()
        if smiles_hash in seen_smiles:
            return True, submitted_chemicals.get(smiles_hash)
        
        if self.inchi_key and self.inchi_key in seen_inchi_keys:
            return True, submitted_chemicals.get(smiles_hash)
        
        return False, None

class ChemicalIngestionPipeline:
    """Pipeline for ingesting chemicals to QFOT blockchain"""
    
    def __init__(self, stake_amount: float = 15.0):
        self.stake_amount = stake_amount
        self.session: Optional[aiohttp.ClientSession] = None
        self.stats = {
            "total_processed": 0,
            "unique_submitted": 0,
            "duplicates_skipped": 0,
            "validation_failed": 0,
            "submission_failed": 0,
            "ethics_rejected": 0,
        }
    
    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()
    
    async def submit_to_blockchain(self, chemical: ChemicalEntry) -> Dict:
        """Submit chemical to QFOT blockchain"""
        
        tx_data = {
            "node_type": "Chemical",
            "content": asdict(chemical),
            "content_hash": chemical.content_hash(),
            "category": "Chemical",
            "stake": self.stake_amount,
            "provenance": []
        }
        
        for node_url in BLOCKCHAIN_NODES:
            try:
                async with self.session.post(
                    f"{node_url}/transaction",
                    json={
                        "pallet": "KnowledgeGraph",
                        "call": "submit_fact",
                        "args": tx_data
                    },
                    timeout=30
                ) as response:
                    if response.status == 200:
                        result = await response.json()
                        fact_id = result["fact_id"]
                        
                        print(f"  ✅ Submitted: {fact_id[:8]}...")
                        
                        # Mark as seen
                        smiles_hash = chemical.smiles_hash()
                        seen_smiles.add(smiles_hash)
                        if chemical.inchi_key:
                            seen_inchi_keys.add(chemical.inchi_key)
                        submitted_chemicals[smiles_hash] = fact_id
                        
                        self.stats["unique_submitted"] += 1
                        
                        return {
                            "success": True,
                            "fact_id": fact_id,
                            "node": node_url
                        }
            except Exception as e:
                print(f"  ⚠️  Node error: {e}")
                continue
        
        self.stats["submission_failed"] += 1
        return {"success": False, "reason": "all_nodes_failed"}
    
    async def ingest_chemical(self, chemical: ChemicalEntry) -> bool:
        """Ingest a single chemical"""
        
        self.stats["total_processed"] += 1
        
        print(f"\n🧪 Processing: {chemical.name or chemical.smiles}")
        print(f"   SMILES: {chemical.smiles}")
        if chemical.formula:
            print(f"   Formula: {chemical.formula}")
        
        # Validation
        is_valid, error = chemical.is_valid()
        if not is_valid:
            print(f"  ❌ Validation failed: {error}")
            self.stats["validation_failed"] += 1
            return False
        
        # Deduplication
        is_duplicate, existing_fact_id = chemical.is_duplicate()
        if is_duplicate:
            print(f"  ⚠️  Duplicate (already submitted)")
            self.stats["duplicates_skipped"] += 1
            return False
        
        # Submit
        result = await self.submit_to_blockchain(chemical)
        return result.get("success", False)
    
    async def ingest_batch(self, chemicals: List[ChemicalEntry]):
        """Ingest batch of chemicals"""
        
        print(f"🚀 Batch ingestion of {len(chemicals)} chemicals")
        print("=" * 60)
        
        for i, chemical in enumerate(chemicals, 1):
            print(f"\n[{i}/{len(chemicals)}]")
            await self.ingest_chemical(chemical)
        
        print("\n" + "=" * 60)
        print("📊 Statistics:")
        for key, value in self.stats.items():
            print(f"   {key.replace('_', ' ').title()}: {value}")
        print("=" * 60)

# Example chemicals
EXAMPLE_CHEMICALS = [
    ChemicalEntry(
        smiles="CC(=O)OC1=CC=CC=C1C(=O)O",
        name="Aspirin",
        formula="C9H8O4",
        molecular_weight=180.16,
        cas_number="50-78-2",
        pubchem_cid=2244,
        source="pubchem"
    ),
    ChemicalEntry(
        smiles="CN1C=NC2=C1C(=O)N(C(=O)N2C)C",
        name="Caffeine",
        formula="C8H10N4O2",
        molecular_weight=194.19,
        cas_number="58-08-2",
        pubchem_cid=2519,
        source="pubchem"
    ),
    # Duplicate (same as aspirin) - should be skipped
    ChemicalEntry(
        smiles="CC(=O)OC1=CC=CC=C1C(=O)O",
        name="Duplicate Aspirin",
        source="test"
    ),
]

async def main():
    print("🧪 QFOT Chemical Ingestion Pipeline")
    print("====================================")
    
    async with ChemicalIngestionPipeline(stake_amount=15.0) as pipeline:
        await pipeline.ingest_batch(EXAMPLE_CHEMICALS)
    
    print("\n✅ Complete!")

if __name__ == "__main__":
    asyncio.run(main())


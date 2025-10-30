#!/usr/bin/env python3
"""
Protein Ingestion Pipeline for QFOT Blockchain
Ingests unique proteins from various sources with deduplication
Submits to blockchain via Knowledge Graph + Ethics Node validation
"""

import hashlib
import json
import asyncio
import aiohttp
from typing import List, Dict, Optional, Set
from dataclasses import dataclass, asdict
from datetime import datetime
import sys

# Blockchain configuration
BLOCKCHAIN_NODES = [
    "http://78.46.149.125:9944",
    "http://91.99.156.64:9944",
    "http://65.109.15.3:9944",
]

# Deduplication cache
seen_sequences: Set[str] = set()
seen_content_hashes: Set[str] = set()
submitted_facts: Dict[str, str] = {}  # sequence_hash -> fact_id

@dataclass
class ProteinEntry:
    """Protein entry for blockchain submission"""
    sequence: str
    uniprot_id: Optional[str] = None
    name: Optional[str] = None
    organism: Optional[str] = None
    mass: Optional[float] = None
    length: Optional[int] = None
    go_annotations: List[str] = None
    pdb_id: Optional[str] = None
    confidence: float = 0.9
    source: str = "manual"
    
    def __post_init__(self):
        if self.go_annotations is None:
            self.go_annotations = []
        if self.length is None:
            self.length = len(self.sequence)
        if self.mass is None:
            self.mass = self.calculate_mass()
    
    def calculate_mass(self) -> float:
        """Calculate molecular mass from sequence"""
        residue_masses = {
            'A': 89.09, 'R': 174.20, 'N': 132.12, 'D': 133.10,
            'C': 121.15, 'E': 147.13, 'Q': 146.15, 'G': 75.07,
            'H': 155.16, 'I': 131.17, 'L': 131.17, 'K': 146.19,
            'M': 149.21, 'F': 165.19, 'P': 115.13, 'S': 105.09,
            'T': 119.12, 'W': 204.23, 'Y': 181.19, 'V': 117.15
        }
        return sum(residue_masses.get(aa, 0.0) for aa in self.sequence.upper())
    
    def sequence_hash(self) -> str:
        """Compute deterministic hash of sequence for deduplication"""
        return hashlib.sha256(self.sequence.upper().encode()).hexdigest()
    
    def content_hash(self) -> str:
        """Compute full content hash"""
        content = {
            "sequence": self.sequence.upper(),
            "mass": round(self.mass, 2),
            "length": self.length
        }
        canonical = json.dumps(content, sort_keys=True)
        return hashlib.sha256(canonical.encode()).hexdigest()
    
    def is_valid(self) -> tuple[bool, Optional[str]]:
        """Validate protein entry"""
        # Check sequence
        valid_aa = set("ACDEFGHIKLMNPQRSTVWY")
        invalid_aa = set(self.sequence.upper()) - valid_aa
        if invalid_aa:
            return False, f"Invalid amino acids: {invalid_aa}"
        
        # Check length
        if self.length < 1 or self.length > 50000:
            return False, f"Invalid length: {self.length}"
        
        # Check mass
        if self.mass <= 0 or self.mass > 10_000_000:
            return False, f"Invalid mass: {self.mass}"
        
        return True, None
    
    def is_duplicate(self) -> tuple[bool, Optional[str]]:
        """Check if this protein is a duplicate"""
        seq_hash = self.sequence_hash()
        if seq_hash in seen_sequences:
            return True, submitted_facts.get(seq_hash)
        
        content_hash = self.content_hash()
        if content_hash in seen_content_hashes:
            return True, submitted_facts.get(seq_hash)
        
        return False, None

class ProteinIngestionPipeline:
    """Pipeline for ingesting proteins to QFOT blockchain"""
    
    def __init__(self, stake_amount: float = 10.0):
        self.stake_amount = stake_amount
        self.session: Optional[aiohttp.ClientSession] = None
        self.stats = {
            "total_processed": 0,
            "unique_submitted": 0,
            "duplicates_skipped": 0,
            "validation_failed": 0,
            "submission_failed": 0,
            "ethics_rejected": 0,
            "human_review_required": 0,
        }
    
    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()
    
    async def submit_to_blockchain(self, protein: ProteinEntry) -> Dict:
        """Submit protein to QFOT blockchain"""
        
        # Prepare blockchain transaction
        tx_data = {
            "node_type": "Protein",
            "content": asdict(protein),
            "content_hash": protein.content_hash(),
            "category": "Protein",
            "stake": self.stake_amount,
            "provenance": []
        }
        
        # Try each blockchain node with failover
        for node_url in BLOCKCHAIN_NODES:
            try:
                # Step 1: Submit to Knowledge Graph pallet
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
                        
                        print(f"  ✅ Submitted to Knowledge Graph: {fact_id[:8]}...")
                        
                        # Step 2: Wait for Ethics Node assessment
                        print(f"  ⏳ Awaiting Ethics Node validation...")
                        ethics_result = await self.wait_for_ethics_assessment(
                            fact_id, 
                            node_url
                        )
                        
                        if not ethics_result["approved"]:
                            print(f"  ❌ Ethics Node rejected: {ethics_result['reason']}")
                            self.stats["ethics_rejected"] += 1
                            return {
                                "success": False,
                                "reason": "ethics_rejected",
                                "details": ethics_result
                            }
                        
                        if ethics_result.get("requires_human_review"):
                            print(f"  ⚠️  Human review required")
                            self.stats["human_review_required"] += 1
                            return {
                                "success": False,
                                "reason": "human_review_required",
                                "fact_id": fact_id
                            }
                        
                        # Step 3: Success!
                        confidence = ethics_result.get("confidence", 0)
                        print(f"  🎉 Validated! Ethical confidence: {confidence}%")
                        
                        # Mark as seen
                        seq_hash = protein.sequence_hash()
                        seen_sequences.add(seq_hash)
                        seen_content_hashes.add(protein.content_hash())
                        submitted_facts[seq_hash] = fact_id
                        
                        self.stats["unique_submitted"] += 1
                        
                        return {
                            "success": True,
                            "fact_id": fact_id,
                            "ethical_confidence": confidence,
                            "node": node_url
                        }
                    
            except asyncio.TimeoutError:
                print(f"  ⚠️  Node {node_url} timeout, trying next...")
                continue
            except Exception as e:
                print(f"  ⚠️  Node {node_url} error: {e}, trying next...")
                continue
        
        # All nodes failed
        self.stats["submission_failed"] += 1
        return {
            "success": False,
            "reason": "all_nodes_failed"
        }
    
    async def wait_for_ethics_assessment(
        self, 
        fact_id: str, 
        node_url: str, 
        max_attempts: int = 10
    ) -> Dict:
        """Wait for Ethics Node to assess the fact"""
        
        for attempt in range(max_attempts):
            await asyncio.sleep(2)  # Wait 2 seconds between checks
            
            try:
                async with self.session.get(
                    f"{node_url}/query",
                    params={
                        "pallet": "EthicsNode",
                        "call": "assessments",
                        "fact_id": fact_id
                    },
                    timeout=10
                ) as response:
                    if response.status == 200:
                        assessment = await response.json()
                        
                        if assessment:
                            return {
                                "approved": assessment["confidence"] >= 70,
                                "confidence": assessment["confidence"],
                                "requires_human_review": assessment.get("requires_human_review", False),
                                "reason": assessment.get("reason", "")
                            }
            except:
                continue
        
        # Timeout
        return {
            "approved": False,
            "reason": "ethics_assessment_timeout"
        }
    
    async def ingest_protein(self, protein: ProteinEntry) -> bool:
        """Ingest a single protein with full validation"""
        
        self.stats["total_processed"] += 1
        
        print(f"\n📋 Processing: {protein.name or protein.uniprot_id or 'Unknown'}")
        print(f"   Sequence: {protein.sequence[:50]}... ({protein.length} aa)")
        
        # Step 1: Validation
        is_valid, error = protein.is_valid()
        if not is_valid:
            print(f"  ❌ Validation failed: {error}")
            self.stats["validation_failed"] += 1
            return False
        
        # Step 2: Deduplication check
        is_duplicate, existing_fact_id = protein.is_duplicate()
        if is_duplicate:
            print(f"  ⚠️  Duplicate detected (already submitted)")
            if existing_fact_id:
                print(f"     Existing fact: {existing_fact_id[:8]}...")
            self.stats["duplicates_skipped"] += 1
            return False
        
        # Step 3: Submit to blockchain
        result = await self.submit_to_blockchain(protein)
        
        return result.get("success", False)
    
    async def ingest_batch(self, proteins: List[ProteinEntry]):
        """Ingest a batch of proteins"""
        
        print(f"🚀 Starting batch ingestion of {len(proteins)} proteins")
        print("=" * 60)
        
        for i, protein in enumerate(proteins, 1):
            print(f"\n[{i}/{len(proteins)}]")
            await self.ingest_protein(protein)
        
        print("\n" + "=" * 60)
        print("📊 Ingestion Statistics:")
        for key, value in self.stats.items():
            print(f"   {key.replace('_', ' ').title()}: {value}")
        print("=" * 60)

# Example proteins from various sources
EXAMPLE_PROTEINS = [
    ProteinEntry(
        sequence="MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKAVQVKVKALPDAQFEVVHSLAKWKRQTLGQHDFSAGEGLYTHMKALRPDEDRLSPLHSVYVDQWDWERSK",
        uniprot_id="P04637",
        name="Tumor protein p53",
        organism="Homo sapiens",
        go_annotations=["GO:0005515", "GO:0006355"],
        confidence=0.95,
        source="uniprot"
    ),
    ProteinEntry(
        sequence="MTEYKLVVVGAGGVGKSALTIQLIQNHFVDEYDPTIEDSYRKQVVIDGETCLLDILDTAGQEEYSAMRDQYMRTGEGFLCVFAINNTKSFEDIHQYREQIKRVKDSDDVPMVLVGNKCDLAARTVESRQAQDLARSYGIPYIETSAKTRQGVEDAFYTLVREIRQHKLRKLNPPDESGPGCMSCKCVLS",
        uniprot_id="P01112",
        name="GTPase HRas",
        organism="Homo sapiens",
        go_annotations=["GO:0005525", "GO:0007165"],
        confidence=0.98,
        source="pdb"
    ),
    # Duplicate (same sequence as p53) - should be skipped
    ProteinEntry(
        sequence="MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKAVQVKVKALPDAQFEVVHSLAKWKRQTLGQHDFSAGEGLYTHMKALRPDEDRLSPLHSVYVDQWDWERSK",
        name="Duplicate p53",
        source="test"
    ),
]

async def main():
    """Main ingestion pipeline"""
    
    print("🧬 QFOT Protein Ingestion Pipeline")
    print("===================================")
    print(f"Blockchain nodes: {len(BLOCKCHAIN_NODES)}")
    print(f"Stake per protein: {10.0} QFOT")
    print("")
    
    async with ProteinIngestionPipeline(stake_amount=10.0) as pipeline:
        await pipeline.ingest_batch(EXAMPLE_PROTEINS)
    
    print("\n✅ Ingestion complete!")

if __name__ == "__main__":
    asyncio.run(main())


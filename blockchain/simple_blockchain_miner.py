#!/usr/bin/env python3
"""
Simple Blockchain Miner - Submits facts directly to blockchain
No wallet dependencies, just pure fact submission
"""

import requests
import hashlib
import time
from datetime import datetime
import json

# API endpoints (prioritize blockchain integration)
API_BASES = [
    "http://94.130.97.66:8000/api",
    "http://46.224.42.20:8000/api",
    "http://localhost:8000/api"
]

class SimpleBlockchainMiner:
    """Simple fact miner for QFOT blockchain"""
    
    def __init__(self, creator_alias: str):
        self.creator_alias = creator_alias
        self.facts_submitted = 0
    
    def submit_fact(self, content: str, domain: str, stake: float = 10.0, provenance: dict = None):
        """Submit fact to blockchain"""
        
        fact_data = {
            "content": content,
            "domain": domain,
            "creator": self.creator_alias,
            "stake": stake,
            "provenance": provenance or {}
        }
        
        # Try each API endpoint
        for api_base in API_BASES:
            try:
                response = requests.post(
                    f"{api_base}/facts/submit",
                    json=fact_data,
                    timeout=10
                )
                
                if response.status_code == 200:
                    result = response.json()
                    self.facts_submitted += 1
                    
                    print(f"✅ Fact submitted: {result.get('fact_id', 'unknown')}")
                    print(f"   API: {api_base}")
                    print(f"   Simulation: {result.get('simulation', 'unknown')}")
                    
                    return result
                else:
                    print(f"⚠️  Failed ({response.status_code}): {api_base}")
                    
            except Exception as e:
                print(f"❌ Error with {api_base}: {e}")
                continue
        
        print(f"❌ All API endpoints failed")
        return None
    
    def mine_education_facts(self, count: int = 10):
        """Mine education facts"""
        
        print(f"\n📚 Mining {count} education facts...")
        
        facts = [
            {
                "content": "The Pythagorean theorem states that in a right triangle, a² + b² = c²",
                "domain": "education",
                "provenance": {"topic": "Mathematics", "grade": "8-12"}
            },
            {
                "content": "Photosynthesis converts light energy into chemical energy using chlorophyll in plant cells",
                "domain": "education",
                "provenance": {"topic": "Biology", "grade": "6-12"}
            },
            {
                "content": "The American Revolution began in 1775 with the battles of Lexington and Concord",
                "domain": "education",
                "provenance": {"topic": "History", "grade": "6-12"}
            },
            {
                "content": "Newton's First Law states that an object in motion stays in motion unless acted upon by an external force",
                "domain": "education",
                "provenance": {"topic": "Physics", "grade": "9-12"}
            },
            {
                "content": "Shakespeare wrote 37 plays and 154 sonnets during the Elizabethan era",
                "domain": "education",
                "provenance": {"topic": "Literature", "grade": "9-12"}
            },
            {
                "content": "The water cycle includes evaporation, condensation, precipitation, and collection",
                "domain": "education",
                "provenance": {"topic": "Earth Science", "grade": "4-8"}
            },
            {
                "content": "DNA contains the genetic instructions for all living organisms using four nucleotide bases: A, T, G, C",
                "domain": "education",
                "provenance": {"topic": "Biology", "grade": "9-12"}
            },
            {
                "content": "The periodic table organizes elements by atomic number and chemical properties",
                "domain": "education",
                "provenance": {"topic": "Chemistry", "grade": "9-12"}
            },
            {
                "content": "The Magna Carta, signed in 1215, established the principle that everyone is subject to the law",
                "domain": "education",
                "provenance": {"topic": "History", "grade": "6-12"}
            },
            {
                "content": "Fractions represent parts of a whole, with a numerator over a denominator",
                "domain": "education",
                "provenance": {"topic": "Mathematics", "grade": "3-6"}
            }
        ]
        
        for i, fact in enumerate(facts[:count], 1):
            print(f"\n[{i}/{count}] Submitting fact...")
            result = self.submit_fact(**fact)
            if result:
                print(f"    Content: {fact['content'][:60]}...")
            time.sleep(1)  # Rate limiting
    
    def mine_medical_facts(self, count: int = 10):
        """Mine medical facts"""
        
        print(f"\n🏥 Mining {count} medical facts...")
        
        facts = [
            {
                "content": "Hypertension is defined as blood pressure consistently above 140/90 mmHg",
                "domain": "medical",
                "provenance": {"source": "AHA Guidelines", "specialty": "Cardiology"}
            },
            {
                "content": "Type 2 diabetes is characterized by insulin resistance and relative insulin deficiency",
                "domain": "medical",
                "provenance": {"source": "ADA Standards", "specialty": "Endocrinology"}
            },
            {
                "content": "Aspirin at 81mg daily reduces cardiovascular events in high-risk patients",
                "domain": "medical",
                "provenance": {"source": "USPSTF", "specialty": "Preventive Medicine"}
            },
            {
                "content": "COVID-19 vaccines significantly reduce severe disease and hospitalization rates",
                "domain": "medical",
                "provenance": {"source": "CDC", "specialty": "Infectious Disease"}
            },
            {
                "content": "COPD is primarily caused by smoking and results in progressive airflow limitation",
                "domain": "medical",
                "provenance": {"source": "GOLD Guidelines", "specialty": "Pulmonology"}
            }
        ]
        
        for i, fact in enumerate(facts[:count], 1):
            print(f"\n[{i}/{count}] Submitting fact...")
            result = self.submit_fact(**fact)
            if result:
                print(f"    Content: {fact['content'][:60]}...")
            time.sleep(1)
    
    def mine_legal_facts(self, count: int = 10):
        """Mine legal facts"""
        
        print(f"\n⚖️  Mining {count} legal facts...")
        
        facts = [
            {
                "content": "The First Amendment protects freedom of speech, religion, press, assembly, and petition",
                "domain": "legal",
                "provenance": {"source": "U.S. Constitution", "jurisdiction": "Federal"}
            },
            {
                "content": "The Fourth Amendment protects against unreasonable searches and seizures",
                "domain": "legal",
                "provenance": {"source": "U.S. Constitution", "jurisdiction": "Federal"}
            },
            {
                "content": "Miranda rights must be read before custodial interrogation",
                "domain": "legal",
                "provenance": {"source": "Miranda v. Arizona (1966)", "jurisdiction": "Federal"}
            },
            {
                "content": "The statute of limitations for most federal crimes is 5 years (18 USC 3282)",
                "domain": "legal",
                "provenance": {"source": "18 USC 3282", "jurisdiction": "Federal"}
            },
            {
                "content": "Probable cause is required for arrest warrants under the Fourth Amendment",
                "domain": "legal",
                "provenance": {"source": "U.S. Constitution", "jurisdiction": "Federal"}
            }
        ]
        
        for i, fact in enumerate(facts[:count], 1):
            print(f"\n[{i}/{count}] Submitting fact...")
            result = self.submit_fact(**fact)
            if result:
                print(f"    Content: {fact['content'][:60]}...")
            time.sleep(1)

def main():
    """Main miner function"""
    
    print("===============================================================================")
    print("🚀 QFOT BLOCKCHAIN MINER")
    print("===============================================================================")
    print("")
    print("Network: MAINNET")
    print("Miner: @SimpleBlockchainMiner")
    print("")
    
    miner = SimpleBlockchainMiner("@SimpleBlockchainMiner")
    
    # Mine facts from all domains
    miner.mine_education_facts(count=10)
    miner.mine_medical_facts(count=5)
    miner.mine_legal_facts(count=5)
    
    print("")
    print("===============================================================================")
    print(f"✅ MINING COMPLETE!")
    print("===============================================================================")
    print(f"   Total facts submitted: {miner.facts_submitted}")
    print(f"   Miner: {miner.creator_alias}")
    print("")
    print("Check results:")
    print("   curl https://safeaicoin.org/api/facts/search | jq")
    print("===============================================================================")

if __name__ == "__main__":
    main()


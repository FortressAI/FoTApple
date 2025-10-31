#!/usr/bin/env python3
"""
EXHAUSTIVE FACT MINER - Runs Until Completely Exhausted

Generates ALL possible facts across ALL domains:
- K-18 Education (comprehensive)
- Medical knowledge
- Legal information
- General knowledge
- Scientific facts
- Historical events
- Geographic data

Runs continuously until all fact sources are exhausted.
Target: 10,000+ facts
"""

import sys
import time
import hashlib
from datetime import datetime
from typing import List, Dict
import requests

sys.path.append('/Users/richardgillespie/Documents/FoTApple/blockchain')
from wallet_manager import WalletManager
from token_faucet import TokenFaucet
from k18_education_fact_generator import (
    MATHEMATICS_FACTS, SCIENCE_FACTS, ENGLISH_FACTS, SOCIAL_STUDIES_FACTS
)

class ExhaustiveFactMiner:
    def __init__(self):
        self.wallet_mgr = WalletManager()
        self.faucet = TokenFaucet(self.wallet_mgr)
        self.creator_alias = "@Exhaustive-Miner-Bot"
        self.creator_wallet = None
        self.facts_submitted = 0
        self.start_time = datetime.now()
        self.api_base = None
        
        # Track what's been mined
        self.mined_subjects = set()
        
    def connect_to_api(self):
        """Find and connect to available API"""
        API_BASES = [
            "http://localhost:8000/api",
            "http://94.130.97.66/api",
            "http://46.224.42.20/api"
        ]
        
        for base in API_BASES:
            try:
                resp = requests.get(f"{base.replace('/api', '')}/health", timeout=5)
                if resp.status_code == 200:
                    self.api_base = base
                    print(f"   ✅ Connected to: {base}")
                    return True
            except:
                continue
        
        print("   ❌ No API available!")
        return False
    
    def initialize_miner_wallet(self):
        """Create/load miner wallet"""
        print("🤖 Initializing Exhaustive Fact Miner...")
        
        wallet = self.wallet_mgr.get_wallet(alias=self.creator_alias)
        
        if not wallet:
            wallet = self.wallet_mgr.create_wallet(
                alias=self.creator_alias,
                user_type="ai_agent"
            )
            print(f"   ✅ Created wallet: {wallet['wallet_id']}")
            
            # Claim maximum faucet
            claim = self.faucet.claim_tokens(
                alias=self.creator_alias,
                user_type="ai_agent"
            )
            
            if claim['success']:
                print(f"   ✅ Claimed {claim['amount']} QFOT")
        else:
            print(f"   ✅ Wallet exists: {wallet['wallet_id']}")
            print(f"   💰 Balance: {wallet['balance']} QFOT")
        
        self.creator_wallet = wallet if isinstance(wallet, dict) and 'wallet_id' in wallet else self.wallet_mgr.get_wallet(alias=self.creator_alias)
    
    def submit_fact(self, content: str, domain: str, subject: str, stake: float = 35.0) -> bool:
        """Submit single fact to blockchain"""
        if not self.api_base:
            return False
        
        try:
            # Check balance
            wallet = self.wallet_mgr.get_wallet(alias=self.creator_alias)
            if wallet['balance'] < stake:
                print(f"\n   ⚠️  Insufficient balance: {wallet['balance']} QFOT")
                print(f"   💤 Waiting for more tokens or ending mining...")
                return False
            
            # Submit fact
            response = requests.post(
                f"{self.api_base}/facts/submit",
                json={
                    "content": content,
                    "domain": domain,
                    "stake": stake
                },
                headers={
                    "X-QFOT-Alias": self.creator_alias,
                    "Content-Type": "application/json"
                },
                timeout=10
            )
            
            if response.status_code == 200:
                self.facts_submitted += 1
                if self.facts_submitted % 100 == 0:
                    elapsed = (datetime.now() - self.start_time).total_seconds()
                    rate = self.facts_submitted / elapsed if elapsed > 0 else 0
                    print(f"   ✅ {self.facts_submitted} facts mined ({rate:.1f}/sec)")
                return True
            elif response.status_code == 409:
                # Already exists, that's ok
                return True
            else:
                return False
                
        except Exception as e:
            if self.facts_submitted % 50 == 0:
                print(f"   ⚠️  Error: {str(e)[:50]}")
            return False
    
    def mine_k18_education(self):
        """Mine ALL K-18 educational facts"""
        print("\n📚 MINING K-18 EDUCATION...")
        
        subjects = {
            "Mathematics": MATHEMATICS_FACTS,
            "Science": SCIENCE_FACTS,
            "English": ENGLISH_FACTS,
            "Social Studies": SOCIAL_STUDIES_FACTS
        }
        
        for subject_name, grade_levels in subjects.items():
            if subject_name in self.mined_subjects:
                continue
            
            print(f"\n   📖 Mining {subject_name}...")
            
            for grade_level, facts in grade_levels.items():
                for fact in facts:
                    content = f"{subject_name} ({grade_level}): {fact}"
                    success = self.submit_fact(content, "education", subject_name.lower())
                    if not success:
                        return False
                    time.sleep(0.05)  # Rate limiting
            
            self.mined_subjects.add(subject_name)
            print(f"   ✅ {subject_name} complete")
        
        return True
    
    def mine_additional_math(self):
        """Mine additional mathematics facts (beyond basic K-18)"""
        print("\n📐 MINING ADVANCED MATHEMATICS...")
        
        advanced_math = [
            "Calculus: Derivatives measure instantaneous rate of change",
            "Calculus: Integrals calculate area under curves",
            "Statistics: Mean is the average, median is the middle value",
            "Probability: Independent events don't affect each other",
            "Trigonometry: sin²θ + cos²θ = 1 (Pythagorean identity)",
            "Algebra: Quadratic formula: x = (-b ± √(b²-4ac)) / 2a",
            "Geometry: Circle area = πr², circumference = 2πr",
            "Number Theory: Prime factorization is unique for each number",
            "Set Theory: Union (∪) combines sets, intersection (∩) finds common elements",
            "Logic: De Morgan's Laws: ¬(A ∧ B) = ¬A ∨ ¬B",
        ]
        
        for fact in advanced_math:
            if not self.submit_fact(f"Advanced Mathematics: {fact}", "education", "mathematics"):
                return False
            time.sleep(0.05)
        
        print("   ✅ Advanced Math complete")
        return True
    
    def mine_additional_science(self):
        """Mine additional science facts"""
        print("\n🔬 MINING ADVANCED SCIENCE...")
        
        advanced_science = [
            "Physics: E = mc² relates energy, mass, and speed of light",
            "Chemistry: Avogadro's number: 6.022 × 10²³ particles per mole",
            "Biology: Mitochondria are the powerhouse of the cell",
            "Astronomy: Light travels at 299,792,458 meters per second",
            "Geology: Earth's crust is 5-70 km thick, varying by location",
            "Ecology: Food webs show complex feeding relationships in ecosystems",
            "Genetics: Humans have approximately 20,000-25,000 genes",
            "Biochemistry: Enzymes are biological catalysts that speed up reactions",
            "Neuroscience: Human brain contains approximately 86 billion neurons",
            "Environmental Science: Greenhouse gases trap heat in Earth's atmosphere",
        ]
        
        for fact in advanced_science:
            if not self.submit_fact(f"Advanced Science: {fact}", "education", "science"):
                return False
            time.sleep(0.05)
        
        print("   ✅ Advanced Science complete")
        return True
    
    def mine_computer_science(self):
        """Mine computer science facts"""
        print("\n💻 MINING COMPUTER SCIENCE...")
        
        cs_facts = [
            "Algorithm: Step-by-step procedure to solve a problem",
            "Variable: Named storage location in memory for data",
            "Loop: Repeats code until condition is met (for, while)",
            "Function: Reusable block of code that performs specific task",
            "Array: Collection of elements stored at contiguous memory locations",
            "Object-Oriented Programming: Organizes code into objects with properties and methods",
            "Recursion: Function that calls itself to solve subproblems",
            "Binary Search: Efficient O(log n) search in sorted data",
            "Big O Notation: Describes algorithm efficiency and scalability",
            "Data Structures: Ways to organize data (arrays, lists, trees, graphs)",
        ]
        
        for fact in cs_facts:
            if not self.submit_fact(f"Computer Science: {fact}", "education", "computer_science"):
                return False
            time.sleep(0.05)
        
        print("   ✅ Computer Science complete")
        return True
    
    def mine_world_history(self):
        """Mine world history facts"""
        print("\n🌍 MINING WORLD HISTORY...")
        
        history_facts = [
            "World War II (1939-1945): Deadliest conflict in history, ~70-85 million casualties",
            "French Revolution (1789-1799): Overthrew monarchy, established republic in France",
            "Industrial Revolution (1760-1840): Transformed agriculture to manufacturing economy",
            "Renaissance (14th-17th century): Cultural rebirth in art, science, literature",
            "Fall of Rome (476 CE): Western Roman Empire collapsed, Medieval period began",
            "Age of Exploration (15th-17th century): Europeans discovered Americas, mapped world",
            "Cold War (1947-1991): Political tension between US and Soviet Union",
            "Scientific Revolution (16th-18th century): Modern science emerged with scientific method",
            "Protestant Reformation (1517): Martin Luther challenged Catholic Church practices",
            "Magna Carta (1215): Limited king's power, foundation for constitutional government",
        ]
        
        for fact in history_facts:
            if not self.submit_fact(f"World History: {fact}", "education", "history"):
                return False
            time.sleep(0.05)
        
        print("   ✅ World History complete")
        return True
    
    def mine_geography(self):
        """Mine geography facts"""
        print("\n🗺️ MINING GEOGRAPHY...")
        
        geo_facts = [
            "Mount Everest: World's highest mountain at 8,849 meters (29,032 feet)",
            "Pacific Ocean: Largest ocean, covers ~165 million km²",
            "Sahara Desert: World's largest hot desert, ~9 million km²",
            "Amazon Rainforest: Produces ~20% of world's oxygen, spans 9 countries",
            "Nile River: World's longest river at ~6,650 km",
            "Antarctica: Coldest continent, temperatures reach -89.2°C",
            "Ring of Fire: Pacific region with 75% of world's active volcanoes",
            "Great Barrier Reef: World's largest coral reef system, 2,300 km long",
            "Equator: Imaginary line at 0° latitude, divides Earth into hemispheres",
            "Continents: 7 continents cover ~29% of Earth's surface",
        ]
        
        for fact in geo_facts:
            if not self.submit_fact(f"Geography: {fact}", "education", "geography"):
                return False
            time.sleep(0.05)
        
        print("   ✅ Geography complete")
        return True
    
    def run_exhaustive_mining(self):
        """Run all mining operations until exhausted"""
        print("=" * 80)
        print("⛏️ EXHAUSTIVE FACT MINING - RUNNING UNTIL EXHAUSTED")
        print("=" * 80)
        print("")
        
        # Initialize
        if not self.connect_to_api():
            print("❌ Cannot connect to API. Exiting.")
            return
        
        self.initialize_miner_wallet()
        
        # Mine everything
        mining_operations = [
            ("K-18 Education", self.mine_k18_education),
            ("Advanced Mathematics", self.mine_additional_math),
            ("Advanced Science", self.mine_additional_science),
            ("Computer Science", self.mine_computer_science),
            ("World History", self.mine_world_history),
            ("Geography", self.mine_geography),
        ]
        
        for name, operation in mining_operations:
            print(f"\n{'='*80}")
            print(f"⛏️  Mining: {name}")
            print(f"{'='*80}")
            
            success = operation()
            
            if not success:
                print(f"\n⚠️  Mining stopped for {name}")
                print(f"   Reason: Insufficient balance or errors")
                break
            
            elapsed = (datetime.now() - self.start_time).total_seconds()
            print(f"\n✅ {name} mining complete!")
            print(f"   Total mined so far: {self.facts_submitted}")
            print(f"   Time elapsed: {elapsed/60:.1f} minutes")
        
        # Final statistics
        elapsed = (datetime.now() - self.start_time).total_seconds()
        
        print("\n" + "=" * 80)
        print("🎉 MINING SESSION COMPLETE")
        print("=" * 80)
        print(f"   Total facts mined: {self.facts_submitted}")
        print(f"   Time elapsed: {elapsed/60:.1f} minutes ({elapsed/3600:.2f} hours)")
        print(f"   Mining rate: {self.facts_submitted/elapsed:.2f} facts/second")
        print(f"   Subjects completed: {len(self.mined_subjects)}")
        
        # Economics
        print(f"\n💰 EARNINGS POTENTIAL:")
        print(f"   Facts mined: {self.facts_submitted}")
        print(f"   Conservative (1 query/day): ${self.facts_submitted * 0.007 * 365:.2f}/year")
        print(f"   Moderate (10 queries/day): ${self.facts_submitted * 0.07 * 365:.2f}/year")
        print(f"   Optimistic (100 queries/day): ${self.facts_submitted * 0.7 * 365:.2f}/year")
        
        # Check if truly exhausted
        wallet = self.wallet_mgr.get_wallet(alias=self.creator_alias)
        if wallet['balance'] < 35:
            print(f"\n⛏️  MINING EXHAUSTED: Insufficient balance ({wallet['balance']:.2f} QFOT)")
        else:
            print(f"\n✅ Mining complete! Balance remaining: {wallet['balance']:.2f} QFOT")
        
        print("=" * 80)

if __name__ == "__main__":
    miner = ExhaustiveFactMiner()
    miner.run_exhaustive_mining()


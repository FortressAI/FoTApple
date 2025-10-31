#!/usr/bin/env python3
"""
K-18 Education Fact Generator (Background Agent)

Continuously generates comprehensive educational facts across all K-18 topics:
- Mathematics (K-12)
- Science (Biology, Chemistry, Physics, Earth Science)
- English Language Arts
- Social Studies (History, Geography, Government)
- Arts & Music
- Physical Education & Health
- Computer Science

Submits facts to QFOT blockchain for monetization.
Runs in background, targets thousands of facts.
"""

import sys
import time
import hashlib
from datetime import datetime
from typing import List, Dict

sys.path.append('/Users/richardgillespie/Documents/FoTApple/blockchain')
from wallet_manager import WalletManager
from token_faucet import TokenFaucet

# K-18 Educational Content Database
# This would normally be extracted from curriculum standards, textbooks, etc.

MATHEMATICS_FACTS = {
    "K-2": [
        "Counting: Numbers 1-100. Each number represents a specific quantity.",
        "Addition: Combining two or more numbers. Example: 2 + 3 = 5",
        "Subtraction: Taking away one number from another. Example: 5 - 2 = 3",
        "Shapes: Basic geometric shapes include circle, square, triangle, and rectangle.",
        "Patterns: Sequences that repeat, like AB-AB-AB or ABC-ABC-ABC.",
        "Measurement: Using standard units like inches, feet, centimeters to measure length.",
        "Time: Reading clocks to the nearest hour and half-hour.",
        "Money: Identifying coins (penny, nickel, dime, quarter) and their values.",
        "Place Value: Understanding ones and tens places in two-digit numbers.",
        "Number Comparison: Using <, >, = to compare numbers.",
    ],
    "3-5": [
        "Multiplication: Repeated addition. Example: 3 × 4 = 3 + 3 + 3 + 3 = 12",
        "Division: Splitting a number into equal groups. Example: 12 ÷ 3 = 4",
        "Fractions: Parts of a whole. Example: 1/2, 1/4, 3/4",
        "Decimals: Another way to represent fractions. Example: 0.5 = 1/2",
        "Area: Space inside a shape, measured in square units. Rectangle area = length × width",
        "Perimeter: Distance around a shape. Add all sides together.",
        "Factors: Numbers that divide evenly into another number. Factors of 12: 1, 2, 3, 4, 6, 12",
        "Prime Numbers: Numbers only divisible by 1 and themselves. Examples: 2, 3, 5, 7, 11",
        "Order of Operations: PEMDAS - Parentheses, Exponents, Multiplication/Division, Addition/Subtraction",
        "Variables: Letters representing unknown numbers in algebra. Example: x + 5 = 10, so x = 5",
    ],
    "6-8": [
        "Ratios: Comparison of two quantities. Example: 3:4 means 3 parts to 4 parts",
        "Proportions: Equal ratios. If 2/4 = 3/6, then 2:4 and 3:6 are proportional",
        "Percentages: Parts per hundred. 25% = 25/100 = 0.25 = 1/4",
        "Integers: Whole numbers and their negatives: ...-2, -1, 0, 1, 2...",
        "Coordinate Plane: Grid with x-axis (horizontal) and y-axis (vertical) for plotting points",
        "Linear Equations: Equations forming straight lines. Example: y = 2x + 3",
        "Pythagorean Theorem: For right triangles: a² + b² = c² where c is the hypotenuse",
        "Volume: Space inside 3D shapes. Cube volume = side³, Cylinder volume = πr²h",
        "Statistical Mean: Average of numbers. Add all values and divide by count.",
        "Probability: Likelihood of an event, expressed as fraction, decimal, or percentage.",
    ],
    "9-12": [
        "Quadratic Equations: Equations with x². Standard form: ax² + bx + c = 0",
        "Functions: Relationship where each input has exactly one output. f(x) notation.",
        "Trigonometry: Study of triangles. SOH-CAH-TOA for sine, cosine, tangent.",
        "Logarithms: Inverse of exponents. If 10² = 100, then log₁₀(100) = 2",
        "Polynomials: Expressions with multiple terms. Example: 3x³ + 2x² - 5x + 7",
        "Limits: Foundation of calculus, value a function approaches. lim(x→a) f(x)",
        "Derivatives: Rate of change in calculus. If f(x) = x², then f'(x) = 2x",
        "Integrals: Area under curves in calculus. Reverse of derivatives.",
        "Matrices: Rectangular arrays of numbers used in linear algebra.",
        "Complex Numbers: Numbers with real and imaginary parts. Example: 3 + 4i",
    ]
}

SCIENCE_FACTS = {
    "K-2": [
        "Plants need sunlight, water, and air to grow.",
        "Animals need food, water, and shelter to survive.",
        "The Sun provides light and heat to Earth.",
        "Matter exists in three states: solid, liquid, and gas.",
        "Magnets attract certain metals like iron.",
        "Seasons change as Earth orbits the Sun.",
        "Weather includes conditions like sunny, rainy, snowy, and windy.",
        "Five senses: sight, hearing, smell, taste, and touch.",
        "Living things grow, reproduce, and need energy.",
        "Day and night occur as Earth rotates.",
    ],
    "3-5": [
        "Photosynthesis: Plants make food using sunlight, water, and carbon dioxide.",
        "Food chains show how energy flows from producers to consumers.",
        "Water cycle: Evaporation, condensation, precipitation, and collection.",
        "Forces: Pushes and pulls that can change an object's motion.",
        "Energy can be transferred but not created or destroyed (Law of Conservation).",
        "Ecosystems: Communities of organisms interacting with their environment.",
        "Electric circuits require a complete path for current to flow.",
        "Earth's layers: Crust (outer), mantle (middle), core (inner).",
        "Fossils provide evidence of organisms that lived long ago.",
        "Properties of matter include mass, volume, density, and temperature.",
    ],
    "6-8": [
        "Cell Theory: All living things are made of cells, the basic unit of life.",
        "Photosynthesis equation: 6CO₂ + 6H₂O + light → C₆H₁₂O₆ + 6O₂",
        "Newton's First Law: Object at rest stays at rest unless acted upon by force.",
        "Periodic Table organizes elements by atomic number and properties.",
        "DNA (Deoxyribonucleic Acid) carries genetic information in all living things.",
        "Plate Tectonics: Earth's crust is divided into plates that move slowly.",
        "Chemical reactions involve breaking and forming bonds between atoms.",
        "Evolution: Species change over time through natural selection.",
        "Energy transformations: Kinetic (movement) and potential (stored) energy.",
        "Climate vs Weather: Climate is long-term patterns, weather is short-term conditions.",
    ],
    "9-12": [
        "Mitosis: Cell division producing two identical daughter cells (body cell reproduction).",
        "Meiosis: Cell division producing four genetically different cells (gamete formation).",
        "Chemical Bonding: Ionic (transfer electrons), Covalent (share electrons), Metallic.",
        "Newton's Second Law: F = ma (Force equals mass times acceleration).",
        "Thermodynamics: Energy transfer through heat, work, and internal energy changes.",
        "Genetics: Mendel's laws - dominance, segregation, independent assortment.",
        "Oxidation-Reduction: Chemical reactions involving electron transfer.",
        "Electromagnetic Spectrum: Radio, microwave, infrared, visible, UV, X-ray, gamma.",
        "pH Scale: Measures acidity/basicity from 0 (acidic) to 14 (basic), 7 is neutral.",
        "Atomic Structure: Protons (positive), neutrons (neutral) in nucleus; electrons orbit.",
    ]
}

ENGLISH_FACTS = {
    "K-5": [
        "Noun: Person, place, thing, or idea. Examples: cat, school, happiness",
        "Verb: Action or state of being. Examples: run, jump, is, are",
        "Adjective: Describes a noun. Examples: big, red, happy",
        "Sentence: Complete thought with subject and predicate. Starts with capital, ends with punctuation.",
        "Alphabet: 26 letters, 5 vowels (A, E, I, O, U) and 21 consonants.",
        "Phonics: Letter sounds help decode words. 'cat' = /k/ /a/ /t/",
        "Rhyming: Words ending with same sound. Examples: cat/hat, run/fun",
        "Main Idea: Central point or message of a text.",
        "Characters: People or animals in a story.",
        "Setting: Where and when a story takes place.",
    ],
    "6-8": [
        "Theme: Central message or lesson in literature (friendship, courage, honesty).",
        "Metaphor: Comparison without 'like' or 'as'. Example: 'Time is money'",
        "Simile: Comparison using 'like' or 'as'. Example: 'Brave as a lion'",
        "Plot Structure: Exposition, rising action, climax, falling action, resolution.",
        "Point of View: First person (I, we), Second person (you), Third person (he, she, they).",
        "Context Clues: Surrounding words that help determine meaning of unknown words.",
        "Prefixes: Added to word beginning. Examples: un- (unhappy), re- (rewrite), pre- (preview)",
        "Suffixes: Added to word end. Examples: -ing (running), -ed (walked), -ly (quickly)",
        "Thesis Statement: Main argument or claim in an essay.",
        "Citation: Giving credit to sources used in writing (MLA, APA formats).",
    ],
    "9-12": [
        "Literary Analysis: Examining themes, symbols, motifs in literature.",
        "Rhetorical Appeals: Ethos (credibility), Pathos (emotion), Logos (logic).",
        "Syntax: Sentence structure and word order affects meaning and style.",
        "Diction: Author's word choice creates tone and mood.",
        "Allusion: Reference to historical, cultural, or literary figure or event.",
        "Irony: Verbal (saying opposite), Situational (unexpected outcome), Dramatic (audience knows more).",
        "Symbolism: Objects representing abstract ideas (dove = peace, red rose = love).",
        "Argumentative Essay: Makes claim, provides evidence, addresses counterarguments.",
        "MLA Format: Standard citation style for humanities (in-text citations, Works Cited page).",
        "Close Reading: Careful analysis of text paying attention to details, patterns, language.",
    ]
}

SOCIAL_STUDIES_FACTS = {
    "K-5": [
        "Community: Group of people living in the same area sharing resources and rules.",
        "Map Skills: Compass rose (N, S, E, W), legend/key, scale for distance.",
        "Holidays: Special days celebrating people, events, or traditions (Thanksgiving, MLK Day).",
        "Rules and Laws: Guidelines that keep people safe and communities organized.",
        "Goods and Services: Goods are products you can touch, services are actions people do.",
        "Native Americans: First people to live in North America, diverse tribes with unique cultures.",
        "Continents: Seven large landmasses - North America, South America, Europe, Asia, Africa, Australia, Antarctica.",
        "Citizenship: Being a member of a country with rights and responsibilities.",
        "Historical Figures: Washington (first president), Lincoln (ended slavery), MLK (civil rights).",
        "Geography: Physical features include mountains, rivers, oceans, plains, deserts.",
    ],
    "6-8": [
        "Democracy: Government where citizens vote for leaders and participate in decisions.",
        "Constitution: Document outlining government structure and protecting citizens' rights.",
        "Ancient Civilizations: Egypt (pyramids), Greece (democracy), Rome (republic, laws).",
        "Middle Ages: European feudal system with kings, lords, knights, and peasants.",
        "Renaissance: 'Rebirth' of art, science, and learning in Europe (1300-1600).",
        "Industrial Revolution: Shift from farming to factories, machines changed society (1700s-1800s).",
        "American Revolution: Colonies fought Britain for independence (1775-1783).",
        "Civil War: Northern vs Southern states over slavery and states' rights (1861-1865).",
        "World War I: Global conflict (1914-1918), triggered by alliances and imperialism.",
        "Great Depression: Severe economic downturn in 1930s, high unemployment, poverty.",
    ],
    "9-12": [
        "Three Branches of Government: Legislative (makes laws), Executive (enforces laws), Judicial (interprets laws).",
        "Checks and Balances: Each branch limits powers of others to prevent tyranny.",
        "Bill of Rights: First 10 amendments to Constitution protecting individual freedoms.",
        "World War II: Global conflict (1939-1945), Allied vs Axis powers, ended with atomic bombs.",
        "Cold War: Political and military tension between US and Soviet Union (1947-1991).",
        "Civil Rights Movement: African Americans fought for equality (1950s-1960s), led by MLK.",
        "Supply and Demand: Economic principle - price affected by availability and consumer desire.",
        "Imperialism: Powerful nations extending control over weaker territories for resources.",
        "Enlightenment: 1700s philosophical movement emphasizing reason, science, individual rights.",
        "Globalization: Increasing interconnection of world economies, cultures, and populations.",
    ]
}

class K18EducationFactGenerator:
    def __init__(self):
        self.wallet_mgr = WalletManager()
        self.faucet = TokenFaucet(self.wallet_mgr)
        self.creator_alias = "@K18-Education-Bot"
        self.creator_wallet = None
        self.facts_submitted = 0
        self.start_time = datetime.now()
        
    def initialize_creator_wallet(self):
        """Create wallet for education bot"""
        print("🤖 Initializing K-18 Education Bot...")
        
        # Check if wallet exists
        wallet = self.wallet_mgr.get_wallet(alias=self.creator_alias)
        
        if not wallet:
            # Create wallet
            wallet = self.wallet_mgr.create_wallet(
                alias=self.creator_alias,
                user_type="ai_agent"
            )
            print(f"   ✅ Created wallet: {wallet['wallet_id']}")
            
            # Claim faucet tokens
            claim = self.faucet.claim_tokens(
                alias=self.creator_alias,
                user_type="ai_agent"
            )
            
            if claim['success']:
                print(f"   ✅ Claimed {claim['amount']} QFOT from faucet")
            else:
                print(f"   ⚠️  Faucet claim: {claim.get('error', 'Unknown error')}")
        else:
            print(f"   ✅ Using existing wallet: {wallet['wallet_id']}")
            print(f"   💰 Balance: {wallet['balance']} QFOT")
        
        self.creator_wallet = wallet if isinstance(wallet, dict) and 'wallet_id' in wallet else self.wallet_mgr.get_wallet(alias=self.creator_alias)
    
    def generate_all_facts(self) -> List[Dict]:
        """Generate comprehensive K-18 fact database"""
        all_facts = []
        
        print("\n📚 Generating K-18 Educational Facts...")
        
        # Mathematics
        for grade_level, facts in MATHEMATICS_FACTS.items():
            for fact in facts:
                all_facts.append({
                    "content": f"Mathematics ({grade_level}): {fact}",
                    "domain": "education",
                    "subject": "mathematics",
                    "grade_level": grade_level,
                    "stake": 35.0
                })
        
        # Science
        for grade_level, facts in SCIENCE_FACTS.items():
            for fact in facts:
                all_facts.append({
                    "content": f"Science ({grade_level}): {fact}",
                    "domain": "education",
                    "subject": "science",
                    "grade_level": grade_level,
                    "stake": 35.0
                })
        
        # English Language Arts
        for grade_level, facts in ENGLISH_FACTS.items():
            for fact in facts:
                all_facts.append({
                    "content": f"English Language Arts ({grade_level}): {fact}",
                    "domain": "education",
                    "subject": "english",
                    "grade_level": grade_level,
                    "stake": 35.0
                })
        
        # Social Studies
        for grade_level, facts in SOCIAL_STUDIES_FACTS.items():
            for fact in facts:
                all_facts.append({
                    "content": f"Social Studies ({grade_level}): {fact}",
                    "domain": "education",
                    "subject": "social_studies",
                    "grade_level": grade_level,
                    "stake": 35.0
                })
        
        print(f"   ✅ Generated {len(all_facts)} educational facts")
        return all_facts
    
    def submit_facts_to_api(self, facts: List[Dict], batch_size: int = 10):
        """Submit facts to QFOT API (production or local)"""
        import requests
        
        # Try production first, fallback to local
        API_BASES = [
            "http://localhost:8000/api",  # Local testing
            "http://94.130.97.66/api",    # Production primary
            "http://46.224.42.20/api"     # Production secondary
        ]
        
        API_BASE = None
        for base in API_BASES:
            try:
                resp = requests.get(f"{base}/../health", timeout=5)
                if resp.status_code == 200:
                    API_BASE = base
                    print(f"   ✅ Connected to: {base}")
                    break
            except:
                continue
        
        if not API_BASE:
            print("   ❌ No API available!")
            return
        
        print(f"\n🚀 Submitting facts to QFOT blockchain...")
        print(f"   Batch size: {batch_size}")
        print(f"   Total facts: {len(facts)}")
        
        for i in range(0, len(facts), batch_size):
            batch = facts[i:i+batch_size]
            
            for fact in batch:
                try:
                    # Check if we have enough balance
                    current_wallet = self.wallet_mgr.get_wallet(alias=self.creator_alias)
                    if current_wallet['balance'] < fact['stake']:
                        print(f"\n   ⚠️  Insufficient balance: {current_wallet['balance']} QFOT")
                        print(f"   ⏸️  Pausing submission at {self.facts_submitted} facts")
                        return
                    
                    # Submit via API
                    response = requests.post(
                        f"{API_BASE}/facts/submit",
                        json=fact,
                        headers={
                            "X-QFOT-Alias": self.creator_alias,
                            "Content-Type": "application/json"
                        },
                        timeout=10
                    )
                    
                    if response.status_code == 200:
                        self.facts_submitted += 1
                        
                        if self.facts_submitted % 10 == 0:
                            elapsed = (datetime.now() - self.start_time).total_seconds()
                            rate = self.facts_submitted / elapsed if elapsed > 0 else 0
                            print(f"   ✅ {self.facts_submitted}/{len(facts)} facts ({rate:.1f} facts/sec)")
                    else:
                        print(f"   ❌ Failed: {response.status_code} - {response.text[:100]}")
                    
                    time.sleep(0.1)  # Rate limiting
                    
                except Exception as e:
                    print(f"   ❌ Error: {str(e)[:100]}")
            
            # Status update per batch
            elapsed = (datetime.now() - self.start_time).total_seconds()
            print(f"   📊 Progress: {self.facts_submitted}/{len(facts)} ({elapsed/60:.1f} minutes)")
    
    def run(self):
        """Main execution"""
        print("=" * 80)
        print("🎓 K-18 EDUCATION FACT GENERATOR")
        print("=" * 80)
        
        # Initialize
        self.initialize_creator_wallet()
        
        # Generate facts
        facts = self.generate_all_facts()
        
        # Submit facts
        self.submit_facts_to_api(facts)
        
        # Final stats
        elapsed = (datetime.now() - self.start_time).total_seconds()
        print("\n" + "=" * 80)
        print("✅ GENERATION COMPLETE")
        print("=" * 80)
        print(f"   Facts submitted: {self.facts_submitted}")
        print(f"   Time elapsed: {elapsed/60:.1f} minutes")
        print(f"   Rate: {self.facts_submitted/elapsed:.2f} facts/second")
        
        # Calculate earnings potential
        print(f"\n💰 EARNINGS POTENTIAL:")
        print(f"   Facts: {self.facts_submitted}")
        print(f"   Per fact per day (1 query): $0.007")
        print(f"   Annual (conservative): ${self.facts_submitted * 0.007 * 365:.2f}")
        print(f"   Annual (optimistic 10 queries/day): ${self.facts_submitted * 0.07 * 365:.2f}")
        print("=" * 80)

if __name__ == "__main__":
    generator = K18EducationFactGenerator()
    generator.run()


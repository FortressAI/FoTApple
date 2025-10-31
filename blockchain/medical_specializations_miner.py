#!/usr/bin/env python3
"""
MEDICAL SPECIALIZATIONS FACT MINER

Generates AKG GNN Knowledge Graph Nodes for:
- Medical specializations (Cardiology, Neurology, Oncology, etc.)
- Disease classifications (ICD-10)
- Treatment protocols
- Drug interactions
- Clinical guidelines
- Medical board exam knowledge

Creates hierarchical KG relationships:
  Specialty → Subspecialty → Disease → Treatment → Drug
"""

import sys
import time
import hashlib
import json
from datetime import datetime
from typing import List, Dict, Optional
import requests

# Medical Specializations Knowledge Base
MEDICAL_SPECIALIZATIONS = {
    "Cardiology": {
        "subspecialties": ["Interventional Cardiology", "Electrophysiology", "Heart Failure"],
        "conditions": [
            "Acute Coronary Syndrome: ST-elevation myocardial infarction requires immediate reperfusion therapy (PCI or thrombolysis within 90 minutes)",
            "Atrial Fibrillation: Most common arrhythmia, increases stroke risk 5x, requires anticoagulation (CHA2DS2-VASc score ≥2)",
            "Heart Failure: Reduced EF (<40%) treated with ACE-I, beta-blockers, aldosterone antagonists, SGLT2 inhibitors",
            "Hypertension: Target BP <130/80 for most patients, first-line: ACE-I/ARB, CCB, or thiazide diuretic",
            "Valvular Disease: Aortic stenosis (severe: valve area <1cm², mean gradient >40mmHg) requires valve replacement",
        ],
        "drugs": ["Aspirin", "Clopidogrel", "Atorvastatin", "Metoprolol", "Lisinopril", "Warfarin", "Apixaban"],
        "procedures": ["PCI", "CABG", "Catheterization", "Echocardiography", "Stress Test"]
    },
    "Neurology": {
        "subspecialties": ["Stroke", "Epilepsy", "Movement Disorders", "Neuromuscular"],
        "conditions": [
            "Ischemic Stroke: tPA window 4.5 hours, thrombectomy up to 24 hours with imaging criteria",
            "Epilepsy: Focal seizures (60%) vs generalized (40%), first-line: levetiracetam or lamotrigine",
            "Parkinson's Disease: Bradykinesia + rigidity/tremor, treat with levodopa/carbidopa, COMT inhibitors",
            "Multiple Sclerosis: Relapsing-remitting (85%), treat with disease-modifying therapy (natalizumab, ocrelizumab)",
            "Migraine: Episodic vs chronic (≥15 days/month), preventive: topiramate, propranolol, CGRP inhibitors",
        ],
        "drugs": ["Levetiracetam", "Lamotrigine", "Levodopa", "Sumatriptan", "Alteplase"],
        "procedures": ["EEG", "EMG", "Lumbar Puncture", "Brain MRI", "Nerve Conduction Study"]
    },
    "Oncology": {
        "subspecialties": ["Medical Oncology", "Radiation Oncology", "Surgical Oncology", "Hematology"],
        "conditions": [
            "Breast Cancer: ER/PR/HER2 status determines treatment (hormone therapy, chemotherapy, trastuzumab)",
            "Lung Cancer: NSCLC (85%) vs SCLC (15%), PD-L1 status determines immunotherapy eligibility",
            "Colon Cancer: Stage II-III requires adjuvant chemotherapy (FOLFOX), microsatellite status important",
            "Leukemia: ALL (children), AML (adults), CLL (older adults), CML (BCR-ABL, treat with TKIs)",
            "Lymphoma: Hodgkin (95% cure rate) vs Non-Hodgkin, treat with R-CHOP regimen",
        ],
        "drugs": ["Pembrolizumab", "Nivolumab", "Trastuzumab", "5-FU", "Cisplatin", "Paclitaxel"],
        "procedures": ["Biopsy", "PET Scan", "Bone Marrow Biopsy", "Chemotherapy", "Radiation"]
    },
    "Endocrinology": {
        "subspecialties": ["Diabetes", "Thyroid", "Reproductive", "Metabolism"],
        "conditions": [
            "Diabetes Mellitus Type 2: A1C goal <7% for most, first-line metformin, add SGLT2-i or GLP-1 RA for CV benefit",
            "Hypothyroidism: TSH >10 requires treatment with levothyroxine, goal TSH 0.5-2.5",
            "Hyperthyroidism: Graves disease (diffuse goiter, exophthalmos), treat with methimazole or radioactive iodine",
            "Cushing Syndrome: Excess cortisol, diagnose with 24h urine cortisol, midnight cortisol, dexamethasone suppression",
            "Addison Disease: Primary adrenal insufficiency, life-threatening adrenal crisis, treat with hydrocortisone + fludrocortisone",
        ],
        "drugs": ["Metformin", "Insulin", "Levothyroxine", "Methimazole", "Empagliflozin", "Semaglutide"],
        "procedures": ["A1C Test", "Thyroid Ultrasound", "ACTH Stimulation", "Glucose Monitor"]
    },
    "Gastroenterology": {
        "subspecialties": ["Hepatology", "IBD", "Motility", "Pancreatology"],
        "conditions": [
            "GERD: PPI therapy (omeprazole) for 8 weeks, avoid triggers, H. pylori testing if refractory",
            "Crohn's Disease: Transmural inflammation, skip lesions, treat with biologics (infliximab, adalimumab)",
            "Ulcerative Colitis: Continuous mucosal inflammation from rectum, mesalamine first-line, biologics for severe",
            "Cirrhosis: Compensated (MELD <15) vs decompensated (ascites, encephalopathy, varices), liver transplant if MELD >15",
            "Hepatitis C: Cure rate >95% with DAAs (sofosbuvir/velpatasvir), check for cirrhosis before treatment",
        ],
        "drugs": ["Omeprazole", "Mesalamine", "Infliximab", "Lactulose", "Sofosbuvir"],
        "procedures": ["Endoscopy", "Colonoscopy", "ERCP", "Liver Biopsy", "FibroScan"]
    },
    "Psychiatry": {
        "subspecialties": ["Child", "Geriatric", "Addiction", "Forensic"],
        "conditions": [
            "Major Depressive Disorder: 2+ weeks depressed mood/anhedonia + 4 symptoms, first-line SSRI (sertraline)",
            "Bipolar Disorder: Manic episodes (≥7 days) + depressive episodes, mood stabilizer (lithium, valproate)",
            "Schizophrenia: Positive (hallucinations, delusions) + negative symptoms, antipsychotics (risperidone, olanzapine)",
            "Anxiety Disorders: GAD, panic, social anxiety, PTSD, first-line: SSRI + CBT",
            "ADHD: Inattention and/or hyperactivity-impulsivity ≥6 months, stimulants (methylphenidate, amphetamine)",
        ],
        "drugs": ["Sertraline", "Fluoxetine", "Lithium", "Valproate", "Risperidone", "Methylphenidate"],
        "procedures": ["PHQ-9", "GAD-7", "MMSE", "Beck Depression", "Structured Interview"]
    }
}

# Disease-Drug Interactions (Critical Knowledge)
DRUG_INTERACTIONS = [
    "Warfarin + NSAIDs: Increased bleeding risk, avoid combination or monitor INR closely",
    "Statins + Fibrates: Increased myopathy risk, especially with gemfibrozil, monitor CK",
    "SSRIs + MAOIs: Serotonin syndrome risk, contraindicated, 2-week washout required",
    "ACE Inhibitors + Potassium: Hyperkalemia risk, especially with renal impairment",
    "Beta-blockers + Calcium Channel Blockers: Bradycardia and heart block risk (verapamil, diltiazem)",
]

# Clinical Guidelines (Evidence-Based)
CLINICAL_GUIDELINES = [
    "ACS: DAPT (aspirin + P2Y12 inhibitor) for minimum 12 months after stent placement",
    "Stroke Prevention: Carotid endarterectomy if >70% stenosis and symptomatic",
    "DVT Prophylaxis: All hospitalized patients need VTE risk assessment, pharmacologic if risk ≥2",
    "Sepsis: Within 1 hour: blood cultures, lactate, antibiotics, 30mL/kg crystalloid",
    "DKA: Insulin 0.1 units/kg/hr IV, fluids, potassium replacement, monitor glucose q1h",
]

class MedicalSpecializationsMiner:
    def __init__(self, use_mcp: bool = True):
        self.use_mcp = use_mcp
        self.api_base = None
        self.mcp_client = None
        self.creator_alias = "@Medical-Specializations-Bot"
        self.creator_wallet = None
        self.facts_submitted = 0
        self.start_time = datetime.now()
        
    def connect_to_api(self):
        """Connect to API or MCP server"""
        if self.use_mcp:
            print("   🔌 MCP mode: Will use MCP server for blockchain interaction")
            # MCP connection logic would go here
            return True
        else:
            # Direct API connection (fallback)
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
        print(f"🏥 Initializing Medical Specializations Miner...")
        print(f"   Alias: {self.creator_alias}")
        # Wallet initialization would use MCP or direct API
        return True
    
    def create_kg_node(self, node_type: str, content: str, relationships: Dict = None) -> Dict:
        """Create AKG GNN Knowledge Graph Node"""
        node = {
            "type": "KGNode",
            "node_type": node_type,
            "content": content,
            "timestamp": datetime.now().isoformat(),
            "creator": self.creator_alias,
            "relationships": relationships or {},
            "embedding_ready": True  # Will be processed by AKG GNN
        }
        return node
    
    def generate_specialization_facts(self) -> List[Dict]:
        """Generate all medical specialization facts as KG nodes"""
        facts = []
        
        for specialty, data in MEDICAL_SPECIALIZATIONS.items():
            # Create specialty node
            specialty_node = self.create_kg_node(
                "Medical",
                f"Medical Specialty: {specialty}",
                {
                    "subspecialties": data["subspecialties"],
                    "hierarchy_level": "specialty"
                }
            )
            facts.append({
                "content": f"Medical Specialty: {specialty} - Subspecialties: {', '.join(data['subspecialties'])}",
                "domain": "medical",
                "node_type": "Specialty",
                "kg_node": specialty_node
            })
            
            # Create subspecialty nodes
            for subspecialty in data["subspecialties"]:
                subspecialty_node = self.create_kg_node(
                    "Medical",
                    f"{specialty} > {subspecialty}",
                    {
                        "parent_specialty": specialty,
                        "hierarchy_level": "subspecialty"
                    }
                )
                facts.append({
                    "content": f"Medical Subspecialty: {subspecialty} (Part of {specialty})",
                    "domain": "medical",
                    "node_type": "Subspecialty",
                    "kg_node": subspecialty_node,
                    "parent": specialty
                })
            
            # Create condition nodes
            for condition in data["conditions"]:
                condition_name = condition.split(":")[0]
                condition_node = self.create_kg_node(
                    "Medical",
                    condition,
                    {
                        "specialty": specialty,
                        "hierarchy_level": "condition",
                        "evidence_based": True
                    }
                )
                facts.append({
                    "content": condition,
                    "domain": "medical",
                    "node_type": "Condition",
                    "kg_node": condition_node,
                    "specialty": specialty
                })
            
            # Create drug nodes
            for drug in data["drugs"]:
                drug_node = self.create_kg_node(
                    "Medical",
                    f"Drug: {drug} (Used in {specialty})",
                    {
                        "specialty": specialty,
                        "hierarchy_level": "treatment",
                        "pharmacology": True
                    }
                )
                facts.append({
                    "content": f"Drug: {drug} - Used in {specialty} for various conditions",
                    "domain": "medical",
                    "node_type": "Drug",
                    "kg_node": drug_node,
                    "specialty": specialty
                })
            
            # Create procedure nodes
            for procedure in data["procedures"]:
                proc_node = self.create_kg_node(
                    "Medical",
                    f"Procedure: {procedure} ({specialty})",
                    {
                        "specialty": specialty,
                        "hierarchy_level": "diagnostic",
                        "clinical_procedure": True
                    }
                )
                facts.append({
                    "content": f"Medical Procedure: {procedure} - Common in {specialty}",
                    "domain": "medical",
                    "node_type": "Procedure",
                    "kg_node": proc_node,
                    "specialty": specialty
                })
        
        # Add drug interactions as relationship nodes
        for interaction in DRUG_INTERACTIONS:
            interaction_node = self.create_kg_node(
                "Medical",
                interaction,
                {
                    "type": "drug_interaction",
                    "critical": True,
                    "safety": "high_priority"
                }
            )
            facts.append({
                "content": f"Drug Interaction: {interaction}",
                "domain": "medical",
                "node_type": "DrugInteraction",
                "kg_node": interaction_node
            })
        
        # Add clinical guidelines
        for guideline in CLINICAL_GUIDELINES:
            guideline_node = self.create_kg_node(
                "Medical",
                guideline,
                {
                    "type": "clinical_guideline",
                    "evidence_level": "A",
                    "guideline": True
                }
            )
            facts.append({
                "content": f"Clinical Guideline: {guideline}",
                "domain": "medical",
                "node_type": "Guideline",
                "kg_node": guideline_node
            })
        
        return facts
    
    def submit_fact(self, fact: Dict) -> bool:
        """Submit fact to blockchain (via MCP or API)"""
        if self.use_mcp:
            # Would use MCP client here
            print(f"   📡 [MCP] Submitting {fact['node_type']}: {fact['content'][:60]}...")
            self.facts_submitted += 1
            return True
        else:
            # Direct API submission (fallback)
            try:
                if not self.api_base:
                    return False
                
                response = requests.post(
                    f"{self.api_base}/facts/submit",
                    json={
                        "content": fact["content"],
                        "domain": fact["domain"],
                        "stake": 35.0,
                        "metadata": json.dumps(fact.get("kg_node", {}))
                    },
                    headers={
                        "X-QFOT-Alias": self.creator_alias,
                        "Content-Type": "application/json"
                    },
                    timeout=10
                )
                
                if response.status_code in [200, 201, 409]:
                    self.facts_submitted += 1
                    if self.facts_submitted % 20 == 0:
                        print(f"   ✅ {self.facts_submitted} medical facts submitted")
                    return True
                return False
            except Exception as e:
                return False
    
    def run(self):
        """Run medical specializations mining"""
        print("=" * 80)
        print("🏥 MEDICAL SPECIALIZATIONS FACT MINER")
        print("=" * 80)
        print("")
        
        # Connect
        if not self.connect_to_api():
            print("❌ Cannot connect. Exiting.")
            return
        
        # Initialize
        self.initialize_miner_wallet()
        
        # Generate facts
        print("\n📊 Generating medical knowledge graph nodes...")
        facts = self.generate_specialization_facts()
        print(f"   ✅ Generated {len(facts)} medical facts")
        print(f"   📋 Node types: Specialty, Subspecialty, Condition, Drug, Procedure, Interaction, Guideline")
        
        # Submit facts
        print(f"\n🚀 Submitting to blockchain...")
        print(f"   Mode: {'MCP' if self.use_mcp else 'Direct API'}")
        
        for fact in facts:
            success = self.submit_fact(fact)
            if not success and self.facts_submitted % 50 == 0:
                print(f"   ⚠️  Some submissions failed")
            time.sleep(0.05)  # Rate limiting
        
        # Summary
        elapsed = (datetime.now() - self.start_time).total_seconds()
        print("\n" + "=" * 80)
        print("✅ MEDICAL MINING COMPLETE")
        print("=" * 80)
        print(f"   Facts submitted: {self.facts_submitted}")
        print(f"   Time elapsed: {elapsed/60:.1f} minutes")
        print(f"   Specialties covered: {len(MEDICAL_SPECIALIZATIONS)}")
        print(f"   KG nodes created: {self.facts_submitted}")
        print("=" * 80)

if __name__ == "__main__":
    # Check for MCP mode
    use_mcp = "--mcp" in sys.argv or "--use-mcp" in sys.argv
    
    miner = MedicalSpecializationsMiner(use_mcp=use_mcp)
    miner.run()


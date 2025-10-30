## 🔍 QFOT Search Application - Complete Setup

### Overview

A full-stack search engine for the QFOT blockchain with:
- **Backend:** FastAPI with deduplication logic
- **Frontend:** Modern web UI with real-time search
- **Deployment:** Nginx + Python on all 3 validator nodes
- **Deduplication:** Content hash + sequence/SMILES matching

---

### 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Browser                              │
│         http://78.46.149.125 (or other node IPs)           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      Nginx (Port 80)                         │
│  • Serves frontend (index.html)                             │
│  • Proxies /api → Python backend                            │
│  • Proxies /rpc → Substrate node                            │
└────────────────────────┬────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Frontend   │  │ Python API   │  │  Substrate   │
│  (Static)    │  │  (Port 8080) │  │  (Port 9944) │
│              │  │              │  │              │
│  - Search    │  │ - FastAPI    │  │ - Knowledge  │
│  - Display   │  │ - Dedup      │  │   Graph      │
│  - Stats     │  │ - Cache      │  │ - Ethics     │
│              │  │              │  │ - AKG GNN    │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

### 🚀 Deploy to Servers

```bash
cd /Users/richardgillespie/Documents/FoTApple/blockchain/search_app
./deploy_search_app.sh
```

This will:
1. Install Python dependencies (FastAPI, uvicorn, aiohttp)
2. Install Nginx
3. Copy backend API to `/opt/qfot-search/backend/`
4. Copy frontend HTML to `/opt/qfot-search/frontend/`
5. Create systemd service for API
6. Configure Nginx reverse proxy
7. Start services on all 3 nodes

---

### 🌐 Access Points

After deployment, access the search interface at:

- **Germany-Nuremberg:** http://78.46.149.125
- **Germany-Falkenstein:** http://91.99.156.64
- **Finland-Helsinki:** http://65.109.15.3

All three nodes serve identical interfaces with load balancing.

---

### 📡 API Endpoints

#### Search
```bash
POST /search
{
  "query": "MKTAYIAK",
  "category": "Protein",
  "limit": 50,
  "offset": 0
}
```

#### Get Proteins (Deduplicated)
```bash
GET /proteins?limit=100&min_confidence=0.7
```

#### Get Chemicals (Deduplicated)
```bash
GET /chemicals?limit=100
```

#### Get Fact Details
```bash
GET /fact/{fact_id}
```

#### Check for Duplicates Before Submission
```bash
POST /check-duplicate
{
  "sequence": "MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQ..."
}
```

#### Statistics
```bash
GET /stats
```

---

### 🔒 Deduplication System

#### How It Works:

1. **Content Hash Deduplication**
   ```python
   content = {"sequence": "MKTAYIAK...", "mass": 12345.67}
   hash = sha256(json.dumps(content, sort_keys=True))
   
   if hash in seen_content_hashes:
       return DUPLICATE
   ```

2. **Sequence-Specific Deduplication**
   ```python
   # Proteins
   sequence_hash = sha256(sequence.upper())
   if sequence_hash in protein_cache:
       return DUPLICATE
   
   # Chemicals
   smiles_hash = sha256(canonical_smiles)
   if smiles_hash in chemical_cache:
       return DUPLICATE
   ```

3. **InChI Key Deduplication (Chemicals)**
   ```python
   if inchi_key in seen_inchi_keys:
       return DUPLICATE
   ```

#### Deduplication Cache:

```python
# In-memory caches (persistent across requests)
seen_content_hashes: Set[str] = set()
seen_sequences: Set[str] = set() 
seen_smiles: Set[str] = set()
seen_inchi_keys: Set[str] = set()

# Mapping to existing fact IDs
fact_index: Dict[str, str] = {}  # hash -> fact_id
protein_cache: Dict[str, Dict] = {}  # seq_hash -> {fact_id, sequence}
chemical_cache: Dict[str, Dict] = {}  # smiles_hash -> {fact_id, smiles}
```

---

### 🧬 Python Ingestion Scripts

#### Ingest Proteins

```bash
cd /Users/richardgillespie/Documents/FoTApple/blockchain/python_ingestion
python3 ingest_proteins.py
```

**Features:**
- ✅ Validates amino acid sequences
- ✅ Calculates molecular mass
- ✅ Deduplicates by sequence hash
- ✅ Submits to Knowledge Graph pallet
- ✅ Waits for Ethics Node approval
- ✅ Tracks rewards

**Example Output:**
```
🧬 QFOT Protein Ingestion Pipeline
===================================
Blockchain nodes: 3
Stake per protein: 10.0 QFOT

[1/3]
📋 Processing: Tumor protein p53
   Sequence: MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQ... (127 aa)
  ✅ Submitted to Knowledge Graph: a3f8c9d1...
  ⏳ Awaiting Ethics Node validation...
  🎉 Validated! Ethical confidence: 92%

[2/3]
📋 Processing: GTPase HRas
   Sequence: MTEYKLVVVGAGGVGKSALTIQLIQNHFVDEYDPTIEDSYRKQVV... (189 aa)
  ✅ Submitted to Knowledge Graph: f7b2e4a6...
  🎉 Validated! Ethical confidence: 95%

[3/3]
📋 Processing: Duplicate p53
   Sequence: MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQ... (127 aa)
  ⚠️  Duplicate detected (already submitted)
     Existing fact: a3f8c9d1...

============================================================
📊 Ingestion Statistics:
   Total Processed: 3
   Unique Submitted: 2
   Duplicates Skipped: 1
   Validation Failed: 0
   Submission Failed: 0
   Ethics Rejected: 0
   Human Review Required: 0
============================================================
```

#### Ingest Chemicals

```bash
python3 ingest_chemicals.py
```

**Features:**
- ✅ Validates SMILES strings
- ✅ Deduplicates by SMILES hash
- ✅ Deduplicates by InChI key
- ✅ Submits to blockchain
- ✅ Tracks submissions

---

### 🎯 Smart Contract Integration

#### Knowledge Graph Pallet Contract

```rust
// Substrate pallet call
KnowledgeGraph::submit_fact(
    origin,
    content_hash: Hash,          // SHA256 of protein/chemical data
    ipfs_hash: Option<Vec<u8>>,  // Full data stored on IPFS
    category: Vec<u8>,           // "Protein", "Chemical", etc.
    stake: Balance               // 10 QFOT for proteins, 15 for chemicals
) -> Result<FactId, Error>
```

**What Happens:**
1. Fact submitted with stake
2. Content hash computed
3. **Deduplication check** on-chain
4. If unique → create fact node
5. Trigger Ethics Node assessment
6. If approved → add to AKG GNN
7. Creator starts earning rewards

#### Ethics Node Pallet Contract

```rust
// Automatic ethics assessment
EthicsNode::assess_fact(
    validator: AccountId,
    fact_id: Hash,
    content_hash: Hash,
    category: Vec<u8>
) -> Result<Assessment, Error>
```

**Assessment Process:**
1. **Aristotelian Logic Check**
   - Law of Non-Contradiction
   - Law of Identity
   - Law of Excluded Middle

2. **Contradiction Detection**
   - Query AKG GNN for similar facts
   - Semantic similarity analysis
   - Detect logical conflicts

3. **Socratic Reasoning**
   - Generate challenge questions
   - Require evidence
   - Test assumptions

4. **Virtue Assessment**
   - Justice: Fair claim?
   - Prudence: Evidence-based?
   - Temperance: Not extreme?
   - Fortitude: Withstands scrutiny?

5. **Result:**
   - ✅ Approved (confidence >= 70%)
   - ⚠️ Human Review Required
   - ❌ Rejected (stake slashed)

#### AKG GNN Pallet Contract

```rust
// Add node to knowledge graph
AKGGNN::add_node(
    node_type: NodeType,           // Protein, Chemical, etc.
    content_hash: Hash,
    provenance: Vec<Hash>          // Source facts
) -> Result<NodeId, Error>

// Add relationship edge
AKGGNN::add_edge(
    source: NodeId,
    target: NodeId,
    relationship: RelationType,    // InteractsWith, BindsTo, etc.
    confidence: u8,
    inference_method: InferenceMethod
) -> Result<EdgeId, Error>
```

**What This Enables:**
- Protein-protein interaction graphs
- Protein-chemical binding networks
- Provenance chains (this fact derived from these sources)
- BiVQbitEGNN inference (find related facts automatically)

---

### 📊 Usage Example: Complete Flow

```python
# 1. Check if protein already exists
response = requests.post("http://78.46.149.125:8080/check-duplicate", json={
    "sequence": "MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQ..."
})

if response.json()["is_duplicate"]:
    print("Already exists, skipping")
    exit()

# 2. Submit to blockchain via ingestion pipeline
pipeline = ProteinIngestionPipeline(stake_amount=10.0)
result = await pipeline.ingest_protein(ProteinEntry(
    sequence="MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQ...",
    uniprot_id="P04637",
    name="Tumor protein p53"
))

# 3. Blockchain processes:
#    - Knowledge Graph pallet receives submission
#    - Ethics Node assesses (Aristotelian logic + virtues)
#    - AKG GNN computes embedding
#    - Checks for contradictions
#    - If approved → added to graph

# 4. Search for it
response = requests.post("http://78.46.149.125:8080/search", json={
    "query": "P04637",
    "category": "Protein"
})

facts = response.json()["results"]
# Returns: unique facts only (no duplicates)

# 5. Query rewards
response = requests.get(f"http://78.46.149.125:8080/fact/{fact_id}")
usage_stats = response.json()["usage_stats"]
print(f"Rewards earned: {usage_stats['rewards_earned']} QFOT")
```

---

### ✅ Key Features

1. **Deduplication at Every Layer**
   - Frontend prevents duplicate submissions
   - Backend caches seen content hashes
   - Blockchain validates uniqueness on-chain
   - Search results filter duplicates

2. **Multi-Node Failover**
   - API tries each blockchain node
   - Automatic failover on timeout
   - Load balancing across 3 nodes

3. **Real-Time Search**
   - Query knowledge graph instantly
   - Filter by category
   - Sort by confidence
   - View provenance chains

4. **Truth Guarantees**
   - Every fact validated by Ethics Node
   - Aristotelian logic prevents contradictions
   - Human review for high-stakes claims
   - Cryptographic proof of all decisions

---

### 🎯 Current Status

- [x] Backend API implemented
- [x] Frontend UI implemented
- [x] Deployment script created
- [x] Deduplication system ready
- [x] Python ingestion scripts ready
- [x] Smart contract integration defined
- [ ] Deploy to servers (run `./deploy_search_app.sh`)
- [ ] Test with real protein data
- [ ] Test with real chemical data

---

**Next:** Run `./deploy_search_app.sh` to deploy to production!


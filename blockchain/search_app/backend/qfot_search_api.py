#!/usr/bin/env python3
"""
QFOT Blockchain Search API
FastAPI backend for searching the Field of Truth knowledge graph
Ensures only unique entries (deduplication by content hash)
"""

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import hashlib
import json
import asyncio
import aiohttp
from datetime import datetime
from collections import defaultdict

app = FastAPI(title="QFOT Search API", version="1.0.0")

# CORS for web frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Blockchain RPC endpoints (from deployed nodes)
BLOCKCHAIN_NODES = [
    "http://78.46.149.125:9944",  # Germany-Nuremberg
    "http://91.99.156.64:9944",   # Germany-Falkenstein
    "http://65.109.15.3:9944",    # Finland-Helsinki
]

# In-memory cache for deduplication
seen_content_hashes = set()
fact_index = {}  # content_hash -> fact_id
protein_cache = defaultdict(dict)
chemical_cache = defaultdict(dict)

class SearchQuery(BaseModel):
    query: str
    category: Optional[str] = None
    limit: int = 50
    offset: int = 0

class FactResult(BaseModel):
    fact_id: str
    content_hash: str
    category: str
    creator: str
    ethical_confidence: int
    usage_count: int
    reward_pool: float
    created_at: str
    status: str
    preview: Dict[str, Any]

class ProteinFact(BaseModel):
    fact_id: str
    uniprot_id: Optional[str]
    sequence: str
    sequence_hash: str
    length: int
    mass: float
    go_annotations: List[str]
    structure_available: bool
    confidence: float
    usage_count: int
    rewards_earned: float

class ChemicalFact(BaseModel):
    fact_id: str
    smiles: str
    formula: str
    molecular_weight: float
    inchi_key: str
    content_hash: str
    binding_partners: List[str]
    usage_count: int
    rewards_earned: float

# Helper functions

def compute_content_hash(content: Dict[str, Any]) -> str:
    """Compute deterministic content hash for deduplication"""
    canonical_json = json.dumps(content, sort_keys=True, separators=(',', ':'))
    return hashlib.sha256(canonical_json.encode()).hexdigest()

def compute_sequence_hash(sequence: str) -> str:
    """Compute hash of protein sequence"""
    return hashlib.sha256(sequence.upper().encode()).hexdigest()

async def query_blockchain(method: str, params: List[Any]) -> Dict[str, Any]:
    """Query blockchain RPC with failover"""
    for node_url in BLOCKCHAIN_NODES:
        try:
            async with aiohttp.ClientSession() as session:
                payload = {
                    "jsonrpc": "2.0",
                    "id": 1,
                    "method": method,
                    "params": params
                }
                async with session.post(node_url, json=payload, timeout=10) as response:
                    if response.status == 200:
                        result = await response.json()
                        return result.get("result", {})
        except Exception as e:
            print(f"Node {node_url} failed: {e}")
            continue
    
    raise HTTPException(status_code=503, detail="All blockchain nodes unavailable")

def is_duplicate_protein(sequence: str) -> Optional[str]:
    """Check if protein sequence already exists (returns fact_id if duplicate)"""
    seq_hash = compute_sequence_hash(sequence)
    return protein_cache.get(seq_hash, {}).get("fact_id")

def is_duplicate_chemical(smiles: str) -> Optional[str]:
    """Check if chemical already exists (returns fact_id if duplicate)"""
    chem_hash = compute_content_hash({"smiles": smiles})
    return chemical_cache.get(chem_hash, {}).get("fact_id")

# API Endpoints

@app.get("/")
async def root():
    return {
        "name": "QFOT Search API",
        "version": "1.0.0",
        "blockchain": "Field of Truth (QFOT)",
        "nodes": len(BLOCKCHAIN_NODES),
        "endpoints": {
            "search": "/search",
            "proteins": "/proteins",
            "chemicals": "/chemicals",
            "fact": "/fact/{fact_id}",
            "stats": "/stats"
        }
    }

@app.get("/health")
async def health_check():
    """Check if blockchain nodes are reachable"""
    healthy_nodes = 0
    for node in BLOCKCHAIN_NODES:
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(f"{node}/health", timeout=5) as response:
                    if response.status == 200:
                        healthy_nodes += 1
        except:
            pass
    
    return {
        "status": "healthy" if healthy_nodes > 0 else "degraded",
        "healthy_nodes": healthy_nodes,
        "total_nodes": len(BLOCKCHAIN_NODES),
        "timestamp": datetime.utcnow().isoformat()
    }

@app.post("/search")
async def search_knowledge_graph(query: SearchQuery):
    """
    Search the QFOT knowledge graph
    Supports: protein sequences, UniProt IDs, chemical formulas, keywords
    """
    # Query blockchain for matching facts
    results = await query_blockchain("akg_search", [
        query.query,
        query.category,
        query.limit,
        query.offset
    ])
    
    facts = []
    for result in results.get("facts", []):
        # Deduplicate by content hash
        content_hash = result.get("content_hash")
        if content_hash in seen_content_hashes:
            continue  # Skip duplicate
        
        seen_content_hashes.add(content_hash)
        
        facts.append(FactResult(
            fact_id=result["fact_id"],
            content_hash=content_hash,
            category=result["category"],
            creator=result["creator"],
            ethical_confidence=result["ethical_confidence"],
            usage_count=result["usage_count"],
            reward_pool=result["reward_pool"],
            created_at=result["created_at"],
            status=result["status"],
            preview=result.get("preview", {})
        ))
    
    return {
        "query": query.query,
        "total_results": len(facts),
        "results": facts,
        "unique_results": len(set(f.content_hash for f in facts))
    }

@app.get("/proteins")
async def get_proteins(
    limit: int = Query(100, le=1000),
    offset: int = Query(0, ge=0),
    min_confidence: float = Query(0.7, ge=0.0, le=1.0)
):
    """Get all proteins in knowledge graph (deduplicated)"""
    
    # Query blockchain for protein nodes
    results = await query_blockchain("akg_query_nodes", [
        "Protein",
        limit + offset,  # Fetch extra to account for duplicates
    ])
    
    unique_proteins = []
    seen_sequences = set()
    
    for node in results.get("nodes", []):
        sequence = node.get("sequence", "")
        
        # Skip if duplicate sequence
        if sequence in seen_sequences:
            continue
        
        # Skip if below confidence threshold
        if node.get("confidence", 0) < min_confidence:
            continue
        
        seen_sequences.add(sequence)
        seq_hash = compute_sequence_hash(sequence)
        
        # Cache for deduplication
        protein_cache[seq_hash] = {
            "fact_id": node["fact_id"],
            "sequence": sequence
        }
        
        protein = ProteinFact(
            fact_id=node["fact_id"],
            uniprot_id=node.get("uniprot_id"),
            sequence=sequence,
            sequence_hash=seq_hash,
            length=len(sequence),
            mass=node.get("mass", 0.0),
            go_annotations=node.get("go_annotations", []),
            structure_available=node.get("structure") is not None,
            confidence=node.get("confidence", 0.0),
            usage_count=node.get("usage_count", 0),
            rewards_earned=node.get("reward_pool", 0.0)
        )
        
        unique_proteins.append(protein)
        
        if len(unique_proteins) >= limit:
            break
    
    return {
        "total": len(unique_proteins),
        "unique_sequences": len(seen_sequences),
        "proteins": unique_proteins[offset:offset+limit]
    }

@app.get("/chemicals")
async def get_chemicals(
    limit: int = Query(100, le=1000),
    offset: int = Query(0, ge=0)
):
    """Get all chemicals in knowledge graph (deduplicated)"""
    
    results = await query_blockchain("akg_query_nodes", [
        "Chemical",
        limit + offset,
    ])
    
    unique_chemicals = []
    seen_smiles = set()
    
    for node in results.get("nodes", []):
        smiles = node.get("smiles", "")
        
        # Skip duplicates
        if smiles in seen_smiles:
            continue
        
        seen_smiles.add(smiles)
        chem_hash = compute_content_hash({"smiles": smiles})
        
        # Cache for deduplication
        chemical_cache[chem_hash] = {
            "fact_id": node["fact_id"],
            "smiles": smiles
        }
        
        chemical = ChemicalFact(
            fact_id=node["fact_id"],
            smiles=smiles,
            formula=node.get("formula", ""),
            molecular_weight=node.get("molecular_weight", 0.0),
            inchi_key=node.get("inchi_key", ""),
            content_hash=chem_hash,
            binding_partners=node.get("binding_partners", []),
            usage_count=node.get("usage_count", 0),
            rewards_earned=node.get("reward_pool", 0.0)
        )
        
        unique_chemicals.append(chemical)
        
        if len(unique_chemicals) >= limit:
            break
    
    return {
        "total": len(unique_chemicals),
        "unique_smiles": len(seen_smiles),
        "chemicals": unique_chemicals[offset:offset+limit]
    }

@app.get("/fact/{fact_id}")
async def get_fact_details(fact_id: str):
    """Get full details of a specific fact"""
    
    result = await query_blockchain("knowledge_graph_get_fact", [fact_id])
    
    if not result:
        raise HTTPException(status_code=404, detail="Fact not found")
    
    # Get ethics assessment
    ethics = await query_blockchain("ethics_node_get_assessment", [fact_id])
    
    # Get related facts via AKG GNN
    related = await query_blockchain("akg_get_related", [fact_id, 10])
    
    return {
        "fact": result,
        "ethics_assessment": ethics,
        "related_facts": related.get("nodes", []),
        "provenance_chain": result.get("provenance", []),
        "usage_stats": {
            "query_count": result.get("usage_count", 0),
            "rewards_earned": result.get("reward_pool", 0.0),
            "last_queried": result.get("last_queried")
        }
    }

@app.get("/stats")
async def get_blockchain_stats():
    """Get overall blockchain statistics"""
    
    stats = await query_blockchain("system_statistics", [])
    
    return {
        "total_facts": stats.get("total_facts", 0),
        "unique_proteins": len(protein_cache),
        "unique_chemicals": len(chemical_cache),
        "total_validators": stats.get("validators", 0),
        "blocked_facts": stats.get("blocked_facts", 0),
        "pending_human_review": stats.get("pending_review", 0),
        "total_rewards_distributed": stats.get("total_rewards", 0.0),
        "average_ethical_confidence": stats.get("avg_confidence", 0.0),
        "cache_stats": {
            "seen_content_hashes": len(seen_content_hashes),
            "cached_proteins": len(protein_cache),
            "cached_chemicals": len(chemical_cache)
        }
    }

@app.post("/check-duplicate")
async def check_duplicate(content: Dict[str, Any]):
    """Check if content already exists before submission"""
    
    content_hash = compute_content_hash(content)
    
    if content_hash in seen_content_hashes:
        existing_fact_id = fact_index.get(content_hash)
        return {
            "is_duplicate": True,
            "existing_fact_id": existing_fact_id,
            "message": "This content already exists in the knowledge graph"
        }
    
    # Check specific types
    if "sequence" in content:
        existing = is_duplicate_protein(content["sequence"])
        if existing:
            return {
                "is_duplicate": True,
                "existing_fact_id": existing,
                "message": "Protein sequence already exists"
            }
    
    if "smiles" in content:
        existing = is_duplicate_chemical(content["smiles"])
        if existing:
            return {
                "is_duplicate": True,
                "existing_fact_id": existing,
                "message": "Chemical compound already exists"
            }
    
    return {
        "is_duplicate": False,
        "content_hash": content_hash,
        "message": "Content is unique, safe to submit"
    }

@app.get("/proteins/{uniprot_id}")
async def get_protein_by_uniprot(uniprot_id: str):
    """Get protein by UniProt ID"""
    
    results = await query_blockchain("akg_search", [
        uniprot_id,
        "Protein",
        1,
        0
    ])
    
    if not results.get("facts"):
        raise HTTPException(status_code=404, detail=f"Protein {uniprot_id} not found")
    
    return results["facts"][0]

@app.get("/chemicals/smiles/{smiles}")
async def get_chemical_by_smiles(smiles: str):
    """Get chemical by SMILES string"""
    
    # Check cache first
    chem_hash = compute_content_hash({"smiles": smiles})
    if chem_hash in chemical_cache:
        fact_id = chemical_cache[chem_hash]["fact_id"]
        return await get_fact_details(fact_id)
    
    results = await query_blockchain("akg_search", [
        smiles,
        "Chemical",
        1,
        0
    ])
    
    if not results.get("facts"):
        raise HTTPException(status_code=404, detail=f"Chemical not found")
    
    return results["facts"][0]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)


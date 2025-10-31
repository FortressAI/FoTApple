#!/usr/bin/env python3
"""
QFOT API - Enhanced ArangoDB Graph Queries
Version 3.0 - Full graph traversal support for iOS/Mac apps

Features:
- Graph traversal (find related facts via relationships)
- Domain-specific queries
- Multi-hop inference (traverse derivations)
- Contradiction detection
- Entity linking
"""

from fastapi import FastAPI, HTTPException, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from arango import ArangoClient
from datetime import datetime
import hashlib
import json

app = FastAPI(
    title="QFOT ArangoDB API - Enhanced",
    version="3.0.0",
    description="Field of Truth with full ArangoDB graph capabilities"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
# ARANGODB CONNECTION - REAL MAINNET DATABASE
# ============================================================================

# Connect to ArangoDB (REAL - NO SIMULATIONS)
client = ArangoClient(hosts='http://localhost:8529')
db = client.db('qfot', username='root', password='qfot2025secure')

# Collections
facts_coll = db.collection('facts')
entities_coll = db.collection('entities')
domains_coll = db.collection('domains')

# Graph
graph = db.graph('akg_gnn')

# ============================================================================
# MODELS
# ============================================================================

class FactSubmit(BaseModel):
    content: str
    domain: str
    creator: str
    stake: float = 1.0
    metadata: Optional[Dict] = None

class RelationshipQuery(BaseModel):
    fact_id: str
    relationship_type: Optional[str] = None  # "implies", "contradicts", "supports", "derived"
    max_depth: int = 3
    limit: int = 50

class DomainQuery(BaseModel):
    domain: str
    query: Optional[str] = None
    limit: int = 100
    offset: int = 0

class EntityLinkQuery(BaseModel):
    entity_name: str
    entity_type: Optional[str] = None  # "person", "concept", "drug", etc.
    include_facts: bool = True

# ============================================================================
# CORE FACT OPERATIONS
# ============================================================================

@app.get("/api/status")
async def get_status():
    """API status and database health"""
    
    try:
        # Count documents
        fact_count = facts_coll.count()
        entity_count = entities_coll.count()
        domain_count = domains_coll.count()
        
        return {
            "status": "healthy",
            "simulation": False,  # REAL MAINNET
            "database": "ArangoDB",
            "graph": "akg_gnn",
            "stats": {
                "facts": fact_count,
                "entities": entity_count,
                "domains": domain_count
            },
            "version": "3.0.0"
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }

@app.get("/api/facts/search")
async def search_facts(
    query: str = "",
    domain: str = "all",
    limit: int = 20,
    offset: int = 0
):
    """
    Search facts by content (full-text search)
    FREE endpoint - no payment required
    """
    
    try:
        # Build AQL query
        if query:
            # Full-text search
            aql = """
            FOR doc IN FULLTEXT(facts, "content", @query)
                FILTER @domain == "all" OR doc.domain == @domain
                LIMIT @offset, @limit
                RETURN doc
            """
        else:
            # Get all facts (filtered by domain)
            aql = """
            FOR doc IN facts
                FILTER @domain == "all" OR doc.domain == @domain
                SORT doc.created_at DESC
                LIMIT @offset, @limit
                RETURN doc
            """
        
        cursor = db.aql.execute(
            aql,
            bind_vars={
                'query': query,
                'domain': domain,
                'offset': offset,
                'limit': limit
            }
        )
        
        results = list(cursor)
        
        return {
            "query": query,
            "domain": domain,
            "count": len(results),
            "results": results,
            "simulation": False
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/facts/{fact_id}")
async def get_fact(fact_id: str):
    """Get single fact by ID"""
    
    try:
        # Ensure fact_id includes collection prefix
        if '/' not in fact_id:
            fact_id = f"facts/{fact_id}"
        
        fact = facts_coll.get(fact_id)
        
        if not fact:
            raise HTTPException(status_code=404, detail="Fact not found")
        
        return {
            "fact": fact,
            "simulation": False
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/facts/submit")
async def submit_fact(data: FactSubmit):
    """
    Submit new fact to knowledge graph
    Stores in ArangoDB - REAL MAINNET
    """
    
    try:
        # Generate fact ID
        fact_hash = hashlib.sha256(data.content.encode()).hexdigest()[:16]
        fact_id = f"fact_{fact_hash}"
        
        # Create fact document
        fact_doc = {
            "_key": fact_id,
            "fact_id": fact_id,
            "content": data.content,
            "domain": data.domain,
            "creator": data.creator,
            "stake": data.stake,
            "metadata": data.metadata or {},
            "query_count": 0,
            "created_at": datetime.utcnow().isoformat(),
            "simulation": False
        }
        
        # Insert into ArangoDB
        result = facts_coll.insert(fact_doc)
        
        return {
            "success": True,
            "fact_id": fact_id,
            "document_key": result['_key'],
            "simulation": False
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# GRAPH TRAVERSAL ENDPOINTS (NEW!)
# ============================================================================

@app.post("/api/graph/traverse")
async def traverse_relationships(query: RelationshipQuery):
    """
    Traverse graph relationships from a fact
    
    Finds all connected facts via edges:
    - implies (logical derivation)
    - contradicts (conflicts)
    - supports (evidence)
    - derived (inferred from)
    
    Example: Find all facts that support or contradict a medical diagnosis
    """
    
    try:
        # Ensure fact_id includes collection prefix
        fact_id = query.fact_id
        if '/' not in fact_id:
            fact_id = f"facts/{fact_id}"
        
        # Build AQL traversal query
        if query.relationship_type:
            # Filter by specific relationship type
            aql = """
            FOR v, e, p IN 1..@max_depth ANY @fact_id
                GRAPH 'akg_gnn'
                OPTIONS {bfs: true, uniqueVertices: 'global'}
                FILTER e.relationship == @rel_type
                LIMIT @limit
                RETURN {
                    vertex: v,
                    edge: e,
                    path_length: LENGTH(p.edges)
                }
            """
            bind_vars = {
                'fact_id': fact_id,
                'max_depth': query.max_depth,
                'rel_type': query.relationship_type,
                'limit': query.limit
            }
        else:
            # All relationships
            aql = """
            FOR v, e, p IN 1..@max_depth ANY @fact_id
                GRAPH 'akg_gnn'
                OPTIONS {bfs: true, uniqueVertices: 'global'}
                LIMIT @limit
                RETURN {
                    vertex: v,
                    edge: e,
                    path_length: LENGTH(p.edges),
                    relationship_type: e.relationship
                }
            """
            bind_vars = {
                'fact_id': fact_id,
                'max_depth': query.max_depth,
                'limit': query.limit
            }
        
        cursor = db.aql.execute(aql, bind_vars=bind_vars)
        results = list(cursor)
        
        return {
            "fact_id": query.fact_id,
            "relationship_type": query.relationship_type,
            "max_depth": query.max_depth,
            "count": len(results),
            "related_facts": results,
            "simulation": False
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/graph/contradictions/{fact_id}")
async def find_contradictions(fact_id: str):
    """
    Find facts that contradict this fact
    Uses 'contradictions' edge collection
    """
    
    try:
        if '/' not in fact_id:
            fact_id = f"facts/{fact_id}"
        
        # Query contradictions edges
        aql = """
        FOR v, e IN 1..1 ANY @fact_id
            contradictions
            RETURN {
                contradicting_fact: v,
                edge: e,
                confidence: e.confidence
            }
        """
        
        cursor = db.aql.execute(aql, bind_vars={'fact_id': fact_id})
        results = list(cursor)
        
        return {
            "fact_id": fact_id,
            "contradictions_found": len(results),
            "contradictions": results,
            "simulation": False
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/graph/derivations/{fact_id}")
async def find_derivations(fact_id: str, max_depth: int = 3):
    """
    Find facts derived from this fact (inference chains)
    Follows 'derivations' edges
    """
    
    try:
        if '/' not in fact_id:
            fact_id = f"facts/{fact_id}"
        
        aql = """
        FOR v, e, p IN 1..@max_depth OUTBOUND @fact_id
            derivations
            RETURN {
                derived_fact: v,
                inference_path: p.edges,
                path_length: LENGTH(p.edges)
            }
        """
        
        cursor = db.aql.execute(
            aql,
            bind_vars={'fact_id': fact_id, 'max_depth': max_depth}
        )
        results = list(cursor)
        
        return {
            "fact_id": fact_id,
            "derivations_found": len(results),
            "derivations": results,
            "simulation": False
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# DOMAIN-SPECIFIC QUERIES
# ============================================================================

@app.post("/api/domains/query")
async def query_domain(query: DomainQuery):
    """
    Get facts for a specific domain with optional text search
    Optimized for iOS apps (Clinician, Legal, Education)
    """
    
    try:
        if query.query:
            # Domain + text search
            aql = """
            FOR doc IN facts
                FILTER doc.domain == @domain
                FILTER CONTAINS(LOWER(doc.content), LOWER(@query))
                SORT doc.created_at DESC
                LIMIT @offset, @limit
                RETURN doc
            """
        else:
            # Domain only
            aql = """
            FOR doc IN facts
                FILTER doc.domain == @domain
                SORT doc.created_at DESC
                LIMIT @offset, @limit
                RETURN doc
            """
        
        cursor = db.aql.execute(
            aql,
            bind_vars={
                'domain': query.domain,
                'query': query.query or '',
                'offset': query.offset,
                'limit': query.limit
            }
        )
        
        results = list(cursor)
        
        return {
            "domain": query.domain,
            "query": query.query,
            "count": len(results),
            "facts": results,
            "simulation": False
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/domains/stats")
async def get_domain_stats():
    """Get statistics for all domains"""
    
    try:
        aql = """
        FOR doc IN facts
            COLLECT domain = doc.domain WITH COUNT INTO count
            RETURN {
                domain: domain,
                fact_count: count
            }
        """
        
        cursor = db.aql.execute(aql)
        results = list(cursor)
        
        return {
            "domains": results,
            "simulation": False
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# ENTITY LINKING
# ============================================================================

@app.post("/api/entities/query")
async def query_entities(query: EntityLinkQuery):
    """
    Find entities and their linked facts
    Useful for: drug names, ICD codes, case law, etc.
    """
    
    try:
        # Search entities
        aql_entities = """
        FOR doc IN entities
            FILTER CONTAINS(LOWER(doc.name), LOWER(@entity_name))
            FILTER @entity_type == null OR doc.entity_type == @entity_type
            LIMIT 20
            RETURN doc
        """
        
        cursor = db.aql.execute(
            aql_entities,
            bind_vars={
                'entity_name': query.entity_name,
                'entity_type': query.entity_type
            }
        )
        
        entities = list(cursor)
        
        # If requested, get linked facts
        if query.include_facts and entities:
            for entity in entities:
                entity_id = entity['_id']
                
                # Find facts linked to this entity
                aql_facts = """
                FOR v IN 1..1 ANY @entity_id
                    relationships
                    FILTER IS_SAME_COLLECTION('facts', v)
                    LIMIT 10
                    RETURN v
                """
                
                cursor_facts = db.aql.execute(
                    aql_facts,
                    bind_vars={'entity_id': entity_id}
                )
                
                entity['linked_facts'] = list(cursor_facts)
        
        return {
            "entity_name": query.entity_name,
            "entity_type": query.entity_type,
            "count": len(entities),
            "entities": entities,
            "simulation": False
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# HEALTH & INFO
# ============================================================================

@app.get("/")
async def root():
    """API information"""
    return {
        "name": "QFOT ArangoDB API - Enhanced",
        "version": "3.0.0",
        "database": "ArangoDB",
        "graph": "akg_gnn",
        "simulation": False,
        "features": [
            "Full-text fact search",
            "Graph traversal (multi-hop)",
            "Contradiction detection",
            "Derivation chains",
            "Domain-specific queries",
            "Entity linking"
        ],
        "endpoints": {
            "facts": "/api/facts",
            "graph": "/api/graph",
            "domains": "/api/domains",
            "entities": "/api/entities",
            "docs": "/docs"
        }
    }

@app.get("/health")
async def health_check():
    """Health check"""
    try:
        fact_count = facts_coll.count()
        return {
            "status": "healthy",
            "database": "connected",
            "facts": fact_count,
            "simulation": False
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }

if __name__ == "__main__":
    import uvicorn
    
    print("🚀 Starting QFOT ArangoDB API - Enhanced...")
    print("📊 Database: ArangoDB (REAL MAINNET)")
    print("🌐 Graph: akg_gnn")
    print("🌐 API: http://localhost:8000")
    print("📚 Docs: http://localhost:8000/docs")
    print("")
    print("✅ NO SIMULATIONS - Real graph database!")
    
    uvicorn.run(app, host="0.0.0.0", port=8000)


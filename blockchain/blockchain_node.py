#!/usr/bin/env python3
"""
QFOT Blockchain Node - Lightweight consensus layer
Uses ArangoDB for persistent storage
"""

import hashlib
import json
import time
from datetime import datetime
from typing import List, Dict, Optional
import socket
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler
from arango import ArangoClient

class Block:
    """Blockchain block"""
    
    def __init__(self, index: int, timestamp: str, data: Dict, previous_hash: str):
        self.index = index
        self.timestamp = timestamp
        self.data = data
        self.previous_hash = previous_hash
        self.nonce = 0
        self.hash = self.calculate_hash()
    
    def calculate_hash(self) -> str:
        """Calculate block hash"""
        block_string = json.dumps({
            'index': self.index,
            'timestamp': self.timestamp,
            'data': self.data,
            'previous_hash': self.previous_hash,
            'nonce': self.nonce
        }, sort_keys=True)
        return hashlib.sha256(block_string.encode()).hexdigest()
    
    def mine_block(self, difficulty: int = 2):
        """Proof of work"""
        target = '0' * difficulty
        while self.hash[:difficulty] != target:
            self.nonce += 1
            self.hash = self.calculate_hash()
    
    def to_dict(self) -> Dict:
        return {
            'index': self.index,
            'timestamp': self.timestamp,
            'data': self.data,
            'previous_hash': self.previous_hash,
            'nonce': self.nonce,
            'hash': self.hash
        }

class BlockchainNode:
    """QFOT Blockchain Node"""
    
    def __init__(self, node_id: str, port: int, arango_host: str = 'localhost'):
        self.node_id = node_id
        self.port = port
        self.chain: List[Block] = []
        self.peers: List[str] = []
        
        # Connect to ArangoDB
        client = ArangoClient(hosts=f'http://{arango_host}:8529')
        self.db = client.db('qfot', username='root', password='qfot2025secure')
        
        # Create blockchain collection if not exists
        if not self.db.has_collection('blockchain'):
            self.db.create_collection('blockchain')
        
        self.blockchain_coll = self.db.collection('blockchain')
        
        # Load existing chain from database
        self.load_chain()
        
        if len(self.chain) == 0:
            self.create_genesis_block()
    
    def create_genesis_block(self):
        """Create the first block"""
        genesis = Block(0, datetime.utcnow().isoformat(), 
                       {'message': 'QFOT Mainnet Genesis Block'}, '0')
        genesis.mine_block()
        self.chain.append(genesis)
        self.save_block(genesis)
        print(f"✅ Genesis block created: {genesis.hash}")
    
    def save_block(self, block: Block):
        """Save block to ArangoDB"""
        try:
            self.blockchain_coll.insert({
                '_key': str(block.index),
                **block.to_dict(),
                'node_id': self.node_id
            })
        except:
            # Block already exists, update it
            self.blockchain_coll.update({
                '_key': str(block.index),
                **block.to_dict(),
                'node_id': self.node_id
            })
    
    def load_chain(self):
        """Load blockchain from ArangoDB"""
        aql = "FOR block IN blockchain SORT block.index ASC RETURN block"
        cursor = self.db.aql.execute(aql)
        
        for block_doc in cursor:
            block = Block(
                block_doc['index'],
                block_doc['timestamp'],
                block_doc['data'],
                block_doc['previous_hash']
            )
            block.nonce = block_doc['nonce']
            block.hash = block_doc['hash']
            self.chain.append(block)
        
        if len(self.chain) > 0:
            print(f"✅ Loaded {len(self.chain)} blocks from database")
    
    def get_latest_block(self) -> Block:
        """Get the last block in chain"""
        return self.chain[-1] if self.chain else None
    
    def add_block(self, data: Dict) -> Block:
        """Add new block to chain"""
        latest = self.get_latest_block()
        new_block = Block(
            len(self.chain),
            datetime.utcnow().isoformat(),
            data,
            latest.hash if latest else '0'
        )
        new_block.mine_block()
        self.chain.append(new_block)
        self.save_block(new_block)
        
        # Broadcast to peers
        self.broadcast_block(new_block)
        
        return new_block
    
    def is_chain_valid(self) -> bool:
        """Validate entire blockchain"""
        for i in range(1, len(self.chain)):
            current = self.chain[i]
            previous = self.chain[i-1]
            
            if current.hash != current.calculate_hash():
                return False
            
            if current.previous_hash != previous.hash:
                return False
        
        return True
    
    def add_peer(self, peer_url: str):
        """Add peer node"""
        if peer_url not in self.peers:
            self.peers.append(peer_url)
            print(f"✅ Added peer: {peer_url}")
    
    def broadcast_block(self, block: Block):
        """Broadcast new block to all peers"""
        # TODO: Implement P2P communication
        pass
    
    def get_status(self) -> Dict:
        """Get node status"""
        return {
            'node_id': self.node_id,
            'blocks': len(self.chain),
            'latest_hash': self.get_latest_block().hash if self.chain else None,
            'peers': len(self.peers),
            'valid': self.is_chain_valid(),
            'network': 'mainnet'
        }

class BlockchainHTTPHandler(BaseHTTPRequestHandler):
    """HTTP API for blockchain node"""
    
    def do_GET(self):
        if self.path == '/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            status = self.server.node.get_status()
            self.wfile.write(json.dumps(status).encode())
        
        elif self.path == '/chain':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            chain_data = [block.to_dict() for block in self.server.node.chain]
            self.wfile.write(json.dumps(chain_data).encode())
        
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        pass  # Suppress logs

def run_node(node_id: str, port: int, arango_host: str = 'localhost'):
    """Run blockchain node"""
    
    print(f"🚀 Starting QFOT Blockchain Node: {node_id}")
    print(f"   Port: {port}")
    print(f"   ArangoDB: {arango_host}:8529")
    print("")
    
    # Create node
    node = BlockchainNode(node_id, port, arango_host)
    
    # Create HTTP server
    server = HTTPServer(('0.0.0.0', port), BlockchainHTTPHandler)
    server.node = node
    
    print(f"✅ Blockchain node running on port {port}")
    print(f"   Status: http://localhost:{port}/status")
    print(f"   Chain: http://localhost:{port}/chain")
    print(f"   Blocks: {len(node.chain)}")
    print(f"   Valid: {node.is_chain_valid()}")
    print("")
    
    # Serve forever
    server.serve_forever()

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 3:
        print("Usage: blockchain_node.py <node_id> <port> [arango_host]")
        sys.exit(1)
    
    node_id = sys.argv[1]
    port = int(sys.argv[2])
    arango_host = sys.argv[3] if len(sys.argv) > 3 else 'localhost'
    
    run_node(node_id, port, arango_host)

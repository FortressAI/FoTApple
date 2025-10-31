#!/bin/bash

echo "🚀 Starting local QFOT blockchain node..."
echo ""

# Check if ArangoDB is running locally
if ! pgrep -x "arangod" > /dev/null; then
    echo "❌ ArangoDB not running locally"
    echo ""
    echo "Install ArangoDB first:"
    echo "   brew install arangodb"
    echo "   brew services start arangodb"
    exit 1
fi

# Initialize local AKG GNN
python3 << 'PYTHON_INIT'
from arango import ArangoClient

try:
    client = ArangoClient(hosts='http://localhost:8529')
    sys_db = client.db('_system', username='root', password='')
    
    if not sys_db.has_database('qfot'):
        sys_db.create_database('qfot')
        print("✅ Created qfot database")
    
    db = client.db('qfot', username='root', password='')
    
    collections = ['facts', 'entities', 'domains', 'relationships', 'validations', 'contradictions', 'derivations', 'blockchain']
    
    for coll in collections:
        if not db.has_collection(coll):
            if coll in ['relationships', 'validations', 'contradictions', 'derivations']:
                db.create_collection(coll, edge=True)
            else:
                db.create_collection(coll)
            print(f"✅ Created {coll}")
    
    print("✅ AKG GNN initialized locally")
except Exception as e:
    print(f"⚠️  {e}")
PYTHON_INIT

# Start blockchain node
python3 ./blockchain_node.py node3 7777 localhost


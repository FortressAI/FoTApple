#!/bin/bash
# Deploy QFOT Search App to blockchain servers
# Installs Python API + web frontend on all 3 validators

set -e

echo "🚀 Deploying QFOT Search App"
echo "============================="
echo ""

# Configuration
SSH_KEY="$HOME/.ssh/safeaicoin_substrate_ed25519"
NODES=(
    "78.46.149.125"   # Germany-Nuremberg
    "91.99.156.64"    # Germany-Falkenstein  
    "65.109.15.3"     # Finland-Helsinki
)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📦 Deploying to ${#NODES[@]} nodes..."
echo ""

for NODE_IP in "${NODES[@]}"; do
    echo -e "${YELLOW}📍 Deploying to $NODE_IP...${NC}"
    
    # Create app directory
    ssh -i "$SSH_KEY" root@"$NODE_IP" "mkdir -p /opt/qfot-search/backend /opt/qfot-search/frontend"
    
    # Install Python dependencies
    ssh -i "$SSH_KEY" root@"$NODE_IP" << 'EOF'
apt-get update
apt-get install -y python3-pip nginx
pip3 install fastapi uvicorn aiohttp pydantic
EOF
    
    # Copy backend files
    scp -i "$SSH_KEY" ../search_app/backend/qfot_search_api.py root@"$NODE_IP":/opt/qfot-search/backend/
    
    # Copy frontend files
    scp -i "$SSH_KEY" ../search_app/frontend/index.html root@"$NODE_IP":/opt/qfot-search/frontend/
    
    # Create systemd service for API
    ssh -i "$SSH_KEY" root@"$NODE_IP" << 'EOF'
cat > /etc/systemd/system/qfot-search-api.service << 'SERVICE'
[Unit]
Description=QFOT Search API
After=network.target safeaicoin.service
Wants=safeaicoin.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/qfot-search/backend
ExecStart=/usr/bin/python3 qfot_search_api.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable qfot-search-api
systemctl restart qfot-search-api
EOF

    # Configure Nginx
    ssh -i "$SSH_KEY" root@"$NODE_IP" << 'EOF'
cat > /etc/nginx/sites-available/qfot-search << 'NGINX'
server {
    listen 80;
    server_name _;
    
    # Frontend
    location / {
        root /opt/qfot-search/frontend;
        index index.html;
        try_files $uri $uri/ =404;
    }
    
    # API proxy
    location /api {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Blockchain RPC proxy
    location /rpc {
        proxy_pass http://localhost:9944;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/qfot-search /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
EOF

    echo -e "${GREEN}✅ Deployed to $NODE_IP${NC}"
    echo "   Web: http://$NODE_IP"
    echo "   API: http://$NODE_IP:8080"
    echo ""
done

echo ""
echo "=============================="
echo "🎉 Deployment Complete!"
echo "=============================="
echo ""
echo "🌐 Access Points:"
for NODE_IP in "${NODES[@]}"; do
    echo "   http://$NODE_IP"
done
echo ""
echo "📊 API Endpoints:"
echo "   /search - Search knowledge graph"
echo "   /proteins - List all unique proteins"
echo "   /chemicals - List all unique chemicals"
echo "   /fact/{id} - Get fact details"
echo "   /stats - Blockchain statistics"
echo "   /check-duplicate - Check for duplicates"
echo ""
echo "✨ Features:"
echo "   ✓ Deduplication by content hash"
echo "   ✓ Unique protein sequences only"
echo "   ✓ Unique chemical SMILES only"
echo "   ✓ Real-time blockchain queries"
echo "   ✓ Multi-node failover"
echo ""


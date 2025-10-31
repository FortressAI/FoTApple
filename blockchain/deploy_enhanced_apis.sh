#!/bin/bash

# Deploy Enhanced QFOT APIs with Domain Services
# Deploys:
# 1. Enhanced ArangoDB API (port 8000) - Graph queries
# 2. Domain Services API (port 8001) - Medical, Legal, Education
# Both run on mainnet servers - NO SIMULATIONS

set -e

echo "==============================================================================="
echo "🚀 DEPLOYING ENHANCED QFOT APIs"
echo "==============================================================================="
echo ""
echo "Target Servers:"
echo "  • Node 1: 94.130.97.66"
echo "  • Node 2: 46.224.42.20"
echo ""
echo "APIs to Deploy:"
echo "  1. Enhanced ArangoDB API (port 8000) - Graph traversal, contradictions, entities"
echo "  2. Domain Services API (port 8001) - Drug dosing, case law, standards"
echo ""
echo "==============================================================================="
echo ""

# Servers
NODE1="94.130.97.66"
NODE2="46.224.42.20"
SSH_KEY="$HOME/.ssh/qfot_production_ed25519"

# Deploy to Node 1 (primary)
echo "📡 Deploying to Node 1 ($NODE1)..."
echo ""

ssh -i "$SSH_KEY" root@$NODE1 << 'REMOTE_EOF'

# Create directory
mkdir -p /opt/qfot/api

# Copy enhanced APIs (we'll send via scp after this)
echo "✅ Directory ready: /opt/qfot/api"

REMOTE_EOF

# Copy API files to server
echo "📤 Copying enhanced API files to Node 1..."
scp -i "$SSH_KEY" qfot_api_arangodb_enhanced.py root@$NODE1:/opt/qfot/api/
scp -i "$SSH_KEY" qfot_domain_services_api.py root@$NODE1:/opt/qfot/api/

# Setup services on Node 1
echo "⚙️  Setting up services on Node 1..."

ssh -i "$SSH_KEY" root@$NODE1 << 'REMOTE_EOF'

cd /opt/qfot/api

# Install Python dependencies
pip3 install fastapi uvicorn python-arango pydantic requests

# Create systemd service for Enhanced ArangoDB API (port 8000)
cat > /etc/systemd/system/qfot-api-enhanced.service << 'SERVICE_EOF'
[Unit]
Description=QFOT Enhanced ArangoDB API
After=network.target arangodb3.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/qfot/api
ExecStart=/usr/bin/python3 /opt/qfot/api/qfot_api_arangodb_enhanced.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Create systemd service for Domain Services API (port 8001)
cat > /etc/systemd/system/qfot-domain-services.service << 'SERVICE_EOF'
[Unit]
Description=QFOT Domain Services API (Medical, Legal, Education)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/qfot/api
ExecStart=/usr/bin/python3 /opt/qfot/api/qfot_domain_services_api.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Reload systemd
systemctl daemon-reload

# Enable and start services
systemctl enable qfot-api-enhanced
systemctl enable qfot-domain-services

systemctl restart qfot-api-enhanced
systemctl restart qfot-domain-services

echo ""
echo "✅ Services configured and started"
echo ""
echo "Service Status:"
systemctl status qfot-api-enhanced --no-pager -l | head -15
echo ""
systemctl status qfot-domain-services --no-pager -l | head -15

REMOTE_EOF

# Update Nginx configuration
echo ""
echo "🌐 Updating Nginx configuration..."

ssh -i "$SSH_KEY" root@$NODE1 << 'REMOTE_EOF'

# Backup existing nginx config
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Create new nginx config with both APIs
cat > /etc/nginx/sites-available/qfot-apis << 'NGINX_EOF'
server {
    listen 80;
    server_name safeaicoin.org 94.130.97.66;

    # Enhanced ArangoDB API (port 8000)
    location /api/ {
        proxy_pass http://localhost:8000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Domain Services API (port 8001)
    location /domain-api/ {
        proxy_pass http://localhost:8001/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # API docs
    location /docs {
        proxy_pass http://localhost:8000/docs;
        proxy_set_header Host $host;
    }

    location /domain-docs {
        proxy_pass http://localhost:8001/docs;
        proxy_set_header Host $host;
    }

    # Health checks
    location /health {
        proxy_pass http://localhost:8000/health;
    }

    location /domain-health {
        proxy_pass http://localhost:8001/health;
    }
}
NGINX_EOF

# Enable site
ln -sf /etc/nginx/sites-available/qfot-apis /etc/nginx/sites-enabled/

# Test nginx config
nginx -t

# Reload nginx
systemctl reload nginx

echo "✅ Nginx configured and reloaded"

REMOTE_EOF

echo ""
echo "==============================================================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "==============================================================================="
echo ""
echo "🌐 API Endpoints (Node 1):"
echo ""
echo "Enhanced ArangoDB API:"
echo "  • https://safeaicoin.org/api/status"
echo "  • https://safeaicoin.org/api/facts/search"
echo "  • https://safeaicoin.org/api/graph/traverse"
echo "  • https://safeaicoin.org/api/graph/contradictions/{id}"
echo "  • https://safeaicoin.org/api/domains/query"
echo "  • https://safeaicoin.org/api/entities/query"
echo "  • Docs: https://safeaicoin.org/docs"
echo ""
echo "Domain Services API:"
echo "  • https://safeaicoin.org/domain-api/medical/calculate-dosing"
echo "  • https://safeaicoin.org/domain-api/medical/check-interactions"
echo "  • https://safeaicoin.org/domain-api/medical/fda-alerts"
echo "  • https://safeaicoin.org/domain-api/medical/icd10-lookup/{query}"
echo "  • https://safeaicoin.org/domain-api/legal/case-law"
echo "  • https://safeaicoin.org/domain-api/legal/statutes"
echo "  • https://safeaicoin.org/domain-api/legal/calculate-deadline"
echo "  • https://safeaicoin.org/domain-api/education/standards"
echo "  • https://safeaicoin.org/domain-api/education/pedagogical-methods"
echo "  • Docs: https://safeaicoin.org/domain-docs"
echo ""
echo "==============================================================================="
echo ""
echo "🧪 Test Commands:"
echo ""
echo "# Test Enhanced API"
echo "curl https://safeaicoin.org/api/status | jq"
echo ""
echo "# Test Domain Services"
echo "curl https://safeaicoin.org/domain-health | jq"
echo ""
echo "# Test Drug Dosing"
echo "curl -X POST https://safeaicoin.org/domain-api/medical/calculate-dosing \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"drug_name\": \"metformin\", \"patient_weight_kg\": 70, \"patient_age_years\": 45, \"indication\": \"Type 2 Diabetes\", \"renal_function\": \"normal\"}' | jq"
echo ""
echo "# Test Drug Interactions"
echo "curl -X POST https://safeaicoin.org/domain-api/medical/check-interactions \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"medications\": [\"metformin\", \"lisinopril\"]}' | jq"
echo ""
echo "# Test ICD-10 Lookup"
echo "curl https://safeaicoin.org/domain-api/medical/icd10-lookup/hypertension | jq"
echo ""
echo "# Test Graph Traversal"
echo "curl -X POST https://safeaicoin.org/api/graph/traverse \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"fact_id\": \"fact_123\", \"max_depth\": 2, \"limit\": 10}' | jq"
echo ""
echo "==============================================================================="
echo ""
echo "📱 iOS/Mac Apps Integration:"
echo ""
echo "Update base URLs in app code:"
echo "  - ArangoDBClient: \"https://safeaicoin.org/api\""
echo "  - QFOTMedicalServices: \"https://safeaicoin.org/domain-api\""
echo "  - QFOTLegalServices: \"https://safeaicoin.org/domain-api\""
echo ""
echo "All services are LIVE on MAINNET - NO SIMULATIONS!"
echo ""
echo "==============================================================================="


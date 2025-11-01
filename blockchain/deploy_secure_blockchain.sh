#!/bin/bash

# Deploy QFOT Secure Blockchain Server
# Production deployment with security hardening

set -e

echo "==============================================================================="
echo "🔐 DEPLOYING QFOT SECURE BLOCKCHAIN SERVER"
echo "==============================================================================="
echo ""
echo "Target: 94.130.97.66"
echo "Features:"
echo "  ✅ Ed25519 signatures"
echo "  ✅ SHA-256 PoW"
echo "  ✅ Rate limiting"
echo "  ✅ Multimedia support"
echo "  ✅ QFOT integration"
echo ""
echo "==============================================================================="
echo ""

SSH_KEY="$HOME/.ssh/qfot_production_ed25519"
NODE1="94.130.97.66"

# Install dependencies locally first (for testing)
echo "📦 Installing local dependencies..."
pip3 install -r blockchain_requirements.txt

echo ""
echo "✅ Local dependencies installed"
echo ""

# Deploy to server
echo "📡 Deploying to Node 1 ($NODE1)..."
echo ""

# Copy files
echo "📤 Copying files..."
scp -i "$SSH_KEY" qfot_secure_blockchain_server.py root@$NODE1:/opt/qfot/blockchain/
scp -i "$SSH_KEY" blockchain_requirements.txt root@$NODE1:/opt/qfot/blockchain/

# Setup on server
ssh -i "$SSH_KEY" root@$NODE1 << 'REMOTE_EOF'

echo "📦 Installing dependencies on server..."
cd /opt/qfot/blockchain
pip3 install -r blockchain_requirements.txt

echo ""
echo "⚙️  Creating systemd service..."

cat > /etc/systemd/system/qfot-blockchain.service << 'SERVICE_EOF'
[Unit]
Description=QFOT Secure Blockchain Server
After=network.target arangodb3.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/qfot/blockchain
Environment="ARANGO_PASSWORD=qfot2025secure"
ExecStart=/usr/bin/python3 /opt/qfot/blockchain/qfot_secure_blockchain_server.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/qfot/multimedia

[Install]
WantedBy=multi-user.target
SERVICE_EOF

echo ""
echo "🔄 Reloading systemd..."
systemctl daemon-reload

echo ""
echo "▶️  Starting blockchain server..."
systemctl enable qfot-blockchain
systemctl restart qfot-blockchain

echo ""
echo "⏳ Waiting for service to start..."
sleep 5

echo ""
echo "📊 Service status:"
systemctl status qfot-blockchain --no-pager -l | head -20

echo ""
echo "✅ Blockchain server deployed!"

REMOTE_EOF

echo ""
echo "==============================================================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "==============================================================================="
echo ""
echo "🌐 API Endpoints:"
echo "  • Status: https://safeaicoin.org/blockchain/status"
echo "  • Chain: https://safeaicoin.org/blockchain/chain"
echo "  • Submit Fact: POST https://safeaicoin.org/blockchain/facts/submit"
echo "  • Upload Media: POST https://safeaicoin.org/blockchain/facts/{id}/multimedia"
echo "  • Validate: https://safeaicoin.org/blockchain/validate"
echo ""
echo "🔐 Security Features:"
echo "  ✅ Ed25519 digital signatures"
echo "  ✅ SHA-256 Proof of Work (difficulty: 4)"
echo "  ✅ Rate limiting (10 req/min)"
echo "  ✅ Input validation & sanitization"
echo "  ✅ XSS/injection protection"
echo "  ✅ Multimedia file support (50MB max)"
echo "  ✅ CORS & trusted host protection"
echo ""
echo "🧪 Test Commands:"
echo ""
echo "# Check status"
echo "curl https://safeaicoin.org/blockchain/status | jq"
echo ""
echo "# Get blockchain"
echo "curl https://safeaicoin.org/blockchain/chain | jq"
echo ""
echo "# Validate chain"
echo "curl https://safeaicoin.org/blockchain/validate | jq"
echo ""
echo "==============================================================================="
echo ""
echo "📝 Next Steps:"
echo "  1. Test the API endpoints above"
echo "  2. Configure Nginx reverse proxy (see SECURE_BLOCKCHAIN_DEPLOYMENT.md)"
echo "  3. Generate Ed25519 keypairs for users"
echo "  4. Start submitting facts with signatures"
echo "  5. Upload multimedia evidence to facts"
echo ""
echo "📚 Documentation: blockchain/SECURE_BLOCKCHAIN_DEPLOYMENT.md"
echo ""
echo "🚀 Your blockchain is ready for production!"
echo "==============================================================================="


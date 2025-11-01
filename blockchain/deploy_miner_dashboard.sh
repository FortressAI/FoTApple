#!/bin/bash

# Deploy QFOT Miner Web Dashboard to all nodes

set -e

echo "==============================================================================="
echo "🌐 DEPLOYING MINER WEB DASHBOARD"
echo "==============================================================================="
echo ""

SSH_KEY="$HOME/.ssh/qfot_production_ed25519"
NODE1="94.130.97.66"
NODE2="46.224.42.20"

# ============================================================================
# DEPLOY TO NODE 1
# ============================================================================

echo "📡 Deploying to Node 1 ($NODE1)..."
echo ""

# Copy files
scp -i "$SSH_KEY" miner_web_dashboard.py root@$NODE1:/opt/qfot/
scp -i "$SSH_KEY" blockchain_requirements.txt root@$NODE1:/opt/qfot/

# Install dependencies and setup
ssh -i "$SSH_KEY" root@$NODE1 << 'REMOTE_EOF'

# Install additional dependencies
pip3 install -q Pillow aiofiles

# Create systemd service
cat > /etc/systemd/system/qfot-miner-dashboard.service << 'SERVICE_EOF'
[Unit]
Description=QFOT Miner Web Dashboard
After=network.target qfot-blockchain.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/qfot
ExecStart=/usr/bin/python3 /opt/qfot/miner_web_dashboard.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/qfot/multimedia

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Reload systemd
systemctl daemon-reload

# Enable and start
systemctl enable qfot-miner-dashboard
systemctl restart qfot-miner-dashboard

# Wait and check status
sleep 5
systemctl status qfot-miner-dashboard --no-pager -l | head -20

echo ""
echo "✅ Node 1 dashboard deployed!"

REMOTE_EOF

# ============================================================================
# DEPLOY TO NODE 2
# ============================================================================

echo ""
echo "📡 Deploying to Node 2 ($NODE2)..."
echo ""

# Copy files
scp -i "$SSH_KEY" miner_web_dashboard.py root@$NODE2:/opt/qfot/
scp -i "$SSH_KEY" blockchain_requirements.txt root@$NODE2:/opt/qfot/

# Install and setup
ssh -i "$SSH_KEY" root@$NODE2 << 'REMOTE_EOF'

# Install dependencies
pip3 install -q Pillow aiofiles

# Create systemd service
cat > /etc/systemd/system/qfot-miner-dashboard.service << 'SERVICE_EOF'
[Unit]
Description=QFOT Miner Web Dashboard
After=network.target qfot-blockchain.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/qfot
ExecStart=/usr/bin/python3 /opt/qfot/miner_web_dashboard.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Reload and start
systemctl daemon-reload
systemctl enable qfot-miner-dashboard
systemctl restart qfot-miner-dashboard

sleep 5
systemctl status qfot-miner-dashboard --no-pager -l | head -20

echo ""
echo "✅ Node 2 dashboard deployed!"

REMOTE_EOF

# ============================================================================
# SETUP LOCAL
# ============================================================================

echo ""
echo "📡 Setting up local dashboard..."
echo ""

# Install dependencies locally
pip3 install Pillow aiofiles 2>/dev/null || echo "Dependencies already installed"

# Create local multimedia directory
mkdir -p ~/qfot_local/multimedia

# Create start script
cat > ~/qfot_local/start_dashboard.sh << 'LOCAL_EOF'
#!/bin/bash

echo "🌐 Starting QFOT Miner Dashboard..."
cd ~/qfot_local
python3 miner_web_dashboard.py > logs/dashboard.log 2>&1 &
echo $! > dashboard.pid

echo "✅ Dashboard started!"
echo ""
echo "URL: http://localhost:8003"
echo ""
echo "To stop: kill $(cat ~/qfot_local/dashboard.pid)"
LOCAL_EOF

chmod +x ~/qfot_local/start_dashboard.sh

# Copy dashboard to local
cp miner_web_dashboard.py ~/qfot_local/

echo "✅ Local dashboard ready!"
echo "   Start: ~/qfot_local/start_dashboard.sh"

# ============================================================================
# VERIFICATION
# ============================================================================

echo ""
echo "==============================================================================="
echo "🧪 VERIFYING DEPLOYMENTS"
echo "==============================================================================="
echo ""

# Test Node 1
echo "Testing Node 1 dashboard..."
if curl -s "http://$NODE1:8003/api/stats" | grep -q "facts_submitted"; then
    echo "  ✅ Node 1 dashboard: ONLINE (http://$NODE1:8003)"
else
    echo "  ⚠️  Node 1 dashboard: Check logs"
fi

# Test Node 2
echo "Testing Node 2 dashboard..."
if curl -s "http://$NODE2:8003/api/stats" | grep -q "facts_submitted"; then
    echo "  ✅ Node 2 dashboard: ONLINE (http://$NODE2:8003)"
else
    echo "  ⚠️  Node 2 dashboard: Check logs"
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "==============================================================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "==============================================================================="
echo ""
echo "🌐 Dashboards:"
echo "  • Node 1: http://94.130.97.66:8003"
echo "  • Node 2: http://46.224.42.20:8003"
echo "  • Local:  http://localhost:8003 (use start script)"
echo ""
echo "✨ Features:"
echo "  ✅ Real-time miner statistics"
echo "  ✅ Submit facts with multimedia"
echo "  ✅ Upload images, videos, documents"
echo "  ✅ View recent facts"
echo "  ✅ Monitor blockchain nodes"
echo "  ✅ Beautiful responsive UI"
echo ""
echo "🔧 Management:"
echo "  # View logs (Node 1)"
echo "  ssh -i $SSH_KEY root@$NODE1 'journalctl -u qfot-miner-dashboard -f'"
echo ""
echo "  # Restart dashboard (Node 1)"
echo "  ssh -i $SSH_KEY root@$NODE1 'systemctl restart qfot-miner-dashboard'"
echo ""
echo "  # Start local dashboard"
echo "  ~/qfot_local/start_dashboard.sh"
echo ""
echo "==============================================================================="


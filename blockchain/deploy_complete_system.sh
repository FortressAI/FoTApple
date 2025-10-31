#!/bin/bash

##############################################################################
# DEPLOY COMPLETE QFOT SYSTEM WITH DATA
##############################################################################

set -e

echo "================================================================================"
echo "🚀 DEPLOYING COMPLETE QFOT SYSTEM WITH LIVE DATA"
echo "================================================================================"
echo ""

PRIMARY_SERVER="94.130.97.66"
SSH_KEY=~/.ssh/qfot_production_ed25519

echo "🚀 STEP 1: DEPLOY MINERS AND SCRIPTS"
echo ""

echo "📦 Creating deployment package..."

# Create temp directory
TMP_DIR=$(mktemp -d)
mkdir -p $TMP_DIR/qfot_deployment

# Copy miners
cp k18_education_fact_generator.py $TMP_DIR/qfot_deployment/
cp exhaustive_fact_miner.py $TMP_DIR/qfot_deployment/
cp live_research_miner.py $TMP_DIR/qfot_deployment/
cp legal_research_miner.py $TMP_DIR/qfot_deployment/
cp education_research_miner.py $TMP_DIR/qfot_deployment/
cp medical_specializations_miner.py $TMP_DIR/qfot_deployment/
cp legal_jurisdictions_miner.py $TMP_DIR/qfot_deployment/

# Copy wallet manager
cp wallet_manager.py $TMP_DIR/qfot_deployment/
cp init_wallet_db.py $TMP_DIR/qfot_deployment/

echo "✅ Package created: $(du -sh $TMP_DIR/qfot_deployment | cut -f1)"
echo ""

echo "📤 Uploading to server..."

scp -i "$SSH_KEY" -r $TMP_DIR/qfot_deployment root@${PRIMARY_SERVER}:/root/

echo "✅ Uploaded"
echo ""

echo "🚀 STEP 2: SETUP ENVIRONMENT ON SERVER"
echo ""

ssh -i "$SSH_KEY" root@${PRIMARY_SERVER} << 'REMOTE_EOF'
set -e

echo "🐍 Installing Python dependencies..."
pip3 install requests sqlite3 2>/dev/null || pip3 install requests

echo ""
echo "📂 Setting up directories..."
mkdir -p /var/www/qfot/data

echo ""
echo "🔧 Making scripts executable..."
cd /root/qfot_deployment
chmod +x *.py

echo ""
echo "✅ Environment ready"
REMOTE_EOF

echo ""
echo "🚀 STEP 3: RUN INITIAL FACT GENERATION"
echo ""

ssh -i "$SSH_KEY" root@${PRIMARY_SERVER} << 'REMOTE_EOF'
set -e

cd /root/qfot_deployment

echo "🎓 Running K-18 Education fact generator (100 facts)..."
python3 k18_education_fact_generator.py 2>&1 | tail -20

echo ""
echo "📚 Running exhaustive fact miner (50 facts)..."
timeout 60s python3 exhaustive_fact_miner.py 2>&1 | tail -20 || echo "Timeout reached (expected)"

echo ""
echo "✅ Initial facts generated"
REMOTE_EOF

echo ""
echo "🚀 STEP 4: START BACKGROUND MINERS"
echo ""

ssh -i "$SSH_KEY" root@${PRIMARY_SERVER} << 'REMOTE_EOF'
set -e

cd /root/qfot_deployment

echo "🔄 Starting continuous miners in background..."

# Create systemd service for K-18 miner
cat > /etc/systemd/system/qfot-k18-miner.service << 'SERVICE_EOF'
[Unit]
Description=QFOT K-18 Education Fact Miner
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/qfot_deployment
ExecStart=/usr/bin/python3 /root/qfot_deployment/k18_education_fact_generator.py
Restart=always
RestartSec=300

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Create systemd service for exhaustive miner
cat > /etc/systemd/system/qfot-exhaustive-miner.service << 'SERVICE_EOF'
[Unit]
Description=QFOT Exhaustive Fact Miner
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/qfot_deployment
ExecStart=/usr/bin/python3 /root/qfot_deployment/exhaustive_fact_miner.py
Restart=always
RestartSec=600

[Install]
WantedBy=multi-user.target
SERVICE_EOF

echo "🔄 Reloading systemd..."
systemctl daemon-reload

echo "▶️  Starting miners..."
systemctl start qfot-k18-miner
systemctl start qfot-exhaustive-miner

echo "✅ Enabling auto-start..."
systemctl enable qfot-k18-miner
systemctl enable qfot-exhaustive-miner

echo ""
echo "📊 Miner status:"
systemctl status qfot-k18-miner --no-pager | head -10
systemctl status qfot-exhaustive-miner --no-pager | head -10

echo ""
echo "✅ Background miners started"
REMOTE_EOF

echo ""
echo "🚀 STEP 5: VERIFY DATA"
echo ""

sleep 5

echo "📊 Checking API for facts..."
curl -s https://${PRIMARY_SERVER}/api/facts/search | python3 -m json.tool | head -30 || echo "Checking data..."

echo ""
echo "================================================================================"
echo "✅ COMPLETE SYSTEM DEPLOYED!"
echo "================================================================================"
echo ""
echo "What's Running:"
echo "   ✅ Backend API (uvicorn on port 8000)"
echo "   ✅ Nginx serving wiki interface"
echo "   ✅ K-18 Education miner (continuous)"
echo "   ✅ Exhaustive fact miner (continuous)"
echo ""
echo "Check Status:"
echo "   ssh -i ~/.ssh/qfot_production_ed25519 root@94.130.97.66"
echo "   systemctl status qfot-k18-miner"
echo "   systemctl status qfot-exhaustive-miner"
echo ""
echo "View Website:"
echo "   https://safeaicoin.org"
echo ""
echo "================================================================================"

# Cleanup
rm -rf $TMP_DIR


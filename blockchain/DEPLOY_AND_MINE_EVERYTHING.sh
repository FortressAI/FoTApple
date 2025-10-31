#!/bin/bash
################################################################################
# DEPLOY & MINE EVERYTHING
# 
# Complete deployment and exhaustive fact mining:
# 1. Deploy to production servers
# 2. Start API services
# 3. Launch ALL fact miners until exhausted
# 4. Monitor progress
################################################################################

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "================================================================================"
echo "🚀 QFOT COMPLETE DEPLOYMENT & EXHAUSTIVE MINING"
echo "================================================================================"
echo ""
echo "This will:"
echo "  1. Deploy tokenomics + wiki to production"
echo "  2. Start API services on Hetzner servers"
echo "  3. Launch exhaustive fact miners"
echo "  4. Run until all fact sources are exhausted"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

echo ""
echo "================================================================================"
echo "PHASE 1: DEPLOY TO PRODUCTION"
echo "================================================================================"
echo ""

chmod +x deploy_wiki_to_production.sh
./deploy_wiki_to_production.sh

echo ""
echo "================================================================================"
echo "PHASE 2: START LOCAL FACT MINERS (for testing)"
echo "================================================================================"
echo ""

# Create miner tracking directory
mkdir -p logs/miners

echo "🎓 Starting K-18 Education Miner..."
chmod +x k18_education_fact_generator.py
nohup python3 k18_education_fact_generator.py > logs/miners/k18_miner.log 2>&1 &
echo $! > logs/miners/k18_miner.pid
echo "   ✅ K-18 miner started (PID: $(cat logs/miners/k18_miner.pid))"

echo ""
echo "⛏️  Starting Exhaustive Fact Miner..."
chmod +x exhaustive_fact_miner.py
nohup python3 exhaustive_fact_miner.py > logs/miners/exhaustive_miner.log 2>&1 &
echo $! > logs/miners/exhaustive_miner.pid
echo "   ✅ Exhaustive miner started (PID: $(cat logs/miners/exhaustive_miner.pid))"

echo ""
echo "================================================================================"
echo "PHASE 3: MONITORING MINERS"
echo "================================================================================"
echo ""

echo "📊 Mining Progress:"
echo ""
echo "   📁 Logs:"
echo "      • K-18: logs/miners/k18_miner.log"
echo "      • Exhaustive: logs/miners/exhaustive_miner.log"
echo ""
echo "   📈 Monitor live:"
echo "      tail -f logs/miners/k18_miner.log"
echo "      tail -f logs/miners/exhaustive_miner.log"
echo ""
echo "   🛑 Stop miners:"
echo "      kill \$(cat logs/miners/k18_miner.pid)"
echo "      kill \$(cat logs/miners/exhaustive_miner.pid)"
echo ""

sleep 5

echo "   Checking initial progress..."
echo ""

if [ -f logs/miners/k18_miner.log ]; then
    echo "   📚 K-18 Miner:"
    tail -5 logs/miners/k18_miner.log | sed 's/^/      /'
fi

echo ""

if [ -f logs/miners/exhaustive_miner.log ]; then
    echo "   ⛏️  Exhaustive Miner:"
    tail -5 logs/miners/exhaustive_miner.log | sed 's/^/      /'
fi

echo ""
echo "================================================================================"
echo "✅ DEPLOYMENT & MINING LAUNCHED!"
echo "================================================================================"
echo ""
echo "🌐 PRODUCTION:"
echo "   Wiki:  http://94.130.97.66/wiki"
echo "          http://safeaicoin.org/wiki"
echo "   API:   http://94.130.97.66/api"
echo ""
echo "⛏️  MINERS RUNNING:"
echo "   • K-18 Education: ~140 facts"
echo "   • Exhaustive: ~200+ additional facts"
echo "   • Will run until balance exhausted"
echo ""
echo "📊 CHECK STATUS:"
echo "   curl http://94.130.97.66/api/stats/network"
echo "   curl http://94.130.97.66/api/faucet/stats"
echo ""
echo "🔄 PRODUCTION MINERS (on server):"
echo "   ssh -i ~/.ssh/qfot_production_ed25519 root@94.130.97.66"
echo "   systemctl status qfot-k18-miner"
echo "   tail -f /var/www/qfot/logs/k18_miner.log"
echo ""
echo "================================================================================"
echo ""
echo "💤 Miners are running in background."
echo "   They will continue until all facts are submitted or balance is exhausted."
echo "   Check logs/miners/ for progress."
echo ""
echo "================================================================================"

# Create status file
cat > logs/deployment_status.txt << EOF
QFOT DEPLOYMENT STATUS
$(date)

PRODUCTION:
- Primary Server: 94.130.97.66
- Wiki: http://94.130.97.66/wiki
- API: http://94.130.97.66/api

LOCAL MINERS:
- K-18 Education (PID: $(cat logs/miners/k18_miner.pid 2>/dev/null || echo "N/A"))
- Exhaustive Miner (PID: $(cat logs/miners/exhaustive_miner.pid 2>/dev/null || echo "N/A"))

LOGS:
- K-18: logs/miners/k18_miner.log
- Exhaustive: logs/miners/exhaustive_miner.log

MONITORING:
tail -f logs/miners/*.log

STOP MINERS:
./stop_all_miners.sh
EOF

echo "📄 Status saved to: logs/deployment_status.txt"
echo ""

# Offer to tail logs
read -p "Monitor miners in real-time? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📊 Monitoring miners (Ctrl+C to exit)..."
    echo "================================================================================"
    tail -f logs/miners/*.log 2>/dev/null || echo "Waiting for miner output..."
fi


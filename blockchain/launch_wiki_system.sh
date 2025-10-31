#!/bin/bash
################################################################################
# QFOT Wiki System Launcher
# 
# Starts:
# 1. API server with tokenomics
# 2. K-18 Education fact generator (background)
# 3. Opens wiki interface in browser
################################################################################

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "================================================================================"
echo "🚀 LAUNCHING QFOT WIKI SYSTEM"
echo "================================================================================"
echo ""

# Check if database exists
if [ ! -f "qfot_wallets.db" ]; then
    echo "⚠️  Wallet database not found. Initializing..."
    python3 init_wallet_db.py
    echo ""
fi

# Start API server in background
echo "1️⃣ Starting API server..."
cd search_app/backend
python3 qfot_search_api_with_wallets.py > ../../logs/api_server.log 2>&1 &
API_PID=$!
echo $API_PID > ../../.api.pid
echo "   ✅ API server started (PID: $API_PID)"
echo "   📋 Logs: logs/api_server.log"
cd ../..

# Wait for API to be ready
echo ""
echo "⏳ Waiting for API to be ready..."
sleep 3

for i in {1..10}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "   ✅ API is ready!"
        break
    fi
    sleep 1
    if [ $i -eq 10 ]; then
        echo "   ❌ API failed to start. Check logs/api_server.log"
        exit 1
    fi
done

# Start K-18 Education fact generator in background
echo ""
echo "2️⃣ Starting K-18 Education fact generator..."
python3 k18_education_fact_generator.py > logs/k18_generator.log 2>&1 &
GENERATOR_PID=$!
echo $GENERATOR_PID > .generator.pid
echo "   ✅ Generator started (PID: $GENERATOR_PID)"
echo "   📋 Logs: logs/k18_generator.log"
echo "   ⏱️  This will run in background and submit ~160 educational facts"

# Create logs directory if needed
mkdir -p logs

# Open wiki in browser
echo ""
echo "3️⃣ Opening wiki interface..."
sleep 2

if command -v open > /dev/null 2>&1; then
    open search_app/frontend/wiki.html
elif command -v xdg-open > /dev/null 2>&1; then
    xdg-open search_app/frontend/wiki.html
else
    echo "   ⚠️  Could not auto-open browser"
    echo "   👉 Manually open: search_app/frontend/wiki.html"
fi

echo ""
echo "================================================================================"
echo "✅ QFOT WIKI SYSTEM RUNNING"
echo "================================================================================"
echo ""
echo "📡 API Server:      http://localhost:8000"
echo "📚 API Docs:        http://localhost:8000/docs"
echo "🌐 Wiki Interface:  file://$(pwd)/search_app/frontend/wiki.html"
echo "💰 Wallet UI:       file://$(pwd)/search_app/frontend/wallet.html"
echo ""
echo "📊 MONITORING:"
echo "   • API logs:        tail -f logs/api_server.log"
echo "   • Generator logs:  tail -f logs/k18_generator.log"
echo "   • API health:      curl http://localhost:8000/health"
echo ""
echo "🛑 TO STOP:"
echo "   ./stop_wiki_system.sh"
echo "   OR:"
echo "   kill $API_PID $GENERATOR_PID"
echo ""
echo "🎓 K-18 EDUCATION FACTS:"
echo "   • ~160 facts being generated across all subjects"
echo "   • Subjects: Math, Science, English, Social Studies"
echo "   • Grade levels: K-2, 3-5, 6-8, 9-12"
echo "   • Each fact earns 70% of query fees!"
echo ""
echo "================================================================================"
echo "Press Ctrl+C to view this info again, or check logs/wiki_info.txt"
echo "================================================================================"

# Save info to file
cat > logs/wiki_info.txt << EOF
QFOT WIKI SYSTEM - Running

API Server:      http://localhost:8000 (PID: $API_PID)
Fact Generator:  Running (PID: $GENERATOR_PID)

Wiki:    search_app/frontend/wiki.html
Wallet:  search_app/frontend/wallet.html

Logs:
  - logs/api_server.log
  - logs/k18_generator.log

To stop:
  kill $API_PID $GENERATOR_PID
  OR
  ./stop_wiki_system.sh
EOF

# Monitor in foreground (Ctrl+C to exit)
echo ""
echo "📊 Live monitoring (Ctrl+C to exit)..."
echo ""

tail -f logs/k18_generator.log 2>/dev/null || echo "Waiting for generator to start..."


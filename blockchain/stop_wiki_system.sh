#!/bin/bash
################################################################################
# Stop QFOT Wiki System
################################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "🛑 Stopping QFOT Wiki System..."

# Stop API server
if [ -f ".api.pid" ]; then
    API_PID=$(cat .api.pid)
    if kill -0 $API_PID 2>/dev/null; then
        kill $API_PID
        echo "   ✅ API server stopped (PID: $API_PID)"
    else
        echo "   ℹ️  API server not running"
    fi
    rm .api.pid
fi

# Stop fact generator
if [ -f ".generator.pid" ]; then
    GEN_PID=$(cat .generator.pid)
    if kill -0 $GEN_PID 2>/dev/null; then
        kill $GEN_PID
        echo "   ✅ Fact generator stopped (PID: $GEN_PID)"
    else
        echo "   ℹ️  Fact generator not running"
    fi
    rm .generator.pid
fi

# Kill any remaining python processes
pkill -f "qfot_search_api_with_wallets.py" 2>/dev/null && echo "   ✅ Cleaned up API processes"
pkill -f "k18_education_fact_generator.py" 2>/dev/null && echo "   ✅ Cleaned up generator processes"

echo ""
echo "✅ QFOT Wiki System stopped"
echo ""
echo "To restart: ./launch_wiki_system.sh"


#!/bin/bash
################################################################################
# Stop All Fact Miners
################################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "🛑 Stopping all fact miners..."

# Stop local miners
if [ -f logs/miners/k18_miner.pid ]; then
    PID=$(cat logs/miners/k18_miner.pid)
    if kill -0 $PID 2>/dev/null; then
        kill $PID
        echo "   ✅ K-18 miner stopped (PID: $PID)"
    fi
    rm logs/miners/k18_miner.pid
fi

if [ -f logs/miners/exhaustive_miner.pid ]; then
    PID=$(cat logs/miners/exhaustive_miner.pid)
    if kill -0 $PID 2>/dev/null; then
        kill $PID
        echo "   ✅ Exhaustive miner stopped (PID: $PID)"
    fi
    rm logs/miners/exhaustive_miner.pid
fi

# Cleanup any orphaned processes
pkill -f "k18_education_fact_generator" && echo "   ✅ Cleaned up K-18 processes"
pkill -f "exhaustive_fact_miner" && echo "   ✅ Cleaned up exhaustive miner processes"

echo ""
echo "✅ All miners stopped"


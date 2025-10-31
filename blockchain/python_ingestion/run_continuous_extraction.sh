#!/bin/bash
###############################################################################
# CONTINUOUS QFOT KNOWLEDGE EXTRACTION ORCHESTRATOR
#
# This script runs ALL extraction agents in sequence to build a comprehensive
# knowledge base of THOUSANDS of facts on the QFOT blockchain.
#
# Agents:
# 1. background_knowledge_agent.py - Static fact extraction
# 2. akg_gnn_extraction_agent.py - AI-powered Q&A generation  
# 3. comprehensive_extraction_agent.py - Swift/Markdown parsing
#
# Usage:
#   ./run_continuous_extraction.sh [--continuous] [--max-facts N]
#
# Options:
#   --continuous    Run forever until interrupted (Ctrl+C to stop)
#   --max-facts N   Stop after N total facts submitted
###############################################################################

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGDIR="$SCRIPT_DIR/extraction_logs"
CONTINUOUS=false
MAX_FACTS=10000  # Default maximum
CURRENT_TOTAL=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --continuous)
            CONTINUOUS=true
            shift
            ;;
        --max-facts)
            MAX_FACTS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--continuous] [--max-facts N]"
            exit 1
            ;;
    esac
done

# Create log directory
mkdir -p "$LOGDIR"

# Log function
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1"
}

banner() {
    echo -e "${BLUE}"
    echo "================================================================================"
    echo "$1"
    echo "================================================================================"
    echo -e "${NC}"
}

# Check Python
if ! command -v python3 &> /dev/null; then
    error "python3 not found. Please install Python 3.9+"
    exit 1
fi

# Main extraction loop
ITERATION=1

banner "🚀 QFOT CONTINUOUS KNOWLEDGE EXTRACTION STARTING"
log "Mode: $([ "$CONTINUOUS" = true ] && echo "CONTINUOUS" || echo "SINGLE RUN")"
log "Max facts: $MAX_FACTS"
log "Log directory: $LOGDIR"
echo ""

while true; do
    banner "🔄 ITERATION $ITERATION - $(date)"
    
    # Agent 1: Background Knowledge Agent
    log "📚 Running Background Knowledge Agent..."
    AGENT1_LOG="$LOGDIR/background_agent_$(date +%Y%m%d_%H%M%S).log"
    
    if python3 "$SCRIPT_DIR/background_knowledge_agent.py" 2>&1 | tee "$AGENT1_LOG"; then
        AGENT1_FACTS=$(grep -o "Total submitted: [0-9]*" "$AGENT1_LOG" | tail -1 | awk '{print $3}' || echo "0")
        log "✅ Background agent: $AGENT1_FACTS facts"
        CURRENT_TOTAL=$((CURRENT_TOTAL + AGENT1_FACTS))
    else
        error "Background agent failed"
    fi
    
    echo ""
    
    # Agent 2: AKG GNN Agent
    log "🧠 Running AKG GNN Q&A Generation Agent..."
    AGENT2_LOG="$LOGDIR/akg_gnn_agent_$(date +%Y%m%d_%H%M%S).log"
    
    if python3 "$SCRIPT_DIR/akg_gnn_extraction_agent.py" 2>&1 | tee "$AGENT2_LOG"; then
        AGENT2_FACTS=$(grep -o "Total facts submitted: [0-9]*" "$AGENT2_LOG" | tail -1 | awk '{print $4}' || echo "0")
        log "✅ AKG GNN agent: $AGENT2_FACTS facts"
        CURRENT_TOTAL=$((CURRENT_TOTAL + AGENT2_FACTS))
    else
        error "AKG GNN agent failed"
    fi
    
    echo ""
    
    # Agent 3: Comprehensive Extraction Agent
    log "🔍 Running Comprehensive Swift/Markdown Parser..."
    AGENT3_LOG="$LOGDIR/comprehensive_agent_$(date +%Y%m%d_%H%M%S).log"
    
    if timeout 300 python3 "$SCRIPT_DIR/comprehensive_extraction_agent.py" 2>&1 | tee "$AGENT3_LOG"; then
        AGENT3_FACTS=$(grep -o "Total submitted: [0-9]*" "$AGENT3_LOG" | tail -1 | awk '{print $3}' || echo "0")
        log "✅ Comprehensive agent: $AGENT3_FACTS facts"
        CURRENT_TOTAL=$((CURRENT_TOTAL + AGENT3_FACTS))
    else
        error "Comprehensive agent timeout or failed (this is OK, may take long on first run)"
    fi
    
    echo ""
    
    # Summary
    banner "📊 ITERATION $ITERATION COMPLETE"
    echo -e "${YELLOW}Current session total: $CURRENT_TOTAL facts${NC}"
    echo -e "${YELLOW}Target: $MAX_FACTS facts${NC}"
    echo ""
    
    # Check if we've reached target
    if [ $CURRENT_TOTAL -ge $MAX_FACTS ]; then
        banner "🎉 TARGET REACHED: $CURRENT_TOTAL facts submitted!"
        log "View your facts at: https://94.130.97.66/review.html"
        log "Estimated earnings: \$$(echo "$CURRENT_TOTAL * 0.5" | bc -l) - \$$(echo "$CURRENT_TOTAL * 2.0" | bc -l) per year"
        break
    fi
    
    # Exit if not continuous
    if [ "$CONTINUOUS" = false ]; then
        log "Single run complete. Use --continuous to keep running."
        break
    fi
    
    # Wait before next iteration
    WAIT_TIME=60  # 1 minute
    log "⏳ Waiting ${WAIT_TIME}s before next iteration..."
    sleep $WAIT_TIME
    
    ITERATION=$((ITERATION + 1))
done

banner "✅ EXTRACTION SESSION COMPLETE"
log "Total facts submitted: $CURRENT_TOTAL"
log "Logs saved to: $LOGDIR"
log ""
log "💰 Your $CURRENT_TOTAL facts are now earning 70% of query fees!"
log "🌐 View: https://94.130.97.66/review.html"
echo ""


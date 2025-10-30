#!/bin/bash
# check_safeaicoin_network.sh
# Check status of deployed SafeAICoin network

set -e

CONFIG_FILE="$HOME/.safeaicoin/network_config.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔍 SafeAICoin Network Status Check"
echo "=================================="
echo ""

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Network configuration not found${NC}"
    echo "   File: $CONFIG_FILE"
    echo ""
    echo "Deploy network first with:"
    echo "   ./scripts/deploy_safeaicoin_hetzner.sh"
    exit 1
fi

echo -e "${GREEN}✅ Configuration found${NC}"
echo ""

# Parse config
NETWORK=$(jq -r '.network' "$CONFIG_FILE")
DEPLOYMENT_DATE=$(jq -r '.deployment_date' "$CONFIG_FILE")
NODE_COUNT=$(jq '.nodes | length' "$CONFIG_FILE")
COST=$(jq -r '.cost_per_month' "$CONFIG_FILE")

echo "📊 Network Info:"
echo "   Network: $NETWORK"
echo "   Deployed: $DEPLOYMENT_DATE"
echo "   Nodes: $NODE_COUNT"
echo "   Cost: \$$COST/month"
echo ""

# SSH key
SSH_KEY="$HOME/.ssh/safeaicoin_ed25519"
if [ ! -f "$SSH_KEY" ]; then
    echo -e "${RED}❌ SSH key not found: $SSH_KEY${NC}"
    exit 1
fi

# Check each node
echo "🖥  Node Status:"
echo ""

for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_NAME=$(jq -r ".nodes[$i].name" "$CONFIG_FILE")
    NODE_IP=$(jq -r ".nodes[$i].ip" "$CONFIG_FILE")
    NODE_LOCATION=$(jq -r ".nodes[$i].location" "$CONFIG_FILE")
    RPC_URL=$(jq -r ".nodes[$i].rpc_url" "$CONFIG_FILE")
    
    echo -e "${BLUE}📍 $NODE_NAME ($NODE_LOCATION)${NC}"
    echo "   IP: $NODE_IP"
    echo "   RPC: $RPC_URL"
    
    # Check if SSH accessible
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
        -i "$SSH_KEY" root@"$NODE_IP" "exit" 2>/dev/null; then
        echo -e "   ${GREEN}✅ SSH: Accessible${NC}"
        
        # Check if safeaicoin service is running
        if ssh -i "$SSH_KEY" root@"$NODE_IP" "systemctl is-active safeaicoin" 2>/dev/null | grep -q "active"; then
            echo -e "   ${GREEN}✅ Service: Running${NC}"
            
            # Get blockchain info
            BLOCK_COUNT=$(ssh -i "$SSH_KEY" root@"$NODE_IP" \
                "safeaicoin-cli getblockchaininfo 2>/dev/null | jq -r '.blocks'" 2>/dev/null || echo "N/A")
            PEER_COUNT=$(ssh -i "$SSH_KEY" root@"$NODE_IP" \
                "safeaicoin-cli getpeerinfo 2>/dev/null | jq '. | length'" 2>/dev/null || echo "N/A")
            
            echo "   📊 Blocks: $BLOCK_COUNT"
            echo "   🔗 Peers: $PEER_COUNT"
            
            if [ "$PEER_COUNT" != "N/A" ] && [ "$PEER_COUNT" -ge 2 ]; then
                echo -e "   ${GREEN}✅ Network: Connected${NC}"
            elif [ "$PEER_COUNT" != "N/A" ] && [ "$PEER_COUNT" -gt 0 ]; then
                echo -e "   ${YELLOW}⚠️  Network: Partially connected${NC}"
            else
                echo -e "   ${RED}❌ Network: No peers${NC}"
            fi
        else
            echo -e "   ${RED}❌ Service: Not running${NC}"
        fi
    else
        echo -e "   ${RED}❌ SSH: Not accessible${NC}"
    fi
    
    echo ""
done

# Check RPC connectivity
echo "🌐 RPC Connectivity:"
echo ""

RPC_USER=$(jq -r '.rpc_credentials.user' "$CONFIG_FILE")
RPC_PASSWORD=$(jq -r '.rpc_credentials.password' "$CONFIG_FILE")

for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_NAME=$(jq -r ".nodes[$i].name" "$CONFIG_FILE")
    NODE_IP=$(jq -r ".nodes[$i].ip" "$CONFIG_FILE")
    
    echo -n "   Testing $NODE_NAME... "
    
    # Try RPC call
    RESPONSE=$(curl -s -u "$RPC_USER:$RPC_PASSWORD" \
        --data-binary '{"jsonrpc": "1.0", "id":"test", "method": "getblockchaininfo", "params": [] }' \
        -H 'content-type: text/plain;' \
        "http://$NODE_IP:8332" 2>/dev/null || echo "error")
    
    if echo "$RESPONSE" | grep -q '"result"'; then
        BLOCKS=$(echo "$RESPONSE" | jq -r '.result.blocks' 2>/dev/null || echo "N/A")
        echo -e "${GREEN}✅ Responding ($BLOCKS blocks)${NC}"
    else
        echo -e "${RED}❌ Not responding${NC}"
    fi
done

echo ""
echo "=================================="
echo ""
echo "📝 Useful Commands:"
echo ""
echo "   # SSH to first node:"
echo "   ssh -i $SSH_KEY root@$(jq -r '.nodes[0].ip' "$CONFIG_FILE")"
echo ""
echo "   # Check blockchain status:"
echo "   ssh -i $SSH_KEY root@$(jq -r '.nodes[0].ip' "$CONFIG_FILE") 'safeaicoin-cli getblockchaininfo'"
echo ""
echo "   # Monitor logs:"
echo "   ssh -i $SSH_KEY root@$(jq -r '.nodes[0].ip' "$CONFIG_FILE") 'journalctl -u safeaicoin -f'"
echo ""
echo "   # Destroy network:"
echo "   ./scripts/destroy_safeaicoin_network.sh"
echo ""

#!/bin/bash
# destroy_safeaicoin_network.sh
# Completely destroy SafeAICoin network and clean up

set -e

CONFIG_FILE="$HOME/.safeaicoin/network_config.json"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "⚠️  SafeAICoin Network Destruction"
echo "=================================="
echo ""
echo -e "${RED}WARNING: This will permanently delete:${NC}"
echo "  • All Hetzner Cloud servers"
echo "  • All blockchain data"
echo "  • Network configuration"
echo ""
echo -e "${YELLOW}This action CANNOT be undone!${NC}"
echo ""

read -p "Are you sure? Type 'destroy' to confirm: " CONFIRM

if [ "$CONFIRM" != "destroy" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "🗑  Destroying network..."
echo ""

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}⚠️  No network configuration found${NC}"
    echo "   Nothing to destroy"
    exit 0
fi

# Check if hcloud is installed and token is set
if ! command -v hcloud &> /dev/null; then
    echo -e "${RED}❌ hcloud CLI not found${NC}"
    echo "Install: brew install hcloud"
    exit 1
fi

if [ -z "$HCLOUD_TOKEN" ]; then
    echo -e "${RED}❌ HCLOUD_TOKEN not set${NC}"
    exit 1
fi

# Get node count
NODE_COUNT=$(jq '.nodes | length' "$CONFIG_FILE")

# Delete each server
for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_NAME=$(jq -r ".nodes[$i].name" "$CONFIG_FILE")
    
    echo "   Deleting $NODE_NAME..."
    if hcloud server delete "$NODE_NAME" 2>/dev/null; then
        echo "   ✅ Deleted"
    else
        echo "   ⚠️  Server not found or already deleted"
    fi
done

# Delete network
echo ""
echo "   Deleting private network..."
if hcloud network delete "safeaicoin-network" 2>/dev/null; then
    echo "   ✅ Deleted"
else
    echo "   ⚠️  Network not found or already deleted"
fi

# Delete SSH key from Hetzner
echo ""
echo "   Deleting SSH key from Hetzner..."
if hcloud ssh-key delete "safeaicoin-deploy" 2>/dev/null; then
    echo "   ✅ Deleted"
else
    echo "   ⚠️  SSH key not found or already deleted"
fi

# Ask if user wants to delete local config
echo ""
read -p "Delete local configuration and SSH keys? (y/n): " DELETE_LOCAL

if [ "$DELETE_LOCAL" == "y" ]; then
    echo ""
    echo "   Deleting local configuration..."
    rm -rf "$HOME/.safeaicoin"
    echo "   ✅ Deleted ~/.safeaicoin/"
    
    echo "   Deleting SSH keys..."
    rm -f "$HOME/.ssh/safeaicoin_ed25519"
    rm -f "$HOME/.ssh/safeaicoin_ed25519.pub"
    rm -f "$HOME/.ssh/safeaicoin_substrate_ed25519"
    rm -f "$HOME/.ssh/safeaicoin_substrate_ed25519.pub"
    echo "   ✅ Deleted SSH keys"
fi

echo ""
echo "=================================="
echo "✅ Network destroyed successfully"
echo ""
echo "To deploy a new network:"
echo "   ./scripts/deploy_safeaicoin_hetzner.sh"
echo ""

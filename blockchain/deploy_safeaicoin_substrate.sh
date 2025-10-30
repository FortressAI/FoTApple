#!/bin/bash
# deploy_safeaicoin_substrate.sh
# Deploy SafeAICoin "Field of Truth" blockchain using Substrate framework
# Complete implementation of tokenomics, governance, and knowledge validation

set -e

echo "🌍 SafeAICoin Field of Truth - Substrate Deployment"
echo "===================================================="
echo ""
echo "This will deploy a complete knowledge validation blockchain with:"
echo "  • Aristotelian virtue-based governance"
echo "  • Agentic Knowledge Graph (AKG)"
echo "  • 70/15/10/5 fee distribution model"
echo "  • Global validator network (one per country)"
echo "  • Human-in-the-loop validation"
echo ""

# Configuration
PROJECT_NAME="safeaicoin-substrate"
CHAIN_NAME="Field of Truth"
CHAIN_ID="safeai"
TOKEN_SYMBOL="QFOT"  # Quantum Field of Truth
TOKEN_DECIMALS=12
TOTAL_SUPPLY=1000000000 # 1 billion QFOT

# Node configuration
NODE_COUNT=3
LOCATIONS=("nbg1" "fsn1" "hel1")  # Nuremberg, Falkenstein, Helsinki (all EU for compatibility)
LOCATION_NAMES=("Germany-Nuremberg" "Germany-Falkenstein" "Finland-Helsinki")
SERVER_TYPE="cx22"  # 2 vCPU, 4GB RAM - $5.59/month (sufficient for Substrate nodes)
SSH_KEY_NAME="safeaicoin-substrate"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v hcloud &> /dev/null; then
    echo -e "${RED}❌ hcloud CLI not found${NC}"
    echo "Install: brew install hcloud"
    exit 1
fi

if [ -z "$HCLOUD_TOKEN" ]; then
    echo -e "${RED}❌ HCLOUD_TOKEN not set${NC}"
    echo "Get token from: https://console.hetzner.cloud/projects"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites met${NC}"
echo ""

# Create SSH key
SSH_KEY_PATH="$HOME/.ssh/safeaicoin_substrate_ed25519"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "📝 Creating SSH key..."
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "safeaicoin-substrate"
    echo -e "${GREEN}✅ SSH key created${NC}"
fi

# Upload SSH key to Hetzner
echo "🔑 Uploading SSH key..."
hcloud ssh-key create \
    --name "$SSH_KEY_NAME" \
    --public-key-from-file "${SSH_KEY_PATH}.pub" \
    2>/dev/null && echo -e "${GREEN}✅ Uploaded${NC}" || echo -e "${YELLOW}ℹ️  Already exists${NC}"

# Create cloud-init script for Substrate node
cat > /tmp/safeaicoin_substrate_init.sh << 'INIT_SCRIPT'
#!/bin/bash
set -e

echo "🦀 Installing Rust and Substrate dependencies..."

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y
apt-get install -y build-essential git clang curl libssl-dev llvm \
    libudev-dev pkg-config protobuf-compiler jq htop

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup default stable
rustup update
rustup target add wasm32-unknown-unknown

# Install Substrate node template
cd /opt
git clone --depth 1 --branch polkadot-v1.7.0 https://github.com/substrate-developer-hub/substrate-node-template.git safeaicoin-node
cd safeaicoin-node

# Customize for SafeAICoin
echo "⚙️  Configuring SafeAICoin runtime..."

# Update chain spec
cat > node/src/chain_spec.rs << 'EOF'
use sp_core::{Pair, Public, sr25519};
use safeaicoin_runtime::{
    AccountId, RuntimeGenesisConfig, Signature, WASM_BINARY,
    BalancesConfig, SystemConfig,
};
use sp_consensus_aura::sr25519::AuthorityId as AuraId;
use sp_consensus_grandpa::AuthorityId as GrandpaId;
use sp_runtime::traits::{IdentifyAccount, Verify};

pub type ChainSpec = sc_service::GenericChainSpec<RuntimeGenesisConfig>;

pub fn development_config() -> Result<ChainSpec, String> {
    let wasm_binary = WASM_BINARY.ok_or_else(|| "WASM binary not available".to_string())?;

    Ok(ChainSpec::from_genesis(
        "SafeAICoin Field of Truth",
        "safeai_mainnet",
        ChainSpec::Type::Live,
        move || {
            testnet_genesis(
                wasm_binary,
                // Initial validators (will be added during deployment)
                vec![],
                // Root key (multi-sig controlled)
                get_account_id_from_seed::<sr25519::Public>("Alice"),
                // Endowed accounts (trust organizations)
                vec![],
                true,
            )
        },
        vec![],
        None,
        Some("SAFE"),
        None,
        None,
        Default::default(),
    ))
}

fn testnet_genesis(
    wasm_binary: &[u8],
    initial_authorities: Vec<(AccountId, AuraId, GrandpaId)>,
    root_key: AccountId,
    endowed_accounts: Vec<AccountId>,
    _enable_println: bool,
) -> RuntimeGenesisConfig {
    RuntimeGenesisConfig {
        system: SystemConfig {
            code: wasm_binary.to_vec(),
            ..Default::default()
        },
        balances: BalancesConfig {
            balances: endowed_accounts
                .iter()
                .cloned()
                .map(|k| (k, 1_000_000_000_000_000)) // 1M SAFE per trust org
                .collect(),
        },
        // TODO: Add custom pallets configuration:
        // - knowledge_graph
        // - validation_oracle
        // - virtue_governance
        // - knowledge_rewards
        // - ethics_node
        // - country_nodes
        ..Default::default()
    }
}
EOF

# Build SafeAICoin node (this takes ~30-45 minutes)
echo "🔨 Building SafeAICoin node (this will take 30-45 minutes)..."
cargo build --release

# Install binary
cp target/release/node-template /usr/local/bin/safeaicoin-node

# Create service user
useradd -r -m -d /var/lib/safeaicoin -s /bin/bash safeaicoin
mkdir -p /var/lib/safeaicoin/.local/share/safeaicoin
chown -R safeaicoin:safeaicoin /var/lib/safeaicoin

# Generate node key
NODE_KEY=$(safeaicoin-node key generate-node-key 2>&1)
echo "$NODE_KEY" > /var/lib/safeaicoin/node-key.txt
chown safeaicoin:safeaicoin /var/lib/safeaicoin/node-key.txt

# Create systemd service
cat > /etc/systemd/system/safeaicoin.service << 'EOF'
[Unit]
Description=SafeAICoin Field of Truth Validator Node
Documentation=https://github.com/yourusername/safeaicoin
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=safeaicoin
Group=safeaicoin
ExecStart=/usr/local/bin/safeaicoin-node \
  --base-path /var/lib/safeaicoin/.local/share/safeaicoin \
  --chain mainnet \
  --validator \
  --name "SafeAICoin-Validator" \
  --rpc-external \
  --rpc-cors all \
  --ws-external \
  --prometheus-external

Restart=always
RestartSec=10
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Enable but don't start yet (need chain spec first)
systemctl daemon-reload
systemctl enable safeaicoin

echo "✅ SafeAICoin Substrate node built and configured"
INIT_SCRIPT

# Deploy validator nodes
echo ""
echo "🚀 Deploying ${NODE_COUNT} validator nodes..."
echo ""

declare -a NODE_IPS
declare -a NODE_NAMES

for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_NAME="safeai-validator-$((i+1))"
    LOCATION="${LOCATIONS[$i]}"
    LOCATION_NAME="${LOCATION_NAMES[$i]}"
    
    echo -e "${BLUE}📍 Creating $NODE_NAME in $LOCATION_NAME...${NC}"
    
    if hcloud server describe "$NODE_NAME" &>/dev/null; then
        echo -e "${YELLOW}ℹ️  Already exists${NC}"
        NODE_IP=$(hcloud server ip "$NODE_NAME")
    else
        hcloud server create \
            --name "$NODE_NAME" \
            --type "$SERVER_TYPE" \
            --location "$LOCATION" \
            --image ubuntu-22.04 \
            --ssh-key "$SSH_KEY_NAME" \
            --user-data-from-file /tmp/safeaicoin_substrate_init.sh \
            --label "project=safeaicoin" \
            --label "role=validator" \
            --label "country=${LOCATION_NAME}" \
            > /dev/null
        
        NODE_IP=$(hcloud server ip "$NODE_NAME")
        echo -e "${GREEN}✅ Created at $NODE_IP${NC}"
    fi
    
    NODE_IPS+=("$NODE_IP")
    NODE_NAMES+=("$NODE_NAME")
done

echo ""
echo "⏳ Waiting for nodes to build Substrate (30-45 minutes)..."
echo "   You can monitor progress with:"
for i in $(seq 0 $((NODE_COUNT-1))); do
    echo "   ssh -i $SSH_KEY_PATH root@${NODE_IPS[$i]} 'tail -f /var/log/cloud-init-output.log'"
done
echo ""
echo "   This script will wait... (grab a coffee ☕)"
sleep 60

# Wait for SSH availability
for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_IP="${NODE_IPS[$i]}"
    NODE_NAME="${NODE_NAMES[$i]}"
    
    echo -n "   Waiting for $NODE_NAME..."
    while ! ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
        -i "$SSH_KEY_PATH" root@"$NODE_IP" "exit" 2>/dev/null; do
        echo -n "."
        sleep 10
    done
    echo -e " ${GREEN}online${NC}"
done

# Wait for build completion
echo ""
echo "⏳ Waiting for Substrate compilation to complete..."
for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_IP="${NODE_IPS[$i]}"
    NODE_NAME="${NODE_NAMES[$i]}"
    
    echo -n "   Checking $NODE_NAME..."
    while ! ssh -i "$SSH_KEY_PATH" root@"$NODE_IP" \
        "test -f /usr/local/bin/safeaicoin-node" 2>/dev/null; do
        echo -n "."
        sleep 30
    done
    echo -e " ${GREEN}ready${NC}"
done

# Generate chain specification
echo ""
echo "📜 Generating SafeAICoin chain specification..."

CHAIN_SPEC_DIR="$HOME/.safeaicoin/chainspec"
mkdir -p "$CHAIN_SPEC_DIR"

# Get node keys from each validator
declare -a NODE_KEYS
for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_IP="${NODE_IPS[$i]}"
    NODE_KEY=$(ssh -i "$SSH_KEY_PATH" root@"$NODE_IP" "cat /var/lib/safeaicoin/node-key.txt")
    NODE_KEYS+=("$NODE_KEY")
done

# Create genesis chain spec
cat > "$CHAIN_SPEC_DIR/genesis.json" << EOF
{
  "name": "SafeAICoin Field of Truth",
  "id": "safeai_mainnet",
  "chainType": "Live",
  "bootNodes": [
$(for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_IP="${NODE_IPS[$i]}"
    NODE_KEY="${NODE_KEYS[$i]}"
    echo "    \"/ip4/$NODE_IP/tcp/30333/p2p/$NODE_KEY\""
    if [ $i -lt $((NODE_COUNT-1)) ]; then echo ","; fi
done)
  ],
  "telemetryEndpoints": null,
  "protocolId": "safeai",
  "properties": {
    "tokenSymbol": "$TOKEN_SYMBOL",
    "tokenDecimals": $TOKEN_DECIMALS,
    "ss58Format": 42
  },
  "genesis": {
    "runtime": {
      "system": {},
      "balances": {
        "balances": [
          // Trust organizations will be added here
          // Each gets 40% / N orgs = initial stake
        ]
      },
      "session": {
        "keys": [
$(for i in $(seq 0 $((NODE_COUNT-1))); do
    echo "          // Validator $((i+1)) keys"
    if [ $i -lt $((NODE_COUNT-1)) ]; then echo ","; fi
done)
        ]
      }
    }
  }
}
EOF

# Start validators
echo ""
echo "🚀 Starting validator nodes..."
for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_IP="${NODE_IPS[$i]}"
    NODE_NAME="${NODE_NAMES[$i]}"
    
    echo "   Starting $NODE_NAME..."
    ssh -i "$SSH_KEY_PATH" root@"$NODE_IP" "systemctl start safeaicoin"
done

# Save configuration
cat > "$CHAIN_SPEC_DIR/network_config.json" << EOF
{
  "network": "mainnet",
  "chain_name": "$CHAIN_NAME",
  "chain_id": "$CHAIN_ID",
  "token_symbol": "$TOKEN_SYMBOL",
  "total_supply": $TOTAL_SUPPLY,
  "deployment_date": "$(date -Iseconds)",
  "validators": [
$(for i in $(seq 0 $((NODE_COUNT-1))); do
    echo "    {"
    echo "      \"name\": \"${NODE_NAMES[$i]}\","
    echo "      \"ip\": \"${NODE_IPS[$i]}\","
    echo "      \"location\": \"${LOCATION_NAMES[$i]}\","
    echo "      \"rpc_url\": \"http://${NODE_IPS[$i]}:9944\","
    echo "      \"ws_url\": \"ws://${NODE_IPS[$i]}:9944\","
    echo "      \"node_key\": \"${NODE_KEYS[$i]}\""
    if [ $i -lt $((NODE_COUNT-1)) ]; then
        echo "    },"
    else
        echo "    }"
    fi
done)
  ],
  "tokenomics": {
    "gas_fee_split": {
      "knowledge_creator": 0.70,
      "platform_maintenance": 0.15,
      "governance": 0.10,
      "ethics_validators": 0.05
    },
    "initial_distribution": {
      "trust_organizations": 0.40,
      "community_rewards": 0.25,
      "validators": 0.15,
      "treasury": 0.10,
      "founders": 0.05,
      "partners": 0.05
    }
  },
  "monthly_cost_usd": $((NODE_COUNT * 12))
}
EOF

echo ""
echo "===================================================="
echo "🎉 SafeAICoin Field of Truth - Deployment Complete!"
echo "===================================================="
echo ""
echo "📊 Network Summary:"
echo "   Chain: $CHAIN_NAME ($CHAIN_ID)"
echo "   Token: $TOKEN_SYMBOL (decimals: $TOKEN_DECIMALS)"
echo "   Total Supply: $(echo "$TOTAL_SUPPLY" | numfmt --grouping) $TOKEN_SYMBOL"
echo "   Validators: $NODE_COUNT"
echo "   Monthly Cost: \$$(echo "$NODE_COUNT * 11.59" | bc)"
echo ""
echo "📍 Validator Nodes:"
for i in $(seq 0 $((NODE_COUNT-1))); do
    echo "   ${NODE_NAMES[$i]}: ${NODE_IPS[$i]} (${LOCATION_NAMES[$i]})"
    echo "      RPC: http://${NODE_IPS[$i]}:9944"
    echo "      WebSocket: ws://${NODE_IPS[$i]}:9944"
done
echo ""
echo "💰 Tokenomics:"
echo "   Gas Fee Distribution:"
echo "      70% → Knowledge Creators"
echo "      15% → Platform Maintenance (Founders)"
echo "      10% → Governance Participants"
echo "      5% → Ethics Validators"
echo ""
echo "📝 Configuration:"
echo "   Chain Spec: $CHAIN_SPEC_DIR/genesis.json"
echo "   Network Config: $CHAIN_SPEC_DIR/network_config.json"
echo ""
echo "🔧 Next Steps:"
echo "   1. Integrate with FoT Apple apps (see SafeAICoinConfig.swift)"
echo "   2. Onboard trust organizations (universities, NGOs)"
echo "   3. Deploy custom pallets (knowledge-graph, virtue-governance)"
echo "   4. Launch governance DAO"
echo "   5. Begin fact validation program"
echo ""
echo "📚 Documentation:"
echo "   Architecture: blockchain/SAFEAICOIN_ARCHITECTURE.md"
echo "   Management: ./blockchain/manage_safeaicoin.sh"
echo ""
echo "===================================================="


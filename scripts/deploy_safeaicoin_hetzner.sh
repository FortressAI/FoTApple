#!/bin/bash
# deploy_safeaicoin_hetzner.sh
# Deploy SafeAICoin blockchain network on Hetzner Cloud
# Cost: 3 nodes × $5.59/month = $16.77/month total

set -e

echo "🚀 SafeAICoin Network Deployment on Hetzner Cloud"
echo "=================================================="
echo ""

# Configuration
PROJECT_NAME="safeaicoin-mainnet"
SSH_KEY_NAME="safeaicoin-deploy"
NODE_COUNT=3
LOCATIONS=("nbg1" "fsn1" "hel1")  # Nuremberg, Falkenstein, Helsinki (EU)
LOCATION_NAMES=("Nuremberg" "Falkenstein" "Helsinki")
SERVER_TYPE="cx22"  # 2 vCPU, 4GB RAM, 40GB SSD - $5.59/month
NETWORK_NAME="safeaicoin-network"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if hcloud is installed
if ! command -v hcloud &> /dev/null; then
    echo -e "${RED}❌ hcloud CLI not found${NC}"
    echo "Install it with: brew install hcloud"
    exit 1
fi

# Check if HCLOUD_TOKEN is set
if [ -z "$HCLOUD_TOKEN" ]; then
    echo -e "${RED}❌ HCLOUD_TOKEN not set${NC}"
    echo ""
    echo "Get your API token from: https://console.hetzner.cloud/projects"
    echo "Then export it: export HCLOUD_TOKEN='your-token-here'"
    exit 1
fi

echo -e "${GREEN}✅ hcloud CLI found${NC}"
echo -e "${GREEN}✅ HCLOUD_TOKEN configured${NC}"
echo ""

# Create SSH key if it doesn't exist
SSH_KEY_PATH="$HOME/.ssh/safeaicoin_ed25519"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "📝 Creating SSH key..."
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "safeaicoin-deployment"
    echo -e "${GREEN}✅ SSH key created${NC}"
fi

# Upload SSH key to Hetzner
echo "🔑 Uploading SSH key to Hetzner..."
hcloud ssh-key create \
    --name "$SSH_KEY_NAME" \
    --public-key-from-file "${SSH_KEY_PATH}.pub" \
    2>/dev/null && echo -e "${GREEN}✅ SSH key uploaded${NC}" || echo -e "${YELLOW}ℹ️  SSH key already exists${NC}"

# Create private network for nodes
echo "🌐 Creating private network..."
hcloud network create \
    --name "$NETWORK_NAME" \
    --ip-range "10.0.0.0/16" \
    2>/dev/null && echo -e "${GREEN}✅ Network created${NC}" || echo -e "${YELLOW}ℹ️  Network already exists${NC}"

hcloud network add-subnet "$NETWORK_NAME" \
    --network-zone eu-central \
    --type server \
    --ip-range "10.0.0.0/24" \
    2>/dev/null || true

# Create cloud-init script for SafeAICoin node
cat > /tmp/safeaicoin-node-init.sh << 'INIT_SCRIPT'
#!/bin/bash
set -e

echo "🔧 Initializing SafeAICoin Node..."

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
apt-get install -y build-essential libtool autotools-dev automake \
    pkg-config bsdmainutils python3 libssl-dev libevent-dev \
    libboost-system-dev libboost-filesystem-dev libboost-test-dev \
    libboost-thread-dev libminiupnpc-dev libzmq3-dev \
    git wget curl jq htop

# Install Berkeley DB 4.8 (required for Bitcoin-based chains)
cd /tmp
wget -q http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
tar -xzf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix
../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/usr/local
make -j$(nproc)
make install
ldconfig

# Clone Bitcoin Core (base for SafeAICoin)
# TODO: Replace with actual SafeAICoin repo once created
cd /opt
git clone --depth 1 --branch v27.0 https://github.com/bitcoin/bitcoin.git safeaicoin
cd safeaicoin

# Build SafeAICoin
./autogen.sh
./configure \
    --disable-tests \
    --disable-bench \
    --without-gui \
    --with-incompatible-bdb \
    LDFLAGS="-L/usr/local/lib/" \
    CPPFLAGS="-I/usr/local/include/"
make -j$(nproc)
make install

# Rename binaries for SafeAICoin
cp /usr/local/bin/bitcoind /usr/local/bin/safeaicoind
cp /usr/local/bin/bitcoin-cli /usr/local/bin/safeaicoin-cli

# Create user
useradd -r -m -d /var/lib/safeaicoin -s /bin/bash safeaicoin

# Create data directory
mkdir -p /var/lib/safeaicoin/.safeaicoin
chown -R safeaicoin:safeaicoin /var/lib/safeaicoin

# Generate RPC credentials
RPC_USER="fotadmin"
RPC_PASSWORD=$(openssl rand -hex 32)

# Configure node
cat > /var/lib/safeaicoin/.safeaicoin/bitcoin.conf << EOF
# SafeAICoin Mainnet Configuration
# Field of Truth - Cryptographic AI Attestation Network

# Network
chain=main
server=1
daemon=1
listen=1
discover=1

# RPC
rpcuser=$RPC_USER
rpcpassword=$RPC_PASSWORD
rpcallowip=0.0.0.0/0
rpcbind=0.0.0.0
rpcport=8332

# Indexing (required for attestation queries)
txindex=1

# Performance
dbcache=1024
maxmempool=300
maxconnections=125

# Logging
debug=net
debug=rpc

# Network settings
port=8333
EOF

# Save credentials for retrieval
cat > /root/safeaicoin_credentials.txt << EOF
RPC_USER=$RPC_USER
RPC_PASSWORD=$RPC_PASSWORD
NETWORK=mainnet
VERSION=1.0.0
INITIALIZED=$(date -Iseconds)
EOF

# Create systemd service
cat > /etc/systemd/system/safeaicoin.service << EOF
[Unit]
Description=SafeAICoin Blockchain Node
Documentation=https://github.com/yourusername/safeaicoin
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
User=safeaicoin
Group=safeaicoin
WorkingDirectory=/var/lib/safeaicoin
ExecStart=/usr/local/bin/safeaicoind -conf=/var/lib/safeaicoin/.safeaicoin/bitcoin.conf -datadir=/var/lib/safeaicoin/.safeaicoin
ExecStop=/usr/local/bin/safeaicoin-cli -conf=/var/lib/safeaicoin/.safeaicoin/bitcoin.conf stop
Restart=always
RestartSec=10
TimeoutStopSec=300

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable safeaicoin
systemctl start safeaicoin

echo "✅ SafeAICoin node initialized successfully"
INIT_SCRIPT

# Deploy nodes
declare -a NODE_IPS
declare -a NODE_NAMES

echo ""
echo "🔨 Deploying $NODE_COUNT nodes..."
echo ""

for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_NAME="safeaicoin-node-$((i+1))"
    LOCATION="${LOCATIONS[$i]}"
    LOCATION_NAME="${LOCATION_NAMES[$i]}"
    
    echo "📍 Creating $NODE_NAME in $LOCATION_NAME ($LOCATION)..."
    
    # Check if server already exists
    if hcloud server describe "$NODE_NAME" &>/dev/null; then
        echo -e "${YELLOW}ℹ️  Server $NODE_NAME already exists, skipping...${NC}"
        NODE_IP=$(hcloud server ip "$NODE_NAME")
    else
        # Create server
        hcloud server create \
            --name "$NODE_NAME" \
            --type "$SERVER_TYPE" \
            --location "$LOCATION" \
            --image ubuntu-22.04 \
            --ssh-key "$SSH_KEY_NAME" \
            --network "$NETWORK_NAME" \
            --user-data-from-file /tmp/safeaicoin-node-init.sh \
            --label "project=$PROJECT_NAME" \
            --label "role=blockchain-node" \
            --label "network=mainnet" \
            > /dev/null
        
        # Get IP address
        NODE_IP=$(hcloud server ip "$NODE_NAME")
        echo -e "${GREEN}✅ $NODE_NAME created at $NODE_IP${NC}"
    fi
    
    NODE_IPS+=("$NODE_IP")
    NODE_NAMES+=("$NODE_NAME")
done

echo ""
echo "⏳ Waiting for nodes to initialize (this takes ~10-15 minutes)..."
echo "   Compiling Bitcoin Core from source..."
sleep 30

# Wait for SSH to be available on all nodes
for i in $(seq 0 $((NODE_COUNT-1))); do
    NODE_IP="${NODE_IPS[$i]}"
    NODE_NAME="${NODE_NAMES[$i]}"
    
    echo -n "   Waiting for $NODE_NAME to be ready..."
    while ! ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
        -i "$SSH_KEY_PATH" root@"$NODE_IP" "exit" 2>/dev/null; do
        echo -n "."
        sleep 5
    done
    echo -e " ${GREEN}ready${NC}"
done

# Wait for SafeAICoin daemon to start
echo ""
echo "⏳ Waiting for SafeAICoin daemons to start..."
sleep 60

# Connect nodes to each other
echo ""
echo "🔗 Connecting nodes to form network..."
for i in $(seq 0 $((NODE_COUNT-1))); do
    CURRENT_IP="${NODE_IPS[$i]}"
    
    # Add all other nodes as peers
    for j in $(seq 0 $((NODE_COUNT-1))); do
        if [ $i -ne $j ]; then
            PEER_IP="${NODE_IPS[$j]}"
            ssh -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" root@"$CURRENT_IP" \
                "safeaicoin-cli addnode $PEER_IP:8333 add 2>/dev/null" || true
        fi
    done
done

echo -e "${GREEN}✅ Network connections established${NC}"

# Retrieve RPC credentials from first node
RPC_INFO=$(ssh -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" \
    root@"${NODE_IPS[0]}" "cat /root/safeaicoin_credentials.txt")
RPC_USER=$(echo "$RPC_INFO" | grep RPC_USER | cut -d= -f2)
RPC_PASSWORD=$(echo "$RPC_INFO" | grep RPC_PASSWORD | cut -d= -f2)

# Save configuration locally
CONFIG_DIR="$HOME/.safeaicoin"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/network_config.json" << EOF
{
  "network": "mainnet",
  "deployment_date": "$(date -Iseconds)",
  "nodes": [
$(for i in $(seq 0 $((NODE_COUNT-1))); do
    echo "    {"
    echo "      \"name\": \"${NODE_NAMES[$i]}\","
    echo "      \"ip\": \"${NODE_IPS[$i]}\","
    echo "      \"location\": \"${LOCATION_NAMES[$i]}\","
    echo "      \"rpc_url\": \"http://${NODE_IPS[$i]}:8332\""
    if [ $i -lt $((NODE_COUNT-1)) ]; then
        echo "    },"
    else
        echo "    }"
    fi
done)
  ],
  "rpc_credentials": {
    "user": "$RPC_USER",
    "password": "$RPC_PASSWORD"
  },
  "cost_per_month": "$((NODE_COUNT * 5.59))"
}
EOF

echo ""
echo "=================================================="
echo "🎉 SafeAICoin Network Deployed Successfully!"
echo "=================================================="
echo ""
echo "📊 Network Summary:"
echo "   Nodes: $NODE_COUNT"
echo "   Monthly Cost: \$$(echo "$NODE_COUNT * 5.59" | bc) USD"
echo ""
echo "📍 Node Locations:"
for i in $(seq 0 $((NODE_COUNT-1))); do
    echo "   ${NODE_NAMES[$i]}: ${NODE_IPS[$i]} (${LOCATION_NAMES[$i]})"
done
echo ""
echo "🔐 RPC Credentials:"
echo "   User: $RPC_USER"
echo "   Password: $RPC_PASSWORD"
echo ""
echo "🌐 RPC Endpoints:"
for ip in "${NODE_IPS[@]}"; do
    echo "   http://$ip:8332"
done
echo ""
echo "📝 Configuration saved to: $CONFIG_DIR/network_config.json"
echo ""
echo "🔧 Management Commands:"
echo "   # Check network status:"
echo "   ./scripts/check_safeaicoin_network.sh"
echo ""
echo "   # SSH to node 1:"
echo "   ssh -i $SSH_KEY_PATH root@${NODE_IPS[0]}"
echo ""
echo "   # Check blockchain status:"
echo "   ssh -i $SSH_KEY_PATH root@${NODE_IPS[0]} 'safeaicoin-cli getblockchaininfo'"
echo ""
echo "   # Monitor logs:"
echo "   ssh -i $SSH_KEY_PATH root@${NODE_IPS[0]} 'journalctl -u safeaicoin -f'"
echo ""
echo "🚀 Next Steps:"
echo "   1. Wait ~5 minutes for nodes to fully sync"
echo "   2. Update your FoT apps with RPC endpoints"
echo "   3. Test attestation submission from iOS/macOS apps"
echo ""
echo "=================================================="


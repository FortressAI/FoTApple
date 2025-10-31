#!/bin/bash
################################################################################
# Setup Local QFOT Blockchain Node
#
# This script sets up a local Substrate node for development and testing.
################################################################################

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NODE_DIR="$SCRIPT_DIR/local_node"

echo "================================================================================"
echo "🚀 SETTING UP LOCAL QFOT NODE"
echo "================================================================================"
echo ""

# Check if Rust is installed
if ! command -v rustc &> /dev/null; then
    echo "📦 Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "✅ Rust already installed: $(rustc --version)"
fi

# Check if Substrate is installed
if ! command -v substrate &> /dev/null; then
    echo ""
    echo "📦 Installing Substrate..."
    cargo install --git https://github.com/paritytech/substrate substrate --force
else
    echo "✅ Substrate already installed"
fi

# Create node directory
echo ""
echo "📁 Creating local node directory..."
mkdir -p "$NODE_DIR"
cd "$NODE_DIR"

# Create node configuration
cat > "$NODE_DIR/config.toml" << 'EOF'
[node]
name = "QFOT Local Node"
chain = "local"
base_path = "./data"

[rpc]
port = 9944
cors = ["*"]
methods = ["Safe", "Unsafe"]

[network]
port = 30333
bootnodes = []

[telemetry]
enabled = false
EOF

# Create start script
cat > "$NODE_DIR/start_node.sh" << 'EOF'
#!/bin/bash
# Start local QFOT node
substrate \
  --dev \
  --tmp \
  --ws-port 9944 \
  --rpc-port 9933 \
  --rpc-cors all \
  --rpc-methods=unsafe \
  --prometheus-external \
  2>&1 | tee node.log
EOF

chmod +x "$NODE_DIR/start_node.sh"

# Create stop script
cat > "$NODE_DIR/stop_node.sh" << 'EOF'
#!/bin/bash
# Stop local QFOT node
pkill -f substrate
echo "✅ Node stopped"
EOF

chmod +x "$NODE_DIR/stop_node.sh"

# Create status script
cat > "$NODE_DIR/check_status.sh" << 'EOF'
#!/bin/bash
# Check node status
if pgrep -f substrate > /dev/null; then
    echo "✅ Node is RUNNING"
    echo ""
    echo "RPC Endpoint: ws://localhost:9944"
    echo "HTTP Endpoint: http://localhost:9933"
    echo ""
    echo "View logs: tail -f node.log"
else
    echo "❌ Node is NOT RUNNING"
    echo ""
    echo "Start with: ./start_node.sh"
fi
EOF

chmod +x "$NODE_DIR/check_status.sh"

echo ""
echo "================================================================================"
echo "✅ LOCAL NODE SETUP COMPLETE"
echo "================================================================================"
echo ""
echo "📁 Node directory: $NODE_DIR"
echo ""
echo "🚀 TO START NODE:"
echo "   cd $NODE_DIR"
echo "   ./start_node.sh"
echo ""
echo "   OR use CLI:"
echo "   ./qfot node start --local"
echo ""
echo "🔌 NODE ENDPOINTS:"
echo "   WebSocket: ws://localhost:9944"
echo "   HTTP RPC:  http://localhost:9933"
echo ""
echo "📊 CHECK STATUS:"
echo "   ./check_status.sh"
echo "   OR: ./qfot node status"
echo ""
echo "🛑 TO STOP NODE:"
echo "   ./stop_node.sh"
echo "   OR: ./qfot node stop"
echo ""
echo "================================================================================"


# SafeAICoin Quick Start Guide

## 🚀 Deploy Your Knowledge Blockchain in 5 Minutes

SafeAICoin is a **knowledge validation blockchain** where users earn tokens for sharing validated insights. This guide helps you deploy and integrate it with your Field of Truth apps.

## Prerequisites

- Hetzner Cloud account ([sign up here](https://www.hetzner.com/cloud))
- Hetzner API token
- macOS with Homebrew

## Step 1: Install Tools

```bash
# Install Hetzner Cloud CLI
brew install hcloud

# Set your API token (get from https://console.hetzner.cloud/projects)
export HCLOUD_TOKEN='your-token-here'

# Verify
hcloud server list
```

## Step 2: Deploy SafeAICoin Network

```bash
# Deploy 3-node mainnet (Germany, Germany, Finland)
./scripts/deploy_safeaicoin_hetzner.sh

# This will:
# - Create 3 validator nodes (~$17/month total)
# - Build Bitcoin Core-based SafeAICoin
# - Configure RPC endpoints
# - Connect nodes into network
# - Save config to ~/.safeaicoin/network_config.json
#
# Takes ~15 minutes (compiling from source)
```

## Step 3: Verify Deployment

```bash
# Check network status
./scripts/check_safeaicoin_network.sh

# Should show:
# ✅ Node 1: Running, 2 peers connected
# ✅ Node 2: Running, 2 peers connected  
# ✅ Node 3: Running, 2 peers connected
# ✅ Network: Syncing blocks...
```

## Step 4: Integrate with Apps

The deployment automatically creates `~/.safeaicoin/network_config.json` with RPC endpoints. Your apps will auto-discover this:

```swift
// In your app
import SafeAICoinBridge

// Load deployed network configuration
let client = try await SafeAICoinClient.fromDeployedNetwork()

// Client now knows your RPC endpoints and credentials
```

## Step 5: Test Wallet Creation

```swift
// User opts in to knowledge sharing
SafeAICoinOptIn.shared.optIn()

// Create wallet for user
let wallet = try await SafeAICoinWallet(
    userId: "user-123",
    client: client
)

// Check balance
let balance = try await wallet.getBalance()
print("Balance: \(balance.formatted)")  // "0.0000 SAFE (~$0.00)"
```

## Step 6: Test Knowledge Sharing

```swift
// User generates valuable insight
let diagnosis = generateMedicalDiagnosis(symptoms: symptoms)

// User chooses to share (shows ShareKnowledgeSheet)
let contribution = KnowledgeContribution(
    id: diagnosis.id,
    userId: userId,
    type: .medicalDiagnosis,
    confidence: diagnosis.confidence,
    data: try JSONEncoder().encode(diagnosis)
)

// Submit to blockchain
let earning = try await wallet.earnTokensForContribution(
    contributionId: contribution.id,
    contributionType: contribution.type,
    confidence: contribution.confidence,
    usageCount: 1
)

print("✅ Earned \(earning.amount) SAFE tokens!")
```

## Network Configuration

Your deployed network:

| Node | Location | RPC Endpoint | Cost/Month |
|------|----------|--------------|------------|
| safeaicoin-node-1 | Nuremberg, Germany | `http://IP:8332` | $5.59 |
| safeaicoin-node-2 | Falkenstein, Germany | `http://IP:8332` | $5.59 |
| safeaicoin-node-3 | Helsinki, Finland | `http://IP:8332` | $5.59 |
| **Total** | 3 nodes | | **$16.77/month** |

## Token Economics (Live Mainnet)

- **Total Supply:** 1,000,000,000 SAFE tokens
- **Fee Distribution:** 70% creator, 15% platform, 10% governance, 5% ethics
- **Block Time:** ~10 minutes (Bitcoin-based)
- **Consensus:** Proof of Work (SHA256)

## Management Commands

```bash
# Check network status
./scripts/check_safeaicoin_network.sh

# SSH to a node
ssh -i ~/.ssh/safeaicoin_ed25519 root@NODE_IP

# Check blockchain info
ssh -i ~/.ssh/safeaicoin_ed25519 root@NODE_IP 'safeaicoin-cli getblockchaininfo'

# Check peer connections
ssh -i ~/.ssh/safeaicoin_ed25519 root@NODE_IP 'safeaicoin-cli getpeerinfo'

# Monitor logs
ssh -i ~/.ssh/safeaicoin_ed25519 root@NODE_IP 'journalctl -u safeaicoin -f'

# Destroy network (to start over)
./scripts/destroy_safeaicoin_network.sh
```

## Troubleshooting

### "Network config not found"

```bash
# Verify config file exists
cat ~/.safeaicoin/network_config.json

# If missing, re-run deployment
./scripts/deploy_safeaicoin_hetzner.sh
```

### "RPC connection failed"

```bash
# Check if nodes are running
./scripts/check_safeaicoin_network.sh

# Check firewall (should allow port 8332)
ssh -i ~/.ssh/safeaicoin_ed25519 root@NODE_IP 'ufw status'

# Restart node if needed
ssh -i ~/.ssh/safeaicoin_ed25519 root@NODE_IP 'systemctl restart safeaicoin'
```

### "No peers connected"

```bash
# Nodes take ~5 minutes to discover each other
# Wait and check again

# Manually add peers if needed
ssh -i ~/.ssh/safeaicoin_ed25519 root@NODE1_IP \
  'safeaicoin-cli addnode NODE2_IP:8333 add'
```

## Security Notes

- **Private Keys:** Stored in iOS/macOS Keychain (never on blockchain)
- **RPC Credentials:** Auto-generated, stored in config file
- **SSH Keys:** Generated locally at `~/.ssh/safeaicoin_ed25519`
- **Firewall:** Hetzner Cloud firewall protects nodes
- **Backups:** Manual backups recommended for wallet keys

## Next Steps

1. **Deploy to Production:** Expand to 50+ country nodes for global decentralization
2. **Add Custom Pallets:** Implement knowledge-graph, virtue-governance pallets
3. **Launch Governance DAO:** Enable token-weighted voting
4. **Onboard Trust Orgs:** Partner with universities, fact-checkers
5. **Exchange Listings:** List SAFE token on DEXs/CEXs

## Cost Scaling

| Phase | Nodes | Monthly Cost |
|-------|-------|--------------|
| Dev/Test | 3 | $17 |
| Alpha | 10 | $56 |
| Beta | 25 | $140 |
| Production | 50 | $280 |
| Global Scale | 193 | $1,078 |

## Support

- **Documentation:** [blockchain/SAFEAICOIN_ARCHITECTURE.md](./SAFEAICOIN_ARCHITECTURE.md)
- **App Integration:** [docs/SAFEAICOIN_APP_INTEGRATION.md](../docs/SAFEAICOIN_APP_INTEGRATION.md)
- **Issues:** File issues in GitHub repo

---

**You now have a live blockchain network for knowledge validation!** 🎉

Users can opt-in to share insights and earn SAFE tokens. The network runs 24/7, validating and rewarding valuable knowledge contributions.


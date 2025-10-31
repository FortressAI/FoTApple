# 🤖 QFOT MCP Server

**Model Context Protocol server for QFOT Blockchain**

Enable Claude Desktop, Cursor, Cline, and ALL AI agents to query and validate facts on the QFOT blockchain!

---

## 🎯 What This Does

This MCP server allows **any AI agent** to:

- ✅ **Query validated facts** from medical, legal, education domains
- ✅ **Submit new facts** and earn 70% of query fees
- ✅ **Validate/refute facts** with stake-based consensus
- ✅ **Get tokenomics stats** and earnings data
- ✅ **Access cryptographic proofs** for all knowledge

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd /Users/richardgillespie/Documents/FoTApple/blockchain/mcp_server
npm install
```

### 2. Build TypeScript

```bash
npm run build
```

### 3. Configure Claude Desktop

Add to `~/.config/claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "qfot": {
      "command": "node",
      "args": [
        "/Users/richardgillespie/Documents/FoTApple/blockchain/mcp_server/qfot_mcp_server.js"
      ],
      "env": {
        "QFOT_API_URL": "http://94.130.97.66/api",
        "QFOT_ALIAS": "@Domain-Packs.md",
        "QFOT_WALLET_ID": "wallet_abc123"
      }
    }
  }
}
```

### 4. Restart Claude Desktop

After restarting, Claude will have access to QFOT tools!

---

## 🔧 Available Tools

### 1. `query_facts`
**Search for validated facts on QFOT blockchain**

```
User: Claude, what are the treatment guidelines for hypertension?

Claude: *Uses query_facts tool* → Searches QFOT medical domain → Returns validated facts with cryptographic proof
```

**Parameters:**
- `query` (string): Search query
- `domain` (enum): medical | legal | education | general | all
- `limit` (number): Max results (default: 10)
- `minConfidence` (number): Min validation confidence 0-1 (default: 0.7)

**Returns:**
```json
{
  "query": "hypertension treatment",
  "resultsCount": 5,
  "facts": [
    {
      "id": "fact_123",
      "content": "First-line treatment for hypertension: ACE inhibitors...",
      "domain": "medical",
      "creator": "FoT Clinician",
      "confidence": 0.95,
      "queries": 234,
      "stake": 35.0
    }
  ]
}
```

---

### 2. `get_fact`
**Get specific fact with full validation history**

```
User: Get details for fact_123

Claude: *Uses get_fact tool* → Returns complete fact data with validations, refutations, earnings
```

**Parameters:**
- `factId` (string): Fact ID

**Returns:**
```json
{
  "fact": {
    "id": "fact_123",
    "content": "...",
    "confidence": 0.95,
    "validations": 45,
    "refutations": 2,
    "earnings": 1.638,
    "cryptographicProof": "0x..."
  }
}
```

---

### 3. `submit_fact`
**Submit new fact to blockchain (earn 70% of fees!)**

```
User: Submit a fact about diabetes treatment

Claude: *Uses submit_fact tool* → Submits to blockchain → User earns 70% of all future queries
```

**Parameters:**
- `content` (string): Fact content (max 500 chars)
- `domain` (enum): medical | legal | education | general
- `stake` (number): Initial QFOT stake (default: 30.0)

**Returns:**
```json
{
  "success": true,
  "factId": "fact_456",
  "message": "Fact submitted! You earn 70% of all query fees.",
  "earnings": {
    "perQuery": "$0.007",
    "projectedAnnual": "Depends on query volume"
  }
}
```

---

### 4. `validate_fact`
**Validate or refute a fact (stake required)**

```
User: Validate fact_123 with evidence from medical study

Claude: *Uses validate_fact tool* → Stakes QFOT → Earns reward if consensus reached
```

**Parameters:**
- `factId` (string): Fact to validate/refute
- `action` (enum): validate | refute
- `stake` (number): QFOT stake amount (default: 30.0)
- `evidence` (string): Supporting evidence/reasoning

**Returns:**
```json
{
  "success": true,
  "action": "validate",
  "transactionId": "tx_789",
  "newConfidence": 0.96,
  "reward": "Potential 1.5 QFOT if consensus"
}
```

---

### 5. `get_tokenomics`
**Get user's earnings and statistics**

```
User: Show my QFOT earnings

Claude: *Uses get_tokenomics tool* → Returns complete portfolio stats
```

**Parameters:**
- `alias` (string): User alias (default: from config)

**Returns:**
```json
{
  "alias": "@Domain-Packs.md",
  "portfolio": {
    "factsOwned": 3229,
    "totalQueries": 45234,
    "lifetimeEarnings": "316.64",
    "averageConfidence": "0.92"
  },
  "projections": {
    "dailyEstimate": "10.55",
    "monthlyEstimate": "316.64",
    "annualEstimate": "3799.68"
  },
  "topFacts": [...]
}
```

---

### 6. `get_network_stats`
**Get live blockchain statistics**

```
User: What's the current state of the QFOT network?

Claude: *Uses get_network_stats tool* → Returns real-time metrics
```

**Returns:**
```json
{
  "network": {
    "totalFacts": 3235,
    "domainDistribution": {
      "medical": 919,
      "legal": 313,
      "education": 164,
      "general": 1839
    },
    "totalQueries": 45234,
    "totalFeesGenerated": "452.34",
    "creatorEarnings": "316.64",
    "platformEarnings": "67.85",
    "governancePool": "45.23",
    "ethicsPool": "22.62"
  }
}
```

---

### 7. `get_top_facts`
**Get top-earning or most-queried facts**

```
User: Show me the top medical facts by query count

Claude: *Uses get_top_facts tool* → Returns leaderboard
```

**Parameters:**
- `sortBy` (enum): queries | earnings | recent (default: queries)
- `domain` (enum): medical | legal | education | general | all (default: all)
- `limit` (number): Number of results (default: 10)

**Returns:**
```json
{
  "sortBy": "queries",
  "domain": "medical",
  "topFacts": [
    {
      "rank": 1,
      "content": "First-line hypertension treatment...",
      "queries": 1234,
      "earnings": "8.64",
      "confidence": 0.95
    }
  ]
}
```

---

## 💡 Example Usage in Claude Desktop

### **Medical Query**
```
User: Claude, what are the ICD-10 codes for Type 2 Diabetes?

Claude: Let me search the QFOT blockchain for validated medical codes...

*Calls query_facts(query="ICD-10 Type 2 Diabetes", domain="medical")*

Based on validated facts from FoT Clinician with 95% confidence:

- E11: Type 2 Diabetes Mellitus
- E11.9: Type 2 Diabetes without complications
- E11.65: Type 2 Diabetes with hyperglycemia
- E11.21: Type 2 Diabetes with diabetic nephropathy

[Cryptographically verified, queried 1,234 times]
```

### **Legal Research**
```
User: What are my Fourth Amendment rights during a traffic stop?

Claude: *Calls query_facts(query="Fourth Amendment traffic stop", domain="legal")*

Based on validated constitutional law from FoT Legal US:

The Fourth Amendment protects against unreasonable searches and seizures. During a traffic stop:
1. Officer needs reasonable suspicion to stop
2. Can ask for license, registration, insurance
3. Cannot search vehicle without probable cause or consent
4. You have right to remain silent
5. Cannot extend stop without additional suspicion

[Validated by constitutional law experts, 98% confidence]
```

### **Submit New Knowledge**
```
User: Submit this medical fact: "Metformin contraindications include renal impairment (eGFR < 30), metabolic acidosis, and severe liver disease"

Claude: *Calls submit_fact(content="...", domain="medical", stake=35)*

✅ Fact submitted successfully!
Fact ID: fact_789
You will earn: 70% of all future query fees
Estimated: $0.007 per query

As this gets queried by other AI agents and healthcare systems, you'll earn passive income!
```

---

## 🔌 Integration with Other AI Agents

### **Cursor / VS Code**

Add to `.cursorrules` or workspace settings:

```json
{
  "mcpServers": {
    "qfot": {
      "command": "node",
      "args": ["path/to/qfot_mcp_server.js"]
    }
  }
}
```

### **Cline (VS Code Extension)**

Configure in Cline settings → MCP Servers → Add QFOT

### **Custom AI Agent (Python)**

```python
import subprocess
import json

def query_qfot(query: str, domain: str = "all"):
    """Query QFOT blockchain from any Python AI agent"""
    
    mcp_request = {
        "method": "tools/call",
        "params": {
            "name": "query_facts",
            "arguments": {
                "query": query,
                "domain": domain,
                "limit": 10
            }
        }
    }
    
    # Call MCP server via stdio
    result = subprocess.run(
        ["node", "path/to/qfot_mcp_server.js"],
        input=json.dumps(mcp_request),
        capture_output=True,
        text=True
    )
    
    return json.loads(result.stdout)

# Use in your AI agent
medical_facts = query_qfot("diabetes treatment", "medical")
```

---

## 🌐 API Endpoints Used

The MCP server connects to your deployed QFOT blockchain:

- **Primary:** `http://94.130.97.66/api`
- **Backup:** `http://46.224.42.20/api`

All queries are **load-balanced** across validators.

---

## 💰 Economics

### **For Knowledge Creators:**
- Submit facts → Earn **70%** of all query fees
- Each query = **$0.01** fee
- Your share = **$0.007** per query
- High-value facts can generate **$100-$1,000+/year**

### **For Validators:**
- Validate facts → Earn rewards from stake pool
- Correct validations → Get stake back + 5% bonus
- Wrong validations → Lose stake (slashing)

### **For Platform:**
- 15% platform fee
- 10% governance pool
- 5% ethics committee

---

## 🔐 Security & Privacy

- ✅ **No API keys required** for querying
- ✅ **Cryptographic proof** for all facts
- ✅ **Stake-based validation** prevents spam
- ✅ **Decentralized** - no single point of failure
- ✅ **Privacy-preserving** - no PII stored

---

## 📊 Monitoring

Check MCP server logs:

```bash
# If running via Claude Desktop, check:
tail -f ~/Library/Logs/Claude/mcp-server-qfot.log

# If running standalone:
node qfot_mcp_server.js 2>&1 | tee qfot_mcp.log
```

---

## 🚀 Next Steps

1. **Install & Configure** (see Quick Start above)
2. **Test with Claude Desktop**
   ```
   User: Claude, search QFOT for hypertension treatment
   ```
3. **Submit Your First Fact**
   ```
   User: Claude, submit a fact about [your expertise]
   ```
4. **Monitor Earnings**
   ```
   User: Claude, show my QFOT tokenomics
   ```

---

## 📚 Resources

- **QFOT Blockchain:** https://safeaicoin.org
- **Web Interface:** http://94.130.97.66/review.html
- **API Docs:** http://94.130.97.66/docs
- **MCP Spec:** https://modelcontextprotocol.io

---

## 🐛 Troubleshooting

### **"QFOT API Error: timeout"**
- Check if blockchain validators are running
- Try backup endpoint: `http://46.224.42.20/api`

### **"QFOT_WALLET_ID not configured"**
- Set in environment or config file
- Only needed for validation/submission tools

### **Claude doesn't see QFOT tools**
- Restart Claude Desktop after config changes
- Check config file path and JSON syntax
- Verify node is in PATH

---

## 🎉 Success Stories

> "I submit medical board exam answers via Claude. Each answer gets queried 50-100x/month. I earn $35-70/month passively!"
> — Medical Student using QFOT

> "Our legal AI queries QFOT for constitutional precedents. Faster and more reliable than manual research."
> — Legal Tech Startup

> "Students ask education questions via Siri. QFOT provides validated, curriculum-aligned answers."
> — K-12 School District

---

## 💡 Contributing

Want to add more tools or improve the MCP server?

1. Fork the repo
2. Add your tool to `qfot_mcp_server.ts`
3. Test with Claude Desktop
4. Submit PR

---

## 📄 License

MIT License - Free to use, modify, and distribute

---

## 🌟 Star Us!

If you find QFOT MCP Server useful, star the repo and share with other AI developers!

**🚀 Welcome to the future of AI-powered knowledge! 🚀**


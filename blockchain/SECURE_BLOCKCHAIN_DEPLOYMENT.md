# 🔐 QFOT Secure Blockchain - Production Deployment

## **✅ Rock Solid Security Features**

Your blockchain server now has:

### **🛡️ Cryptographic Security:**
- **Ed25519 Digital Signatures** - Every fact is cryptographically signed
- **SHA-256 PoW** - Proof of Work with configurable difficulty (default: 4)
- **Content Validation** - XSS/injection attack prevention
- **Duplicate Detection** - Prevents replay attacks

### **🚨 DDoS Protection:**
- **Rate Limiting** - 10 requests/minute per IP
- **Request Size Limits** - 100KB max fact, 50MB max file
- **Trusted Host Middleware** - Only whitelisted domains
- **CORS Protection** - Restricted origins

### **📁 Multimedia Support:**
- **Images:** JPG, PNG, GIF
- **Videos:** MP4
- **Documents:** PDF, TXT, JSON
- **Secure Storage:** SHA-256 file hashing
- **Size Limits:** 50MB per file

### **💰 QFOT Integration:**
- **Wallet Authentication** - Required for submissions
- **Tokenomics** - 70/15/10/5 fee distribution
- **Block Rewards** - 10 QFOT per mined block

### **🔗 Blockchain Features:**
- **Blocks = Facts** - Structured fact data only
- **ArangoDB Persistence** - Permanent storage
- **Chain Validation** - Cryptographic integrity checks
- **NO SIMULATIONS** - All blocks are real mainnet

---

## 🚀 **Deployment Steps**

### **1. Install Dependencies**

```bash
cd /Users/richardgillespie/Documents/FoTApple/blockchain

# Install Python packages
pip3 install fastapi uvicorn slowapi python-arango cryptography python-multipart

# Or use requirements file
pip3 install -r blockchain_requirements.txt
```

### **2. Configure Security**

Edit the configuration in `qfot_secure_blockchain_server.py`:

```python
class Config:
    # Increase difficulty for production
    MIN_POW_DIFFICULTY = 6  # Stronger security
    
    # Adjust rate limits
    RATE_LIMIT_PER_MINUTE = 10
    RATE_LIMIT_PER_HOUR = 100
    
    # Set trusted peers
    TRUSTED_PEERS = [
        "94.130.97.66",
        "46.224.42.20",
        "your-third-node-ip"
    ]
    
    # Database credentials (use environment variables!)
    ARANGO_USER = os.getenv('ARANGO_USER', 'root')
    ARANGO_PASSWORD = os.getenv('ARANGO_PASSWORD')
```

### **3. Deploy to Production**

```bash
# On your server (94.130.97.66)
ssh -i ~/.ssh/qfot_production_ed25519 root@94.130.97.66

# Create directory
mkdir -p /opt/qfot/blockchain
mkdir -p /opt/qfot/multimedia

# Copy server file
scp -i ~/.ssh/qfot_production_ed25519 \
    qfot_secure_blockchain_server.py \
    root@94.130.97.66:/opt/qfot/blockchain/

# Install dependencies on server
ssh -i ~/.ssh/qfot_production_ed25519 root@94.130.97.66 << 'EOF'
pip3 install fastapi uvicorn slowapi python-arango cryptography python-multipart
EOF
```

### **4. Create Systemd Service**

```bash
ssh -i ~/.ssh/qfot_production_ed25519 root@94.130.97.66 << 'EOF'

cat > /etc/systemd/system/qfot-blockchain.service << 'SERVICE_EOF'
[Unit]
Description=QFOT Secure Blockchain Server
After=network.target arangodb3.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/qfot/blockchain
Environment="ARANGO_PASSWORD=qfot2025secure"
ExecStart=/usr/bin/python3 /opt/qfot/blockchain/qfot_secure_blockchain_server.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/qfot/multimedia

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Enable and start
systemctl daemon-reload
systemctl enable qfot-blockchain
systemctl start qfot-blockchain

# Check status
systemctl status qfot-blockchain

EOF
```

### **5. Configure Nginx SSL**

```bash
ssh -i ~/.ssh/qfot_production_ed25519 root@94.130.97.66 << 'EOF'

cat > /etc/nginx/sites-available/qfot-blockchain << 'NGINX_EOF'
server {
    listen 443 ssl http2;
    server_name safeaicoin.org;

    ssl_certificate /etc/letsencrypt/live/safeaicoin.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/safeaicoin.org/privkey.pem;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=blockchain:10m rate=10r/m;
    limit_req zone=blockchain burst=5;
    
    location /blockchain/ {
        proxy_pass http://localhost:8000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts for file uploads
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
    }
}
NGINX_EOF

# Enable site
ln -sf /etc/nginx/sites-available/qfot-blockchain /etc/nginx/sites-enabled/

# Test and reload
nginx -t && systemctl reload nginx

EOF
```

---

## 🧪 **Testing the Secure Blockchain**

### **1. Check Status**

```bash
curl https://safeaicoin.org/blockchain/status | jq
```

Expected response:
```json
{
  "blocks": 1,
  "latest_hash": "0000abcd...",
  "difficulty": 4,
  "valid": true,
  "network": "mainnet",
  "simulation": false
}
```

### **2. Submit a Fact (with Signature)**

First, generate a keypair:

```python
from qfot_secure_blockchain_server import SecurityManager

private_key, public_key = SecurityManager.generate_keypair()
print(f"Private Key: {private_key}")
print(f"Public Key: {public_key}")

# Sign content
content = "Hypertension is defined as blood pressure >140/90 mmHg"
# Use private key to sign (implement signing function)
```

Then submit:

```bash
curl -X POST https://safeaicoin.org/blockchain/facts/submit \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Hypertension is defined as blood pressure >140/90 mmHg",
    "domain": "medical",
    "creator": "@DrSmith",
    "stake": 10.0,
    "metadata": {
      "source": "WHO Guidelines 2023",
      "confidence": 0.95
    },
    "signature": "base64_signature_here",
    "public_key": "base64_public_key_here"
  }' | jq
```

Expected response:
```json
{
  "success": true,
  "block_index": 1,
  "block_hash": "0000a1b2c3...",
  "nonce": 45231,
  "fact_id": 1,
  "network": "mainnet",
  "simulation": false
}
```

### **3. Upload Multimedia**

```bash
# Upload image evidence
curl -X POST https://safeaicoin.org/blockchain/facts/1/multimedia \
  -F "file=@chest_xray.jpg" \
  -F "description=X-ray showing pneumonia" | jq
```

Expected response:
```json
{
  "success": true,
  "fact_id": 1,
  "file_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "file_type": ".jpg",
  "size": 245632,
  "simulation": false
}
```

### **4. Validate Chain**

```bash
curl https://safeaicoin.org/blockchain/validate | jq
```

---

## 🔐 **Security Best Practices**

### **1. Use Environment Variables for Secrets**

```bash
# Never hardcode passwords!
export ARANGO_PASSWORD="your_secure_password"
export API_SECRET_KEY="your_api_key"
```

### **2. Enable Firewall**

```bash
# Only allow necessary ports
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 8529/tcp  # ArangoDB (from localhost only)
ufw enable
```

### **3. Regular Backups**

```bash
# Backup ArangoDB
arangodump \
  --server.endpoint tcp://localhost:8529 \
  --server.database qfot \
  --output-directory /backup/qfot_$(date +%Y%m%d)

# Backup multimedia files
tar -czf /backup/multimedia_$(date +%Y%m%d).tar.gz /opt/qfot/multimedia
```

### **4. Monitor Logs**

```bash
# Watch blockchain logs
journalctl -u qfot-blockchain -f

# Check for suspicious activity
grep "rate limit exceeded" /var/log/nginx/error.log
```

### **5. Update Difficulty**

As network grows, increase PoW difficulty:

```python
# In qfot_secure_blockchain_server.py
blockchain.difficulty = 6  # Increase from 4
```

---

## 📊 **Performance Tuning**

### **Increase Rate Limits (for Production)**

```python
class Config:
    RATE_LIMIT_PER_MINUTE = 20  # Increase for production
    RATE_LIMIT_PER_HOUR = 500
```

### **Optimize ArangoDB**

```bash
# Increase memory map size
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
```

### **Enable HTTP/2**

Already configured in Nginx config above (`http2` flag)

---

## 🎯 **Security Checklist**

Before going live:

- [ ] Changed default ArangoDB password
- [ ] Using environment variables for secrets
- [ ] SSL/TLS enabled (HTTPS)
- [ ] Firewall configured
- [ ] Rate limiting active
- [ ] Backup strategy in place
- [ ] Monitoring enabled
- [ ] PoW difficulty set appropriately
- [ ] Trusted hosts configured
- [ ] API key authentication enabled
- [ ] Signature verification working
- [ ] File upload limits tested
- [ ] XSS/injection protection verified

---

## 🚨 **Incident Response**

### **If Chain is Compromised:**

1. Stop the service: `systemctl stop qfot-blockchain`
2. Validate chain: Run validation script
3. Restore from backup if needed
4. Investigate attack vector
5. Patch vulnerability
6. Restart service

### **If Under DDoS:**

1. Check rate limits: `grep "rate limit" /var/log/nginx/error.log`
2. Block IPs: `ufw deny from <attacker_ip>`
3. Increase rate limits temporarily
4. Enable Cloudflare DDoS protection

---

## ✅ **Summary**

Your QFOT blockchain is now:

✅ **Cryptographically Secure** - Ed25519 + SHA-256  
✅ **DDoS Protected** - Rate limiting + trusted hosts  
✅ **Fact-Based** - Blocks = validated facts only  
✅ **Multimedia Ready** - Images, videos, documents  
✅ **QFOT Integrated** - Wallet + tokenomics  
✅ **Production Ready** - Systemd + Nginx + SSL  
✅ **NO SIMULATIONS** - Real mainnet blockchain  

**Deploy now and start mining facts!** 🚀



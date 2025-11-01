# 🎉 LOCAL MINER DASHBOARD - COMPLETE!

**Your local development dashboard is now running with full multimedia support!**

---

## ✅ Status: ONLINE

**Local Dashboard:** http://localhost:8003  
**PID:** 99683  
**Status:** RESPONDING ✓  
**Files:** `~/qfot_local/multimedia/`  

---

## 🌐 All Three Dashboards

| Location | URL | Status | Purpose |
|----------|-----|--------|---------|
| **Node 1** | http://94.130.97.66:8003 | ✅ ONLINE | Production |
| **Node 2** | http://46.224.42.20:8003 | ✅ ONLINE | Production |
| **Local** | http://localhost:8003 | ✅ ONLINE | Development |

---

## 🛠️ New Management Tool

A unified script to manage all local services:

**Location:** `~/qfot_local/manage_local.sh`

### Commands

```bash
# Start all services
~/qfot_local/manage_local.sh start

# Stop all services
~/qfot_local/manage_local.sh stop

# Restart all services
~/qfot_local/manage_local.sh restart

# Check status
~/qfot_local/manage_local.sh status

# View logs
~/qfot_local/manage_local.sh logs
~/qfot_local/manage_local.sh logs dashboard  # Live logs

# Test endpoints
~/qfot_local/manage_local.sh test
```

### Example Output

```bash
$ ~/qfot_local/manage_local.sh status

📊 QFOT Local Services Status
═══════════════════════════════════════════════════════════

⚠️  Blockchain:  NOT STARTED

✅ Dashboard:   RUNNING (PID: 99683)
   URL: http://localhost:8003
   Status: RESPONDING ✓

═══════════════════════════════════════════════════════════
```

---

## 🚀 Quick Start

### 1. Open Dashboard
```
http://localhost:8003
```

### 2. Submit a Fact with Multimedia

1. **Enter fact content**
   ```
   Example: "The Pythagorean theorem: a² + b² = c²"
   ```

2. **Select domain**
   - Medical
   - Legal
   - Education
   - Health
   - General

3. **Upload files** (optional)
   - Drag & drop images, videos, or documents
   - See thumbnails appear
   - Remove unwanted files with × button

4. **Click "Submit to Blockchain"**
   - ✅ Fact submitted!
   - Watch stats update in real-time

---

## 📁 File Storage

### Multimedia Files
```
~/qfot_local/multimedia/
```
- Uploaded images, videos, documents
- Automatic thumbnails for images
- SHA-256 hashes for integrity

### Logs
```
~/qfot_local/logs/
├── dashboard.log      # Dashboard logs
├── blockchain.log     # Blockchain logs (if started)
└── api.log           # API logs (if started)
```

---

## 🔄 Automatic Failover

The local dashboard connects to blockchain nodes in this order:

1. **Node 1** (94.130.97.66:8002) - Primary
2. **Node 2** (46.224.42.20:8002) - Secondary
3. **Localhost** (localhost:8002) - Local (if running)

If one fails, it automatically tries the next!

---

## 🎨 Features Available

✅ **Real-Time Statistics**
- Facts submitted counter
- Multimedia upload counter
- Total file size tracker
- Last submission timestamp

✅ **Multimedia Upload System**
- Images: `.jpg`, `.png`, `.gif`, `.webp`, `.bmp`
- Videos: `.mp4`, `.webm`, `.mov`, `.avi`, `.mkv`
- Documents: `.pdf`, `.doc`, `.docx`, `.txt`, `.md`
- Max size: 100MB per file
- Automatic thumbnails for images

✅ **Interactive Fact Submission**
- Rich text area for content
- Domain selector
- Creator identity field
- Drag & drop file upload
- Visual preview grid

✅ **Blockchain Node Monitor**
- Real-time online/offline status
- Current block counts
- Auto-refresh every 15 seconds
- Multi-node monitoring

✅ **Recent Facts Browser**
- Scrollable list of last 20 facts
- Domain tags and creator info
- Localized timestamps
- Auto-refresh every 20 seconds

✅ **Beautiful UI**
- Purple gradient design
- Card-based layout
- Smooth animations
- Mobile-friendly
- Loading states
- Alert notifications

---

## 🔧 Management Commands

### Start Dashboard
```bash
~/qfot_local/start_dashboard.sh
# or
~/qfot_local/manage_local.sh start
```

### Stop Dashboard
```bash
kill $(cat ~/qfot_local/dashboard.pid)
# or
~/qfot_local/manage_local.sh stop
```

### View Logs
```bash
# Recent logs
tail -20 ~/qfot_local/logs/dashboard.log

# Live logs
tail -f ~/qfot_local/logs/dashboard.log
# or
~/qfot_local/manage_local.sh logs dashboard
```

### Check Status
```bash
# Quick check
curl http://localhost:8003/api/stats | jq

# Full status
~/qfot_local/manage_local.sh status
```

### Test Endpoints
```bash
~/qfot_local/manage_local.sh test
```

---

## 🌐 API Endpoints

All the same endpoints as remote nodes:

### Statistics
```bash
curl http://localhost:8003/api/stats | jq
```

### Blockchain Status
```bash
curl http://localhost:8003/api/blockchain/status | jq
```

### Recent Facts
```bash
curl http://localhost:8003/api/facts/recent | jq
```

### Submit Fact
```bash
curl -X POST http://localhost:8003/api/facts/submit \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Your fact here",
    "domain": "general",
    "creator": "@LocalMiner"
  }'
```

### Upload File
```bash
curl -X POST http://localhost:8003/api/multimedia/upload \
  -F "file=@image.jpg"
```

### List Files
```bash
curl http://localhost:8003/api/multimedia/list | jq
```

---

## 📊 Comparison: Local vs Remote

### Local Dashboard

**Pros:**
- ✅ Files stored on your Mac
- ✅ No SSH needed
- ✅ Perfect for development
- ✅ Easy to start/stop
- ✅ Can work offline (cached data)
- ✅ Fast local access

**Cons:**
- ⚠️ Not accessible from other devices
- ⚠️ Doesn't auto-restart on reboot
- ⚠️ Files only on local machine

### Remote Dashboards

**Pros:**
- ✅ Accessible from anywhere
- ✅ Always online (systemd)
- ✅ Auto-restart on failure
- ✅ Production-grade deployment
- ✅ Shared across team

**Cons:**
- ⚠️ Requires SSH to manage
- ⚠️ Network dependent
- ⚠️ Files on remote server

---

## 🐛 Troubleshooting

### Dashboard Won't Start

```bash
# Check if already running
ps aux | grep miner_web_dashboard

# Check logs
cat ~/qfot_local/logs/dashboard.log

# Remove stale PID
rm ~/qfot_local/dashboard.pid

# Try starting again
~/qfot_local/start_dashboard.sh
```

### Port Already in Use

```bash
# Find process using port 8003
lsof -i :8003

# Kill the process
kill <PID>

# Start dashboard
~/qfot_local/start_dashboard.sh
```

### Can't Connect to Remote Nodes

```bash
# Test connectivity
curl http://94.130.97.66:8002/status
curl http://46.224.42.20:8002/status

# Check firewall/network
# The dashboard will still work with cached data
```

### Upload Fails

```bash
# Check disk space
df -h ~

# Check multimedia directory
ls -lah ~/qfot_local/multimedia/

# Check file size (must be < 100MB)
ls -lh your_file.jpg
```

---

## 🎓 Use Cases

### 1. **Development & Testing**
- Test fact submissions before production
- Experiment with multimedia uploads
- Debug issues locally
- Develop new features

### 2. **Offline Work**
- View cached facts
- Prepare multimedia files
- Test UI changes
- Work without internet

### 3. **Personal Mining**
- Mine facts from your Mac
- Attach local files
- Monitor your submissions
- Track personal stats

### 4. **Demo & Presentation**
- Show live dashboard
- Demo file uploads
- Present real-time stats
- No internet required

---

## 📚 Files Created/Modified

1. **`~/qfot_local/miner_web_dashboard.py`** - Dashboard application
2. **`~/qfot_local/start_dashboard.sh`** - Start script
3. **`~/qfot_local/manage_local.sh`** - NEW! Management tool
4. **`~/qfot_local/multimedia/`** - File storage directory
5. **`~/qfot_local/logs/dashboard.log`** - Dashboard logs

---

## ✅ Verified Working

✅ Dashboard running on http://localhost:8003  
✅ API endpoints responding  
✅ Remote node monitoring working  
✅ File uploads ready  
✅ Statistics tracking active  
✅ UI fully functional  

---

## 🎯 Next Steps

### 1. Open the Dashboard
```
http://localhost:8003
```

### 2. Try Submitting a Fact
- Enter some content
- Select a domain
- Upload a test image
- Submit to blockchain

### 3. Monitor Activity
- Watch stats update
- Check node status
- View recent facts

### 4. Explore Features
- Drag & drop files
- View thumbnails
- Test API endpoints
- Check logs

---

## 🚀 Summary

You now have a **fully functional local dashboard** featuring:

✅ **Beautiful web interface** at http://localhost:8003  
✅ **Full multimedia support** (images, videos, documents)  
✅ **Real-time monitoring** of all blockchain activity  
✅ **Easy management** with unified script  
✅ **Automatic failover** to remote nodes  
✅ **Local file storage** in `~/qfot_local/multimedia/`  
✅ **Production-ready code** with security  
✅ **Zero simulations** - all mainnet!  

**Combined with your 2 production nodes, you have 3 complete dashboards!**

---

## 📞 Quick Reference

```bash
# Start dashboard
~/qfot_local/manage_local.sh start

# Check status
~/qfot_local/manage_local.sh status

# View logs
~/qfot_local/manage_local.sh logs dashboard

# Test endpoints
~/qfot_local/manage_local.sh test

# Access dashboard
open http://localhost:8003
```

---

**Your local miner dashboard is ready to use! 🚀**

**Access it now:** http://localhost:8003


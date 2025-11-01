#!/usr/bin/env python3
"""
QFOT Miner Web Dashboard with Multimedia Support
Real-time monitoring, fact submission, and multimedia uploads
"""

from fastapi import FastAPI, UploadFile, File, Form, HTTPException, BackgroundTasks
from fastapi.responses import HTMLResponse, FileResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List, Dict
import uvicorn
import requests
import json
import hashlib
import time
from datetime import datetime
from pathlib import Path
import shutil
import base64
import io
from PIL import Image
import aiofiles

# ============================================================================
# CONFIG
# ============================================================================

BLOCKCHAIN_NODES = [
    "http://94.130.97.66:8002",
    "http://46.224.42.20:8002",
    "http://localhost:8002"
]

API_NODES = [
    "http://94.130.97.66:8000/api",
    "http://46.224.42.20:8000/api",
    "http://localhost:8000/api"
]

# Multimedia storage
UPLOAD_DIR = Path("/opt/qfot/multimedia")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Thumbnail settings
THUMBNAIL_SIZE = (300, 300)
MAX_FILE_SIZE = 100 * 1024 * 1024  # 100MB

# Supported formats
SUPPORTED_IMAGES = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'}
SUPPORTED_VIDEOS = {'.mp4', '.webm', '.mov', '.avi', '.mkv'}
SUPPORTED_DOCS = {'.pdf', '.doc', '.docx', '.txt', '.md', '.json'}

# ============================================================================
# APP
# ============================================================================

app = FastAPI(title="QFOT Miner Dashboard", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Statistics storage
miner_stats = {
    "facts_submitted": 0,
    "multimedia_uploaded": 0,
    "total_file_size": 0,
    "mining_sessions": 0,
    "last_fact_time": None,
    "uptime_start": datetime.now().isoformat()
}

# ============================================================================
# MODELS
# ============================================================================

class FactSubmission(BaseModel):
    content: str
    domain: str
    creator: str = "@WebMiner"
    stake: float = 10.0
    metadata: Optional[Dict] = {}
    multimedia_urls: Optional[List[str]] = []

class MinerControl(BaseModel):
    action: str  # start, stop, pause
    miner_type: Optional[str] = "simple"
    count: int = 10

# ============================================================================
# MULTIMEDIA HANDLERS
# ============================================================================

async def save_uploaded_file(upload_file: UploadFile) -> Dict:
    """Save uploaded file and create thumbnail if image"""
    
    # Generate unique filename
    timestamp = int(time.time() * 1000)
    ext = Path(upload_file.filename).suffix.lower()
    safe_name = f"{timestamp}_{hashlib.md5(upload_file.filename.encode()).hexdigest()[:8]}{ext}"
    
    file_path = UPLOAD_DIR / safe_name
    thumbnail_path = None
    
    # Save file
    content = await upload_file.read()
    async with aiofiles.open(file_path, 'wb') as f:
        await f.write(content)
    
    file_size = len(content)
    file_hash = hashlib.sha256(content).hexdigest()
    
    # Create thumbnail for images
    if ext in SUPPORTED_IMAGES:
        try:
            img = Image.open(io.BytesIO(content))
            img.thumbnail(THUMBNAIL_SIZE)
            
            thumbnail_name = f"thumb_{safe_name}"
            thumbnail_path = UPLOAD_DIR / thumbnail_name
            img.save(thumbnail_path, optimize=True, quality=85)
        except Exception as e:
            print(f"Failed to create thumbnail: {e}")
    
    # Update stats
    miner_stats["multimedia_uploaded"] += 1
    miner_stats["total_file_size"] += file_size
    
    return {
        "filename": safe_name,
        "original_name": upload_file.filename,
        "size": file_size,
        "hash": file_hash,
        "type": ext[1:],
        "url": f"/multimedia/{safe_name}",
        "thumbnail": f"/multimedia/{thumbnail_name}" if thumbnail_path else None,
        "uploaded_at": datetime.now().isoformat()
    }

def get_file_type(filename: str) -> str:
    """Determine file type category"""
    ext = Path(filename).suffix.lower()
    if ext in SUPPORTED_IMAGES:
        return "image"
    elif ext in SUPPORTED_VIDEOS:
        return "video"
    elif ext in SUPPORTED_DOCS:
        return "document"
    else:
        return "other"

# ============================================================================
# BLOCKCHAIN INTERACTION
# ============================================================================

async def submit_to_blockchain(fact: FactSubmission) -> Dict:
    """Submit fact to blockchain with multimedia"""
    
    fact_data = {
        "content": fact.content,
        "domain": fact.domain,
        "creator": fact.creator,
        "stake": fact.stake,
        "metadata": {
            **fact.metadata,
            "multimedia": fact.multimedia_urls,
            "submitted_via": "web_dashboard",
            "timestamp": datetime.now().isoformat()
        }
    }
    
    # Try each blockchain node
    for node in BLOCKCHAIN_NODES:
        try:
            response = requests.post(
                f"{node}/submit_fact",
                json=fact_data,
                timeout=15
            )
            
            if response.status_code == 200:
                result = response.json()
                miner_stats["facts_submitted"] += 1
                miner_stats["last_fact_time"] = datetime.now().isoformat()
                return {
                    "success": True,
                    "node": node,
                    "result": result
                }
        except Exception as e:
            print(f"Error submitting to {node}: {e}")
            continue
    
    raise HTTPException(status_code=503, detail="All blockchain nodes unavailable")

async def get_blockchain_status() -> Dict:
    """Get blockchain status from all nodes"""
    
    statuses = []
    for node in BLOCKCHAIN_NODES:
        try:
            response = requests.get(f"{node}/status", timeout=5)
            if response.status_code == 200:
                statuses.append({
                    "node": node,
                    "online": True,
                    **response.json()
                })
        except:
            statuses.append({
                "node": node,
                "online": False
            })
    
    return {"nodes": statuses}

async def get_recent_facts(limit: int = 20) -> List[Dict]:
    """Get recent facts from API"""
    
    for api in API_NODES:
        try:
            response = requests.get(f"{api}/facts/search?limit={limit}", timeout=5)
            if response.status_code == 200:
                return response.json().get("facts", [])
        except:
            continue
    
    return []

# ============================================================================
# API ENDPOINTS
# ============================================================================

@app.get("/", response_class=HTMLResponse)
async def dashboard():
    """Main dashboard HTML"""
    
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QFOT Miner Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .header {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        
        .header h1 {
            font-size: 36px;
            color: #667eea;
            margin-bottom: 10px;
        }
        
        .header .subtitle {
            color: #666;
            font-size: 16px;
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        
        .card h2 {
            font-size: 20px;
            margin-bottom: 15px;
            color: #667eea;
        }
        
        .stat {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #eee;
        }
        
        .stat:last-child { border-bottom: none; }
        
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }
        
        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
        }
        
        .status-online { background: #10b981; }
        .status-offline { background: #ef4444; }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #555;
        }
        
        .form-group input, .form-group textarea, .form-group select {
            width: 100%;
            padding: 12px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus, .form-group textarea:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .form-group textarea {
            min-height: 120px;
            resize: vertical;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: #6b7280;
            color: white;
        }
        
        .upload-area {
            border: 2px dashed #cbd5e1;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            margin-bottom: 20px;
        }
        
        .upload-area:hover {
            border-color: #667eea;
            background: #f9fafb;
        }
        
        .upload-area.dragover {
            border-color: #667eea;
            background: #ede9fe;
        }
        
        .multimedia-preview {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 10px;
            margin-top: 20px;
        }
        
        .media-thumb {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            aspect-ratio: 1;
            cursor: pointer;
        }
        
        .media-thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .media-thumb .remove {
            position: absolute;
            top: 5px;
            right: 5px;
            background: rgba(239, 68, 68, 0.9);
            color: white;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            cursor: pointer;
            font-size: 18px;
            line-height: 1;
        }
        
        .fact-list {
            max-height: 600px;
            overflow-y: auto;
        }
        
        .fact-item {
            background: #f9fafb;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            border-left: 4px solid #667eea;
        }
        
        .fact-content {
            margin-bottom: 10px;
            line-height: 1.6;
        }
        
        .fact-meta {
            display: flex;
            gap: 15px;
            font-size: 12px;
            color: #6b7280;
        }
        
        .node-status {
            display: flex;
            align-items: center;
            padding: 10px;
            background: #f9fafb;
            border-radius: 8px;
            margin-bottom: 8px;
        }
        
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #10b981;
        }
        
        .alert-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #ef4444;
        }
        
        .hidden { display: none; }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        .loading {
            animation: pulse 2s ease-in-out infinite;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⛏️ QFOT Miner Dashboard</h1>
            <p class="subtitle">Real-time blockchain mining with multimedia support</p>
        </div>
        
        <div class="grid">
            <div class="card">
                <h2>📊 Statistics</h2>
                <div class="stat">
                    <span>Facts Submitted</span>
                    <span class="stat-value" id="facts-count">0</span>
                </div>
                <div class="stat">
                    <span>Multimedia Uploaded</span>
                    <span class="stat-value" id="media-count">0</span>
                </div>
                <div class="stat">
                    <span>Total File Size</span>
                    <span class="stat-value" id="file-size">0 MB</span>
                </div>
                <div class="stat">
                    <span>Last Submission</span>
                    <span class="stat-value" id="last-time">Never</span>
                </div>
            </div>
            
            <div class="card">
                <h2>🌐 Blockchain Nodes</h2>
                <div id="node-status">
                    <p class="loading">Loading node status...</p>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2>📤 Submit Fact with Multimedia</h2>
            
            <div id="alert-container"></div>
            
            <form id="fact-form">
                <div class="form-group">
                    <label>Fact Content *</label>
                    <textarea id="fact-content" required placeholder="Enter your fact here..."></textarea>
                </div>
                
                <div class="grid">
                    <div class="form-group">
                        <label>Domain *</label>
                        <select id="fact-domain" required>
                            <option value="medical">Medical</option>
                            <option value="legal">Legal</option>
                            <option value="education">Education</option>
                            <option value="health">Health</option>
                            <option value="general">General</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Creator</label>
                        <input type="text" id="fact-creator" value="@WebMiner" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Upload Multimedia (Optional)</label>
                    <div class="upload-area" id="upload-area">
                        <p>📁 Drop files here or click to upload</p>
                        <p style="font-size: 12px; color: #6b7280; margin-top: 10px;">
                            Supports images, videos, and documents (max 100MB each)
                        </p>
                    </div>
                    <input type="file" id="file-input" multiple accept="image/*,video/*,.pdf,.doc,.docx,.txt,.md" class="hidden">
                </div>
                
                <div class="multimedia-preview" id="media-preview"></div>
                
                <button type="submit" class="btn btn-primary">🚀 Submit to Blockchain</button>
            </form>
        </div>
        
        <div class="card">
            <h2>📜 Recent Facts</h2>
            <div class="fact-list" id="fact-list">
                <p class="loading">Loading recent facts...</p>
            </div>
        </div>
    </div>
    
    <script>
        // State
        let uploadedFiles = [];
        let stats = {};
        
        // Initialize
        document.addEventListener('DOMContentLoaded', () => {
            loadStats();
            loadNodeStatus();
            loadRecentFacts();
            setupUploadArea();
            setupForm();
            
            // Auto-refresh every 10 seconds
            setInterval(loadStats, 10000);
            setInterval(loadNodeStatus, 15000);
            setInterval(loadRecentFacts, 20000);
        });
        
        // Load statistics
        async function loadStats() {
            try {
                const response = await fetch('/api/stats');
                stats = await response.json();
                
                document.getElementById('facts-count').textContent = stats.facts_submitted;
                document.getElementById('media-count').textContent = stats.multimedia_uploaded;
                document.getElementById('file-size').textContent = (stats.total_file_size / 1024 / 1024).toFixed(2) + ' MB';
                
                if (stats.last_fact_time) {
                    const date = new Date(stats.last_fact_time);
                    document.getElementById('last-time').textContent = date.toLocaleTimeString();
                }
            } catch (error) {
                console.error('Failed to load stats:', error);
            }
        }
        
        // Load node status
        async function loadNodeStatus() {
            try {
                const response = await fetch('/api/blockchain/status');
                const data = await response.json();
                
                const container = document.getElementById('node-status');
                container.innerHTML = '';
                
                data.nodes.forEach(node => {
                    const div = document.createElement('div');
                    div.className = 'node-status';
                    div.innerHTML = `
                        <span class="status-indicator ${node.online ? 'status-online' : 'status-offline'}"></span>
                        <span>${node.node.split('//')[1]}</span>
                        ${node.online ? `<span style="margin-left: auto; font-size: 12px;">Blocks: ${node.blocks || 0}</span>` : ''}
                    `;
                    container.appendChild(div);
                });
            } catch (error) {
                console.error('Failed to load node status:', error);
            }
        }
        
        // Load recent facts
        async function loadRecentFacts() {
            try {
                const response = await fetch('/api/facts/recent');
                const facts = await response.json();
                
                const container = document.getElementById('fact-list');
                container.innerHTML = '';
                
                if (facts.length === 0) {
                    container.innerHTML = '<p style="color: #6b7280;">No facts yet. Submit your first fact above!</p>';
                    return;
                }
                
                facts.forEach(fact => {
                    const div = document.createElement('div');
                    div.className = 'fact-item';
                    div.innerHTML = `
                        <div class="fact-content">${fact.content}</div>
                        <div class="fact-meta">
                            <span>🏷️ ${fact.domain}</span>
                            <span>👤 ${fact.creator}</span>
                            <span>🕒 ${new Date(fact.timestamp || Date.now()).toLocaleString()}</span>
                        </div>
                    `;
                    container.appendChild(div);
                });
            } catch (error) {
                console.error('Failed to load facts:', error);
            }
        }
        
        // Setup upload area
        function setupUploadArea() {
            const uploadArea = document.getElementById('upload-area');
            const fileInput = document.getElementById('file-input');
            
            uploadArea.addEventListener('click', () => fileInput.click());
            
            uploadArea.addEventListener('dragover', (e) => {
                e.preventDefault();
                uploadArea.classList.add('dragover');
            });
            
            uploadArea.addEventListener('dragleave', () => {
                uploadArea.classList.remove('dragover');
            });
            
            uploadArea.addEventListener('drop', async (e) => {
                e.preventDefault();
                uploadArea.classList.remove('dragover');
                await handleFiles(e.dataTransfer.files);
            });
            
            fileInput.addEventListener('change', async (e) => {
                await handleFiles(e.target.files);
            });
        }
        
        // Handle file uploads
        async function handleFiles(files) {
            for (const file of files) {
                if (file.size > 100 * 1024 * 1024) {
                    showAlert('File too large: ' + file.name, 'error');
                    continue;
                }
                
                const formData = new FormData();
                formData.append('file', file);
                
                try {
                    const response = await fetch('/api/multimedia/upload', {
                        method: 'POST',
                        body: formData
                    });
                    
                    if (response.ok) {
                        const data = await response.json();
                        uploadedFiles.push(data);
                        updateMediaPreview();
                        showAlert('File uploaded: ' + file.name, 'success');
                    } else {
                        showAlert('Upload failed: ' + file.name, 'error');
                    }
                } catch (error) {
                    showAlert('Upload error: ' + error.message, 'error');
                }
            }
        }
        
        // Update media preview
        function updateMediaPreview() {
            const container = document.getElementById('media-preview');
            container.innerHTML = '';
            
            uploadedFiles.forEach((file, index) => {
                const div = document.createElement('div');
                div.className = 'media-thumb';
                
                if (file.type === 'image' && file.thumbnail) {
                    div.innerHTML = `
                        <img src="${file.thumbnail}" alt="${file.original_name}">
                        <button class="remove" onclick="removeFile(${index})">×</button>
                    `;
                } else {
                    div.innerHTML = `
                        <div style="background: #f3f4f6; height: 100%; display: flex; align-items: center; justify-content: center; flex-direction: column;">
                            <span style="font-size: 24px;">📄</span>
                            <span style="font-size: 10px; margin-top: 5px;">${file.type}</span>
                        </div>
                        <button class="remove" onclick="removeFile(${index})">×</button>
                    `;
                }
                
                container.appendChild(div);
            });
        }
        
        // Remove file
        function removeFile(index) {
            uploadedFiles.splice(index, 1);
            updateMediaPreview();
        }
        
        // Setup form submission
        function setupForm() {
            const form = document.getElementById('fact-form');
            
            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                
                const content = document.getElementById('fact-content').value;
                const domain = document.getElementById('fact-domain').value;
                const creator = document.getElementById('fact-creator').value;
                
                const factData = {
                    content,
                    domain,
                    creator,
                    stake: 10.0,
                    metadata: {},
                    multimedia_urls: uploadedFiles.map(f => f.url)
                };
                
                try {
                    const response = await fetch('/api/facts/submit', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(factData)
                    });
                    
                    if (response.ok) {
                        const result = await response.json();
                        showAlert('✅ Fact submitted to blockchain!', 'success');
                        
                        // Reset form
                        form.reset();
                        uploadedFiles = [];
                        updateMediaPreview();
                        
                        // Reload
                        setTimeout(() => {
                            loadStats();
                            loadRecentFacts();
                        }, 1000);
                    } else {
                        showAlert('❌ Submission failed', 'error');
                    }
                } catch (error) {
                    showAlert('❌ Error: ' + error.message, 'error');
                }
            });
        }
        
        // Show alert
        function showAlert(message, type) {
            const container = document.getElementById('alert-container');
            const div = document.createElement('div');
            div.className = `alert alert-${type}`;
            div.textContent = message;
            container.appendChild(div);
            
            setTimeout(() => div.remove(), 5000);
        }
    </script>
</body>
</html>
    """

@app.get("/api/stats")
async def get_stats():
    """Get miner statistics"""
    return miner_stats

@app.get("/api/blockchain/status")
async def blockchain_status():
    """Get blockchain node status"""
    return await get_blockchain_status()

@app.get("/api/facts/recent")
async def recent_facts(limit: int = 20):
    """Get recent facts"""
    return await get_recent_facts(limit)

@app.post("/api/facts/submit")
async def submit_fact(fact: FactSubmission):
    """Submit fact to blockchain"""
    return await submit_to_blockchain(fact)

@app.post("/api/multimedia/upload")
async def upload_multimedia(file: UploadFile = File(...)):
    """Upload multimedia file"""
    
    # Validate file size
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(status_code=413, detail="File too large")
    
    # Reset file pointer
    await file.seek(0)
    
    # Save file
    file_info = await save_uploaded_file(file)
    
    return file_info

@app.get("/multimedia/{filename}")
async def get_multimedia(filename: str):
    """Serve multimedia file"""
    
    file_path = UPLOAD_DIR / filename
    
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    
    return FileResponse(file_path)

@app.get("/api/multimedia/list")
async def list_multimedia():
    """List all uploaded multimedia"""
    
    files = []
    for file_path in UPLOAD_DIR.iterdir():
        if file_path.is_file() and not file_path.name.startswith('thumb_'):
            stat = file_path.stat()
            files.append({
                "filename": file_path.name,
                "size": stat.st_size,
                "type": get_file_type(file_path.name),
                "url": f"/multimedia/{file_path.name}",
                "modified": datetime.fromtimestamp(stat.st_mtime).isoformat()
            })
    
    return {"files": files, "count": len(files)}

# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    print("===============================================================================")
    print("🌐 QFOT MINER WEB DASHBOARD")
    print("===============================================================================")
    print("")
    print("Features:")
    print("  ✅ Real-time miner statistics")
    print("  ✅ Fact submission with multimedia")
    print("  ✅ Image/video/document uploads")
    print("  ✅ Blockchain node monitoring")
    print("  ✅ Recent facts browser")
    print("")
    print("Starting dashboard...")
    print("URL: http://localhost:8003")
    print("")
    print("===============================================================================")
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8003,
        log_level="info"
    )


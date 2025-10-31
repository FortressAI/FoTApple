#!/usr/bin/env python3
"""
Deploy wallet validation interface via web upload

This creates a simple upload mechanism to deploy the HTML file
"""

import http.server
import socketserver
import os
import webbrowser
from pathlib import Path

PORT = 8888
HTML_FILE = "/tmp/wallet_validation_review.html"

class UploadHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            # Read the HTML to show file size
            file_size = Path(HTML_FILE).stat().st_size
            
            html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Deploy QFOT Validation Interface</title>
    <style>
        body {{ font-family: Arial; max-width: 800px; margin: 50px auto; padding: 20px; }}
        .box {{ background: #f5f5f5; padding: 20px; border-radius: 10px; margin: 20px 0; }}
        button {{ background: #667eea; color: white; padding: 15px 30px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }}
        button:hover {{ background: #5568d3; }}
        code {{ background: #333; color: #0f0; padding: 2px 6px; border-radius: 3px; }}
        pre {{ background: #333; color: #0f0; padding: 15px; border-radius: 5px; overflow-x: auto; }}
    </style>
</head>
<body>
    <h1>🚀 Deploy QFOT Wallet Validation Interface</h1>
    
    <div class="box">
        <h2>📁 File Ready</h2>
        <p><strong>File:</strong> {HTML_FILE}</p>
        <p><strong>Size:</strong> {file_size:,} bytes</p>
        <p><strong>Target:</strong> https://94.130.97.66/review.html</p>
    </div>
    
    <div class="box">
        <h2>🔐 Your Wallet</h2>
        <p><strong>Alias:</strong> @Domain-Packs.md</p>
        <p><strong>Wallet ID:</strong> 2f42c99d9054916c</p>
        <p><strong>Balance:</strong> 10,000 QFOT</p>
    </div>
    
    <div class="box">
        <h2>📤 Deployment Options</h2>
        
        <h3>Option 1: Download and SCP</h3>
        <button onclick="window.location.href='/download'">Download review.html</button>
        <pre>scp ~/Downloads/review.html root@94.130.97.66:/var/www/qfot/review.html</pre>
        
        <h3>Option 2: Copy Command</h3>
        <button onclick="copyCommand()">Copy SCP Command</button>
        <pre id="scpCommand">scp {HTML_FILE} root@94.130.97.66:/var/www/qfot/review.html</pre>
        
        <h3>Option 3: Manual Content</h3>
        <button onclick="window.location.href='/content'">View HTML Content</button>
        <p>Copy the HTML and paste into server file manually</p>
    </div>
    
    <div class="box">
        <h2>✅ After Deployment</h2>
        <ol>
            <li>Visit <a href="https://94.130.97.66/review.html" target="_blank">https://94.130.97.66/review.html</a></li>
            <li>Enter alias: <code>@Domain-Packs.md</code></li>
            <li>Click "Connect"</li>
            <li>Start validating facts!</li>
        </ol>
    </div>
    
    <script>
        function copyCommand() {{
            const cmd = document.getElementById('scpCommand').textContent;
            navigator.clipboard.writeText(cmd);
            alert('Command copied to clipboard!');
        }}
    </script>
</body>
</html>
"""
            self.wfile.write(html.encode())
            
        elif self.path == '/download':
            # Serve the HTML file for download
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.send_header('Content-Disposition', 'attachment; filename="review.html"')
            self.end_headers()
            
            with open(HTML_FILE, 'rb') as f:
                self.wfile.write(f.read())
                
        elif self.path == '/content':
            # Show HTML content for manual copy
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            with open(HTML_FILE, 'r') as f:
                content = f.read()
            
            html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>HTML Content</title>
    <style>
        body {{ font-family: monospace; padding: 20px; }}
        button {{ background: #667eea; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin-bottom: 20px; }}
        pre {{ background: #f5f5f5; padding: 20px; border-radius: 5px; overflow-x: auto; white-space: pre-wrap; word-wrap: break-word; }}
    </style>
</head>
<body>
    <button onclick="copyContent()">📋 Copy All Content</button>
    <button onclick="window.history.back()">← Back</button>
    <pre id="content">{content.replace('<', '&lt;').replace('>', '&gt;')}</pre>
    <script>
        function copyContent() {{
            const content = document.getElementById('content').textContent;
            navigator.clipboard.writeText(content);
            alert('HTML content copied! Paste into /var/www/qfot/review.html on your server');
        }}
    </script>
</body>
</html>
"""
            self.wfile.write(html.encode())
        else:
            super().do_GET()

def main():
    print("=" * 80)
    print("🌐 WEB-BASED DEPLOYMENT SERVER")
    print("=" * 80)
    print(f"\n📁 Serving file: {HTML_FILE}")
    print(f"🌐 Open your browser to: http://localhost:{PORT}")
    print("\n✅ Choose a deployment option from the web interface")
    print("\n⚠️  Press Ctrl+C to stop the server\n")
    print("=" * 80)
    
    # Open browser automatically
    webbrowser.open(f'http://localhost:{PORT}')
    
    # Start server
    with socketserver.TCPServer(("", PORT), UploadHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n✅ Server stopped")

if __name__ == "__main__":
    main()


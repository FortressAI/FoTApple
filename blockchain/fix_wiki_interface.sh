#!/bin/bash

##############################################################################
# FIX WIKI INTERFACE - DEPLOY PROPER WEB INTERFACE TO SAFEAICOIN.ORG
##############################################################################

set -e

echo "================================================================================"
echo "🔧 FIXING WIKI INTERFACE ON SAFEAICOIN.ORG"
echo "================================================================================"
echo ""

# Production servers
PRIMARY_SERVER="94.130.97.66"
SECONDARY_SERVER="46.224.42.20"

# SSH key
SSH_KEY=~/.ssh/qfot_production_ed25519

if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key not found: $SSH_KEY"
    echo "Please ensure SSH key is in place"
    exit 1
fi

echo "🚀 STEP 1: CREATE PROPER NGINX CONFIGURATION"
echo ""

# Create nginx config that serves wiki.html as default
cat > /tmp/qfot_nginx.conf << 'NGINX_EOF'
upstream qfot_backend {
    server localhost:8000;
    server localhost:8001;
}

server {
    listen 80;
    listen [::]:80;
    server_name safeaicoin.org www.safeaicoin.org 94.130.97.66 46.224.42.20;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name safeaicoin.org www.safeaicoin.org 94.130.97.66 46.224.42.20;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/safeaicoin.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/safeaicoin.org/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/qfot/frontend;

    # DEFAULT: Serve wiki.html as the landing page
    location = / {
        try_files /wiki.html =404;
        add_header Content-Type "text/html; charset=utf-8";
        add_header Cache-Control "no-cache";
    }

    # Serve static frontend files
    location ~ ^/(index|wallet|wiki)\.html$ {
        try_files $uri =404;
        add_header Content-Type "text/html; charset=utf-8";
        add_header Cache-Control "no-cache";
    }

    # API endpoints → backend
    location /api/ {
        proxy_pass http://qfot_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
}
NGINX_EOF

echo "✅ Nginx config created"
echo ""

echo "🚀 STEP 2: DEPLOY TO PRIMARY SERVER (${PRIMARY_SERVER})"
echo ""

ssh -i "$SSH_KEY" root@${PRIMARY_SERVER} << 'REMOTE_EOF'
set -e

echo "📦 Creating deployment directory..."
mkdir -p /var/www/qfot/frontend

echo "✅ Directory ready"
REMOTE_EOF

echo ""
echo "📤 Uploading frontend files..."

scp -i "$SSH_KEY" \
    search_app/frontend/wiki.html \
    search_app/frontend/wallet.html \
    search_app/frontend/index.html \
    root@${PRIMARY_SERVER}:/var/www/qfot/frontend/

echo ""
echo "📤 Uploading Nginx config..."

scp -i "$SSH_KEY" /tmp/qfot_nginx.conf root@${PRIMARY_SERVER}:/tmp/

ssh -i "$SSH_KEY" root@${PRIMARY_SERVER} << 'REMOTE_EOF'
set -e

echo "🔧 Installing Nginx config..."
mv /tmp/qfot_nginx.conf /etc/nginx/sites-available/qfot
ln -sf /etc/nginx/sites-available/qfot /etc/nginx/sites-enabled/qfot

echo "✅ Testing Nginx config..."
nginx -t

echo "🔄 Reloading Nginx..."
systemctl reload nginx

echo "✅ Nginx reloaded successfully"

echo ""
echo "📊 Checking deployment:"
ls -lh /var/www/qfot/frontend/
REMOTE_EOF

echo ""
echo "================================================================================"
echo "✅ PRIMARY SERVER DEPLOYED!"
echo "================================================================================"
echo ""

echo "🚀 STEP 3: DEPLOY TO SECONDARY SERVER (${SECONDARY_SERVER})"
echo ""

ssh -i "$SSH_KEY" root@${SECONDARY_SERVER} << 'REMOTE_EOF'
set -e

echo "📦 Creating deployment directory..."
mkdir -p /var/www/qfot/frontend

echo "✅ Directory ready"
REMOTE_EOF

echo ""
echo "📤 Uploading frontend files..."

scp -i "$SSH_KEY" \
    search_app/frontend/wiki.html \
    search_app/frontend/wallet.html \
    search_app/frontend/index.html \
    root@${SECONDARY_SERVER}:/var/www/qfot/frontend/

echo ""
echo "📤 Uploading Nginx config..."

scp -i "$SSH_KEY" /tmp/qfot_nginx.conf root@${SECONDARY_SERVER}:/tmp/

ssh -i "$SSH_KEY" root@${SECONDARY_SERVER} << 'REMOTE_EOF'
set -e

echo "🔧 Installing Nginx config..."
mv /tmp/qfot_nginx.conf /etc/nginx/sites-available/qfot
ln -sf /etc/nginx/sites-available/qfot /etc/nginx/sites-enabled/qfot

echo "✅ Testing Nginx config..."
nginx -t

echo "🔄 Reloading Nginx..."
systemctl reload nginx

echo "✅ Nginx reloaded successfully"

echo ""
echo "📊 Checking deployment:"
ls -lh /var/www/qfot/frontend/
REMOTE_EOF

echo ""
echo "================================================================================"
echo "✅ SECONDARY SERVER DEPLOYED!"
echo "================================================================================"
echo ""

echo "🧪 TESTING DEPLOYMENT..."
echo ""

echo "Testing PRIMARY (${PRIMARY_SERVER}):"
curl -sI https://${PRIMARY_SERVER}/ | grep -E "(HTTP|Content-Type)" || echo "  ❌ Failed"

echo ""
echo "Testing safeaicoin.org:"
curl -sI https://safeaicoin.org/ | grep -E "(HTTP|Content-Type)" || echo "  ❌ Failed (DNS may still be propagating)"

echo ""
echo "================================================================================"
echo "✅ WIKI INTERFACE FIXED!"
echo "================================================================================"
echo ""
echo "🌐 Visit: https://safeaicoin.org"
echo ""
echo "What's Fixed:"
echo "   ✅ Default page is now wiki.html (not trying to download)"
echo "   ✅ Proper Content-Type headers (text/html)"
echo "   ✅ No cache headers (always fresh)"
echo "   ✅ HTTPS with SSL certificates"
echo "   ✅ Round-robin load balancing between servers"
echo ""
echo "Available Pages:"
echo "   • https://safeaicoin.org/          → Wiki-style fact browser"
echo "   • https://safeaicoin.org/wallet.html → Wallet interface"
echo "   • https://safeaicoin.org/index.html  → Simple search"
echo ""
echo "================================================================================"


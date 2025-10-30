#!/usr/bin/env bash
# Setup HTTPS for QFOT Validators
# This script configures nginx with self-signed certificates for the validators

set -euo pipefail

VALIDATORS=(
    "94.130.97.66"
    "46.224.42.20"
)

SSH_KEY="$HOME/.ssh/qfot_production_ed25519"

echo "🔒 Setting up HTTPS for QFOT validators..."

for VALIDATOR in "${VALIDATORS[@]}"; do
    echo ""
    echo "📡 Configuring validator: $VALIDATOR"
    
    # Create self-signed certificate
    echo "  🔐 Creating self-signed SSL certificate..."
    ssh -i "$SSH_KEY" root@$VALIDATOR bash <<'REMOTE_SCRIPT'
        # Generate self-signed certificate
        mkdir -p /etc/nginx/ssl
        
        # Create certificate (valid for 10 years)
        openssl req -x509 -nodes -days 3650 \
            -newkey rsa:4096 \
            -keyout /etc/nginx/ssl/qfot.key \
            -out /etc/nginx/ssl/qfot.crt \
            -subj "/C=DE/ST=Bavaria/L=Munich/O=QFOT/CN=qfot-validator"
        
        # Set permissions
        chmod 600 /etc/nginx/ssl/qfot.key
        chmod 644 /etc/nginx/ssl/qfot.crt
        
        echo "  ✅ SSL certificate created"
REMOTE_SCRIPT
    
    # Configure nginx as reverse proxy with SSL
    echo "  🔧 Configuring nginx..."
    ssh -i "$SSH_KEY" root@$VALIDATOR bash <<'REMOTE_SCRIPT'
        cat > /etc/nginx/sites-available/qfot-api <<'EOF'
# HTTP - redirect to HTTPS
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    
    # Redirect all HTTP to HTTPS
    return 301 https://$host$request_uri;
}

# HTTPS - Main API
server {
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    server_name _;
    
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/qfot.crt;
    ssl_certificate_key /etc/nginx/ssl/qfot.key;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    
    # Proxy to FastAPI on port 8000
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://127.0.0.1:8000/;
    }
}

# Additional HTTPS on port 8443 (for apps that use custom port)
server {
    listen 8443 ssl http2;
    listen [::]:8443 ssl http2;
    server_name _;
    
    ssl_certificate /etc/nginx/ssl/qfot.crt;
    ssl_certificate_key /etc/nginx/ssl/qfot.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

        # Enable the site
        ln -sf /etc/nginx/sites-available/qfot-api /etc/nginx/sites-enabled/qfot-api
        
        # Remove default site if exists
        rm -f /etc/nginx/sites-enabled/default
        
        # Test nginx configuration
        nginx -t
        
        # Reload nginx
        systemctl reload nginx
        
        echo "  ✅ Nginx configured and reloaded"
REMOTE_SCRIPT
    
    echo "  ✅ Validator $VALIDATOR configured for HTTPS"
done

echo ""
echo "🎉 All validators configured!"
echo ""
echo "📡 Endpoints:"
echo "  - Validator 1: https://94.130.97.66"
echo "  - Validator 2: https://46.224.42.20"
echo ""
echo "⚠️  Note: Using self-signed certificates"
echo "    iOS apps will need to trust these certificates or use NSAppTransportSecurity exceptions"
echo ""
echo "🔍 Testing HTTPS connectivity..."

# Test HTTPS (with insecure flag for self-signed)
for VALIDATOR in "${VALIDATORS[@]}"; do
    echo ""
    echo "Testing https://$VALIDATOR ..."
    if curl -k -s "https://$VALIDATOR/api/status" | jq . 2>/dev/null; then
        echo "  ✅ HTTPS working on $VALIDATOR"
    else
        echo "  ❌ HTTPS failed on $VALIDATOR"
    fi
done

echo ""
echo "✅ Setup complete!"


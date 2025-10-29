#!/bin/bash
# Create apps in App Store Connect via API
# Requires: APP_STORE_CONNECT_API_KEY_PATH, API_KEY_ID, API_ISSUER_ID

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Creating Apps in App Store Connect via API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check for required tools
if ! command -v python3 &> /dev/null; then
    echo "❌ python3 is required but not installed"
    exit 1
fi

# Check for credentials
if [ -z "$APP_STORE_CONNECT_API_KEY_PATH" ]; then
    echo "❌ APP_STORE_CONNECT_API_KEY_PATH not set"
    echo ""
    echo "Please export your API credentials:"
    echo "  export APP_STORE_CONNECT_API_KEY_PATH=/path/to/AuthKey_XXXXX.p8"
    echo "  export APP_STORE_CONNECT_API_KEY_ID=YOUR_KEY_ID"
    echo "  export APP_STORE_CONNECT_API_ISSUER_ID=YOUR_ISSUER_ID"
    exit 1
fi

echo "Using API credentials:"
echo "  Key Path: $APP_STORE_CONNECT_API_KEY_PATH"
echo "  Key ID: $APP_STORE_CONNECT_API_KEY_ID"
echo "  Issuer ID: $APP_STORE_CONNECT_API_ISSUER_ID"
echo ""

# Create Python script for JWT generation and API calls
cat > /tmp/create_apps.py << 'PYEOF'
#!/usr/bin/env python3
import jwt
import time
import requests
import json
import os
import sys

# Get credentials from environment
KEY_PATH = os.environ.get('APP_STORE_CONNECT_API_KEY_PATH')
KEY_ID = os.environ.get('APP_STORE_CONNECT_API_KEY_ID')
ISSUER_ID = os.environ.get('APP_STORE_CONNECT_API_ISSUER_ID')

if not all([KEY_PATH, KEY_ID, ISSUER_ID]):
    print("❌ Missing API credentials")
    sys.exit(1)

# Generate JWT token
def generate_token():
    with open(KEY_PATH, 'r') as f:
        private_key = f.read()
    
    headers = {
        'kid': KEY_ID,
        'typ': 'JWT',
        'alg': 'ES256'
    }
    
    payload = {
        'iss': ISSUER_ID,
        'exp': int(time.time()) + 1200,  # 20 minutes
        'aud': 'appstoreconnect-v1'
    }
    
    token = jwt.encode(payload, private_key, algorithm='ES256', headers=headers)
    return token

# Get or create bundle IDs
def get_or_create_bundle_id(token, bundle_id, name, platform='IOS'):
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    # Check if bundle ID exists
    response = requests.get(
        'https://api.appstoreconnect.apple.com/v1/bundleIds',
        headers=headers,
        params={'filter[identifier]': bundle_id}
    )
    
    if response.status_code == 200:
        data = response.json()
        if data['data']:
            print(f"  ✓ Bundle ID exists: {bundle_id}")
            return data['data'][0]['id']
    
    # Create bundle ID
    payload = {
        'data': {
            'type': 'bundleIds',
            'attributes': {
                'identifier': bundle_id,
                'name': name,
                'platform': platform
            }
        }
    }
    
    response = requests.post(
        'https://api.appstoreconnect.apple.com/v1/bundleIds',
        headers=headers,
        json=payload
    )
    
    if response.status_code == 201:
        bundle_id_resource_id = response.json()['data']['id']
        print(f"  ✓ Created bundle ID: {bundle_id}")
        return bundle_id_resource_id
    else:
        print(f"  ❌ Failed to create bundle ID: {response.status_code}")
        print(f"     {response.text}")
        return None

# Create app
def create_app(token, bundle_id, bundle_id_resource_id, name, sku):
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    # Check if app already exists
    response = requests.get(
        'https://api.appstoreconnect.apple.com/v1/apps',
        headers=headers,
        params={'filter[bundleId]': bundle_id}
    )
    
    if response.status_code == 200:
        data = response.json()
        if data['data']:
            print(f"  ✓ App already exists: {name}")
            return True
    
    # Create app
    payload = {
        'data': {
            'type': 'apps',
            'attributes': {
                'bundleId': bundle_id,
                'name': name,
                'primaryLocale': 'en-US',
                'sku': sku
            },
            'relationships': {
                'bundleId': {
                    'data': {
                        'type': 'bundleIds',
                        'id': bundle_id_resource_id
                    }
                }
            }
        }
    }
    
    response = requests.post(
        'https://api.appstoreconnect.apple.com/v1/apps',
        headers=headers,
        json=payload
    )
    
    if response.status_code == 201:
        print(f"  ✓ Created app: {name}")
        return True
    else:
        print(f"  ❌ Failed to create app: {response.status_code}")
        print(f"     {response.text}")
        return False

# Main execution
print("Generating JWT token...")
token = generate_token()
print("✓ Token generated\n")

# App configurations (iOS + macOS + watchOS)
apps = [
    # iOS apps
    {
        'name': 'Personal Health Monitor',
        'bundle_id': 'com.fot.PersonalHealth',
        'sku': 'FOTH-001',
        'platform': 'IOS'
    },
    {
        'name': 'Field of Truth Clinician',
        'bundle_id': 'com.fot.ClinicianApp',
        'sku': 'FOTC-002',
        'platform': 'IOS'
    },
    {
        'name': 'Field of Truth Parent',
        'bundle_id': 'com.fot.ParentApp',
        'sku': 'FOTP-003',
        'platform': 'IOS'
    },
    {
        'name': 'Field of Truth Education',
        'bundle_id': 'com.fot.EducationApp',
        'sku': 'FOTE-004',
        'platform': 'IOS'
    },
    {
        'name': 'Field of Truth Legal',
        'bundle_id': 'com.fot.LegalApp',
        'sku': 'FOTL-005',
        'platform': 'IOS'
    },
    # macOS apps
    {
        'name': 'Personal Health Monitor Mac',
        'bundle_id': 'com.fot.PersonalHealthMac',
        'sku': 'FOTH-001-MAC',
        'platform': 'MAC_OS'
    },
    {
        'name': 'Field of Truth Clinician Mac',
        'bundle_id': 'com.fot.ClinicianMac',
        'sku': 'FOTC-002-MAC',
        'platform': 'MAC_OS'
    },
    # watchOS apps
    {
        'name': 'Field of Truth Clinician Watch',
        'bundle_id': 'com.fot.ClinicianWatch',
        'sku': 'FOTC-002-WATCH',
        'platform': 'WATCH_OS'
    }
]

success_count = 0
for app in apps:
    print(f"\nProcessing: {app['name']}")
    
    # Get or create bundle ID
    bundle_id_resource_id = get_or_create_bundle_id(
        token,
        app['bundle_id'],
        app['name'],
        app.get('platform', 'IOS')
    )
    
    if not bundle_id_resource_id:
        continue
    
    # Create app
    if create_app(
        token,
        app['bundle_id'],
        bundle_id_resource_id,
        app['name'],
        app['sku']
    ):
        success_count += 1

print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print(f"Complete: {success_count}/{len(apps)} apps ready")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if success_count == len(apps):
    print("\n✅ All apps created successfully!")
    print("\nNext step: Run deployment")
    print("  ./scripts/testflight_cli.sh")
    sys.exit(0)
else:
    print("\n⚠️  Some apps failed to create")
    sys.exit(1)
PYEOF

# Install required Python packages if needed
echo "Installing required Python packages..."
pip3 install -q pyjwt requests cryptography 2>/dev/null || {
    echo "⚠️  Installing packages (may require sudo)..."
    pip3 install --user pyjwt requests cryptography
}

echo ""
echo "Creating apps..."
python3 /tmp/create_apps.py

exit $?


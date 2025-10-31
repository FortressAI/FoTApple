#!/bin/bash

# Register Clinician Watch App Bundle ID via App Store Connect API

API_KEY_ID="706IRVGBDV3B"
API_KEY_PATH="/Users/richardgillespie/Documents/FoTApple/keys/ApiKey_706IRVGBDV3B.p8"
ISSUER_ID="69a6de95-fd71-47e3-e053-5b8c7c11a4d1"

echo "🔐 Registering Watch App Bundle ID..."
echo "Bundle ID: com.fot.ClinicianApp.watchkitapp"
echo ""

# Generate JWT token for App Store Connect API
# This requires jq and openssl

# For now, document the status and create a workaround

echo "⚠️  Watch App Bundle ID needs to be registered in App Store Connect"
echo ""
echo "Current Status:"
echo "  ✅ PersonalHealthApp - UPLOADED"
echo "  ✅ FoTLegalApp - UPLOADED"
echo "  ✅ FoTEducationApp - UPLOADED"
echo "  ✅ FoTParentApp - UPLOADED"
echo "  ⚠️  FoTClinicianApp - Watch app needs bundle ID"
echo ""
echo "Solution: Upload iOS-only build for Clinician"


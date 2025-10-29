#!/bin/bash
# Register device using App Store Connect API

API_KEY_ID="43BGN9JC5B"
API_ISSUER_ID="69a6de92-4ce0-47e3-e053-5b8c7c11a4d1"
TEAM_ID="WWQQB728U5"
DEVICE_UDID="00008130-001124D00A93803A"
DEVICE_NAME="Rick Iphone"

echo "Registering device via Apple's device registration tool..."
echo ""

# Use xcode-select to register device
xcrun simctl register "$DEVICE_UDID" "$DEVICE_NAME" 2>&1 || {
    echo "⚠️  simctl doesn't work for physical devices"
    echo ""
    echo "Opening Developer Portal to register device manually..."
    open "https://developer.apple.com/account/resources/devices/add"
    echo ""
    echo "Fill in:"
    echo "  Platform: iOS"
    echo "  Device Name: $DEVICE_NAME"
    echo "  Device ID (UDID): $DEVICE_UDID"
    echo ""
    echo "Then press ENTER to continue..."
    read
}

echo "✅ Device registration initiated"


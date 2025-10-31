#!/bin/bash

set -e

echo "🔨 REBUILDING 3 FIXED APPS"
echo "======================================="
echo ""

cd "$(dirname "$0")/.."
mkdir -p build/logs

# 1. Clinician (fixed AnimatedSplashScreen)
echo "1️⃣ Building FoTClinicianApp iOS..."
xcodebuild -project apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj \
  -scheme FoTClinicianApp \
  -sdk iphoneos \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  clean build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
  > build/logs/FoTClinicianApp_rebuilt.log 2>&1 && \
echo "✅ FoTClinicianApp" || echo "❌ FoTClinicianApp FAILED"

# 2. Education (fixed AppShortcuts)
echo ""
echo "2️⃣ Building FoTEducationApp iOS..."
xcodebuild -project apps/EducationApp/iOS/FoTEducationApp.xcodeproj \
  -scheme FoTEducationApp \
  -sdk iphoneos \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  clean build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
  > build/logs/FoTEducationApp_rebuilt.log 2>&1 && \
echo "✅ FoTEducationApp" || echo "❌ FoTEducationApp FAILED"

# 3. Parent (fixed AppShortcuts)
echo ""
echo "3️⃣ Building FoTParentApp iOS..."
xcodebuild -project apps/ParentApp/iOS/FoTParentApp.xcodeproj \
  -scheme FoTParentApp \
  -sdk iphoneos \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  clean build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
  > build/logs/FoTParentApp_rebuilt.log 2>&1 && \
echo "✅ FoTParentApp" || echo "❌ FoTParentApp FAILED"

echo ""
echo "======================================="
echo "🎉 REBUILD COMPLETE!"
echo ""
echo "📊 Summary:"
grep -E "✅|❌" build/logs/*_rebuilt.log 2>/dev/null | tail -10 || echo "Check individual logs"
echo ""
echo "All 3 apps rebuilt. Ready for archiving."


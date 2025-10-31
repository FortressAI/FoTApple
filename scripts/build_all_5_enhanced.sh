#!/bin/bash

set -e

echo "🚀 BUILDING ALL 5 APPS WITH ENHANCED DOMAIN SERVICES"
echo ""
echo "Apps to build:"
echo "  1. PersonalHealthApp"
echo "  2. FoTClinicianApp"
echo "  3. FoTLegalApp"
echo "  4. FoTEducationApp"
echo "  5. FoTParentApp"
echo ""

cd "$(dirname "$0")/.."
mkdir -p build/logs

# 1. PersonalHealthApp
echo "1️⃣ Building PersonalHealthApp iOS..."
xcodebuild -project apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj \
  -scheme PersonalHealthApp \
  -sdk iphoneos \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  clean build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
  > build/logs/PersonalHealthApp_enhanced.log 2>&1 && \
echo "✅ PersonalHealthApp" || { echo "❌ PersonalHealthApp FAILED"; tail -50 build/logs/PersonalHealthApp_enhanced.log; }

# 2. FoTClinicianApp
echo ""
echo "2️⃣ Building FoTClinicianApp iOS..."
xcodebuild -project apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj \
  -scheme FoTClinicianApp \
  -sdk iphoneos \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  clean build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
  > build/logs/FoTClinicianApp_enhanced.log 2>&1 && \
echo "✅ FoTClinicianApp" || { echo "❌ FoTClinicianApp FAILED"; tail -50 build/logs/FoTClinicianApp_enhanced.log; }

# 3. FoTLegalApp
echo ""
echo "3️⃣ Building FoTLegalApp iOS..."
xcodebuild -project apps/LegalApp/iOS/FoTLegalApp.xcodeproj \
  -scheme FoTLegalApp \
  -sdk iphoneos \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  clean build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
  > build/logs/FoTLegalApp_enhanced.log 2>&1 && \
echo "✅ FoTLegalApp" || { echo "❌ FoTLegalApp FAILED"; tail -50 build/logs/FoTLegalApp_enhanced.log; }

# 4. FoTEducationApp
echo ""
echo "4️⃣ Building FoTEducationApp iOS..."
xcodebuild -project apps/EducationApp/iOS/FoTEducationApp.xcodeproj \
  -scheme FoTEducationApp \
  -sdk iphoneos \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  clean build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
  > build/logs/FoTEducationApp_enhanced.log 2>&1 && \
echo "✅ FoTEducationApp" || { echo "❌ FoTEducationApp FAILED"; tail -50 build/logs/FoTEducationApp_enhanced.log; }

# 5. FoTParentApp
echo ""
echo "5️⃣ Building FoTParentApp iOS..."
xcodebuild -project apps/ParentApp/iOS/FoTParentApp.xcodeproj \
  -scheme FoTParentApp \
  -sdk iphoneos \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  clean build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
  > build/logs/FoTParentApp_enhanced.log 2>&1 && \
echo "✅ FoTParentApp" || { echo "❌ FoTParentApp FAILED"; tail -50 build/logs/FoTParentApp_enhanced.log; }

echo ""
echo "🎉 BUILD SUMMARY:"
echo ""
ls -lh build/logs/*_enhanced.log | awk '{print $9}' | while read log; do
  app=$(basename "$log" _enhanced.log)
  if grep -q "BUILD SUCCEEDED" "$log"; then
    echo "✅ $app"
  else
    echo "❌ $app - check $log"
  fi
done

echo ""
echo "All builds complete!"
echo "Logs in: build/logs/*_enhanced.log"


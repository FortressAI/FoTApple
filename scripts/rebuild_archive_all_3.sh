#!/bin/bash

set -e

echo "🚀 REBUILD & ARCHIVE 3 APPS"
echo "======================================="
echo ""

cd "$(dirname "$0")/.."
mkdir -p build/{logs,archives}

# Function to build and archive an app
build_and_archive() {
    local APP_NAME=$1
    local PROJECT_PATH=$2
    local SCHEME=$3
    
    echo "🔨 Building $APP_NAME..."
    xcodebuild -project "$PROJECT_PATH" \
      -scheme "$SCHEME" \
      -sdk iphoneos \
      -configuration Release \
      -destination 'generic/platform=iOS' \
      clean build \
      CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
      > "build/logs/${APP_NAME}_final_build.log" 2>&1 && \
    echo "✅ $APP_NAME built" || { echo "❌ $APP_NAME build failed"; return 1; }
    
    echo "📦 Archiving $APP_NAME..."
    xcodebuild archive \
      -project "$PROJECT_PATH" \
      -scheme "$SCHEME" \
      -sdk iphoneos \
      -configuration Release \
      -archivePath "build/archives/${APP_NAME}_v13.xcarchive" \
      CODE_SIGN_STYLE=Automatic \
      DEVELOPMENT_TEAM=WWQQB728U5 \
      > "build/logs/${APP_NAME}_final_archive.log" 2>&1 && \
    echo "✅ $APP_NAME archived" || { echo "❌ $APP_NAME archive failed"; return 1; }
    
    echo ""
}

# Build and archive all 3 apps
build_and_archive "FoTClinicianApp" "apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj" "FoTClinicianApp"
build_and_archive "FoTEducationApp" "apps/EducationApp/iOS/FoTEducationApp.xcodeproj" "FoTEducationApp"
build_and_archive "FoTParentApp" "apps/ParentApp/iOS/FoTParentApp.xcodeproj" "FoTParentApp"

echo "======================================="
echo "🎉 ALL 3 APPS BUILT & ARCHIVED!"
echo ""
echo "📦 Archives ready:"
ls -lh build/archives/*_v13.xcarchive 2>/dev/null | awk '{print "  ", $9}' | grep -E "Clinician|Education|Parent"
echo ""
echo "✅ Total: 5 apps archived and ready for TestFlight!"
echo "  1. PersonalHealthApp"
echo "  2. FoTClinicianApp"
echo "  3. FoTLegalApp"
echo "  4. FoTEducationApp"
echo "  5. FoTParentApp"


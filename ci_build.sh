#!/usr/bin/env bash
set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}==${NC} $1"; }
ok() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }

log "Swift Package: build"
swift build
ok "Swift build succeeded"

log "Swift Package: test"
swift test
ok "Swift tests passed"

if command -v xcbeautify >/dev/null 2>&1; then
  PIPE='| xcbeautify'
else
  PIPE=''
fi

log "iOS App: FoTClinician build (simulator)"
set +e
BUILD_CMD=(xcodebuild -project apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj \
  -scheme FoTClinicianApp \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1" \
  -configuration Debug \
  clean build)

if command -v xcbeautify >/dev/null 2>&1; then
  "${BUILD_CMD[@]}" | xcbeautify
else
  "${BUILD_CMD[@]}"
fi
STATUS=$?
set -e

if [ $STATUS -ne 0 ]; then
  fail "FoTClinician app build failed. See log above."
  exit $STATUS
fi
ok "FoTClinician app build succeeded"

ok "All builds and tests passed"

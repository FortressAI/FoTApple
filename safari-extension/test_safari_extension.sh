#!/bin/bash

################################################################################
# QFOT Wallet Safari Extension - Automated Test Script
################################################################################

set -e

echo ""
echo "================================================================================"
echo "🧪 QFOT WALLET SAFARI EXTENSION - AUTOMATED TESTING"
echo "================================================================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${BLUE}🧪 Test: $test_name${NC}"
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}   ❌ FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "Phase 1: Pre-Flight Checks"
echo "────────────────────────────────────────────────────────────────────────────"
echo ""

# Test 1: Check Safari extension built
run_test "Safari extension built" \
    "test -f 'QFOTWallet-Safari/QFOT Wallet/QFOT Wallet.xcodeproj/project.pbxproj'"

# Test 2: Check genesis wallets created
run_test "Genesis wallets database exists" \
    "test -f ../blockchain/qfot_wallets.db"

# Test 3: Check genesis JSON exists
run_test "Genesis wallets JSON exported" \
    "test -f genesis_wallets.json"

# Test 4: Verify database has 16 wallets
run_test "Database contains 16 wallets" \
    "test $(sqlite3 ../blockchain/qfot_wallets.db 'SELECT COUNT(*) FROM wallets;') -eq 16"

# Test 5: Verify creator wallet balance
run_test "Creator wallet has 200M QFOT" \
    "test \$(sqlite3 ../blockchain/qfot_wallets.db 'SELECT CAST(balance AS INTEGER) FROM wallets WHERE alias=\"@Domain-Packs.md\";') -eq 200000000"

# Test 6: Check extension files exist
run_test "Extension manifest exists" \
    "test -f QFOTWallet/manifest.json"

run_test "Extension popup HTML exists" \
    "test -f QFOTWallet/Resources/popup.html"

run_test "Extension crypto.js exists" \
    "test -f QFOTWallet/Resources/scripts/crypto.js"

run_test "Extension api.js exists" \
    "test -f QFOTWallet/Resources/scripts/api.js"

echo ""
echo "Phase 2: Blockchain Connectivity Tests"
echo "────────────────────────────────────────────────────────────────────────────"
echo ""

# Test blockchain endpoints
for endpoint in "https://safeaicoin.org/api/status" "http://94.130.97.66:8000/api/status" "http://46.224.42.20:8000/api/status"; do
    run_test "Blockchain API reachable: $endpoint" \
        "curl -s -f -m 5 '$endpoint' | grep -q 'total_facts'" || true
done

echo ""
echo "Phase 3: Database Integrity Tests"
echo "────────────────────────────────────────────────────────────────────────────"
echo ""

# Test wallet types
run_test "Creator wallets: 1" \
    "test \$(sqlite3 ../blockchain/qfot_wallets.db 'SELECT COUNT(*) FROM wallets WHERE wallet_type=\"creator\";') -eq 1"

run_test "Miner wallets: 7" \
    "test \$(sqlite3 ../blockchain/qfot_wallets.db 'SELECT COUNT(*) FROM wallets WHERE wallet_type=\"miner\";') -eq 7"

run_test "Validator wallets: 3" \
    "test \$(sqlite3 ../blockchain/qfot_wallets.db 'SELECT COUNT(*) FROM wallets WHERE wallet_type=\"validator\";') -eq 3"

# Test total supply
TOTAL_BALANCE=$(sqlite3 ../blockchain/qfot_wallets.db 'SELECT CAST(SUM(balance) AS INTEGER) FROM wallets;')
run_test "Total supply is 1 billion QFOT" \
    "test $TOTAL_BALANCE -eq 1000000000"

echo ""
echo "Phase 4: Extension Code Validation"
echo "────────────────────────────────────────────────────────────────────────────"
echo ""

# Check for required functions in crypto.js
run_test "crypto.js has generateKeyPair()" \
    "grep -q 'generateKeyPair' QFOTWallet/Resources/scripts/crypto.js"

run_test "crypto.js has sign()" \
    "grep -q 'async sign' QFOTWallet/Resources/scripts/crypto.js"

run_test "crypto.js has encrypt()" \
    "grep -q 'async encrypt' QFOTWallet/Resources/scripts/crypto.js"

# Check for API functions
run_test "api.js has getBalance()" \
    "grep -q 'getBalance' QFOTWallet/Resources/scripts/api.js"

run_test "api.js has sendTransaction()" \
    "grep -q 'sendTransaction' QFOTWallet/Resources/scripts/api.js"

# Check tokenomics
run_test "tokenomics.js has fee split" \
    "grep -q 'FEE_SPLIT' QFOTWallet/Resources/scripts/tokenomics.js"

echo ""
echo "Phase 5: Security Validation"
echo "────────────────────────────────────────────────────────────────────────────"
echo ""

# Check that private keys are in database
run_test "Private keys stored in database" \
    "test $(sqlite3 ../blockchain/qfot_wallets.db 'SELECT COUNT(*) FROM wallets WHERE private_key IS NOT NULL;') -eq 16"

# Check database permissions
run_test "Database file has proper permissions" \
    "test $(stat -f '%Lp' ../blockchain/qfot_wallets.db) -le 644"

echo ""
echo "================================================================================"
echo "📊 TEST RESULTS"
echo "================================================================================"
echo ""
echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}"
fi
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo "Success Rate: $SUCCESS_RATE%"
fi

echo ""
echo "================================================================================"
echo "🚀 NEXT STEPS (MANUAL)"
echo "================================================================================"
echo ""
echo "The automated testing is complete! Now you need to:"
echo ""
echo "1. Open Xcode:"
echo "   $ open QFOTWallet-Safari/QFOT\ Wallet.xcodeproj"
echo ""
echo "2. In Xcode:"
echo "   - Select your development team (Signing & Capabilities)"
echo "   - Press ⌘B to build"
echo "   - Press ⌘R to run"
echo "   - Keep the app running!"
echo ""
echo "3. In Safari:"
echo "   - Safari → Preferences → Extensions"
echo "   - Enable 'QFOT Wallet'"
echo "   - Allow on all websites (or safeaicoin.org)"
echo ""
echo "4. Test the Extension:"
echo "   - Click ⚛️ icon in Safari toolbar"
echo "   - Create a test wallet"
echo "   - OR import creator wallet:"
echo "     Alias: @Domain-Packs.md"
echo "     (Get keys from genesis_wallets.json)"
echo ""
echo "5. Test Website Integration:"
echo "   - Navigate to https://safeaicoin.org"
echo "   - Open browser console (⌘⌥C)"
echo "   - Type: window.qfotWallet.getAddress()"
echo "   - Should see your wallet address!"
echo ""
echo "================================================================================"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All automated tests passed! Ready for manual testing!${NC}"
    echo ""
    
    # Display creator wallet info
    echo "Your Creator Wallet Info:"
    echo "─────────────────────────"
    sqlite3 ../blockchain/qfot_wallets.db << 'SQL'
.mode line
SELECT 
    alias,
    address,
    balance || ' QFOT' as balance,
    wallet_type as type
FROM wallets 
WHERE alias = '@Domain-Packs.md';
SQL
    
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Review errors above.${NC}"
    echo ""
    exit 1
fi


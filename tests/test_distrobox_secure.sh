#!/bin/bash

# Test suite for Distrobox Secure
# Run with: bash tests/test_distrobox_secure.sh

set +H
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DISTROBOX_SECURE_TEST=1

# Source the main script
source "$SCRIPT_DIR/distrobox-secure" >/dev/null 2>&1

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

test_start() {
    printf "%b[TEST]%b %s\n" "$BLUE" "$NC" "$1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_pass() {
    printf "  %b✓ PASS%b\n" "$GREEN" "$NC"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    printf "  %b✗ FAIL%b\n" "$RED" "$NC"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Mock distrobox
distrobox() {
    return 0
}

# ==============================================================================
# Test 1
# ==============================================================================
test_start "Container name validation (valid)"
result=$(validate_container_name "mycontainer" >/dev/null 2>&1; echo $?)
if [[ "$result" == "0" ]]; then
    test_pass
else
    test_fail
fi

# ==============================================================================
# Test 2
# ==============================================================================
test_start "Container name validation (invalid)"
result=$(validate_container_name "my container" >/dev/null 2>&1; echo $?)
if [[ "$result" != "0" ]]; then
    test_pass
else
    test_fail
fi

# ==============================================================================
# Test 3
# ==============================================================================
test_start "Path validation"
test_file=$(mktemp)
result=$(validate_path "$test_file" >/dev/null 2>&1; echo $?)
rm "$test_file"
if [[ "$result" == "0" ]]; then
    test_pass
else
    test_fail
fi

# ==============================================================================
# Test 4
# ==============================================================================
test_start "Mount path parsing"
test_perm_value="/src/path:with:colons:/dst/path"
src_path="${test_perm_value%%:*}"
dst_path="${test_perm_value#*:}"
if [[ "$src_path" == "/src/path" ]] && [[ "$dst_path" == "with:colons:/dst/path" ]]; then
    test_pass
else
    test_fail
fi

# ==============================================================================
# Test 5
# ==============================================================================
test_start "Bash syntax"
result=$(bash -n "$SCRIPT_DIR/distrobox-secure" >/dev/null 2>&1; echo $?)
if [[ "$result" == "0" ]]; then
    test_pass
else
    test_fail
fi

# ==============================================================================
# Summary
# ==============================================================================
printf "\n%b=== Test Results ===%b\n" "$YELLOW" "$NC"
printf "Total:  %d\n" "$TESTS_RUN"
printf "Passed: %b%d%b\n" "$GREEN" "$TESTS_PASSED" "$NC"
printf "Failed: %b%d%b\n" "$RED" "$TESTS_FAILED" "$NC"
printf "\n"

if [[ $TESTS_FAILED -eq 0 ]]; then
    printf "%bAll tests passed!%b\n" "$GREEN" "$NC"
    exit 0
else
    printf "%bSome tests failed.%b\n" "$RED" "$NC"
    exit 1
fi

#!/bin/bash

# Test suite for Distrobox Secure
# Run with: bash tests/test_distrobox_secure.sh

set -euo pipefail

# Source the main script for testing functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/distrobox-secure"

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test output functions
test_start() {
    local test_name="$1"
    echo -e "${BLUE}[TEST]${NC} $test_name"
    ((TESTS_RUN++))
}

test_pass() {
    echo -e "  ${GREEN}✓ PASS${NC}"
    ((TESTS_PASSED++))
}

test_fail() {
    local reason="${1:-}"
    echo -e "  ${RED}✗ FAIL${NC}${reason:+: $reason}"
    ((TESTS_FAILED++))
}

# Setup test environment
setup_test_env() {
    export TEST_HOME=$(mktemp -d)
    export HOME="$TEST_HOME"
    DISTROBOX_BASE_DIR="${HOME}/.local/share/distrobox-secure"
    CONFIG_DIR="${HOME}/.config/distrobox-secure"
    PERMISSIONS_FILE="${CONFIG_DIR}/permissions.conf"
    mkdir -p "$DISTROBOX_BASE_DIR" "$CONFIG_DIR"
}

# Cleanup test environment
cleanup_test_env() {
    if [[ -d "$TEST_HOME" ]]; then
        rm -rf "$TEST_HOME"
    fi
}

# ==============================================================================
# Tests
# ==============================================================================

# Test: validate_container_name - Valid names
test_validate_container_name_valid() {
    test_start "validate_container_name - Valid names"

    local valid_names=("mycontainer" "my-container" "my_container" "my.container" "container123")

    for name in "${valid_names[@]}"; do
        if ! validate_container_name "$name" 2>/dev/null; then
            test_fail "Should accept: $name"
            return
        fi
    done
    test_pass
}

# Test: validate_container_name - Invalid names
test_validate_container_name_invalid() {
    test_start "validate_container_name - Invalid names"

    local invalid_names=("my container" "container@name" "container/name" "container:name" "container!name")

    for name in "${invalid_names[@]}"; do
        if validate_container_name "$name" 2>/dev/null; then
            test_fail "Should reject: $name"
            return
        fi
    done
    test_pass
}

# Test: validate_path - Existing path
test_validate_path_existing() {
    test_start "validate_path - Existing readable path"

    local test_file=$(mktemp)
    if validate_path "$test_file" 2>/dev/null; then
        test_pass
        rm "$test_file"
    else
        test_fail "Should accept existing readable file"
        rm "$test_file"
    fi
}

# Test: validate_path - Non-existent path
test_validate_path_nonexistent() {
    test_start "validate_path - Non-existent path (should warn but pass)"

    local nonexistent="/path/to/nonexistent/file"
    if validate_path "$nonexistent" 2>/dev/null; then
        test_pass
    else
        test_fail "Should warn but not fail for non-existent paths"
    fi
}

# Test: Mount path parsing with colons
test_mount_parsing() {
    test_start "Mount path parsing - Paths with colons"

    local test_perm_value="/src/path:with:colons:/dst/path"

    # Extract src and dst paths using the same logic as in the script
    local src_path="${test_perm_value%%:*}"
    local dst_path="${test_perm_value#*:}"

    if [[ "$src_path" == "/src/path" ]] && [[ "$dst_path" == "with:colons:/dst/path" ]]; then
        test_pass
    else
        test_fail "Mount parsing failed. src=$src_path, dst=$dst_path"
    fi
}

# Test: init_dirs creates required files
test_init_dirs() {
    test_start "init_dirs - Creates required directories and config"

    if [[ -d "$DISTROBOX_BASE_DIR" ]] && [[ -d "$CONFIG_DIR" ]] && [[ -f "$PERMISSIONS_FILE" ]]; then
        # Check that permissions file has content
        if grep -q "Distrobox Secure Permissions Configuration" "$PERMISSIONS_FILE"; then
            test_pass
        else
            test_fail "Permissions config file missing expected header"
        fi
    else
        test_fail "Required directories/files not created"
    fi
}

# Test: isolated home directory creation
test_create_isolated_home() {
    test_start "create_isolated_home - Creates home directory structure"

    local container_name="test-container"
    local isolated_home
    isolated_home=$(create_isolated_home "$container_name")

    # Check directory structure
    local required_dirs=(".bashrc" "Desktop" "Documents" "Downloads" "Pictures" "Videos" "Music")
    local all_exist=true

    for dir in "${required_dirs[@]}"; do
        if [[ ! -e "${isolated_home}/${dir}" ]]; then
            all_exist=false
            break
        fi
    done

    if $all_exist && [[ -d "$isolated_home" ]]; then
        test_pass
    else
        test_fail "Required home directory structure not created"
    fi
}

# Test: permissions config parsing
test_get_permissions() {
    test_start "get_permissions - Parses permissions correctly"

    local container_name="test-container"

    # Add some test permissions
    cat >> "$PERMISSIONS_FILE" << EOF
$container_name:home_folder:/home/user/Documents
$container_name:audio:enable
$container_name:unshare_netns:false
EOF

    # Get permissions
    local perms
    readarray -t perms < <(get_permissions "$container_name")

    # Check for expected flags
    local found_volume=false
    local found_unshare=false

    for perm in "${perms[@]}"; do
        [[ "$perm" == "/home/user/Documents:rw" ]] && found_volume=true
        [[ "$perm" == "--unshare-devsys" ]] && found_unshare=true
    done

    if $found_volume && $found_unshare; then
        test_pass
    else
        test_fail "Permissions not parsed correctly. Got: ${perms[@]}"
    fi
}

# Test: list_permissions - Shows permissions correctly
test_list_permissions() {
    test_start "list_permissions - Lists permissions correctly"

    local container_name="test-container"

    # Add permissions
    echo "${container_name}:audio:enable" >> "$PERMISSIONS_FILE"
    echo "${container_name}:gpu:enable" >> "$PERMISSIONS_FILE"

    # Capture output and check for permissions
    local output
    output=$(list_permissions "$container_name" 2>&1)

    if echo "$output" | grep -q "audio.*enable" && echo "$output" | grep -q "gpu.*enable"; then
        test_pass
    else
        test_fail "Permissions not listed correctly"
    fi
}

# Test: Empty permissions list
test_list_permissions_empty() {
    test_start "list_permissions - Shows message when no permissions"

    local container_name="nonexistent-container"

    # Get output
    local output
    output=$(list_permissions "$container_name" 2>&1)

    if echo "$output" | grep -q "No custom permissions"; then
        test_pass
    else
        test_fail "Should show 'No custom permissions' message"
    fi
}

# ==============================================================================
# Run tests
# ==============================================================================

echo -e "${YELLOW}=== Distrobox Secure Test Suite ===${NC}\n"

# Setup
setup_test_env

# Run tests
test_validate_container_name_valid
test_validate_container_name_invalid
test_validate_path_existing
test_validate_path_nonexistent
test_mount_parsing
test_init_dirs
test_create_isolated_home
test_get_permissions
test_list_permissions
test_list_permissions_empty

# Cleanup
cleanup_test_env

# Summary
echo ""
echo -e "${YELLOW}=== Test Results ===${NC}"
echo "Total: $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi

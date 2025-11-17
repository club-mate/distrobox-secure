#!/bin/bash

# Install script for Distrobox Secure
# Installs the distrobox-secure tool to the system

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Detect installation prefix
INSTALL_PREFIX="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default installation locations
BIN_DIR="${HOME}/.local/bin"
COMPLETION_DIR="${HOME}/.local/share/bash-completion/completions"
COMPLETION_DIR_ZSH="${HOME}/.zsh/completions"

log "Distrobox Secure Installer"
log "=========================="
echo ""

# Check dependencies
log "Checking dependencies..."
for dep in distrobox podman; do
    if ! command -v "$dep" &> /dev/null; then
        error "$dep is not installed. Please install it first:"
        echo "  Visit: https://github.com/89luca89/distrobox"
        exit 1
    fi
    log "✓ $dep found"
done

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$COMPLETION_DIR"
mkdir -p "$COMPLETION_DIR_ZSH"

# Copy executable
log "Installing distrobox-secure to $BIN_DIR..."
cp "${SCRIPT_DIR}/distrobox-secure" "$BIN_DIR/distrobox-secure"
chmod +x "$BIN_DIR/distrobox-secure"

# Copy bash completion if it exists
if [[ -f "${SCRIPT_DIR}/completions/distrobox-secure.bash" ]]; then
    log "Installing bash completion..."
    cp "${SCRIPT_DIR}/completions/distrobox-secure.bash" "$COMPLETION_DIR/distrobox-secure"
fi

# Copy zsh completion if it exists
if [[ -f "${SCRIPT_DIR}/completions/_distrobox-secure" ]]; then
    log "Installing zsh completion..."
    cp "${SCRIPT_DIR}/completions/_distrobox-secure" "$COMPLETION_DIR_ZSH/_distrobox-secure"
fi

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    warn "Warning: $BIN_DIR is not in your PATH"
    echo "Add this line to your ~/.bashrc or ~/.profile:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
log "Installation successful!"
log "Usage: distrobox-secure --help"

# Show next steps
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. If not already in PATH, add ~/.local/bin to your PATH"
echo "2. Run 'distrobox-secure create <container-name>' to get started"
echo "3. Read the README.md for detailed documentation"
echo ""

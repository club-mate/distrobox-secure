#!/bin/bash

# Uninstall script for Distrobox Secure
# Removes the distrobox-secure tool from the system

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

# Default uninstall locations
BIN_DIR="${HOME}/.local/bin"
COMPLETION_DIR="${HOME}/.local/share/bash-completion/completions"
COMPLETION_DIR_ZSH="${HOME}/.zsh/completions"

log "Distrobox Secure Uninstaller"
log "============================="
echo ""

# Confirm uninstall
echo "This will remove distrobox-secure from your system."
echo "Your container data will NOT be affected."
read -p "Are you sure? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "Uninstall cancelled"
    exit 0
fi

# Remove executable
if [[ -f "$BIN_DIR/distrobox-secure" ]]; then
    log "Removing executable from $BIN_DIR..."
    rm "$BIN_DIR/distrobox-secure"
fi

# Remove bash completion
if [[ -f "$COMPLETION_DIR/distrobox-secure" ]]; then
    log "Removing bash completion..."
    rm "$COMPLETION_DIR/distrobox-secure"
fi

# Remove zsh completion
if [[ -f "$COMPLETION_DIR_ZSH/_distrobox-secure" ]]; then
    log "Removing zsh completion..."
    rm "$COMPLETION_DIR_ZSH/_distrobox-secure"
fi

echo ""
log "Uninstall successful!"
warn "Your containers and configuration files remain in:"
echo "  ~/.local/share/distrobox-secure/"
echo "  ~/.config/distrobox-secure/"
echo ""
echo "To fully remove these as well, run:"
echo "  rm -rf ~/.local/share/distrobox-secure/"
echo "  rm -rf ~/.config/distrobox-secure/"
echo ""

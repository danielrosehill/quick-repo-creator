#!/bin/bash
# QuickRepo CLI Installation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Installing QuickRepo CLI...${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUICKREPO_SCRIPT="$SCRIPT_DIR/quickrepo.py"

# Check if the script exists
if [ ! -f "$QUICKREPO_SCRIPT" ]; then
    echo -e "${RED}Error: quickrepo.py not found in $SCRIPT_DIR${NC}"
    exit 1
fi

# Make the script executable
chmod +x "$QUICKREPO_SCRIPT"

# Create symlink in /usr/local/bin (requires sudo)
INSTALL_PATH="/usr/local/bin/quickrepo"

if [ -L "$INSTALL_PATH" ] || [ -f "$INSTALL_PATH" ]; then
    echo -e "${YELLOW}Removing existing installation...${NC}"
    sudo rm -f "$INSTALL_PATH"
fi

echo -e "${GREEN}Creating symlink to $INSTALL_PATH...${NC}"
sudo ln -s "$QUICKREPO_SCRIPT" "$INSTALL_PATH"

# Verify installation
if command -v quickrepo &> /dev/null; then
    echo -e "${GREEN}✅ QuickRepo CLI installed successfully!${NC}"
    echo -e "${GREEN}You can now use 'quickrepo' from anywhere in your terminal.${NC}"
    echo ""
    echo -e "${YELLOW}Usage: quickrepo${NC}"
else
    echo -e "${RED}❌ Installation failed. Please check your PATH.${NC}"
    exit 1
fi

#!/bin/bash
# QuickRepo CLI Uninstallation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🗑️  Uninstalling QuickRepo CLI...${NC}"

INSTALL_PATH="/usr/local/bin/quickrepo"

if [ -L "$INSTALL_PATH" ] || [ -f "$INSTALL_PATH" ]; then
    echo -e "${GREEN}Removing $INSTALL_PATH...${NC}"
    sudo rm -f "$INSTALL_PATH"
    echo -e "${GREEN}✅ QuickRepo CLI uninstalled successfully!${NC}"
else
    echo -e "${YELLOW}QuickRepo CLI is not installed (no symlink found at $INSTALL_PATH)${NC}"
fi

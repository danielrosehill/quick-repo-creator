#!/bin/bash
# QuickRepo CLI Update Script
# Updates the installed QuickRepo CLI to the latest version from GitHub

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="danielrosehill/quick-repo-creator"
INSTALL_DIR="/usr/local/share/quickrepo"
INSTALL_PATH="/usr/local/bin/quickrepo"
TEMP_DIR="/tmp/quickrepo-update-$$"

echo -e "${BLUE}🔄 QuickRepo CLI Update Script${NC}"
echo "=================================="

# Check if QuickRepo is currently installed
if [ ! -f "$INSTALL_PATH" ]; then
    echo -e "${RED}❌ QuickRepo CLI is not currently installed.${NC}"
    echo -e "${YELLOW}Please install QuickRepo first using the install script.${NC}"
    exit 1
fi

# Check if the installation directory exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}❌ QuickRepo installation directory not found: $INSTALL_DIR${NC}"
    echo -e "${YELLOW}Please reinstall QuickRepo using the install script.${NC}"
    exit 1
fi

# Check required tools
for tool in git curl; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}❌ Error: $tool is not installed or not in PATH.${NC}"
        exit 1
    fi
done

# Get current installation info
echo -e "${BLUE}📋 Current installation info:${NC}"
echo -e "   Executable: $INSTALL_PATH"
echo -e "   Installation directory: $INSTALL_DIR"
if [ -f "$INSTALL_DIR/quickrepo_main.py" ]; then
    echo -e "   Main module: $INSTALL_DIR/quickrepo_main.py"
else
    echo -e "   ${YELLOW}Warning: Main module not found${NC}"
fi

# Create temporary directory
echo -e "\n${BLUE}📁 Creating temporary directory...${NC}"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Download latest version from GitHub
echo -e "\n${BLUE}⬇️  Downloading latest version from GitHub...${NC}"
git clone "https://github.com/$GITHUB_REPO.git" quickrepo-latest
cd quickrepo-latest

# Get latest commit info
LATEST_COMMIT=$(git rev-parse --short HEAD)
echo -e "${GREEN}Latest version: $LATEST_COMMIT${NC}"

# Show version info
echo -e "${GREEN}Latest version: $LATEST_COMMIT${NC}"
echo -e "${YELLOW}📥 Update available${NC}"

# Confirm update
echo -e "\n${BLUE}Do you want to proceed with the update? (y/n): ${NC}"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Update cancelled.${NC}"
    rm -rf "$TEMP_DIR"
    exit 0
fi

# Backup current installation
echo -e "\n${BLUE}💾 Creating backup of current installation...${NC}"
BACKUP_DIR="$HOME/.quickrepo-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup the main module
if [ -f "$INSTALL_DIR/quickrepo_main.py" ]; then
    cp "$INSTALL_DIR/quickrepo_main.py" "$BACKUP_DIR/quickrepo_main.py"
    echo -e "   Backed up: $INSTALL_DIR/quickrepo_main.py"
fi

# Backup the executable
if [ -f "$INSTALL_PATH" ]; then
    cp "$INSTALL_PATH" "$BACKUP_DIR/quickrepo"
    echo -e "   Backed up: $INSTALL_PATH"
fi

echo -e "   Backup saved to: $BACKUP_DIR"

# Update installation
echo -e "\n${BLUE}🔄 Updating QuickRepo installation...${NC}"

# Update the main module
sudo cp "$TEMP_DIR/quickrepo-latest/quickrepo.py" "$INSTALL_DIR/quickrepo_main.py"
echo -e "${GREEN}✅ Updated main module: $INSTALL_DIR/quickrepo_main.py${NC}"

# Create the updated wrapper executable
sudo tee "$INSTALL_PATH" > /dev/null << 'EOF'
#!/usr/bin/env python3

# QuickRepo - CLI tool for creating GitHub repositories
# This is the main executable that will be installed to /usr/local/bin/

import sys
import os

# Add the package directory to Python path
package_dir = '/usr/local/share/quickrepo'
if package_dir not in sys.path:
    sys.path.insert(0, package_dir)

# Import and run the main application
try:
    from quickrepo_main import main
    if __name__ == '__main__':
        main()
except ImportError as e:
    print(f"Error: Could not import QuickRepo modules: {e}")
    print("Please ensure QuickRepo is properly installed.")
    sys.exit(1)
except Exception as e:
    print(f"Error running QuickRepo: {e}")
    sys.exit(1)
EOF

# Make executable
sudo chmod +x "$INSTALL_PATH"
echo -e "${GREEN}✅ Updated executable: $INSTALL_PATH${NC}"

# Verify the update
echo -e "\n${BLUE}🔍 Verifying update...${NC}"
if command -v quickrepo &> /dev/null; then
    echo -e "${GREEN}✅ QuickRepo CLI updated successfully!${NC}"
    echo -e "${BLUE}New version: $LATEST_COMMIT${NC}"
    echo -e "\n${GREEN}You can now use the updated 'quickrepo' command.${NC}"
else
    echo -e "${RED}❌ Update verification failed. Please check your installation.${NC}"
    echo -e "${YELLOW}You can restore from backup: $BACKUP_DIR${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Cleanup
echo -e "\n${BLUE}🧹 Cleaning up temporary files...${NC}"
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}🎉 Update completed successfully!${NC}"
echo -e "${YELLOW}💾 Backup location: $BACKUP_DIR${NC}"
echo -e "${BLUE}🚀 Run 'quickrepo' to use the updated CLI${NC}"

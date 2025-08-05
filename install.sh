#!/bin/bash
# QuickRepo CLI Installation Script
# Installs the QuickRepo CLI tool to /usr/local/bin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/usr/local/share/quickrepo"
INSTALL_PATH="/usr/local/bin/quickrepo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 QuickRepo CLI Installation Script${NC}"
echo "====================================="

# Check if running as root (for system installation)
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Running as root. Installing system-wide.${NC}"
fi

# Check if QuickRepo is already installed
if [ -f "$INSTALL_PATH" ] || [ -L "$INSTALL_PATH" ]; then
    echo -e "${YELLOW}⚠️  QuickRepo CLI is already installed at $INSTALL_PATH${NC}"
    echo -e "${BLUE}Do you want to overwrite the existing installation? (y/n): ${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi
    echo -e "${BLUE}Removing existing installation...${NC}"
    sudo rm -f "$INSTALL_PATH"
    sudo rm -rf "$INSTALL_DIR"
fi

# Check required dependencies
echo -e "\n${BLUE}🔍 Checking dependencies...${NC}"
for tool in python3 git; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}❌ Error: $tool is not installed or not in PATH.${NC}"
        echo -e "${YELLOW}Please install $tool and try again.${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ $tool is available${NC}"
    fi
done

# Check for GitHub CLI
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) is not installed.${NC}"
    echo -e "${BLUE}QuickRepo requires GitHub CLI to function properly.${NC}"
    echo -e "${BLUE}Install it from: https://cli.github.com/${NC}"
    echo -e "\n${BLUE}Do you want to continue anyway? (y/n): ${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi
else
    echo -e "${GREEN}✅ GitHub CLI is available${NC}"
fi

# Install QuickRepo
echo -e "\n${BLUE}📦 Installing QuickRepo CLI...${NC}"

# Create installation directory
sudo mkdir -p "$INSTALL_DIR"
echo -e "${GREEN}✅ Created installation directory: $INSTALL_DIR${NC}"

# Copy the main script
sudo cp "$SCRIPT_DIR/quickrepo.py" "$INSTALL_DIR/quickrepo_main.py"
echo -e "${GREEN}✅ Copied main script to $INSTALL_DIR${NC}"

# Create the wrapper executable
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

# Make the executable script executable
sudo chmod +x "$INSTALL_PATH"
echo -e "${GREEN}✅ Created executable: $INSTALL_PATH${NC}"

# Verify installation
echo -e "\n${BLUE}🔍 Verifying installation...${NC}"
if command -v quickrepo &> /dev/null; then
    echo -e "${GREEN}✅ QuickRepo CLI installed successfully!${NC}"
    echo -e "\n${GREEN}You can now use the 'quickrepo' command from anywhere.${NC}"
    echo -e "${BLUE}Try: quickrepo --help${NC}"
else
    echo -e "${RED}❌ Installation verification failed.${NC}"
    echo -e "${YELLOW}Please check that /usr/local/bin is in your PATH.${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 Installation completed successfully!${NC}"

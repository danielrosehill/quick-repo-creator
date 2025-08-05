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
INSTALL_PATH="/usr/local/bin/quickrepo"
TEMP_DIR="/tmp/quickrepo-update-$$"

echo -e "${BLUE}🔄 QuickRepo CLI Update Script${NC}"
echo "=================================="

# Check if QuickRepo is currently installed
if [ ! -L "$INSTALL_PATH" ] && [ ! -f "$INSTALL_PATH" ]; then
    echo -e "${RED}❌ QuickRepo CLI is not currently installed.${NC}"
    echo -e "${YELLOW}Please install QuickRepo first using the install script.${NC}"
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
if [ -L "$INSTALL_PATH" ]; then
    CURRENT_TARGET=$(readlink "$INSTALL_PATH")
    echo -e "   Symlink target: $CURRENT_TARGET"
    if [ -f "$CURRENT_TARGET" ]; then
        CURRENT_DIR=$(dirname "$CURRENT_TARGET")
        echo -e "   Installation directory: $CURRENT_DIR"
    fi
else
    echo -e "   Direct installation detected"
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

# Check if we're already up to date (if current installation is from git)
if [ -L "$INSTALL_PATH" ]; then
    CURRENT_TARGET=$(readlink "$INSTALL_PATH")
    if [ -f "$CURRENT_TARGET" ]; then
        CURRENT_DIR=$(dirname "$CURRENT_TARGET")
        if [ -d "$CURRENT_DIR/.git" ]; then
            cd "$CURRENT_DIR"
            CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
            cd "$TEMP_DIR/quickrepo-latest"
            
            if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
                echo -e "${GREEN}✅ You're already up to date!${NC}"
                echo -e "${BLUE}Current version: $CURRENT_COMMIT${NC}"
                rm -rf "$TEMP_DIR"
                exit 0
            fi
            
            echo -e "${YELLOW}📥 Update available: $CURRENT_COMMIT → $LATEST_COMMIT${NC}"
        fi
    fi
fi

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

if [ -L "$INSTALL_PATH" ]; then
    CURRENT_TARGET=$(readlink "$INSTALL_PATH")
    if [ -f "$CURRENT_TARGET" ]; then
        cp "$CURRENT_TARGET" "$BACKUP_DIR/quickrepo.py" 2>/dev/null || true
        CURRENT_DIR=$(dirname "$CURRENT_TARGET")
        echo -e "   Backed up from: $CURRENT_TARGET"
    fi
fi
echo -e "   Backup saved to: $BACKUP_DIR"

# Determine installation method
if [ -L "$INSTALL_PATH" ]; then
    CURRENT_TARGET=$(readlink "$INSTALL_PATH")
    INSTALL_DIR=$(dirname "$CURRENT_TARGET")
    
    # Check if it's installed in a git repository
    if [ -d "$INSTALL_DIR/.git" ]; then
        echo -e "\n${BLUE}🔄 Updating git-based installation...${NC}"
        cd "$INSTALL_DIR"
        
        # Stash any local changes
        if [ -n "$(git status --porcelain)" ]; then
            echo -e "${YELLOW}Stashing local changes...${NC}"
            git stash
        fi
        
        # Pull latest changes
        git fetch origin
        git reset --hard origin/main 2>/dev/null || git reset --hard origin/master 2>/dev/null
        
        # Make executable
        chmod +x quickrepo.py
        
        NEW_COMMIT=$(git rev-parse --short HEAD)
        echo -e "${GREEN}Updated to commit: $NEW_COMMIT${NC}"
    else
        echo -e "\n${BLUE}🔄 Updating file-based installation...${NC}"
        # Copy new version to existing location
        cp "$TEMP_DIR/quickrepo-latest/quickrepo.py" "$CURRENT_TARGET"
        chmod +x "$CURRENT_TARGET"
        echo -e "${GREEN}Updated file: $CURRENT_TARGET${NC}"
    fi
else
    echo -e "\n${BLUE}🔄 Updating direct installation...${NC}"
    # Replace the file directly
    sudo cp "$TEMP_DIR/quickrepo-latest/quickrepo.py" "$INSTALL_PATH"
    sudo chmod +x "$INSTALL_PATH"
    echo -e "${GREEN}Updated: $INSTALL_PATH${NC}"
fi

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

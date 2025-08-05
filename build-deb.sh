#!/bin/bash
set -e

# QuickRepo Debian Package Builder
# This script builds a .deb package for QuickRepo

VERSION="2.0.0"
PACKAGE_NAME="quickrepo"
BUILD_DIR="build"
PACKAGE_DIR="${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}"

echo "🔨 Building QuickRepo v${VERSION} Debian package..."

# Clean previous builds
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi

# Create build directory structure
mkdir -p "$PACKAGE_DIR"

# Copy debian package structure
cp -r packaging/* "$PACKAGE_DIR/"

# Copy the actual quickrepo.py to the package
cp quickrepo.py "$PACKAGE_DIR/usr/share/quickrepo/quickrepo_main.py"

# Set proper permissions
chmod 755 "$PACKAGE_DIR/DEBIAN/postinst"
chmod 755 "$PACKAGE_DIR/DEBIAN/prerm"
chmod 755 "$PACKAGE_DIR/usr/local/bin/quickrepo"
chmod 644 "$PACKAGE_DIR/usr/share/quickrepo/quickrepo_main.py"

# Update version in control file
sed -i "s/Version: .*/Version: ${VERSION}/" "$PACKAGE_DIR/DEBIAN/control"

# Build the package
echo "📦 Building package..."
dpkg-deb --build "$PACKAGE_DIR"

# Move the .deb file to the root directory
mv "${PACKAGE_DIR}.deb" "${PACKAGE_NAME}_${VERSION}_all.deb"

echo "✅ Package built successfully: ${PACKAGE_NAME}_${VERSION}_all.deb"
echo ""
echo "To install:"
echo "  sudo dpkg -i ${PACKAGE_NAME}_${VERSION}_all.deb"
echo ""
echo "To test installation:"
echo "  quickrepo --help"

#!/bin/bash
set -e

# QuickRepo Release Script
# This script helps you create a new release by tagging and pushing to GitHub

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 2.0.0"
    echo ""
    echo "This will:"
    echo "  1. Create and push a git tag v<version>"
    echo "  2. Trigger GitHub Actions to build and release the Debian package"
    exit 1
fi

VERSION="$1"
TAG="v$VERSION"

# Validate version format (basic check)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 2.0.0)"
    exit 1
fi

echo "🚀 Preparing release for QuickRepo v$VERSION"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes. Please commit or stash them first."
    git status --short
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$TAG$"; then
    echo "Error: Tag $TAG already exists"
    exit 1
fi

# Update version in files
echo "📝 Updating version in files..."
sed -i "s/VERSION=\".*\"/VERSION=\"$VERSION\"/" build-deb.sh
sed -i "s/Version: .*/Version: $VERSION/" packaging/DEBIAN/control

# Check if there are changes to commit
if ! git diff-index --quiet HEAD --; then
    echo "📦 Committing version updates..."
    git add build-deb.sh packaging/DEBIAN/control
    git commit -m "Bump version to $VERSION"
fi

# Create and push tag
echo "🏷️  Creating tag $TAG..."
git tag -a "$TAG" -m "Release version $VERSION"

echo "⬆️  Pushing to GitHub..."
git push origin main
git push origin "$TAG"

echo ""
echo "✅ Release $TAG has been pushed to GitHub!"
echo ""
echo "GitHub Actions will now:"
echo "  1. Build the Debian package"
echo "  2. Create a GitHub release"
echo "  3. Upload the .deb file as a release asset"
echo ""
echo "Check the progress at:"
echo "  https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
echo ""
echo "The release will be available at:"
echo "  https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/releases/tag/$TAG"

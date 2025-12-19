#!/bin/bash

# Build script for yong-macos input method

set -e

echo "🔨 Building yong-macos..."

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found. Please install Xcode."
    exit 1
fi

# Build the project
xcodebuild -project yong-macos.xcodeproj \
    -scheme yong-macos \
    -configuration Debug \
    build

echo "✅ Build completed successfully!"
echo ""
echo "📦 Built app location:"
find . -name "yong-macos.app" -path "*/Build/Products/*" | head -1
echo ""
echo "To install the input method, run:"
echo "  sudo ./scripts/install.sh"

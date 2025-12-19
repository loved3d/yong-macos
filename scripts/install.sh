#!/bin/bash

# Installation script for yong-macos input method

set -e

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Error: This script must be run with sudo"
    exit 1
fi

# Find the built app
APP_PATH=$(find . -name "yong-macos.app" -path "*/Build/Products/*" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Error: yong-macos.app not found. Please build the project first:"
    echo "  ./scripts/build.sh"
    exit 1
fi

echo "📦 Found app at: $APP_PATH"

# Set the installation path
INSTALL_PATH="/Library/Input Methods/yong-macos.app"

# Remove old installation if exists
if [ -d "$INSTALL_PATH" ]; then
    echo "🗑️  Removing old installation..."
    rm -rf "$INSTALL_PATH"
fi

# Copy the app to Input Methods directory
echo "📥 Installing to $INSTALL_PATH..."
cp -r "$APP_PATH" "$INSTALL_PATH"

# Set proper permissions
echo "🔐 Setting permissions..."
chmod -R 755 "$INSTALL_PATH"

echo "✅ Installation completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Open System Settings > Keyboard > Input Sources"
echo "2. Click '+' to add a new input source"
echo "3. Select 'Chinese' and find 'Yong'"
echo "4. Log out and log back in (or restart) for changes to take effect"
echo ""
echo "To uninstall, run:"
echo "  sudo ./scripts/uninstall.sh"

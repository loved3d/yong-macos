#!/bin/bash

# Uninstallation script for yong-macos input method

set -e

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Error: This script must be run with sudo"
    exit 1
fi

INSTALL_PATH="/Library/Input Methods/yong-macos.app"

if [ ! -d "$INSTALL_PATH" ]; then
    echo "ℹ️  yong-macos is not installed at $INSTALL_PATH"
    exit 0
fi

echo "🗑️  Removing yong-macos from $INSTALL_PATH..."
rm -rf "$INSTALL_PATH"

echo "✅ Uninstallation completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Open System Settings > Keyboard > Input Sources"
echo "2. Remove 'Yong' from the list if present"
echo "3. Log out and log back in (or restart) for changes to take effect"

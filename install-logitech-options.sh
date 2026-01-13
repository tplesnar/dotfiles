#!/bin/bash
set -e

echo "Installing Logitech Options+ (Offline Version)..."

# URLs
OFFLINE_INSTALLER_URL="https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer_offline.zip"
PATCH_URL="https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer_patch.zip"

# Temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "📦 Downloading Logitech Options+ offline installer (~483MB)..."
curl -L -o logioptionsplus_offline.zip "$OFFLINE_INSTALLER_URL"

echo "📦 Downloading certificate patch..."
curl -L -o logioptionsplus_patch.zip "$PATCH_URL"

echo "📂 Extracting offline installer..."
unzip -q logioptionsplus_offline.zip

echo "📂 Extracting patch..."
unzip -q logioptionsplus_patch.zip

echo "🔧 Installing Logitech Options+ (offline version)..."
# Find the .pkg file in the extracted contents
OFFLINE_PKG=$(find . -name "*.pkg" -path "*offline*" | head -n 1)
if [[ -z "$OFFLINE_PKG" ]]; then
    # Fallback: look for any pkg file
    OFFLINE_PKG=$(find . -name "*.pkg" | head -n 1)
fi

if [[ -z "$OFFLINE_PKG" ]]; then
    echo "❌ Error: Could not find .pkg file in offline installer"
    exit 1
fi

sudo installer -pkg "$OFFLINE_PKG" -target /

echo "🔧 Applying certificate patch..."
# Find the patch .pkg file
PATCH_PKG=$(find . -name "*.pkg" -path "*patch*" | head -n 1)
if [[ -z "$PATCH_PKG" ]]; then
    # Try alternate search
    PATCH_PKG=$(find . -name "*patch*.pkg" -o -name "*Patch*.pkg" | head -n 1)
fi

if [[ -n "$PATCH_PKG" ]]; then
    sudo installer -pkg "$PATCH_PKG" -target /
    echo "✅ Patch applied successfully"
else
    echo "⚠️  Warning: Could not find patch .pkg file"
    echo "   The offline installer may already include the certificate fix"
fi

# Cleanup
cd ~
rm -rf "$TMP_DIR"

echo ""
echo "✅ Logitech Options+ installation complete!"
echo ""
echo "Note: This is the OFFLINE version, which means:"
echo "  ✅ Works without internet"
echo "  ✅ No telemetry/cloud features"
echo "  ❌ No Logi Account sync"
echo "  ❌ No Flow feature"
echo "  ❌ No backup & restore to cloud"
echo ""
echo "Launch Options+ from /Applications/logioptionsplus.app"

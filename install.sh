#!/bin/bash
# env2json installation script

set -e

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    arm64|aarch64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case $OS in
    darwin)
        BINARY_NAME="env2json-darwin-$ARCH"
        ;;
    linux)
        BINARY_NAME="env2json-linux-$ARCH"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Download URL
REPO="gbretas/env2json"
LATEST_URL="https://github.com/$REPO/releases/latest/download/$BINARY_NAME"

echo "🔄 Installing env2json for $OS-$ARCH..."

# Download binary
echo "📥 Downloading from $LATEST_URL"
curl -L -o env2json "$LATEST_URL"

# Make executable
chmod +x env2json

# Install to /usr/local/bin
if [ -w /usr/local/bin ]; then
    mv env2json /usr/local/bin/
    echo "✅ env2json installed to /usr/local/bin/"
else
    echo "🔐 Installing to /usr/local/bin/ (requires sudo):"
    sudo mv env2json /usr/local/bin/
    echo "✅ env2json installed to /usr/local/bin/"
fi

# Test installation
echo "🧪 Testing installation..."
env2json -help

echo ""
echo "🎉 Installation complete!"
echo "💡 Usage: env2json (in any directory with .env file)"

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

# Create ~/.local/bin if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Install to ~/.local/bin
mv env2json "$HOME/.local/bin/"
echo "✅ env2json installed to $HOME/.local/bin/"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    echo "✅ $HOME/.local/bin is already in your PATH"
else
    echo "💡 Add $HOME/.local/bin to your PATH by adding this line to your shell config:"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "   For bash: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
    echo "   For zsh:  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
    echo ""
    echo "   Then restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
fi

# Test installation
echo "🧪 Testing installation..."
env2json -help

echo ""
echo "🎉 Installation complete!"
echo "💡 Usage: env2json (in any directory with .env file)"

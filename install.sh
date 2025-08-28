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

# Create ~/bin if it doesn't exist
mkdir -p "$HOME/bin"

# Install to ~/bin
mv env2json "$HOME/bin/"
echo "✅ env2json installed to $HOME/bin/"

# Check if ~/bin is in PATH
if [[ ":$PATH:" == *":$HOME/bin:"* ]]; then
    echo "✅ $HOME/bin is already in your PATH"
else
    echo "💡 Add $HOME/bin to your PATH by adding this line to your shell config:"
    echo "   export PATH=\"\$HOME/bin:\$PATH\""
    echo ""
    echo "   For bash: echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bashrc"
    echo "   For zsh:  echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.zshrc"
    echo ""
    echo "   Then restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
fi

# Test installation
echo "🧪 Testing installation..."
env2json -help

echo ""
echo "🎉 Installation complete!"
echo "💡 Usage: env2json (in any directory with .env file)"

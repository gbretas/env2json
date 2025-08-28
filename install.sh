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

# Determine install directory based on OS
case $OS in
    darwin)
        # macOS standard: ~/bin
        INSTALL_DIR="$HOME/bin"
        SHELL_CONFIG="~/.zshrc"
        if [[ "$SHELL" == *"bash"* ]]; then
            SHELL_CONFIG="~/.bash_profile"
        fi
        ;;
    linux)
        # Linux standard: ~/.local/bin (XDG spec)
        INSTALL_DIR="$HOME/.local/bin"
        SHELL_CONFIG="~/.bashrc"
        if [[ "$SHELL" == *"zsh"* ]]; then
            SHELL_CONFIG="~/.zshrc"
        fi
        ;;
esac

# Create install directory
mkdir -p "$INSTALL_DIR"

# Install binary
mv env2json "$INSTALL_DIR/"
echo "✅ env2json installed to $INSTALL_DIR/"

# Check if install directory is in PATH
if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
    echo "✅ $INSTALL_DIR is already in your PATH"
else
    echo "💡 Add $INSTALL_DIR to your PATH by adding this line to $SHELL_CONFIG:"
    echo "   export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
    echo "   Run: echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> $SHELL_CONFIG"
    echo "   Then restart your terminal or run: source $SHELL_CONFIG"
fi

# Test installation
echo "🧪 Testing installation..."
env2json -help

echo ""
echo "🎉 Installation complete!"
echo "💡 Usage: env2json (in any directory with .env file)"

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
    echo "🔧 Adding $INSTALL_DIR to your PATH..."
    
    # Determine actual shell config file
    case $OS in
        darwin)
            if [[ "$SHELL" == *"bash"* ]]; then
                ACTUAL_CONFIG="$HOME/.bash_profile"
            else
                ACTUAL_CONFIG="$HOME/.zshrc"
            fi
            ;;
        linux)
            if [[ "$SHELL" == *"zsh"* ]]; then
                ACTUAL_CONFIG="$HOME/.zshrc"
            else
                ACTUAL_CONFIG="$HOME/.bashrc"
            fi
            ;;
    esac
    
    # Add to PATH if not already there
    if ! grep -q "export PATH.*$INSTALL_DIR" "$ACTUAL_CONFIG" 2>/dev/null; then
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$ACTUAL_CONFIG"
        echo "✅ Added $INSTALL_DIR to $ACTUAL_CONFIG"
    else
        echo "✅ $INSTALL_DIR already configured in $ACTUAL_CONFIG"
    fi
    
    # Update current session PATH
    export PATH="$INSTALL_DIR:$PATH"
fi

# Test installation in current session
echo "🧪 Testing installation..."
if command -v env2json >/dev/null 2>&1; then
    env2json -help
    echo ""
    echo "🎉 Installation successful!"
    echo "💡 You can now use 'env2json' from anywhere!"
else
    echo ""
    echo "✅ Installation completed successfully!"
    echo ""
    echo "🔄 **IMPORTANT: You need to restart your terminal or reload your shell:**"
    echo ""
    case $OS in
        darwin)
            echo "   Option 1 (Quick): source ~/.zshrc"
            echo "   Option 2 (Recommended): Restart Terminal.app completely"
            echo "   Option 3: Open new terminal tab/window"
            ;;
        linux)
            if [[ "$SHELL" == *"zsh"* ]]; then
                echo "   Option 1 (Quick): source ~/.zshrc"
            else
                echo "   Option 1 (Quick): source ~/.bashrc"
            fi
            echo "   Option 2 (Recommended): Close and reopen terminal"
            echo "   Option 3: Open new terminal tab"
            ;;
    esac
    echo ""
    echo "💡 After restarting, test with: env2json -help"
fi

echo ""
echo "📋 Usage examples:"
echo "   env2json                    # Convert .env to JSON + clipboard"
echo "   env2json -input .env.prod   # Convert specific file"
echo "   env2json -output secrets.json  # Save to file"

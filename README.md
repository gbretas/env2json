# env2json

🔄 Convert `.env` files to JSON format for easy import into AWS Secrets Manager and other secrets management services.

[![CI](https://github.com/gbretas/env2json/workflows/CI/badge.svg)](https://github.com/gbretas/env2json/actions)
[![Release](https://github.com/gbretas/env2json/workflows/Release/badge.svg)](https://github.com/gbretas/env2json/releases)
[![Go Report Card](https://goreportcard.com/badge/github.com/gbretas/env2json)](https://goreportcard.com/report/github.com/gbretas/env2json)

## Features

- 🎯 **Simple**: Just run `env2json` in any directory with a `.env` file
 - 📋 **Clipboard**: Automatically copies JSON to clipboard for easy pasting
- 🔒 **Secure**: Automatically masks sensitive values in preview output
- 🌍 **Cross-platform**: Works on macOS, Linux, and Windows WSL
- 📁 **Flexible**: Specify custom input files with `--input` flag
- 💾 **Output options**: Print to stdout (with clipboard) or save to file
- ⚡ **Fast**: Single binary with no dependencies

## Installation

### Quick Install (Recommended)

```bash
# One-line install script (macOS/Linux)
curl -sSL https://raw.githubusercontent.com/gbretas/env2json/main/install.sh | bash
```

### Download Pre-built Binaries

Download the appropriate binary for your platform from the [releases page](https://github.com/gbretas/env2json/releases):

```bash
# macOS (Apple Silicon) - instala em ~/bin (padrão macOS)
curl -L -o env2json https://github.com/gbretas/env2json/releases/latest/download/env2json-darwin-arm64
chmod +x env2json && mkdir -p ~/bin && mv env2json ~/bin/

# macOS (Intel) - instala em ~/bin (padrão macOS)
curl -L -o env2json https://github.com/gbretas/env2json/releases/latest/download/env2json-darwin-amd64
chmod +x env2json && mkdir -p ~/bin && mv env2json ~/bin/

# Linux (x64) - instala em ~/.local/bin (padrão XDG)
curl -L -o env2json https://github.com/gbretas/env2json/releases/latest/download/env2json-linux-amd64
chmod +x env2json && mkdir -p ~/.local/bin && mv env2json ~/.local/bin/

# Linux (ARM64) - instala em ~/.local/bin (padrão XDG)
curl -L -o env2json https://github.com/gbretas/env2json/releases/latest/download/env2json-linux-arm64
chmod +x env2json && mkdir -p ~/.local/bin && mv env2json ~/.local/bin/

# Windows WSL
curl -L -o env2json.exe https://github.com/gbretas/env2json/releases/latest/download/env2json-windows-amd64.exe
```

### Build from Source

```bash
git clone https://github.com/gbretas/env2json.git
cd env2json
make build
```

### Install Globally

```bash
# Build and install (uses OS-specific standard directory)
make build && make install

# macOS: instala em ~/bin
# Linux: instala em ~/.local/bin
# Siga as instruções para adicionar ao PATH se necessário
```

## Usage

### Basic Usage

```bash
# Convert .env in current directory (JSON to stdout + clipboard)
env2json

# Convert specific .env file  
env2json -input .env.production
env2json -input /path/to/.env

# Save output to file (no clipboard)
env2json -output secrets.json
env2json -input .env.prod -output prod-secrets.json
```

### Examples

#### Convert local .env file (output to console + clipboard)
```bash
$ env2json
{
  "API_KEY": "abc123def456",
  "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb",
  "NODE_ENV": "development",
  "PORT": "3000",
  "DEBUG": "true"
}
# ↑ JSON automatically copied to clipboard!
```

#### Convert specific .env file
```bash
$ env2json -input .env.production
{
  "API_SECRET": "prod_secret_key",
  "DATABASE_URL": "postgresql://prod-server:5432/app",
  "ENVIRONMENT": "production"
}
```

#### Save to file instead of clipboard
```bash
$ env2json -output secrets.json
Saved to secrets.json (5 variables)

$ cat secrets.json
{
  "API_KEY": "abc123def456",
  "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb",
  "NODE_ENV": "development",
  "PORT": "3000",
  "DEBUG": "true"
}
```

#### Error handling examples
```bash
$ env2json
No .env file found in current directory.
Use --input flag to specify a different .env file:
  env2json --input /path/to/.env
  env2json --input .env.production

$ env2json -input nonexistent.env  
File not found: nonexistent.env
```

### AWS Secrets Manager Integration

#### Method 1: Direct clipboard paste (recommended)
```bash
# Convert .env and copy to clipboard
env2json

# Then paste directly in AWS Console Secrets Manager
# Or use AWS CLI with clipboard:
aws secretsmanager create-secret \
  --name "my-app-secrets" \
  --secret-string "$(pbpaste)"  # macOS
  # --secret-string "$(xclip -o)"  # Linux
```

#### Method 2: File-based import
```bash
# Generate secrets file
env2json -output secrets.json

# Import to AWS Secrets Manager
aws secretsmanager create-secret \
  --name "my-app-secrets" \
  --secret-string file://secrets.json
```

### Other Cloud Services

#### Kubernetes Secrets
```bash
# Convert and create k8s secret
env2json | kubectl create secret generic my-app-secrets --from-file=/dev/stdin

# Or save to file first
env2json -output secrets.json
kubectl create secret generic my-app-secrets --from-file=secrets.json
```

#### Azure Key Vault
```bash
env2json -output secrets.json
az keyvault secret set --vault-name MyKeyVault --name app-secrets --file secrets.json
```

## Troubleshooting

### PATH Issues
If `env2json` command is not found after installation:

```bash
# Check if binary exists
ls -la ~/.local/bin/env2json  # Linux
ls -la ~/bin/env2json         # macOS

# Add to PATH manually
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # Linux
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc         # macOS

# Reload shell
source ~/.bashrc  # or ~/.zshrc
```

### Clipboard Issues
If clipboard doesn't work:
- **macOS**: Should work out of the box
- **Linux**: Install `xclip` or `xsel`: `sudo apt install xclip`
- **Windows WSL**: Install `clip` (usually pre-installed)

### Common Issues
```bash
# Empty .env file
$ env2json
The .env file is empty or contains no valid environment variables.

# Permission denied
$ env2json -input /etc/secrets.env
Error reading .env file: open /etc/secrets.env: permission denied
```

## Development

### Build Commands

```bash
# Build for current platform
make build

# Build for all platforms  
make build-all

# Run tests
make test

# Install locally (OS-specific directory)
make install

# Clean build files
make clean

# Run locally
make run ARGS="-help"
make run ARGS="-input .env.test"
```

### Project Structure
```
env2json/
├── main.go              # Main CLI application
├── main_test.go         # Unit tests  
├── go.mod              # Go module definition
├── Makefile            # Build automation
├── install.sh          # Installation script
├── LICENSE             # MIT license
├── README.md           # This file
├── .github/workflows/  # GitHub Actions CI/CD
└── build/              # Generated binaries
```

## Security

- **Clean output**: Only outputs JSON, no sensitive data leaked in logs
- **No network calls**: Purely local processing
- **No data storage**: Doesn't save or cache any environment data
- **Clipboard only**: Sensitive data only goes to clipboard (user controlled)

## Supported .env Format

The tool supports standard `.env` file format with robust parsing:

```env
# Comments are ignored
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb

# Quoted values (quotes are automatically removed)
API_KEY="abc123def456"
JWT_SECRET='super-secret-key'

# Unquoted values
PORT=3000
DEBUG=true

# Empty lines are ignored

# Complex values
REDIS_URL=redis://username:password@redis-server:6379/0
ALLOWED_HOSTS=localhost,127.0.0.1,myapp.com
```

### Parsing Features
- ✅ **Comments**: Lines starting with `#` are ignored
- ✅ **Empty lines**: Automatically skipped  
- ✅ **Quoted values**: Single and double quotes removed
- ✅ **Complex values**: URLs, comma-separated lists, etc.
- ✅ **Whitespace**: Automatically trimmed
- ✅ **Invalid lines**: Gracefully skipped

## License

MIT License

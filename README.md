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
# macOS (Apple Silicon)
curl -L -o env2json https://github.com/gbretas/env2json/releases/latest/download/env2json-darwin-arm64
chmod +x env2json && mkdir -p ~/bin && mv env2json ~/bin/

# macOS (Intel)  
curl -L -o env2json https://github.com/gbretas/env2json/releases/latest/download/env2json-darwin-amd64
chmod +x env2json && mkdir -p ~/bin && mv env2json ~/bin/

# Linux (x64)
curl -L -o env2json https://github.com/gbretas/env2json/releases/latest/download/env2json-linux-amd64
chmod +x env2json && mkdir -p ~/bin && mv env2json ~/bin/

# Linux (ARM64)
curl -L -o env2json https://github.com/gbretas/env2json/releases/latest/download/env2json-linux-arm64
chmod +x env2json && mkdir -p ~/bin && mv env2json ~/bin/

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
# Build and install to ~/bin
make build
mkdir -p ~/bin
cp build/env2json ~/bin/

# Add to PATH (if not already there)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc  # or ~/.bashrc
source ~/.zshrc  # or ~/.bashrc
```

## Usage

### Basic Usage

```bash
# Convert .env in current directory
env2json

# Specify input file
env2json --input .env.production
env2json --input /path/to/.env

# Save output to file
env2json --output secrets.json
env2json --input .env.prod --output prod-secrets.json
```

### Examples

#### Convert local .env file
```bash
$ env2json
✅ Successfully converted .env to JSON (5 variables):

{
  "API_KEY": "abc123def456",
  "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb",
  "NODE_ENV": "development",
  "PORT": "3000",
  "SECRET_KEY": "mysecretkey"
}

📋 JSON copied to clipboard! Ready to paste into AWS Secrets Manager or other services.
💡 To save to file instead: env2json --output secrets.json

📋 Variables found:
   API_KEY: [MASKED]
   DATABASE_URL: postgresql://user:pass@localhost:5432/mydb
   NODE_ENV: development
   PORT: 3000
   SECRET_KEY: [MASKED]
```

#### Save to file for AWS import
```bash
$ env2json --output aws-secrets.json
✅ Successfully converted .env to JSON and saved to aws-secrets.json (5 variables)
```

#### Import specific environment file
```bash
$ env2json --input .env.production --output prod-secrets.json
✅ Successfully converted .env.production to JSON and saved to prod-secrets.json (8 variables)
```

### AWS Secrets Manager Integration

After generating the JSON file, you can import it directly into AWS Secrets Manager:

```bash
# Generate secrets file
env2json --output secrets.json

# Import to AWS Secrets Manager
aws secretsmanager create-secret \
  --name "my-app-secrets" \
  --secret-string file://secrets.json
```

## Error Handling

The tool provides helpful error messages and suggestions:

```bash
$ env2json
❌ No .env file found in current directory.
💡 Use --input flag to specify a different .env file:
   env2json --input /path/to/.env
   env2json --input .env.production
```

## Build Commands

```bash
# Build for current platform
make build

# Build for all platforms
make build-all

# Run tests
make test

# Install locally
make install

# Clean build files
make clean
```

## Security Features

- Automatically detects and masks sensitive environment variables in preview output
- Variables containing keywords like `password`, `secret`, `key`, `token`, etc. are masked as `[MASKED]`
- JSON output contains actual values (needed for secrets managers)

## Supported .env Format

The tool supports standard `.env` file format:

```env
# Comments are ignored
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
API_KEY=abc123def456
PORT=3000

# Empty lines are ignored
NODE_ENV=production
```

## License

MIT License

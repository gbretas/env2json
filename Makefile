# env2json - Cross-platform build Makefile

# Variables
BINARY_NAME=env2json
VERSION=1.0.0
BUILD_DIR=build
LDFLAGS=-ldflags "-X main.Version=${VERSION} -s -w" -trimpath
BUILD_FLAGS=CGO_ENABLED=0

# Default target
.PHONY: all
all: clean build

# Clean build directory
.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}

# Install dependencies
.PHONY: deps
deps:
	go mod download
	go mod tidy

# Build for current platform
.PHONY: build
build: deps
	${BUILD_FLAGS} go build ${LDFLAGS} -o ${BUILD_DIR}/${BINARY_NAME} .

# Build for all platforms
.PHONY: build-all
build-all: clean deps build-linux build-darwin build-windows

# Build for Linux (amd64 and arm64)
.PHONY: build-linux
build-linux:
	${BUILD_FLAGS} GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -o ${BUILD_DIR}/${BINARY_NAME}-linux-amd64 .
	${BUILD_FLAGS} GOOS=linux GOARCH=arm64 go build ${LDFLAGS} -o ${BUILD_DIR}/${BINARY_NAME}-linux-arm64 .

# Build for macOS (Intel and Apple Silicon)
.PHONY: build-darwin
build-darwin:
	${BUILD_FLAGS} GOOS=darwin GOARCH=amd64 go build ${LDFLAGS} -o ${BUILD_DIR}/${BINARY_NAME}-darwin-amd64 .
	${BUILD_FLAGS} GOOS=darwin GOARCH=arm64 go build ${LDFLAGS} -o ${BUILD_DIR}/${BINARY_NAME}-darwin-arm64 .

# Build for Windows (WSL)
.PHONY: build-windows
build-windows:
	${BUILD_FLAGS} GOOS=windows GOARCH=amd64 go build ${LDFLAGS} -o ${BUILD_DIR}/${BINARY_NAME}-windows-amd64.exe .

# Install locally (OS-specific directories)
.PHONY: install
install: build
	@echo "🔧 Installing for $(shell uname -s)..."
ifeq ($(shell uname -s),Darwin)
	# macOS: use ~/bin
	mkdir -p ~/bin
	cp ${BUILD_DIR}/${BINARY_NAME} ~/bin/
	@echo "✅ env2json installed to ~/bin/"
	@echo "💡 Make sure ~/bin is in your PATH:"
	@echo "   export PATH=\"\$$HOME/bin:\$$PATH\""
else
	# Linux: use ~/.local/bin (XDG standard)
	mkdir -p ~/.local/bin
	cp ${BUILD_DIR}/${BINARY_NAME} ~/.local/bin/
	@echo "✅ env2json installed to ~/.local/bin/"
	@echo "💡 Make sure ~/.local/bin is in your PATH:"
	@echo "   export PATH=\"\$$HOME/.local/bin:\$$PATH\""
endif

# Test
.PHONY: test
test:
	go test -v ./...

# Run
.PHONY: run
run:
	go run . $(ARGS)

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all         - Clean and build for current platform"
	@echo "  build       - Build for current platform"
	@echo "  build-all   - Build for all platforms"
	@echo "  build-linux - Build for Linux (amd64, arm64)"
	@echo "  build-darwin- Build for macOS (Intel, Apple Silicon)"
	@echo "  build-windows- Build for Windows"
	@echo "  install     - Install binary to /usr/local/bin"
	@echo "  test        - Run tests"
	@echo "  clean       - Clean build directory"
	@echo "  deps        - Download dependencies"
	@echo "  run ARGS=   - Run with arguments"
	@echo ""
	@echo "Examples:"
	@echo "  make run ARGS='--help'"
	@echo "  make run ARGS='--input .env.prod'"

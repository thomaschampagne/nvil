#!/bin/bash

set -euo pipefail

# Load requirements
source /nvil/core/utils/feats.require.sh

# Install Runtime then get access to it with activate
mise use -g go@latest && eval "$(~/.local/bin/mise activate bash)"

# Required dependencies
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install mvdan.cc/gofumpt@latest

# Clean cache to reduc image size
go clean -cache -modcache -testcache

# Helix language config
cat >> ~/.config/helix/languages.toml << 'EOF'
[[language]]
name = "go"
auto-format = true
formatter = { command = "gofumpt" }
language-servers = ["gopls"]

[language-server.gopls.config]
gofumpt = true
staticcheck = true
vulncheck = "Imports"
usePlaceholders = true
completeUnimported = true

EOF

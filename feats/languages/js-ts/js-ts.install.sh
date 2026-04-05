#!/bin/bash

set -euo pipefail

# Load requirements
source /nvil/core/utils/feats.require.sh

# Required dependencies
pnpm add -g \
  typescript@latest \
  typescript-language-server@latest \
  prettier@latest

# Force pnpm store prune --force
pnpm store prune --force
pnpm cache delete

# Helix language config
cat >>~/.config/helix/languages.toml <<'EOF'
[language-server.eslint]
command = "vscode-eslint-language-server"
args = ["--stdio"]

[[language]]
name = "typescript"
language-servers = ["typescript-language-server", "eslint"]
formatter = { command = "prettier", args = ["--parser", "typescript"] }
auto-format = true

[[language]]
name = "javascript"
language-servers = ["typescript-language-server", "eslint"]
formatter = { command = "prettier", args = ["--parser", "typescript"] }
auto-format = true
EOF

# TODO @P1: DAP config not working ATM
# mise use -g 'github:microsoft/vscode-js-debug[asset_pattern=js-debug-dap-v*.tar.gz]'

# Note: You can force bun to execute LSP instead of node (if installed) with below. Also ensure: bun add -g typescript-language-server typescript prettier
# [language-server.typescript-language-server]
# command = "bunx"
# args = [ "--bun", "typescript-language-server", "--stdio" ]

#!/bin/bash

set -eo pipefail

# Load requirements
source /nvil/core/utils/feats.require.sh

# Required dependencies
npm add -g -y typescript@6 # TODO migrate from typescript 6 to latest (7) once angular supports it 
npm add -g -y \
  tslib@latest \
  typescript-language-server@latest \
  prettier@latest

# Required dependencies
npm add -g -y @angular/cli \
   @angular/language-service \
   @angular/language-server

# Force pnpm clean
npm cache verify

# Helix language config
cat >>~/.config/helix/languages.toml <<'EOF'

# --- ESLint ---
[language-server.eslint]
command = "vscode-eslint-language-server"
args = ["--stdio"]

# --- Angular LS Server ---
[language-server.angular-ls]
command = "ngserver"
args = [
  "--stdio",
  "--tsProbeLocations",
  "/home/smith/.local/share/mise/installs/node/lts/lib/node_modules",
  "--ngProbeLocations",
  "/home/smith/.local/share/mise/installs/node/lts/lib/node_modules",
  "--forceStrictTemplates"
]

# --- Languages Def ---
[[language]]
name = "css"
formatter = { command = "dprint", args = ["fmt", "--stdin", "css"] }
language-servers = ["vscode-css-language-server", "emmet-language-server"]
auto-format = true

[[language]]
name = "scss"
formatter = { command = "dprint", args = ["fmt", "--stdin", "scss"] }
language-servers = ["vscode-css-language-server", "emmet-language-server"]
auto-format = true
 
[[language]]
name = "typescript"
formatter = { command = "prettier", args = ["--parser", "typescript"] }
language-servers = ["angular-ls", "typescript-language-server", "eslint"]
auto-format = true

[[language]]
name = "javascript"
formatter = { command = "prettier", args = ["--parser", "typescript"] }
language-servers = ["angular-ls", "typescript-language-server", "eslint"]
auto-format = true

[[language]]
name = "html"
file-types = ["html", "htm"]
formatter = { command = "dprint", args = ["fmt", "--stdin", "html"] }
language-servers = ["angular-ls", "vscode-html-language-server", "emmet-language-server"]
auto-format = true
EOF

# TODO @P1: DAP config not working ATM
# mise use -g 'github:microsoft/vscode-js-debug[asset_pattern=js-debug-dap-v*.tar.gz]'

# Note: You can force bun to execute LSP instead of node (if installed) with below. Also ensure: bun add -g typescript-language-server typescript prettier
# [language-server.typescript-language-server]
# command = "bunx"
# args = [ "--bun", "typescript-language-server", "--stdio" ]

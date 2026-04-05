#!/bin/bash

set -euo pipefail

# Load requirements
source /nvil/core/utils/feats.require.sh

# Install dockerfile LSP
pnpm add -g dockerfile-language-server-nodejs

# Force pnpm store prune --force
pnpm store prune --force
pnpm cache delete

# Install yaml formatter
dprint add --global dockerfile

# Add Helix language config
cat >>~/.config/helix/languages.toml <<'EOF'
[[language]]
name = "dockerfile"
formatter = { command = "dprint", args = ["fmt", "--stdin", "dockerfile"] }
auto-format = true
EOF

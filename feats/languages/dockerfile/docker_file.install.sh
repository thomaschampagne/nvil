#!/bin/bash

set -eo pipefail

# Load requirements
source /nvil/core/utils/feats.require.sh

# Install dockerfile LSP
npm add -g -y dockerfile-language-server-nodejs

# Install yaml formatter
dprint add --global dockerfile

# Add Helix language config
cat >>~/.config/helix/languages.toml <<'EOF'
[[language]]
name = "dockerfile"
formatter = { command = "dprint", args = ["fmt", "--stdin", "dockerfile"] }
auto-format = true
EOF

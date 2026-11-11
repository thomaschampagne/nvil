#!/bin/bash

# Description: AI coding assistant for the terminal.
# Repo Link: https://github.com/anomalyco/opencode

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g opencode

# Clean caches
mise prune && mise cache clean

# Re-export mise PATH
eval "$(~/.local/bin/mise activate bash)" # Reactivate mise for usage

# Execute script relatively where script is
cd "$(dirname "$0")"

# Copy .opencode.jsonc to home config
mkdir -p ~/.config/opencode/
cp ./opencode.jsonc ~/.config/opencode/

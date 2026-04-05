#!/bin/bash

set -euo pipefail

# Load requirements
source /nvil/core/utils/feats.require.sh

# Install Runtime
mise use -g bun@latest

# Configure shell
echo -e '\n# Append BunJS configuration' >> ~/.zshrc
# - Append bun to PATH
echo 'export PATH=$PATH:/home/${USERNAME}/.bun/bin' >> ~/.zshrc

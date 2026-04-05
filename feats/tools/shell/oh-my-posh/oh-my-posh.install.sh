#!/bin/bash

# Description: The most customisable and low-latency cross platform/shell prompt renderer.
# Repo Link: https://github.com/JanDeDobbeleer/oh-my-posh

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g oh-my-posh

echo -e '\n# Append Oh My Posh configuration' >> ~/.zshrc
echo 'eval "$(oh-my-posh init zsh --config ${NVIL_OMP_THEME})"' >> ~/.zshrc


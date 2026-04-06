#!/bin/bash

# Description: A modern alternative to ls.
# Repo Link: https://github.com/eza-community/eza

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g eza

# Add e => eza alias to zshrc
echo -e '\n# Append eza alias' >> ~/.zshrc
echo 'alias e="eza"' >> ~/.zshrc
echo 'alias el="eza -l"' >> ~/.zshrc
echo 'alias ea="eza -la"' >> ~/.zshrc

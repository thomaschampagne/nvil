#!/bin/bash

# Description: A smarter cd command. Supports all major shells.
# Repo Link: https://github.com/ajeetdsouza/zoxide

set -euo pipefail

source /nvil/core/utils/feats.require.sh

require_feature "../../search/fzf/fzf.install.sh"

mise use -g zoxide

eval "$(~/.local/bin/mise activate bash)" # Reactivate mise for usage

echo -e '\n# Append zoxide configuration' >> ~/.zshrc
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

zoxide add /nvil
zoxide add ${NVIL_WORKSPACE_DIR}
zoxide add ~/.cache
zoxide add ~/.config
zoxide add ~/.config/dprint
zoxide add ~/.config/helix
zoxide add ~/.config/mise
zoxide add ~/.config/yazi
zoxide add ~/.config/zellij

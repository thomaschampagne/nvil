#!/bin/bash

# Description: Manage your dotfiles across multiple diverse machines, securely.
# Repo Link: https://github.com/twpayne/chezmoi

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g chezmoi

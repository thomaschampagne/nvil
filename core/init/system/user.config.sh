#!/bin/bash

set -euo pipefail

echo "============================================================"
echo "exec \"$(realpath "$0")\" as \"$(whoami)\" user"
echo "============================================================"

# Verify script is run as user ${NVIL_USER}
if [ "$(whoami)" != "${NVIL_USER}" ]; then
  echo "Error: This script must be run as user ${NVIL_USER}" >&2
  exit 1
fi

# Configure Git
git config --global --add safe.directory /workspace
git config --global --add safe.directory /home/${NVIL_USER}
git config --global init.defaultBranch main
git config --global core.autocrlf true                                                                                                           # Ensure skip LF vs CRLF comparison
git config --global alias.prune-deprecated-branches "!git fetch -p && git branch -vv | grep ': gone]' | awk '{print \$1}' | xargs git branch -D" # Prune local branches have been tracked remotely and are no longer tracked
git config --global alias.prune-deprecated-tags "!git tag -l | xargs git tag -d && git fetch -t"                                                 # Prune all local tags and get them back from remote

# Add homebrew to PATH
echo -e '\n# Append HomeBrew configuration' >> ~/.zshrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"' >> ~/.zshrc

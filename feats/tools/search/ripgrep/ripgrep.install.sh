#!/bin/bash

# Description: ripgrep recursively searches directories for a regex pattern while respecting your gitignore.
# Repo Link: https://github.com/BurntSushi/ripgrep

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g ripgrep

#!/bin/bash

# Description: An interactive cheatsheet tool for the command-line.
# Repo Link: https://github.com/denisidoro/navi

set -euo pipefail

source /nvil/core/utils/feats.require.sh

require_feature "../fzf/fzf.install.sh"

mise use -g navi

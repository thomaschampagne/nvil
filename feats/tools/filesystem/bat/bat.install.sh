#!/bin/bash

# Description: A cat(1) clone with syntax highlighting and Git integration.
# Repo Link: https://github.com/sharkdp/bat

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g bat

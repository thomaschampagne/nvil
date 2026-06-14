#!/bin/bash

# Description: Grammar and spell checking language server for Helix.
# Repo Link: https://github.com/harper-ls/harper-ls

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g harper-ls@latest

mise prune && mise cache clean

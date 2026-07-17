#!/bin/bash

# Description: RTK AI - Terminal AI Coding Assistant
# Repo Link: https://github.com/rtk-ai/rtk

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g rtk@latest

eval "$(~/.local/bin/mise activate bash)" # Reactivate mise for usage

# Init rtk for opencode
rtk init -g --opencode
rtk telemetry disable   # withdraw consent

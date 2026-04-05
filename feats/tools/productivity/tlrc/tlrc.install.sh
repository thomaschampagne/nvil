#!/bin/bash

# Description: Official tldr client written in Rust.
# Repo Link: https://github.com/tldr-pages/tlrc

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g tlrc

eval "$(~/.local/bin/mise activate bash)" # Reactivate mise for usage

tldr --update

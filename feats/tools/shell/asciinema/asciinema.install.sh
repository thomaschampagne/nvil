#!/bin/bash

# Description: Terminal session recorder, streamer and player.
# Repo Link: https://github.com/asciinema/asciinema

set -euo pipefail

source /nvil/core/utils/feats.require.sh

# Install asciinema and agg via mise
mise use -g github:asciinema/asciinema@latest \
  github:asciinema/agg@latest

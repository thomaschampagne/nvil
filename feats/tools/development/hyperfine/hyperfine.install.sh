#!/bin/bash

# Description: A command-line benchmarking tool.
# Repo Link: https://github.com/sharkdp/hyperfine

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g hyperfine

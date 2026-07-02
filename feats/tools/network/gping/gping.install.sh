#!/bin/bash

# Description: Ping, but with a graph.
# Repo Link: https://github.com/orf/gping

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g github:orf/gping

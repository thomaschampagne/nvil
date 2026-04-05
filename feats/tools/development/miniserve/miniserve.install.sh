#!/bin/bash

# Description: For when you really just want to serve some files over HTTP right now!
# Repo Link: https://github.com/svenstaro/miniserve

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g aqua:svenstaro/miniserve

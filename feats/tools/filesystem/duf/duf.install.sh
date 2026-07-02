#!/bin/bash

# Description: Disk Usage/Free Utility - a better 'df' alternative.
# Repo Link: https://github.com/muesli/duf

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g duf

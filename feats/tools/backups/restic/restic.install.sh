#!/bin/bash

# Description: Fast, secure, efficient backup program.
# Repo Link: https://github.com/restic/restic

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g restic

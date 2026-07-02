#!/bin/bash

# Description: Execute commands when files change
# Repo Link: https://github.com/watchexec/watchexec

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g watchexec

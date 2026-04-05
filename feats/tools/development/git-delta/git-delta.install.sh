#!/bin/bash

# Description: A syntax-highlighting pager for git, diff, grep, and blame output.
# Repo Link: https://github.com/dandavison/delta

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g delta

#!/bin/bash

# Description: Manage encrypted files with YAML/JSON/ENV support
# Repo Link: https://github.com/getsops/sops

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g sops

#!/bin/bash

# Description: Vulnerability scanner for container images and filesystems
# Repo Link: https://github.com/anchore/grype

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g grype

#!/bin/bash

# Description: Generate Software Bill of Materials (SBOM) from container images and filesystems
# Repo Link: https://github.com/anchore/syft

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g syft

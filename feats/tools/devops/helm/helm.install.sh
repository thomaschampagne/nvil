#!/bin/bash

# Description: The package manager for Kubernetes.
# Repo Link: https://github.com/helm/helm

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g helm

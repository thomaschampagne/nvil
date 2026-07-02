#!/bin/bash

# Description: Kubernetes command-line tool.
# Repo Link: https://github.com/kubernetes/kubernetes

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g kubectl

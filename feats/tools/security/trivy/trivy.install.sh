#!/bin/bash

# Description: Find and fix container misconfigurations, IaC issues, and vulnerabilities
# Repo Link: https://github.com/aquasecurity/trivy

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g trivy

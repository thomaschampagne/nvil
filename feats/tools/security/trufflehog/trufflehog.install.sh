#!/bin/bash

# Description: Find and verify credentials in your codebase.
# Repo Link: https://github.com/trufflesecurity/trufflehog

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g github:trufflesecurity/trufflehog

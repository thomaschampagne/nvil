#!/bin/bash

# Description: A powerful duplicate file finder and an enhanced fork of fdupes.
# Repo Link: https://github.com/h2oai/jdupes

set -euo pipefail

source /nvil/core/utils/feats.require.sh

# Install jdupes via brew
# Brew Link: https://formulae.brew.sh/formula/jdupes
brew install jdupes

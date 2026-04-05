#!/bin/bash

# Description: A program that displays statistics about your code.
# Repo Link: https://github.com/XAMPPRocky/tokei

set -euo pipefail

source /nvil/core/utils/feats.require.sh

# Install tokei via brew
# Brew Link: https://formulae.brew.sh/formula/tokei
brew install tokei

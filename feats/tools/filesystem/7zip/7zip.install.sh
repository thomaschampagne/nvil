#!/bin/bash

# Description: 7-Zip file archiver
# Repo Link: https://github.com/ip7z/7zip/

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g "github:ip7z/7zip[exe=7zz,rename_exe=7z]"

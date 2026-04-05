#!/bin/bash

set -euo pipefail

echo "============================================================"
echo "exec \"$(realpath "$0")\" as \"$(whoami)\" user"
echo "============================================================"

# Verify script is run as user ${NVIL_USER}
if [ "$(whoami)" != "${NVIL_USER}" ]; then
  echo "Error: This script must be run as user ${NVIL_USER}" >&2
  exit 1
fi

# Install homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install mise for user
curl https://mise.run | sh

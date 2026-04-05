#!/bin/bash

set -euo pipefail

# Execute script from root
cd "$(dirname "$0")/.."

# Start podman if required
if [[ $(podman machine inspect --format '{{.State}}') != "running" ]]; then
    podman machine start
fi

# loading required dev to build
source ./.dev/.env

# Build image
sh nvil.img.make.sh --gh-token=$gh_token --docker-file=./core/core.Dockerfile --image=nvil-core-dev:latest

# Test command:
# podman run -it --rm -v .:/workspace --hostname dev-core nvil-core-dev:latest zsh -ic zellij # Pass '--network=none' to test offline

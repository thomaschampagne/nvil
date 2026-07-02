#!/bin/bash

set -eo pipefail

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
# podman run -it --rm -v .:/home/smith/workspace -v /mnt/wslg/runtime-dir/wayland-0:/run/user/smith/wayland-0:ro --userns=keep-id --hostname dev-core --name dev-core nvil-core-dev:latest zsh -ic zellij # Pass '--network=none' to test offline

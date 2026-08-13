#!/bin/bash

set -eo pipefail

# Execute script from root
cd "$(dirname "$0")/.."

# loading required dev to build
source ./.dev/.env

# Build image
sh nvil.img.make.sh --gh-token-file="$gh_token_file" --docker-file=./flavors/full.Dockerfile --image=nvil-full-dev:latest --arg-file=.dev/build-args.dev.conf

# Test command:
# podman run -it --rm -v .:/home/smith/workspace -v /mnt/wslg/runtime-dir/wayland-0:/run/user/smith/wayland-0:ro --userns=keep-id --hostname dev-full nvil-full-dev:latest zsh -ic zellij # Pass '--network=none' to test offline

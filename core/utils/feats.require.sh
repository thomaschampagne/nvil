#!/bin/bash

# Ensure brew/mise are loaded in PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
eval "$(~/.local/bin/mise activate bash)"

# Configure pnpm for potential pnpm features installs
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
export PATH="$PNPM_HOME:$PATH"

require_feature() {
    local feature_path="$1"
    local script_path="$(dirname "$0")/$feature_path"

    if [ ! -f "$script_path" ]; then
        echo "Error: $feature_path feature is not installed. Please ensure his copy in image you build." >&2
        exit 1
    fi

    source "$script_path"
}

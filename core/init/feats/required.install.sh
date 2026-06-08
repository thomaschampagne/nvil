#!/bin/bash

set -eo pipefail

echo "============================================================"
echo "exec \"$(realpath "$0")\" as \"$(whoami)\" user"
echo "============================================================"

# Verify script is run as user ${NVIL_USER}
if [ "$(whoami)" != "${NVIL_USER}" ]; then
  echo "Error: This script must be run as user ${NVIL_USER}" >&2
  exit 1
fi

# ======= Install Required Feats  =======
# Ensure brew/mise are loaded in PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
eval "$(~/.local/bin/mise activate bash)" # Reactivate mise for usage

# --- Install Required Tools
mise use -g \
  helix \
  neovim \
  lazygit \
  yazi \
  zellij \
  tlrc

# --- Install Required Formatters (dprint <json, yaml, html/xml, css/scss>, taplo <toml>, shfmt <bash>)
mise use -g \
  dprint \
  taplo \
  shfmt

# --- Install Required Runtime (Node for many LSPs) and ensure usage on upcoming commands
# => Use pnpm as node package manager for performance purpose against npm
mise use -g node@lts
eval "$(~/.local/bin/mise activate bash)" # Reactivate mise for usage
# Install PNPM & Configure for bash installs
corepack enable
corepack prepare pnpm@latest --activate
# Bash setup
export SHELL="$(which bash)" && pnpm setup
# ZSH setup
export SHELL="$(which zsh)" && pnpm setup

# source ~/.bashrc # TODO Can be drooped?

# --- Configure Formatters markdown, json, toml, yaml
mkdir -p ~/.config/dprint/
echo "{}" >~/.config/dprint/dprint.jsonc
dprint add --global \
  markdown \
  json \
  toml \
  g-plane/pretty_yaml \
  g-plane/malva \
  g-plane/markup_fmt
dprint fmt --allow-no-files # Trigger dprint wasm download

# --- Install Required LSP
# - vscode-langservers-extracted: css/scss, eslint, html, json, markdown
# - yaml-language-server: yaml
# - emmet-ls: snippet support for web
# - bash-language-server: bash support
npm add -g -y \
  vscode-langservers-extracted \
  yaml-language-server \
  emmet-ls \
  bash-language-server
# - marksman: markdown lsp, GitHub: https://github.com/artempyanykh/marksman
# - lemminx: xml lsp
mise use -g \
  marksman \
  github:redhat-developer/vscode-xml

# Update tldr helper command
tldr --update

# Cleaning
mise reshim
mise prune
mise cache clean
pnpm cache delete
brew autoremove
brew cleanup --prune=all

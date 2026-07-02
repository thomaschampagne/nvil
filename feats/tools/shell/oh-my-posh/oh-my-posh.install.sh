#!/bin/bash

# Description: The most customisable and low-latency cross platform/shell prompt renderer.
# Repo Link: https://github.com/JanDeDobbeleer/oh-my-posh

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g oh-my-posh

OMP_THEME_DIR="${HOME}/.cache/oh-my-posh/themes"
mkdir -p "${OMP_THEME_DIR}"

echo "Fetching oh-my-posh theme list..."
THEMES=$(curl -fsSL https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/contents/themes | jq -r '.[].name')
THEME_COUNT=$(echo "$THEMES" | wc -l)
echo "Downloading ${THEME_COUNT} themes to ${OMP_THEME_DIR}..."
for THEME in $THEMES; do
  [ "$THEME" = "schema.json" ] && continue
  echo "  Downloading ${THEME}..."
  curl -fsSL "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${THEME}" \
    -o "${OMP_THEME_DIR}/${THEME}"
done
echo "Oh My Posh themes downloaded successfully."

echo -e '\n# Append Oh My Posh configuration' >> ~/.zshrc
echo 'eval "$(oh-my-posh init zsh --config '"${OMP_THEME_DIR}"'/${NVIL_OMP_THEME}.omp.json)"' >> ~/.zshrc

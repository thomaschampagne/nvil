#!/bin/bash
set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g oh-my-posh

OMP_THEME_DIR="${HOME}/.cache/oh-my-posh/themes"
mkdir -p "${OMP_THEME_DIR}"

echo "Downloading oh-my-posh themes..."
curl -fsSL https://codeload.github.com/JanDeDobbeleer/oh-my-posh/tar.gz/refs/heads/main \
  | tar -xz --strip-components=2 -C "${OMP_THEME_DIR}" --wildcards '*/themes/*'
rm -f "${OMP_THEME_DIR}/schema.json"
echo "Oh My Posh themes downloaded successfully."

echo -e '\n# Append Oh My Posh configuration' >> ~/.zshrc
echo 'eval "$(oh-my-posh init zsh --config '"${OMP_THEME_DIR}"'/${NVIL_OMP_THEME}.omp.json)"' >> ~/.zshrc
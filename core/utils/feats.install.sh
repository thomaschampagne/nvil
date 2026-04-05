#!/bin/bash

set -euo pipefail

# Ensure brew/mise is loaded in PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
eval "$(~/.local/bin/mise activate bash)"

echo "============================================================"
echo "exec \"$(realpath "$0")\" as \"$(whoami)\" user"
echo "============================================================"

FEATURES_FOLDER=""

show_help() {
  cat <<'EOF'
Usage: $0 [--features-folder PATH] [--help]

Options:
  --features-folder PATH   Set features folder path (required)
  --help                   Show this help message
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --features-folder=*)
    FEATURES_FOLDER="${1#*=}"
    shift
    ;;
  --features-folder)
    FEATURES_FOLDER="$2"
    shift 2
    ;;
  -h | --help)
    show_help
    ;;
  *)
    echo "Unknown option: $1" >&2
    echo "Use --help for usage information" >&2
    exit 1
    ;;
  esac
done

if [ -z "$FEATURES_FOLDER" ]; then
  echo "Error: --features-folder is required" >&2
  echo "Use --help for usage information" >&2
  exit 1
fi

run_feature_installers() {
  local root_folder="${FEATURES_FOLDER:?Usage: run_feature_installers <root_folder>}"
  local username="${NVIL_USER:-}"
  local -a scripts=()

  if [ ! -d "$root_folder" ]; then
    echo "Error: Directory '$root_folder' does not exist" >&2
    return 1
  fi

  if [ -z "$username" ]; then
    echo "Error: NVIL_USER is not set" >&2
    return 1
  fi

  while IFS= read -r -d '' file; do
    dos2unix -q "$file" 2>/dev/null || true
    chown "${username}:${username}" "$file"
    if [[ "$file" == *.install.sh ]]; then
      scripts+=("$file")
    fi
  done < <(find "$root_folder" -type f -print0)

  if [ ${#scripts[@]} -eq 0 ]; then
    echo "No installer scripts found in '$root_folder'"
    return 0
  fi

  IFS=$'\n' sorted_scripts=($(sort <<<"${scripts[*]}"))
  unset IFS

  for script in "${sorted_scripts[@]}"; do
    echo "Running: $script"
    bash $script
  done

  # Merge feature metadata into global pkgs.metadata.json
  merge_metadata() {
    local global_metadata="/nvil/core/cmd/pkgs.metadata.json"
    local -a feature_metadatas=()

    while IFS= read -r -d '' metadata_file; do
      feature_metadatas+=("$metadata_file")
    done < <(find "$root_folder" -name "metadata.json" -type f -print0)

    if [ ${#feature_metadatas[@]} -eq 0 ]; then
      return 0
    fi

    if [ ! -f "$global_metadata" ]; then
      echo "Error: Global metadata file not found at $global_metadata" >&2
      return 1
    fi

    # Build a combined JSON array from all feature metadata files
    local combined="[]"
    for meta in "${feature_metadatas[@]}"; do
      combined=$(jq -s '.[0] + .[1]' <(echo "$combined") "$meta")
    done

    # Merge into global metadata: overwrite entries with the same name
    local existing
    existing=$(cat "$global_metadata")
    local merged
    merged=$(jq --argjson existing "$existing" --argjson new "$combined" '
            ($new | map({(.name): .}) | add) as $lookup |
            ($existing | map(if $lookup[.name] then $lookup[.name] else . end)) as $deduped |
            ($new | map(select(.name as $n | ($existing | map(.name) | index($n)) | not))) as $onlyNew |
            $deduped + $onlyNew
        ' <(echo "$existing"))

    echo "$merged" >"$global_metadata"
    echo "Merged ${#feature_metadatas[@]} metadata file(s) into $global_metadata"
  }

  merge_metadata

  # Drop feature folder
  rm -rf "$FEATURES_FOLDER"
  echo "Feature folder $FEATURES_FOLDER has been deleted"

  # Update tldr helper command
  tldr --update

  # Reshim any packages from mise
  mise reshim
  mise cache clear
  /home/linuxbrew/.linuxbrew/bin/brew autoremove
  /home/linuxbrew/.linuxbrew/bin/brew cleanup --prune=all
}

run_feature_installers

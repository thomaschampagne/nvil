#!/usr/bin/env bash
#
# list.pkgs.sh - Render a colored terminal table of all installed packages
# Sources: dnf, mise, brew, npm/pnpm, go
# Uses pkgs.metadata.json as primary database, tldr as fallback for descriptions
#

set -uo pipefail

# ============================================================
# Colors
# ============================================================
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_BLUE='\033[34m'
C_MAGENTA='\033[35m'
C_RED='\033[31m'
C_WHITE='\033[97m'

# Manager colors
declare -A MGR_COLORS
MGR_COLORS[dnf]="$C_GREEN"
MGR_COLORS[mise]="$C_CYAN"
MGR_COLORS[brew]="$C_YELLOW"
MGR_COLORS[npm]="$C_RED"
MGR_COLORS[pnpm]="$C_MAGENTA"
MGR_COLORS[go]="$C_BLUE"

# Category colors
declare -A CAT_COLORS
CAT_COLORS[system]="$C_DIM"
CAT_COLORS[development]="$C_GREEN"
CAT_COLORS[devops]="$C_CYAN"
CAT_COLORS[filesystem]="$C_YELLOW"
CAT_COLORS[search]="$C_BLUE"
CAT_COLORS[network]="$C_MAGENTA"
CAT_COLORS[security]="$C_RED"
CAT_COLORS[backups]="$C_YELLOW"
CAT_COLORS[shell]="$C_GREEN"
CAT_COLORS[productivity]="$C_BLUE"
CAT_COLORS[language-server]="$C_MAGENTA"
CAT_COLORS[formatter]="$C_CYAN"
CAT_COLORS[monitoring]="$C_RED"
CAT_COLORS[languages]="$C_GREEN"
CAT_COLORS[runtimes]="$C_YELLOW"
CAT_COLORS[ai]="$C_MAGENTA"

# ============================================================
# Parse arguments
# ============================================================
FORMAT="shell"

for arg in "$@"; do
  case "$arg" in
  --format=*)
    FORMAT="${arg#*=}"
    ;;
  esac
done

case "$FORMAT" in
shell | markdown | json | yaml) ;;
*)
  echo "Error: unknown format '$FORMAT'. Use: shell, markdown, json, yaml" >&2
  exit 1
  ;;
esac

# ============================================================
# Metadata database: pkgs.metadata.json + feats/**/metadata.json
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -A META_SCOPE META_DESC META_LICENCE META_REPO META_CATEGORY META_BY_CMD

load_metadata_file() {
  local file="$1"
  local default_scope="$2"
  [ -f "$file" ] || return 0
  while IFS=$'\t' read -r scope name command desc licence repo category; do
    [ -z "$scope" ] && scope="$default_scope"
    META_SCOPE["$name"]="$scope"
    META_DESC["$name"]="$desc"
    META_LICENCE["$name"]="$licence"
    META_REPO["$name"]="$repo"
    META_CATEGORY["$name"]="$category"
    META_BY_CMD["$command"]="$name"
  done < <(jq -r '.[] | "\(.scope // "")\t\(.name)\t\(.command)\t\(.description)\t\(.licence)\t\(.repo_url)\t\(.category)"' "$file")
}

# Load core metadata
load_metadata_file "$SCRIPT_DIR/pkgs.metadata.json" "core"

# Load feature metadata
if [ -d "/nvil/feats" ]; then
  while IFS= read -r -d '' meta_file; do
    load_metadata_file "$meta_file" "pick"
  done < <(find /nvil/feats -name "metadata.json" -type f -print0)
elif [ -d "/workspace/feats" ]; then
  while IFS= read -r -d '' meta_file; do
    load_metadata_file "$meta_file" "pick"
  done < <(find /workspace/feats -name "metadata.json" -type f -print0)
fi

lookup_meta() {
  local name="$1"
  local field="$2"

  local -n target="META_${field}"
  if [[ -n "${target[$name]:-}" ]]; then
    echo "${target[$name]}"
    return 0
  fi

  if [[ -n "${META_BY_CMD[$name]:-}" ]]; then
    local real_name="${META_BY_CMD[$name]}"
    if [[ -n "${target[$real_name]:-}" ]]; then
      echo "${target[$real_name]}"
      return 0
    fi
  fi

  return 1
}

# ============================================================
# Get metadata or fall back to tldr (description only)
# ============================================================
get_description() {
  local name="$1"
  local desc
  if desc=$(lookup_meta "$name" DESC); then
    echo "$desc"
    return
  fi

  local max_depth=5
  local depth=0
  local tldr_cmd="$name"

  while [ $depth -lt $max_depth ]; do
    depth=$((depth + 1))
    desc=$(timeout 3 tldr -q -c "$tldr_cmd" 2>/dev/null | sed -n '2p' | sed 's/^[[:space:]]*//')

    if [ -z "$desc" ]; then
      desc=$(timeout 3 tldr -q "$tldr_cmd" 2>/dev/null | sed -n '2p' | sed 's/^[[:space:]]*//')
    fi

    if echo "$desc" | grep -qi "this command is an alias of"; then
      tldr_cmd=$(echo "$desc" | sed 's/.*alias of[[:space:]]*//' | sed 's/\.$//')
      continue
    fi

    break
  done

  if [ -z "$desc" ]; then
    echo "-"
  else
    echo "$desc"
  fi
}

get_licence() {
  local name="$1"
  local val
  if val=$(lookup_meta "$name" LICENCE); then
    echo "$val"
  else
    echo "-"
  fi
}

get_repo() {
  local name="$1"
  local val
  if val=$(lookup_meta "$name" REPO); then
    echo "$val"
  else
    echo "-"
  fi
}

get_category() {
  local name="$1"
  local val
  if val=$(lookup_meta "$name" CATEGORY); then
    echo "$val"
  else
    echo "-"
  fi
}

get_scope() {
  local name="$1"
  if [[ -n "${META_SCOPE[$name]:-}" ]]; then
    echo "${META_SCOPE[$name]}"
    return
  fi
  if [[ -n "${META_BY_CMD[$name]:-}" ]]; then
    local real_name="${META_BY_CMD[$name]}"
    if [[ -n "${META_SCOPE[$real_name]:-}" ]]; then
      echo "${META_SCOPE[$real_name]}"
      return
    fi
  fi
  echo "-"
}

# ============================================================
# Blacklist: default system packages installed by dnf on a fresh system
# ============================================================
DNF_DEFAULT_BLACKLIST=(
  bash
  bind-utils
  coreutils
  corepack
  dnf5
  fedora-release-container
  fedora-release-common
  fedora-release-identity-container
  filesystem
  gawk
  glibc-minimal-langpack
  gettext
  hostname
  less
  libicu
  iproute
  iputils
  ncurses
  procps-ng
  psmisc
  rpm
  shadow-utils
  sudo
  systemd-standalone-sysusers
  tar
  tini
  util-linux
  util-linux-core
  which
  zsh-autosuggestions
  zsh-syntax-highlighting
  file
  glibc
  glibc-common
  libgcc
  libstdc++
  libzstd
  xz
  zlib-ng-compat
  crypto-policies
  fedora-gpg-keys
  fedora-repos
  setup
  libjodycode
)

declare -A DNF_BLACKLIST_MAP
for pkg in "${DNF_DEFAULT_BLACKLIST[@]}"; do
  DNF_BLACKLIST_MAP["$pkg"]=1
done

is_dnf_default() {
  local name="$1"
  [[ -n "${DNF_BLACKLIST_MAP[$name]:-}" ]] && return 0
  return 1
}

is_blacklisted() {
  local name="$1"
  [[ "$name" == lib* ]] && return 0
  [[ "$name" == *-libs ]] && return 0
  return 1
}

# ============================================================
# Normalize mise tool name: aqua:x/y -> y, github:x/y -> y
# ============================================================
normalize_tool_name() {
  local tool="$1"
  local stripped
  stripped=$(echo "$tool" | sed 's|^[^:]*:||')
  echo "$stripped" | sed 's|.*/||'
}

# ============================================================
# Collect packages into arrays
# ============================================================
declare -a PKG_SCOPES=()
declare -a PKG_NAMES=()
declare -a PKG_VERSIONS=()
declare -a PKG_DESCS=()
declare -a PKG_LICENCES=()
declare -a PKG_REPOS=()
declare -a PKG_CATEGORIES=()
declare -a PKG_MANAGERS=()

add_pkg() {
  local scope="$1" name="$2" version="$3" desc="$4" licence="$5" repo="$6" category="$7" manager="$8"

  PKG_SCOPES+=("$scope")
  PKG_NAMES+=("$name")
  PKG_VERSIONS+=("$version")
  PKG_DESCS+=("$desc")
  PKG_LICENCES+=("$licence")
  PKG_REPOS+=("$repo")
  PKG_CATEGORIES+=("$category")
  PKG_MANAGERS+=("$manager")
}

# --- DNF packages (user-installed only, excluding defaults) ---
if command -v dnf &>/dev/null; then
  while IFS='|' read -r name version; do
    [ -z "$name" ] && continue
    is_dnf_default "$name" && continue
    is_blacklisted "$name" && continue
    scope=$(get_scope "$name")
    desc=$(get_description "$name")
    licence=$(get_licence "$name")
    repo=$(get_repo "$name")
    category=$(get_category "$name")
    add_pkg "$scope" "$name" "$version" "$desc" "$licence" "$repo" "$category" "dnf"
  done < <(dnf repoquery --userinstalled --qf '%{NAME}|%{VERSION}\n' 2>/dev/null | sort -t'|' -k1,1)
fi

# --- Mise packages ---
if command -v mise &>/dev/null; then
  while IFS='|' read -r tool version; do
    [ -z "$tool" ] && continue
    bin_name=$(normalize_tool_name "$tool")
    is_blacklisted "$bin_name" && continue
    scope=$(get_scope "$bin_name")
    desc=$(get_description "$bin_name")
    licence=$(get_licence "$bin_name")
    repo=$(get_repo "$bin_name")
    category=$(get_category "$bin_name")
    add_pkg "$scope" "$bin_name" "$version" "$desc" "$licence" "$repo" "$category" "mise"
  done < <(mise list --current --json 2>/dev/null | jq -r 'to_entries[] | .key as $tool | .value[] | select(.installed and .active) | "\($tool)|\(.version)"')
fi

# --- Brew packages ---
if command -v brew &>/dev/null; then
  while read -r line; do
    [ -z "$line" ] && continue
    name=$(echo "$line" | awk '{print $1}')
    version=$(echo "$line" | awk '{print $2}')
    [ -z "$name" ] && continue
    is_blacklisted "$name" && continue
    scope=$(get_scope "$name")
    desc=$(get_description "$name")
    licence=$(get_licence "$name")
    repo=$(get_repo "$name")
    category=$(get_category "$name")
    add_pkg "$scope" "$name" "$version" "$desc" "$licence" "$repo" "$category" "brew"
  done < <(brew list --versions 2>/dev/null | sort)
fi

# --- npm global packages ---
if command -v npm &>/dev/null; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    pkg_name=$(echo "$line" | sed 's/^[├└│ ─@]*//')
    pkg_version=$(echo "$pkg_name" | grep -oE '@[0-9].*$' | sed 's/^@//')
    pkg_name=$(echo "$pkg_name" | sed 's/@[0-9].*$//')
    [ -z "$pkg_name" ] && continue
    [ -z "$pkg_version" ] && pkg_version="latest"
    is_blacklisted "$pkg_name" && continue
    scope=$(get_scope "$pkg_name")
    desc=$(get_description "$pkg_name")
    licence=$(get_licence "$pkg_name")
    repo=$(get_repo "$pkg_name")
    category=$(get_category "$pkg_name")
    add_pkg "$scope" "$pkg_name" "$pkg_version" "$desc" "$licence" "$repo" "$category" "npm"
  done < <(npm list --global --depth=0 2>/dev/null | grep -E '^[├└]')
fi

# --- pnpm global packages ---
if command -v pnpm &>/dev/null; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    pkg_name=$(echo "$line" | sed 's/^[├└│ ─@]*//')
    pkg_version=$(echo "$pkg_name" | grep -oE '@[0-9].*$' | sed 's/^@//')
    pkg_name=$(echo "$pkg_name" | sed 's/@[0-9].*$//')
    [ -z "$pkg_name" ] && continue
    [ -z "$pkg_version" ] && pkg_version="latest"
    is_blacklisted "$pkg_name" && continue
    scope=$(get_scope "$pkg_name")
    desc=$(get_description "$pkg_name")
    licence=$(get_licence "$pkg_name")
    repo=$(get_repo "$pkg_name")
    category=$(get_category "$pkg_name")
    add_pkg "$scope" "$pkg_name" "$pkg_version" "$desc" "$licence" "$repo" "$category" "pnpm"
  done < <(pnpm --global list 2>/dev/null | grep -E '^[├└]')
fi

# --- Go global packages ---
if command -v go &>/dev/null; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    pkg_name=$(echo "$line" | awk '{print $1}')
    pkg_version=$(echo "$line" | awk '{print $2}')
    [ -z "$pkg_name" ] && continue
    [ -z "$pkg_version" ] && pkg_version="latest"
    is_blacklisted "$pkg_name" && continue
    scope=$(get_scope "$pkg_name")
    desc=$(get_description "$pkg_name")
    licence=$(get_licence "$pkg_name")
    repo=$(get_repo "$pkg_name")
    category=$(get_category "$pkg_name")
    add_pkg "$scope" "$pkg_name" "$pkg_version" "$desc" "$licence" "$repo" "$category" "go"
  done < <(go list -m -json all 2>/dev/null | jq -r 'select(.Main) | "\(.Path) \(.Version)"' 2>/dev/null)
fi

# ============================================================
# Build sorted index
# ============================================================
COUNT=${#PKG_NAMES[@]}

mapfile -t SORTED_INDICES < <(
  for ((i = 0; i < COUNT; i++)); do
    printf '%d\t%s\t%s\t%s\n' "$i" "${PKG_SCOPES[$i]}" "${PKG_CATEGORIES[$i]}" "${PKG_NAMES[$i]}"
  done | sort -t$'\t' -k2,2 -k3,3 -k4,4 -f | cut -f1
)

# ============================================================
# Render: shell (colored)
# ============================================================
render_shell() {
  local MAX_SCOPE=4 MAX_CAT=10 MAX_NAME=4 MAX_VER=7 MAX_DESC=11 MAX_LICENCE=7 MAX_REPO=8 MAX_MGR=7

  for idx in "${SORTED_INDICES[@]}"; do
    len=${#PKG_SCOPES[$idx]}
    ((len > MAX_SCOPE)) && MAX_SCOPE=$len
    len=${#PKG_CATEGORIES[$idx]}
    ((len > MAX_CAT)) && MAX_CAT=$len
    len=${#PKG_NAMES[$idx]}
    ((len > MAX_NAME)) && MAX_NAME=$len
    len=${#PKG_VERSIONS[$idx]}
    ((len > MAX_VER)) && MAX_VER=$len
    len=${#PKG_DESCS[$idx]}
    ((len > MAX_DESC)) && MAX_DESC=$len
    len=${#PKG_LICENCES[$idx]}
    ((len > MAX_LICENCE)) && MAX_LICENCE=$len
    len=${#PKG_REPOS[$idx]}
    ((len > MAX_REPO)) && MAX_REPO=$len
    len=${#PKG_MANAGERS[$idx]}
    ((len > MAX_MGR)) && MAX_MGR=$len
  done

  printf '\n'

  printf "  ${C_BOLD}${C_WHITE}%-*s${C_RESET}  " "$MAX_SCOPE" "Scope"
  printf "${C_BOLD}${C_WHITE}%-*s${C_RESET}  " "$MAX_CAT" "Category"
  printf "${C_BOLD}${C_WHITE}%-*s${C_RESET}  " "$MAX_NAME" "Name"
  printf "${C_BOLD}${C_WHITE}%-*s${C_RESET}  " "$MAX_VER" "Version"
  printf "${C_BOLD}${C_WHITE}%-*s${C_RESET}  " "$MAX_DESC" "Description"
  printf "${C_BOLD}${C_WHITE}%-*s${C_RESET}\n" "$MAX_MGR" "Manager"

  printf "  ${C_DIM}%*s${C_RESET}  " "$MAX_SCOPE" "$(printf '%0.s─' $(seq 1 $MAX_SCOPE))"
  printf "${C_DIM}%*s${C_RESET}  " "$MAX_CAT" "$(printf '%0.s─' $(seq 1 $MAX_CAT))"
  printf "${C_DIM}%*s${C_RESET}  " "$MAX_NAME" "$(printf '%0.s─' $(seq 1 $MAX_NAME))"
  printf "${C_DIM}%*s${C_RESET}  " "$MAX_VER" "$(printf '%0.s─' $(seq 1 $MAX_VER))"
  printf "${C_DIM}%*s${C_RESET}  " "$MAX_DESC" "$(printf '%0.s─' $(seq 1 $MAX_DESC))"
  printf "${C_DIM}%*s${C_RESET}\n" "$MAX_MGR" "$(printf '%0.s─' $(seq 1 $MAX_MGR))"

  for idx in "${SORTED_INDICES[@]}"; do
    scope="${PKG_SCOPES[$idx]}"
    category="${PKG_CATEGORIES[$idx]}"
    name="${PKG_NAMES[$idx]}"
    version="${PKG_VERSIONS[$idx]}"
    desc="${PKG_DESCS[$idx]}"
    manager="${PKG_MANAGERS[$idx]}"

    mgr_color="${MGR_COLORS[$manager]:-$C_RESET}"
    cat_color="${CAT_COLORS[$category]:-$C_RESET}"

    if [ "$scope" = "core" ]; then
      scope_color="$C_CYAN"
    else
      scope_color="$C_MAGENTA"
    fi

    printf "  ${scope_color}%-*s${C_RESET}  " "$MAX_SCOPE" "$scope"
    printf "${cat_color}%-*s${C_RESET}  " "$MAX_CAT" "$category"
    printf "${C_BOLD}%-*s${C_RESET}  " "$MAX_NAME" "$name"
    printf "%-*s  " "$MAX_VER" "$version"
    printf "%-*s  " "$MAX_DESC" "$desc"
    printf "${mgr_color}%-*s${C_RESET}\n" "$MAX_MGR" "$manager"
  done

  printf '\n'
  printf "  ${C_DIM}Total: %d packages${C_RESET}\n" "$COUNT"
  printf '\n'
}

# ============================================================
# Render: markdown
# ============================================================
render_markdown() {
  printf '| %-6s | %-15s | %-30s | %-15s | %-70s | %-15s | %-50s | %-10s |\n' "Scope" "Category" "Name" "Version" "Description" "Licence" "Repo" "Manager"
  printf '| %-6s | %-15s | %-30s | %-15s | %-70s | %-15s | %-50s | %-10s |\n' "------" "---------------" "------------------------------" "---------------" "----------------------------------------------------------------------" "---------------" "--------------------------------------------------" "----------"

  for idx in "${SORTED_INDICES[@]}"; do
    scope="${PKG_SCOPES[$idx]}"
    category="${PKG_CATEGORIES[$idx]}"
    name="${PKG_NAMES[$idx]}"
    version="${PKG_VERSIONS[$idx]}"
    desc="${PKG_DESCS[$idx]}"
    licence="${PKG_LICENCES[$idx]}"
    repo="${PKG_REPOS[$idx]}"
    manager="${PKG_MANAGERS[$idx]}"
    printf '| %-6s | %-15s | %-30s | %-15s | %-70s | %-15s | %-50s | %-10s |\n' "$scope" "$category" "$name" "$version" "$desc" "$licence" "$repo" "$manager"
  done

  printf '\nTotal: %d packages\n' "$COUNT"
}

# ============================================================
# Render: json
# ============================================================
render_json() {
  local first=1
  printf '{\n  "packages": [\n'
  for idx in "${SORTED_INDICES[@]}"; do
    if [ "$first" -eq 1 ]; then
      first=0
    else
      printf ',\n'
    fi
    printf '    {"scope": "%s", "category": "%s", "name": "%s", "version": "%s", "description": "%s", "licence": "%s", "repo": "%s", "manager": "%s"}' \
      "${PKG_SCOPES[$idx]}" \
      "${PKG_CATEGORIES[$idx]}" \
      "${PKG_NAMES[$idx]}" \
      "${PKG_VERSIONS[$idx]}" \
      "$(echo "${PKG_DESCS[$idx]}" | sed 's/"/\\"/g')" \
      "${PKG_LICENCES[$idx]}" \
      "${PKG_REPOS[$idx]}" \
      "${PKG_MANAGERS[$idx]}"
  done
  printf '\n  ],\n  "total": %d\n}\n' "$COUNT"
}

# ============================================================
# Render: yaml
# ============================================================
render_yaml() {
  printf 'packages:\n'
  for idx in "${SORTED_INDICES[@]}"; do
    printf '  - scope: "%s"\n' "${PKG_SCOPES[$idx]}"
    printf '    category: "%s"\n' "${PKG_CATEGORIES[$idx]}"
    printf '    name: "%s"\n' "${PKG_NAMES[$idx]}"
    printf '    version: "%s"\n' "${PKG_VERSIONS[$idx]}"
    printf '    description: "%s"\n' "$(echo "${PKG_DESCS[$idx]}" | sed 's/"/\\"/g')"
    printf '    licence: "%s"\n' "${PKG_LICENCES[$idx]}"
    printf '    repo: "%s"\n' "${PKG_REPOS[$idx]}"
    printf '    manager: "%s"\n' "${PKG_MANAGERS[$idx]}"
  done
  printf 'total: %d\n' "$COUNT"
}

# ============================================================
# Dispatch
# ============================================================
case "$FORMAT" in
shell) render_shell ;;
markdown) render_markdown ;;
json) render_json ;;
yaml) render_yaml ;;
esac

# NVIL Agent Guide

## What is this repo?

NVIL is a containerized terminal-first development environment built on Fedora. It's not a typical code project - the "code" is Dockerfiles, shell scripts, and install scripts that build container images.

## Building images

```bash
# Build full flavor image
sh nvil.img.make.sh --docker-file=./flavors/full.Dockerfile --image=nvil-full:latest

# Build with custom tag
sh nvil.img.make.sh --docker-file=./flavors/my-flavor.Dockerfile --image=nvil-my-flavor:latest
```

The script auto-detects podman (preferred) or docker.

## Development workflow

Use `.dev/` directory for iterative development:

- `.dev/core-dev.make.sh` - build core dev image
- `.dev/full-dev.make.sh` - build full dev image
- `.dev/*-dev.nvil.yaml` - compose files to run containers

## Adding a new tool (feature)

1. Create directory: `feats/<category>/<name>/`
2. Add `<name>.install.sh` - must start with `#!/bin/bash` and `set -euo pipefail`
3. Add `metadata.json` - array with scope, name, command, description, repo_url, licence, packageManager, category (use among existing ones if possible)
4. Register in `flavors/full.Dockerfile`: `COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/<category>/<name> /nvil/.tmp/`

Install script template:

```bash
#!/bin/bash
set -euo pipefail
source /nvil/core/utils/feats.require.sh
mise use -g toolname@latest
# Clean caches (critical for image size depending on package manager used):
mise prune && mise cache clean
brew autoremove && brew cleanup --prune=all
pnpm store prune --force && pnpm cache delete  # for Node tools
go clean -cache -modcache -testcache   # for Go tools
```

## Package managers

| Manager | Use for                                       |
| ------- | --------------------------------------------- |
| dnf     | System packages only (in `core/init/system/`) |
| mise    | Dev tools (preferred)                         |
| brew    | Tools not in mise                             |
| pnpm    | Node.js LSPs and formatters in not in mise    |

## Key directories

| Path       | Purpose                                                |
| ---------- | ------------------------------------------------------ |
| `core/`    | Base Rhel Based image with shell, editors, core tools  |
| `feats/`   | Modular tool features (languages, runtimes, CLI tools) |
| `flavors/` | Dockerfile compositions (core + selected feats)        |
| `.dev/`    | Local dev compose files                                |

## Gotchas

- Always clean caches (mise, brew, go, pnpm) after installations - every MB matters in container images
- Use single-quoted heredocs (`<< 'EOF'`) to prevent variable expansion
- Don't use `dnf` in feature scripts - system packages belong in `core/init/system/`
- Validate JSON with `jq .` before committing
- Scripts must use `set -euo pipefail` - failures must abort the build

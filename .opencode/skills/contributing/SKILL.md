---
name: contributing
description: Contribution guidelines for NVIL - a containerized terminal-first development forge on Fedora Linux - covering feature module creation, development workflow, testing, and pull request standards
license: MIT
---

## What I do

Provide comprehensive contribution guidelines for NVIL, ensuring contributors understand the project architecture, feature module pattern, development workflow, and quality standards.

## Project overview

NVIL (from French "enclume" meaning "anvil") is a portable, terminal-first development environment built on Fedora Linux. It provides a containerized development forge with essential tools for coding, debugging, and shipping software.

- **Repository**: https://github.com/thomaschampagne/nvil
- **License**: MIT
- **Base OS**: Fedora 43 (fedora-minimal)
- **Container registry**: `ghcr.io/thomaschampagne/nvil-core` and `ghcr.io/thomaschampagne/nvil-full`

## Architecture

```
┌─────────────────────────────────────────────────┐
│              nvil-full (Flavor)                  │
│  ┌───────────────────────────────────────────┐  │
│  │         nvil-core (Base Image)             │  │
│  │  ┌─────────────────────────────────────┐  │  │
│  │  │  Fedora 43 minimal                   │  │  │
│  │  │  + DNF system packages               │  │  │
│  │  │  + User creation & sudo config       │  │  │
│  │  │  + Homebrew + mise                   │  │  │
│  │  │  + Core tools (helix, nvim, yazi,   │  │  │
│  │  │    zellij, lazygit, LSPs, formatters)│  │  │
│  │  │  + Git config, Zsh config            │  │  │
│  │  └─────────────────────────────────────┘  │  │
│  │  + Feature modules (Go, Bun, JS/TS, etc.) │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

### Key directories

| Path | Purpose |
|------|---------|
| `core/` | Base image: Dockerfile, bootstrap scripts, init scripts, tool configs |
| `core/init/system/` | System-level setup: DNF packages, user creation, sudo config |
| `core/init/feats/` | Core features: helix, neovim, yazi, zellij, lazygit, LSPs |
| `core/init/res/home/` | Home directory templates (.zshrc, editor configs) |
| `core/utils/` | Helper scripts: `feats.install.sh`, `feats.require.sh` |
| `core/cmd/` | CLI tools: `nvil`, `entrypoint.sh`, `list.pkgs.sh` |
| `feats/` | Modular features (opt-in for flavors) |
| `flavors/` | Image variants that extend core |
| `.dev/` | Local development compose files and build scripts |

## Development setup

### Prerequisites

- Docker or Podman installed on your host
- Nerd Font installed in your terminal for proper icon display

### Build locally

```bash
# Clone the repository
git clone https://github.com/thomaschampagne/nvil.git
cd nvil

# Build the core image
bash nvil.img.make.sh --flavor core

# Build the full image (includes features)
bash nvil.img.make.sh --flavor full
```

### Development mode

Use the `.dev/` directory for iterative development:

```bash
# Build core dev image
bash .dev/core-dev.make.sh

# Run core dev container
podman compose -f .dev/core-dev.nvil.yaml up -d

# Build full dev image
bash .dev/full-dev.make.sh

# Run full dev container
podman compose -f .dev/full-dev.nvil.yaml up -d
```

### Environment variables

```bash
cp .env.sample .env
# Edit .env to customize:
#   NVIL_USER - username inside container (default: smith)
#   NVIL_WORKSPACE_DIR - mounted workspace path (default: ./workspace)
```

### Build arguments

Override defaults in `build-args.default.conf`:

```
NVIL_FEDORA_BASE_VERSION=latest
NVIL_USER=smith
NVIL_WORKSPACE_DIR=/workspace
```

## Adding a new feature

Features are modular components installed during flavor builds. See the full guide below.

### Quick steps

1. Create directory: `feats/<category>/<name>/`
2. Write install script: `<name>.install.sh`
3. Write metadata: `metadata.json`
4. Register in flavor Dockerfile: `COPY --parents ...`
5. Build and test

### Feature module structure

```
feats/<category>/<name>/
├── <name>.install.sh    # Installation script (required)
├── metadata.json        # Package metadata (required)
└── sample/              # Example code (optional)
```

### Install script requirements

```bash
#!/bin/bash

set -euo pipefail

# Load requirements (brew + mise in PATH)
source /nvil/core/utils/feats.require.sh

# Install your tool
mise use -g toolname@latest

# Clean caches (critical for image size)
# go clean -cache -modcache -testcache     # for Go tools
# pnpm store prune --force                 # for pnpm packages
# pnpm cache delete

# Helix language config (if applicable)
cat >> ~/.config/helix/languages.toml << 'EOF'
[[language]]
name = "toolname"
auto-format = true
EOF
```

### Metadata format

```json
[
  {
    "scope": "pick",
    "name": "toolname",
    "command": "toolname",
    "description": "One-line description",
    "repo_url": "https://github.com/org/repo",
    "licence": "MIT",
    "packageManager": "mise",
    "category": "search"
  }
]
```

### Register in flavor

Add to `flavors/full.Dockerfile`:

```dockerfile
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/<category>/<name> /nvil/.tmp/
```

## Pull request workflow

### Branch naming

```
feat/add-python-support
fix/go-lsp-config
docs/update-readme
ci/add-shellcheck
refactor/extract-bootstrap-logic
```

### Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat(go): add delve debugger support
fix(helix): correct yaml-language-server config
docs(readme): add architecture diagram
ci(workflow): add shellcheck linting
refactor(core): extract user setup from bootstrap
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `build`, `revert`

### PR checklist

- [ ] Feature module follows the established pattern (`*.install.sh` + `metadata.json`)
- [ ] Install script uses `set -euo pipefail`
- [ ] Install script sources `/nvil/core/utils/feats.require.sh`
- [ ] Caches are cleaned after installations (go, pnpm)
- [ ] `metadata.json` is valid JSON with all required fields
- [ ] Feature is registered in the flavor Dockerfile
- [ ] Image builds successfully locally (`bash nvil.img.make.sh --flavor full`)
- [ ] Commit messages follow Conventional Commits
- [ ] No secrets or credentials in any files
- [ ] `.gitignore` is respected (no `.env` files committed)

### Opening a PR

1. Fork the repository
2. Create a feature branch from `main`
3. Make changes with descriptive commits
4. Build the image locally to verify it works
5. Push and open a draft PR early for feedback
6. Address review comments, mark ready for review
7. Maintainer merges after CI passes and approval

## Code conventions

### Bash scripts

- Always start with `#!/bin/bash` and `set -euo pipefail`
- Use `local` for all function variables
- Quote all variable expansions: `"$variable"`
- Use `[[ ]]` over `[ ]` for conditionals
- Use `$(cmd)` over backticks
- Functions over inline code for reusable logic
- No `eval` unless absolutely necessary and documented

### JSON files

- 2-space indentation (per `.editorconfig`)
- Trailing newline at end of file
- Valid JSON - validate with `jq .` before committing

### Configuration files

- Follow existing patterns in `core/init/res/home/.config/`
- Use TOML for Helix config, KDL for Zellij, YAML for Lazygit
- No hardcoded usernames - use `${NVIL_USER}` or environment variables

### Dockerfiles

- Pin base image versions
- Use multi-stage builds where applicable
- Combine RUN commands to reduce layers
- Clean package manager caches in the same layer
- Use `COPY --chown` to avoid extra chown layers

## Testing

### Manual testing

After building the image:

```bash
# Run the container
podman run -it --rm ghcr.io/thomaschampagne/nvil-full:latest zsh

# Verify your feature is installed
toolname --version

# Check metadata was merged
cat /nvil/core/cmd/pkgs.metadata.json | jq '.[] | select(.name == "toolname")'

# Verify Helix recognizes the language
hx --health toolname
```

### Dev container iteration

For faster iteration during development:

```bash
# Build dev image
bash .dev/full-dev.make.sh

# Run with workspace mounted
podman compose -f .dev/full-dev.nvil.yaml up -d

# Enter the container
podman exec -it nvil-full-dev zsh

# After making changes to install scripts, rebuild and re-run
```

## Design principles

1. **Immutability** - Base image is rebuilt rather than patched in place
2. **Modularity** - Features can be added/removed independently
3. **Reproducibility** - Fixed build dates and versions
4. **User consistency** - Same environment across machines
5. **Terminal optimization** - Keyboard-driven, minimal GUI dependencies
6. **Security** - Non-root user by default, minimal attack surface
7. **Image size** - Every MB matters; clean all caches after installations

## Package managers

| Manager | Scope | Use for |
|---------|-------|---------|
| **DNF** | System | Core OS packages (gcc, curl, jq, etc.) - in `core/init/system/` only |
| **mise** | Dev tools | Version-managed tools (go, node, bun, fzf, helix, etc.) - preferred for features |
| **pnpm** | Node.js | LSP servers and formatters written in Node.js |
| **Homebrew** | CLI tools | Tools not available in mise |

## Common tasks

### Add an LSP server for an existing language

If the language is already installed, you only need the LSP:

```bash
# In an existing feature's install.sh
pnpm add -g typescript-language-server
# or
go install golang.org/x/tools/gopls@latest
```

Then append to `~/.config/helix/languages.toml` and add a metadata entry.

### Add a formatter

```bash
# For dprint-supported formats
dprint add --global formatname

# For standalone formatters
go install mvdan.cc/gofumpt@latest
npm i -g prettier
```

Configure in Helix:

```bash
cat >> ~/.config/helix/languages.toml << 'EOF'
[[language]]
name = "mylang"
formatter = { command = "formatter-cmd", args = ["--stdin"] }
auto-format = true
EOF
```

### Add a CLI tool

```bash
mise use -g toolname@latest
```

Add metadata entry with `category` matching the tool's purpose.

### Debug a failing install script

```bash
# Run the script manually inside a container
podman run -it --rm ghcr.io/thomaschampagne/nvil-core:latest zsh
bash /nvil/core/utils/feats.install.sh --features-folder /path/to/features
```

## Getting help

- [Discussions](https://github.com/thomaschampagne/nvil/discussions) - questions and ideas
- [Issues](https://github.com/thomaschampagne/nvil/issues) - bug reports and feature requests
- [AGENT.md](./AGENT.md) - AI agent codebase summary

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

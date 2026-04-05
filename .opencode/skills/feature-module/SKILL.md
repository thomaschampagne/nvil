---
name: feature-module
description: Create new feature modules for NVIL following the established pattern with install scripts, metadata.json, Helix language config, and proper cleanup for container image optimization
license: MIT
---

## What I do

Guide the creation of new feature modules in the `feats/` directory following NVIL's established conventions for install scripts, metadata, editor configuration, and image size optimization.

## Feature module structure

Every feature module lives under `feats/<category>/<name>/` and contains:

```
feats/<category>/<name>/
├── <name>.install.sh    # Installation script (required)
├── metadata.json        # Package metadata (required)
└── sample/              # Example code (optional)
    └── ...
```

### Categories

| Category | Path | Examples |
|----------|------|----------|
| `languages` | `feats/languages/<name>/` | golang, dockerfile, js-ts |
| `runtimes` | `feats/runtimes/<name>/` | bun, node, python |
| `tools/search` | `feats/tools/search/<name>/` | fzf, sd, ripgrep |
| `tools/network` | `feats/tools/network/<name>/` | xh, curl, httpie |
| `tools/system` | `feats/tools/system/<name>/` | procs, btop, htop |
| `frameworks` | `feats/frameworks/<name>/` | react, angular, vue |
| `devops` | `feats/devops/<name>/` | terraform, kubectl, helm |

## metadata.json

Required. An array of package entries that get merged into `/nvil/core/cmd/pkgs.metadata.json` during build.

```json
[
  {
    "scope": "pick",
    "name": "package-name",
    "command": "cmd",
    "description": "One-line description of what this tool does",
    "repo_url": "https://github.com/org/repo",
    "licence": "MIT",
    "packageManager": "mise",
    "category": "language"
  }
]
```

### Fields

| Field | Required | Values | Description |
|-------|----------|--------|-------------|
| `scope` | Yes | `core` or `pick` | `core` = always included, `pick` = opt-in feature |
| `name` | Yes | string | Package/tool name |
| `command` | Yes | string | Command to verify installation |
| `description` | Yes | string | Human-readable description |
| `repo_url` | Yes | URL | Upstream repository |
| `licence` | Yes | SPDX identifier | MIT, GPL-3.0, Apache-2.0, BSD-3-Clause, ISC, etc. |
| `packageManager` | Yes | `dnf`, `mise`, `pnpm`, `brew` | How the package is installed |
| `category` | Yes | string | Logical grouping: `language`, `language-server`, `runtimes`, `search`, `network`, `system`, `formatter`, `devops` |

### Multiple entries per feature

A single feature can install multiple tools and list them all:

```json
[
  {
    "scope": "pick",
    "name": "go",
    "command": "go",
    "description": "Open source programming language",
    "repo_url": "https://github.com/golang/go",
    "licence": "BSD-3-Clause",
    "packageManager": "mise",
    "category": "language"
  },
  {
    "scope": "check",
    "name": "gopls",
    "command": "gopls",
    "description": "Go language server",
    "repo_url": "https://github.com/golang/tools/tree/master/gopls",
    "licence": "BSD-3-Clause",
    "packageManager": "go",
    "category": "language-server"
  },
  {
    "scope": "check",
    "name": "gofumpt",
    "command": "gofumpt",
    "description": "Strict Go formatter",
    "repo_url": "https://github.com/mvdan/gofumpt",
    "licence": "BSD-3-Clause",
    "packageManager": "go",
    "category": "formatter"
  }
]
```

## Install script

Required. Named `<name>.install.sh`. Must be executable.

### Template

```bash
#!/bin/bash

set -euo pipefail

# Load requirements (brew + mise in PATH)
source /nvil/core/utils/feats.require.sh

# --- Install the tool ---
mise use -g toolname@latest

# --- Install LSP servers, formatters, debuggers ---
go install golang.org/x/tools/gopls@latest
go install mvdan.cc/gofumpt@latest

# --- Clean caches to reduce image size ---
go clean -cache -modcache -testcache

# --- Helix language config ---
cat >> ~/.config/helix/languages.toml << 'EOF'
[[language]]
name = "toolname"
auto-format = true
formatter = { command = "gofumpt" }
language-servers = ["gopls"]

[language-server.gopls.config]
go.fumpt = true
EOF
```

### Package manager patterns

#### mise (preferred for dev tools)

```bash
mise use -g toolname@latest
# or pin version
mise use -g toolname@1.23
```

#### pnpm (for Node.js LSP servers and formatters)

```bash
pnpm add -g dockerfile-language-server-nodejs

# Force pnpm store prune --force
pnpm store prune --force
pnpm cache delete
```

#### dnf (for system packages - should be in core init, not features)

```bash
# Generally avoid dnf in features - use core/init/system/main.install.sh instead
# If absolutely necessary:
sudo dnf install -y package-name
```

#### go install (for Go-based tools)

```bash
go install github.com/user/tool@latest

# Clean cache after
go clean -cache -modcache -testcache
```

#### brew (for CLI tools not in mise)

```bash
brew install toolname
```

### Helix language config

Append to `~/.config/helix/languages.toml` using heredoc with single-quoted delimiter to prevent variable expansion:

```bash
cat >> ~/.config/helix/languages.toml << 'EOF'
[[language]]
name = "go"
auto-format = true
formatter = { command = "gofumpt" }
language-servers = ["gopls"]

[language-server.gopls.config]
gofumpt = true
staticcheck = true
usePlaceholders = true
EOF
```

#### dprint formatter

```bash
cat >> ~/.config/helix/languages.toml << 'EOF'
[[language]]
name = "dockerfile"
formatter = { command = "dprint", args = ["fmt", "--stdin", "dockerfile"] }
auto-format = true
EOF
```

### Shell configuration

Append to `~/.zshrc` when needed:

```bash
echo -e '\n# Append BunJS configuration' >> ~/.zshrc
echo 'export PATH=$PATH:/home/${USERNAME}/.bun/bin' >> ~/.zshrc
```

### Feature dependencies

If a feature requires another feature to be present:

```bash
#!/bin/bash

set -euo pipefail

source /nvil/core/utils/feats.require.sh

# Require another feature (path relative to current script)
require_feature "../other-feature/other-feature.install.sh"

# Now install this feature knowing the dependency is met
mise use -g mytool@latest
```

## Cleanup rules (critical for image size)

Every install script must clean up after itself:

### Go

```bash
go clean -cache -modcache -testcache
```

### pnpm

```bash
pnpm store prune --force
pnpm cache delete
```

### mise

The `feats.install.sh` runner handles this after all scripts run:

```bash
mise reshim
mise cache clear
```

### brew

Also handled by the runner:

```bash
brew autoremove
brew cleanup --prune=all
```

## Registering the feature in a flavor

Add a COPY line to the flavor Dockerfile (`flavors/full.Dockerfile`):

```dockerfile
# Go Language
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/languages/golang /nvil/.tmp/
```

The `--parents` flag preserves the directory structure. The feature folder is copied to `/nvil/.tmp/` where `feats.install.sh` discovers and runs it.

## Complete examples

### Simple tool (fzf)

`feats/tools/search/fzf/fzf.install.sh`:
```bash
#!/bin/bash

set -euo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g fzf
```

`feats/tools/search/fzf/metadata.json`:
```json
[
  {
    "scope": "pick",
    "name": "fzf",
    "command": "fzf",
    "description": "A command-line fuzzy finder",
    "repo_url": "https://github.com/junegunn/fzf",
    "licence": "MIT",
    "packageManager": "mise",
    "category": "search"
  }
]
```

### Language with LSP + formatter (Go)

`feats/languages/golang/go.install.sh`:
```bash
#!/bin/bash

set -euo pipefail

source /nvil/core/utils/feats.require.sh

# Install runtime
mise use -g go@latest && eval "$(~/.local/bin/mise activate bash)"

# Install LSP, debugger, formatter
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install mvdan.cc/gofumpt@latest

# Clean cache
go clean -cache -modcache -testcache

# Helix config
cat >> ~/.config/helix/languages.toml << 'EOF'
[[language]]
name = "go"
auto-format = true
formatter = { command = "gofumpt" }
language-servers = ["gopls"]

[language-server.gopls.config]
gofumpt = true
staticcheck = true
vulncheck = "Imports"
usePlaceholders = true
completeUnimported = true
EOF
```

### LSP only (Dockerfile)

`feats/languages/dockerfile/docker_file.install.sh`:
```bash
#!/bin/bash

set -euo pipefail

source /nvil/core/utils/feats.require.sh

# Install LSP
pnpm add -g dockerfile-language-server-nodejs

# Clean pnpm
pnpm store prune --force
pnpm cache delete

# Add formatter
dprint add --global dockerfile

# Helix config
cat >>~/.config/helix/languages.toml <<'EOF'
[[language]]
name = "dockerfile"
formatter = { command = "dprint", args = ["fmt", "--stdin", "dockerfile"] }
auto-format = true
EOF
```

### Runtime with shell config (Bun)

`feats/runtimes/bun/bun.install.sh`:
```bash
#!/bin/bash

set -euo pipefail

source /nvil/core/utils/feats.require.sh

# Install runtime
mise use -g bun@latest

# Configure shell
echo -e '\n# Append BunJS configuration' >> ~/.zshrc
echo 'export PATH=$PATH:/home/${USERNAME}/.bun/bin' >> ~/.zshrc
```

## Checklist for new features

- [ ] Directory created under correct `feats/<category>/<name>/` path
- [ ] `<name>.install.sh` starts with `#!/bin/bash` and `set -euo pipefail`
- [ ] Script sources `/nvil/core/utils/feats.require.sh`
- [ ] Tool installed via appropriate package manager (mise preferred)
- [ ] LSP servers, formatters, debuggers installed if applicable
- [ ] Helix language config appended if applicable
- [ ] Caches cleaned (go, pnpm) to reduce image size
- [ ] `metadata.json` is a valid JSON array with all required fields
- [ ] `scope` is `pick` (not `core` - core is for base image packages)
- [ ] `packageManager` matches how the tool is actually installed
- [ ] Feature registered in flavor Dockerfile with `COPY --parents`
- [ ] Sample code included if it helps users understand the feature

## Anti-patterns

- Never skip `set -euo pipefail` - failures must abort the build
- Never leave caches uncleared - every MB matters in container images
- Never use `dnf` in feature scripts - system packages belong in `core/init/system/main.install.sh`
- Never use unquoted heredoc delimiters (`<< EOF` instead of `<< 'EOF'`) - variables will expand unexpectedly
- Never forget to source `feats.require.sh` - brew and mise won't be in PATH
- Never hardcode `/home/smith` - use `/home/${USERNAME}` or `~`
- Never add a feature without registering it in the flavor Dockerfile
- Never use `scope: "core"` for features - that's reserved for base image packages

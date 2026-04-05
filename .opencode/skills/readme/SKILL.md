---
name: readme
description: Create state-of-the-art README files in current year that serve both new users exploring a repository on GitHub and developers contributing via pull requests, with clear structure, visual hierarchy, and actionable content
license: MIT
---

## What I do

Write production-grade README files that instantly orient new visitors, provide developers with everything needed to contribute, and serve as the authoritative project documentation entry point.

## Structure

A complete README follows this order:

```
1. Project name + badge bar
2. One-line value proposition
3. Visual (screenshot/demo/diagram)
4. Quick start (under 2 minutes)
5. Features / capabilities
6. Architecture overview
7. Installation
8. Usage (with examples)
9. Configuration
10. API reference (or link)
11. Contributing guide (or link)
12. Project structure
13. Testing
14. Deployment
15. Troubleshooting / FAQ
16. Roadmap
17. License
18. Community / contact
```

## Badge bar

Place badges immediately after the title. Use shields.io with consistent styling. Group logically.

```markdown
![Version](https://img.shields.io/badge/version-2.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Python](https://img.shields.io/badge/python-3.12+-3776AB)
![CI](https://img.shields.io/github/actions/workflow/status/org/repo/ci.yml?label=build)
![Coverage](https://img.shields.io/codecov/c/github/org/repo)
![Downloads](https://img.shields.io/pypi/dm/package-name)
```

Rules:
- Maximum 8 badges - prioritize signal over decoration
- Always include: version, license, build status, language/runtime
- Use real data (GitHub Actions, Codecov, etc.), not static placeholders
- Group by category: project · status · ecosystem

## Hero section

### Title + tagline

```markdown
# ProjectName

> A concise, specific description of what this does and for whom. Avoid buzzwords.
```

### Visual proof

Include one of:
- **Screenshot** for UI/CLI tools: `![Screenshot](docs/screenshots/overview.png)`
- **Architecture diagram** for libraries/services: `![Architecture](docs/diagrams/architecture.svg)`
- **Animated GIF** for interactive tools: `![Demo](docs/demo.gif)`
- **Terminal recording** (asciinema/terminalizer) for CLIs

Place the visual immediately after the tagline. No preamble.

## Quick start

The fastest path to a working result. Must complete in under 2 minutes.

```markdown
## Quick Start

```bash
# Install
pip install package-name

# Run
package-name --config config.yml

# Verify
package-name --health
```

That's it. See [Usage](#usage) for detailed examples.
```

Rules:
- Copy-paste commands only - no explanation in this section
- Use the most common/default configuration
- Show a verifiable result ("Verify" step confirms it worked)
- Link to deeper sections, don't expand here

## Features

Use a scannable list with concrete outcomes, not marketing language.

```markdown
## Features

- **Hot reloading** - Changes apply in <50ms without restart
- **Zero-config TLS** - Automatic certificate provisioning via ACME
- **Multi-tenant RBAC** - Per-organization roles with SSO integration
- **Structured logging** - JSON output with correlation IDs, ready for Datadog/Loki
- **Graceful shutdown** - Drains connections with configurable timeout
- **Health endpoints** - `/health`, `/ready`, `/live` for Kubernetes probes
```

Rules:
- Each feature: **name** - concrete benefit with numbers where possible
- No vague claims like "blazing fast" or "enterprise-grade"
- Order by user value, not implementation order
- 5-8 features maximum - link to full feature matrix if more

## Architecture overview

Provide a mental model before details.

```markdown
## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Client    │────▶│   Gateway    │────▶│   Service   │
│  (Browser)  │◀────│  (Reverse    │◀────│   (App)     │
└─────────────┘     │   Proxy)     │     └──────┬──────┘
                    └──────────────┘            │
                                                ▼
                                         ┌─────────────┐
                                         │  Database   │
                                         │  (Postgres) │
                                         └─────────────┘
```

| Component   | Technology    | Responsibility                    |
|-------------|---------------|-----------------------------------|
| Gateway     | Caddy         | TLS termination, rate limiting    |
| Service     | Go 1.23       | Business logic, API               |
| Database    | PostgreSQL 16 | Persistent storage, migrations    |
| Cache       | Redis 7       | Session store, rate limit counter |
| Queue       | NATS          | Async job processing              |
```

Rules:
- ASCII diagrams for simple architectures (render everywhere)
- Mermaid diagrams for complex flows (GitHub renders natively)
- Always include a component table with technology and responsibility
- Keep at one level of abstraction - no internal module details here

## Installation

Provide paths for every supported platform/method.

```markdown
## Installation

### Package manager (recommended)

```bash
brew install org/tap/package-name    # macOS
apt install package-name              # Debian/Ubuntu
```

### Binary download

```bash
curl -fsSL https://example.com/install.sh | sh
# Or download directly:
curl -Lo package-name https://github.com/org/repo/releases/latest/download/package-name-linux-amd64
chmod +x package-name
sudo mv package-name /usr/local/bin/
```

### From source

```bash
git clone https://github.com/org/repo.git
cd repo
make build
```

### Docker

```bash
docker pull ghcr.io/org/repo:latest
docker run -p 8080:8080 ghcr.io/org/repo:latest
```
```

Rules:
- Mark the recommended method
- Include all supported platforms
- Pin versions in production examples
- Provide checksums for binary downloads
- Docker image should include registry, not just Docker Hub

## Usage

Show, don't tell. Use progressive disclosure.

```markdown
## Usage

### Basic

```bash
# Start with defaults
package-name

# Start with custom config
package-name --config /etc/app/config.yml
```

### Common patterns

```bash
# Run as daemon
package-name start --daemon

# Run with specific log level
package-name --log-level debug

# Dry run (show what would happen)
package-name deploy --dry-run
```

### Advanced

```bash
# Pipe input from another command
cat events.jsonl | package-name process --format jsonl

# Run with environment-specific overrides
APP_ENV=production package-name --config config.yml --config config.prod.yml
```

For the full CLI reference, see [CLI Reference](docs/cli.md).
```

Rules:
- Start with the simplest possible example
- Group by complexity: basic → common → advanced
- Every example must be runnable (or clearly marked as illustrative)
- Show output when non-obvious: `# → {"status": "ok"}`
- Link to detailed docs, don't duplicate them

## Configuration

```markdown
## Configuration

### Environment variables

| Variable          | Required | Default      | Description                    |
|-------------------|----------|--------------|--------------------------------|
| `APP_PORT`        | No       | `8080`       | HTTP listen port               |
| `APP_LOG_LEVEL`   | No       | `info`       | Log level (debug\|info\|warn)  |
| `DB_URL`          | Yes      | -            | PostgreSQL connection string   |
| `REDIS_URL`       | No       | `redis://localhost:6379` | Redis connection URL   |

### Config file

```yaml
# config.yml
server:
  port: 8080
  host: "0.0.0.0"

database:
  url: "postgres://user:pass@localhost:5432/db"
  max_open_conns: 25

logging:
  level: info
  format: json
```

Config precedence (highest to lowest): CLI flags → environment variables → config file → defaults.
```

Rules:
- Table format for environment variables
- Show a complete example config file
- Document precedence/override order explicitly
- Mark required vs optional clearly
- Link to full config schema if available

## Contributing

For large projects, link to a separate `CONTRIBUTING.md`. For smaller projects, include inline.

```markdown
## Contributing

Contributions are welcome. Here's how to get started:

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/repo.git
cd repo

# Set up development environment
make dev

# Run tests
make test

# Run linter
make lint
```

### Pull request checklist

- [ ] Tests added/updated for new behavior
- [ ] `make test` passes locally
- [ ] `make lint` passes with no errors
- [ ] Documentation updated (README, config, CLI help)
- [ ] Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
- [ ] Changelog entry added (if user-facing change)

### Development workflow

1. Create a feature branch from `main`
2. Make your changes with descriptive commits
3. Push and open a draft PR early for feedback
4. Address review comments, mark ready for review
5. Maintainer merges after CI passes and approval

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on coding standards, commit conventions, and release process.
```

Rules:
- Include copy-paste setup commands
- PR checklist must be specific and checkable
- Show the full workflow from fork to merge
- Link to detailed contributing guide if one exists
- Mention commit convention if the project uses one

## Project structure

```markdown
## Project Structure

```
├── cmd/                    # CLI entry points
│   └── server/             #   Main server command
├── internal/               # Private application code
│   ├── api/                #   HTTP handlers and routing
│   ├── auth/               #   Authentication and authorization
│   ├── config/             #   Configuration loading and validation
│   ├── db/                 #   Database queries and migrations
│   └── service/            #   Business logic
├── pkg/                    # Public library code
├── web/                    # Frontend application
├── deploy/                 # Deployment configs (Docker, K8s, etc.)
├── docs/                   # Documentation
├── test/                   # Integration and E2E tests
├── Makefile                # Build and development commands
├── config.example.yml      # Example configuration
└── README.md               # You are here
```
```

Rules:
- Only include directories with meaningful content
- Add one-line descriptions aligned to the right
- Use tree format for consistency
- Update when the structure changes significantly

## Testing

```markdown
## Testing

```bash
# All tests
make test

# Unit tests only
make test-unit

# Integration tests (requires Docker)
make test-integration

# With coverage
make test-coverage
# → opens coverage report in browser
```

### Writing tests

- Unit tests live alongside source: `internal/api/handler_test.go`
- Integration tests in `test/integration/`
- Use table-driven tests for multiple cases
- Mock external dependencies with generated mocks (`mockgen`)
```

## Troubleshooting

```markdown
## Troubleshooting

### Common issues

**Connection refused on startup**
→ Check that `DB_URL` is set and the database is reachable: `nc -zv db-host 5432`

**High memory usage**
→ Set `GOMEMLIMIT` (Go 1.19+): `GOMEMLIMIT=512MiB package-name`

**TLS certificate errors**
→ Run `package-name tls provision` to auto-provision via ACME

### Getting help

- [Documentation](https://docs.example.com)
- [Discussions](https://github.com/org/repo/discussions)
- [Issues](https://github.com/org/repo/issues) - bug reports and feature requests
```

Rules:
- Address the top 3-5 most common problems
- Each issue: symptom → exact fix command
- Include where to get help

## Roadmap

```markdown
## Roadmap

- [ ] **v2.2** - gRPC support, OpenTelemetry native export
- [ ] **v2.3** - Plugin system with WASM runtime
- [ ] **v3.0** - Multi-cluster federation

See [GitHub Issues](https://github.com/org/repo/issues) for the full backlog.
```

Rules:
- Only include committed/planned items
- Use version markers, not dates
- Keep to 3-5 items - link to full backlog
- Mark completed items or remove them

## Formatting rules

### Markdown conventions

- Use ATX headers (`#`, `##`, `###`) - never setext (`===`, `---`)
- One blank line between sections
- Two blank lines before `##` headers
- Code blocks always specify language: ` ```bash `, not ` ``` `
- Use `→` for output/continuation in code comments
- Use `#` for inline comments in code blocks
- Bold for UI elements: **Settings**, **Save**
- Backticks for code, filenames, commands: `config.yml`, `make build`
- Tables for structured data (config, comparison, requirements)
- When mentioning external site add link with `[Site Name](https://...)`

### Readability

- Sentences under 25 words where possible
- Paragraphs under 4 lines
- Lists over prose when enumerating
- Active voice: "Run the command" not "The command should be run"
- No filler sections - if a section has no content, remove it
- Every link must work - test all URLs before finalizing

### GitHub-specific features

- Use `<details>` for collapsible content (long logs, full configs)
- Use GitHub-native Mermaid diagrams for flows:

```markdown
```mermaid
sequenceDiagram
    Client->>Gateway: HTTPS request
    Gateway->>Service: Forward with auth header
    Service->>Database: Query
    Database-->>Service: Result
    Service-->>Gateway: Response
    Gateway-->>Client: JSON response
```

- Use GitHub issue/PR linking: `#123`, `@username`
- Use relative links for internal docs: `./docs/api.md`
- Use absolute links for external docs

## Anti-patterns to avoid

- Never start with "Welcome to..." or "Thank you for your interest"
- Never include a table of contents for READMEs under 30 sections (GitHub auto-generates one)
- Never use badges that don't link to live data
- Never write installation instructions that don't work when copy-pasted
- Never omit the license section
- Never include TODO comments in a README
- Never use screenshots with sensitive data visible
- Never write a README longer than 200 lines - link to detailed docs instead
- Never assume the reader knows your internal terminology - define acronyms on first use
- Never leave broken links - use a link checker in CI

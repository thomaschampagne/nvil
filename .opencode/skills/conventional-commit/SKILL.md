---
name: conventional-commit
description: Create conventional commits following the project's commit message convention with type, scope, breaking change indicator, description, body, and ticket reference
license: MIT
---

## What I do

Create git commits that follow the Conventional Commits specification with the project's custom scopes and formatting rules.

## Commit format

```
type(scope)(!): description (#ticket)

[optional body]

refers to #ticket
```

## Types

- **feat** - A new feature
- **fix** - A bug fix
- **build** - Changes that affect the build system or external dependencies
- **chore** - Other changes that don't modify src or test files
- **ci** - Changes to CI configuration files and scripts
- **docs** - Documentation only changes
- **perf** - A code change that improves performance
- **refactor** - A code change that neither fixes a bug nor adds a feature
- **revert** - Reverts a previous commit
- **style** - Changes that do not affect the meaning of the code
- **test** - Adding missing tests or correcting existing tests

## Scopes

- **ui** - Frontend application or UI components
- **db** - Database schema, queries, migrations, or connection logic
- **api** - REST controllers, endpoints, API service logic, ORM persistence
- **auth** - Authentication and authorization, tokens, sessions, permissions
- **style** - Styling, themes, layout, or linting
- **core** - Core business logic, domain models, or application logic
- **shared** - Shared code, libraries, or utilities used by both frontend and backend
- **ci** - CI/CD pipeline configuration
- **docs** - Documentation updates, READMEs, inline docs
- **ai** - AI/ML models, prompts, embeddings, or LLM integration
- **config** - Configuration files, settings, or environment variables
- **types** - Type definitions, interfaces, or type safety improvements
- **security** - Security fixes, vulnerabilities
- **devops** - DevOps, infrastructure, Docker, Kubernetes, deployment
- **tools** - Development tools, scripts, CLIs, or utilities

## Rules

- Description must be short and meaningful (10 words max)
- Use imperative mood in description (e.g., "add" not "added")
- Do not capitalize the first letter of the description
- No period at the end of the description
- Scope is optional - omit parentheses if not applicable
- Breaking changes: append `!` after type/scope and add `BREAKING CHANGE: ` prefix to body
- Ticket references: append ` (#<number>)` to subject line and add `refers to #<number>` as a separate commit message line
- Body is optional but recommended for complex changes

## Examples

```
feat(api): add user authentication endpoint (#123)

Implement JWT-based auth with refresh token rotation.

refers to #123
```

```
fix(ui)!: resolve layout shift on mobile viewports
```

```
chore: update dependencies
```

```
refactor(core): extract payment validation logic

Move validation rules into shared utility module.

refers to #456
```

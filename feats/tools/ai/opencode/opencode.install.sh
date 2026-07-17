#!/bin/bash

# Description: AI coding assistant for the terminal.
# Repo Link: https://github.com/anomalyco/opencode

set -eo pipefail

source /nvil/core/utils/feats.require.sh

mise use -g opencode

# Clean caches
mise prune && mise cache clean

# Re-export mise PATH
eval "$(~/.local/bin/mise activate bash)" # Reactivate mise for usage

# ─────────────────────────────────────────────
# Meta / Discovery
# ─────────────────────────────────────────────
npx --yes skills add https://github.com/vercel-labs/skills --skill find-skills --global --yes --agent opencode        # Find the right skill for any task
npx --yes skills add https://github.com/mattpocock/skills --skill writing-great-skills --global --yes --agent opencode       # Create your own custom skills

# ─────────────────────────────────────────────
# Architecture & Code Quality
# ─────────────────────────────────────────────
npx --yes skills add https://github.com/mattpocock/skills --skill improve-codebase-architecture --global --yes --agent opencode  # Refactor & structure codebases
npx --yes skills add https://github.com/mattpocock/skills --skill codebase-design --global --yes --agent opencode                # Design decisions & patterns
npx --yes skills add https://github.com/mattpocock/skills --skill domain-modeling --global --yes --agent opencode                # Model business domains cleanly
npx --yes skills add https://github.com/mattpocock/skills --skill tdd --global --yes --agent opencode                            # Test-driven development workflow
npx --yes skills add https://github.com/alirezarezvani/claude-skills --skill caveman --global --yes --agent opencode                        # Write minimal, obvious code first
npx --yes skills add https://github.com/mattpocock/skills --skill diagnosing-bugs --global --yes --agent opencode                # Systematic bug diagnosis
npx --yes skills add https://github.com/github/awesome-copilot --skill diagnose --global --yes --agent opencode                       # General issue diagnosis
npx --yes skills add https://github.com/obra/superpowers --skill systematic-debugging --global --yes --agent opencode            # Deep debugging superpowers
npx --yes skills add https://github.com/roin-orca/skills --skill simple --global --yes --agent opencode                          # Keep complexity ruthlessly low

# ─────────────────────────────────────────────
# Frontend & Design
# ─────────────────────────────────────────────
npx --yes skills add https://github.com/anthropics/skills --skill frontend-design --global --yes --agent opencode                         # Anthropic's UI design guidelines
npx --yes skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices --global --yes --agent opencode      # React best practices
npx --yes skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines --global --yes --agent opencode            # Web design principles
npx --yes skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max --global --yes --agent opencode        # Advanced UI/UX patterns
npx --yes skills add https://github.com/leonxlnx/taste-skill --skill design-taste-frontend --global --yes --agent opencode                # Frontend design taste & aesthetics

# ─────────────────────────────────────────────
# Workflow & Planning
# ─────────────────────────────────────────────
npx --yes skills add https://github.com/mattpocock/skills --skill to-tickets --global --yes --agent opencode         # Break PRDs into actionable issues
npx --yes skills add https://github.com/mattpocock/skills --skill prototype --global --yes --agent opencode         # Build rapid prototypes
npx --yes skills add https://github.com/mattpocock/skills --skill triage --global --yes --agent opencode            # Triage tasks and issues
npx --yes skills add https://github.com/mattpocock/skills --skill implement --global --yes --agent opencode         # Structured implementation workflow
npx --yes skills add https://github.com/mattpocock/skills --skill handoff --global --yes --agent opencode           # Hand off tasks/context cleanly
npx --yes skills add https://github.com/obra/superpowers --skill writing-plans --global --yes --agent opencode      # Write thorough plans before coding
npx --yes skills add https://github.com/obra/superpowers --skill executing-plans --global --yes --agent opencode    # Execute plans step by step

# ─────────────────────────────────────────────
# Testing, Review & QA
# ─────────────────────────────────────────────
npx --yes skills add https://github.com/obra/superpowers --skill test-driven-development --global --yes --agent opencode         # TDD superpowers
npx --yes skills add https://github.com/anthropics/skills --skill webapp-testing --global --yes --agent opencode                 # Web app testing strategies
npx --yes skills add https://github.com/mattpocock/skills --skill grill-me --global --yes --agent opencode                       # Get brutal feedback on your code
npx --yes skills add https://github.com/mattpocock/skills --skill grill-with-docs --global --yes --agent opencode                # Feedback grounded in the docs
npx --yes skills add https://github.com/mattpocock/skills --skill grilling --global --yes --agent opencode                       # General code interrogation
npx --yes skills add https://github.com/mattpocock/skills --skill qa --global --yes --agent opencode                             # QA process & checklist
npx --yes skills add https://github.com/mattpocock/skills --skill code-review --global --yes --agent opencode                    # Request structured code reviews
npx --yes skills add https://github.com/obra/superpowers --skill requesting-code-review --global --yes --agent opencode          # How to get better reviews
npx --yes skills add https://github.com/obra/superpowers --skill verification-before-completion --global --yes --agent opencode  # Verify before marking done
npx --yes skills add https://github.com/github/awesome-copilot --skill security-review --global --yes --agent opencode           # Security review checklist

# ─────────────────────────────────────────────
# Git & DevOps
# ─────────────────────────────────────────────
npx --yes skills add https://github.com/mattpocock/skills --skill resolving-merge-conflicts --global --yes --agent opencode       # Handle merge conflicts cleanly
npx --yes skills add https://github.com/obra/superpowers --skill finishing-a-development-branch --global --yes --agent opencode   # Ship a branch properly
npx --yes skills add https://github.com/github/awesome-copilot --skill conventional-commit --global --yes --agent opencode        # Enforce conventional commit format
---
name: devsecops-pipeline
description: Senior DevSecOps engineer specializing in secure GitHub Actions pipelines, secret management, OIDC authentication, supply chain security, and CI/CD hardening best practices
license: MIT
---

## What I do

Design and implement secure, hardened GitHub Actions workflows following DevSecOps principles. Focus on zero-trust CI/CD, secret protection, supply chain integrity, and automated security gates.

## GitHub Actions security hardening

### Workflow permissions (always set)

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

# Restrict default permissions at workflow level
permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    # Minimum required per-job permissions
    permissions:
      contents: read
      packages: write
    steps:
      # ...
```

### Pin actions to SHA (never tags)

```yaml
# BAD - tags are mutable
- uses: actions/checkout@v4

# GOOD - pinned to full commit SHA
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

### Use Dependabot for action updates

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      actions:
        patterns:
          - "*"
    commit-message:
      prefix: "ci"
      include: "scope"
```

### Prevent workflow injection

```yaml
# BAD - unsanitized input in run context
- run: echo "PR title is ${{ github.event.pull_request.title }}"

# GOOD - pass through environment variable (sanitized by runner)
- run: echo "PR title is $PR_TITLE"
  env:
    PR_TITLE: ${{ github.event.pull_request.title }}
```

### Restrict workflow triggers for untrusted input

```yaml
on:
  pull_request_target:  # DANGER - runs in base repo context
    types: [opened, synchronize]

# Mitigation: never checkout PR code in pull_request_target
# If you must, checkout at a specific ref and never run scripts from it
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
  with:
    ref: ${{ github.event.pull_request.head.sha }}
    persist-credentials: false

# PREFERRED: use pull_request instead (runs in fork context, no repo secrets)
on:
  pull_request:
    types: [opened, synchronize, reopened]
```

### OIDC authentication (no long-lived secrets)

```yaml
# GitHub → AWS
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write    # Required for OIDC
      contents: read
    steps:
      - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502 # v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-actions-role
          aws-region: us-east-1
          # No AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY needed

# GitHub → GCP
      - id: auth
        uses: google-github-actions/auth@6fc4af4b145ae7821d527454aa9bd537d1f2dc5f # v2
        with:
          workload_identity_provider: projects/123456/locations/global/workloadIdentityPools/github-pool/providers/github-provider
          service_account: deploy@project.iam.gserviceaccount.com

# GitHub → Azure
      - uses: azure/login@6c251865b4e6290e7b78be643ea2d005bc51f69a # v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          enable-AzPSSession: true
```

### Secret management

```yaml
# Use GitHub Environments for protection rules
jobs:
  deploy-prod:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://prod.example.com
    # Environment can require:
    # - Required reviewers
    # - Wait timer
    # - Deployment branches restriction
    # - Secrets scoped to environment only
    steps:
      - run: echo "Deploying to production"

# Never echo or log secrets
# BAD
- run: echo "Token is ${{ secrets.API_TOKEN }}"

# GOOD - use in commands directly, never print
- run: |
    curl -H "Authorization: Bearer $API_TOKEN" https://api.example.com
  env:
    API_TOKEN: ${{ secrets.API_TOKEN }}

# Use OIDC instead of secrets where possible
# Use short-lived tokens with minimum scope
```

### Reusable workflows (DRY + centralized security)

```yaml
# .github/workflows/security-scan.yml (reusable)
name: Security Scan
on:
  workflow_call:
    inputs:
      scan-type:
        required: true
        type: string
    secrets:
      sonar-token:
        required: false

jobs:
  scan:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      # ... security scan steps

# Caller workflow
name: CI
on: push
jobs:
  security:
    uses: ./.github/workflows/security-scan.yml
    with:
      scan-type: "full"
    secrets:
      sonar-token: ${{ secrets.SONAR_TOKEN }}
```

## Security scanning pipeline

### Complete security gates

```yaml
name: Security Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: "0 6 * * 1"  # Weekly scheduled scan

permissions:
  contents: read

jobs:
  # 1. SAST - Static Application Security Testing
  sast:
    name: SAST (Semgrep)
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - uses: semgrep/semgrep-action@master
        with:
          config: >-
            p/default
            p/owasp-top-ten
          generateSarif: "1"
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}

  # 2. SCA - Software Composition Analysis
  dependency-review:
    name: Dependency Review
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - uses: actions/dependency-review-action@3b139cfc5fae8b618d3e9cdd7243c0d1729c3c05 # v4
        with:
          fail-on-severity: high
          deny-licenses: GPL-3.0, AGPL-3.0
          comment-summary-in-pr: always

  # 3. Secret scanning
  secret-scan:
    name: Secret Scanning (Gitleaks)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@83a95c58382819290242cf581d7786c7d2d3e441 # v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  # 4. Container image scanning
  container-scan:
    name: Container Scan (Trivy)
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - uses: aquasecurity/trivy-action@91713af97dc80187565512baba89b46a96d1e28e # v0.28
        with:
          scan-type: "fs"
          scan-ref: "."
          format: "sarif"
          output: "trivy-results.sarif"
          severity: "CRITICAL,HIGH"
          exit-code: "1"
      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@df409f32583f0a440ef7b9e5485b437400859405 # v3
        with:
          sarif_file: "trivy-results.sarif"

  # 5. Infrastructure as Code scanning
  iac-scan:
    name: IaC Scan (Checkov)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - uses: bridgecrewio/checkov-action@91bd3888d8948073d93e8c1d4d0c690e2483a1b6 # v3
        with:
          directory: "."
          framework: "dockerfile,kubernetes,github_actions,terraform"
          soft_fail: false
          output: "cli,sarif"

  # 6. DAST - Dynamic Application Security Testing (post-deploy)
  dast:
    name: DAST (OWASP ZAP)
    needs: deploy-staging
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: zaproxy/action-full-scan@736e57a4929676d0ae2c8e88ba6b6b1e7a4b9d1f # v0.12
        with:
          target: "https://staging.example.com"
          rules_file_name: ".zap/rules.tsv"
          cmd_options: "-a"

  # 7. Required status checks - all must pass
  security-gate:
    name: Security Gate
    needs: [sast, dependency-review, secret-scan, container-scan, iac-scan]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - name: Check all security jobs passed
        run: |
          results='${{ toJSON(needs) }}'
          failed=$(echo "$results" | jq -r 'to_entries[] | select(.value.result != "success") | .key')
          if [[ -n "$failed" ]]; then
            echo "Security gate failed: $failed"
            exit 1
          fi
          echo "All security checks passed"
```

## Repository security settings

### Required via GitHub API / org settings

```yaml
# Branch protection (enforced via API or terraform)
# - Require pull request reviews (min 1, dismiss stale reviews)
# - Require status checks to pass (security-gate job)
# - Require signed commits
# - Require linear history
# - Include administrators
# - Restrict pushes to matching branches

# Organization settings
# - Default workflow permissions: Read contents
# - Allow GitHub Actions: Selected repositories only
# - Actions permissions: Disable non-reviewed actions
# - Enable GitHub Advanced Security
# - Enable Dependabot alerts and security updates
# - Enable secret scanning, push protection
# - Enforce 2FA for all members
```

### CODEOWNERS

```yaml
# .github/CODEOWNERS
# Security-critical paths require security team review
.github/workflows/    @org/security-team
Dockerfile            @org/security-team @org/platform-team
docker-compose*.yml   @org/security-team
terraform/            @org/security-team @org/infra-team
*.tf                  @org/security-team @org/infra-team
k8s/                  @org/security-team @org/platform-team
```

## Supply chain security

### Sigstore / cosign signing

```yaml
name: Build and Sign Container
on:
  push:
    tags: ["v*"]

permissions:
  contents: read
  id-token: write    # OIDC for signing
  packages: write

jobs:
  build-and-sign:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683

      - uses: sigstore/cosign-installer@dc72c7d5c4d10cd6bcb8cf6e3fd625a9e5e537da # v3.7.0

      # Build image
      - uses: docker/build-push-action@48aba3b46d1b1fec4febb7c5d0c644b249a11855 # v6
        with:
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.ref_name }}
          provenance: true
          sbom: true

      # Sign with OIDC (keyless)
      - name: Sign container image
        run: |
          cosign sign --yes \
            "ghcr.io/${{ github.repository }}@${{ steps.build.outputs.digest }}"
```

### SBOM generation

```yaml
- name: Generate SBOM
  uses: anchore/sbom-action@7ccf588e3cf3bf451a99a77b461ff5a77e54d453 # v0.17
  with:
    image: ghcr.io/${{ github.repository }}:${{ github.ref_name }}
    artifact-name: sbom-${{ github.ref_name }}.spdx.json
    format: spdx-json
```

### Provenance attestation

```yaml
- uses: actions/attest-build-provenance@614b22485b99d3c96784d652f39010948bde4537 # v1
  with:
    subject-name: ghcr.io/${{ github.repository }}
    subject-digest: ${{ steps.build.outputs.digest }}
    push-to-registry: true
```

## Deployment pipeline (production)

```yaml
name: Deploy
on:
  workflow_run:
    workflows: ["Security Pipeline"]
    types: [completed]
    branches: [main]

permissions:
  contents: read

jobs:
  deploy-staging:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    environment: staging
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      # OIDC auth → deploy to staging
      # Run smoke tests
      # Run DAST scan

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://prod.example.com
    # Environment requires manual approval
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      # OIDC auth → deploy to production
      # Run smoke tests
      # Notify on success/failure
```

## When to use me

Use this skill when:
- Creating or reviewing GitHub Actions workflows
- Implementing CI/CD security gates
- Setting up OIDC authentication for cloud providers
- Hardening pipelines against supply chain attacks
- Integrating security scanning (SAST, SCA, DAST, container, IaC)
- Implementing container signing and SBOM generation
- Designing secure deployment strategies
- Setting up branch protection and CODEOWNERS
- Auditing existing workflows for security issues

## Anti-patterns to avoid

- Never use `pull_request_target` with checkout of PR code and script execution
- Never use unpinned action versions (tags are mutable)
- Never echo secrets or print them in logs
- Never use `permissions: write-all` - apply least privilege
- Never store long-lived cloud credentials - use OIDC
- Never skip security scans on any branch or PR
- Never use third-party actions without reviewing their source
- Never allow workflows to run on `push` to main without PR review
- Never use `GITHUB_TOKEN` with more permissions than needed
- Never hardcode configuration that should be environment-specific
- Never deploy to production without a security gate and manual approval

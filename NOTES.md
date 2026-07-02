# Notes

<!--toc:start-->
- [Notes](#notes)
    - [With wayland](#with-wayland)
  - [Avoiding GitHub download rate limits when using `mise` in Docker builds](#avoiding-github-download-rate-limits-when-using-mise-in-docker-builds)
    - [Problem](#problem)
    - [Fix (two parts)](#fix-two-parts)
    - [Dockerfile (works identically on CI & locally)](#dockerfile-works-identically-on-ci-locally)
    - [1. GitHub Actions (CI)](#1-github-actions-ci)
      - [Workflow (using `docker/build-push-action`)](#workflow-using-dockerbuild-push-action)
    - [2. Local build (Podman / Docker)](#2-local-build-podman-docker)
      - [a) Authenticate with a token](#a-authenticate-with-a-token)
      - [b) Build with secret + cache](#b-build-with-secret-cache)
          - [**Podman**](#podman)
          - [**Docker (BuildKit)**](#docker-buildkit)
    - [Verify the token is **not** in the final image](#verify-the-token-is-not-in-the-final-image)
    - [Important](#important)
<!--toc:end-->

### With wayland

Working In WSL2:
https://www.funwithlinux.net/blog/pipe-from-clipboard-in-linux-subsytem-for-windows/#installing-and-using-wl-clipboard

+

```
export XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
export WAYLAND_DISPLAY=wayland-0
```

+ Add WSL_INTEROP access ??

-v /mnt:/mnt \
-v /usr/bin/wsl.exe:/usr/bin/wsl.exe \
--pid=host \
-e WSL_INTEROP=$WSL_INTEROP


## Avoiding GitHub download rate limits when using `mise` in Docker builds

### Problem

`mise install` downloads many tools directly from **GitHub Releases**.\
In a Docker build (especially on GitHub Actions) without authentication, these requests quickly hit GitHub’s **unauthenticated rate limit (60 req/h per IP)** → build fails with `429 Too Many Requests`.

### Fix (two parts)

1. **Authenticate** downloads with a `GITHUB_TOKEN` (raises limit to 1,000 req/h).
2. **Cache** the downloaded files so they aren’t re‑downloaded on every build.

---

### Dockerfile (works identically on CI & locally)

```dockerfile
# syntax=docker/dockerfile:1

# … rest of your Dockerfile …

# Secure secret mount (token never stays in the image)
# + persistent cache mount for mise downloads
RUN --mount=type=cache,target=/root/.local/share/mise,id=mise-cache \
    --mount=type=secret,id=GITHUB_TOKEN \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    mise install
```

- Adjust `/root/.local/share/mise` if you use a non‑root user (use `$HOME/.local/share/mise`).
- The **cache id** (`mise-cache`) lets you reuse downloads across any build.

---

### 1. GitHub Actions (CI)

#### Workflow (using `docker/build-push-action`)

```yaml
- name: Build and push
  uses: docker/build-push-action@v6
  with:
    context: .
    push: true
    tags: my-image:latest
    secrets: |
      "GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }}"
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

- `${{ secrets.GITHUB_TOKEN }}` is automatically provided by GitHub – no setup needed.
- `type=gha` stores the BuildKit cache in the repository’s GitHub Actions cache (survives across workflows, branches, and runs for 7 days).

> **No token in the image** – the secret is only available during the `RUN` instruction and disappears afterward.

---

### 2. Local build (Podman / Docker)

#### a) Authenticate with a token

**Prepare a classic GitHub personal access token** (no special scopes needed unless your tools are in private repos).\
Then set it as an environment variable:

```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

#### b) Build with secret + cache

###### **Podman**

```bash
podman build \
  --secret id=GITHUB_TOKEN,type=env,src=GITHUB_TOKEN \
  -t my-image .
```

For caching, use a host directory bind mount (since local BuildKit caches are not as persistent as `gha`):

```bash
mkdir -p ~/.cache/mise-docker
podman build \
  --secret id=GITHUB_TOKEN,type=env,src=GITHUB_TOKEN \
  --volume ~/.cache/mise-docker:/root/.local/share/mise:Z \
  -t my-image .
```

_(The `:Z` flag is for SELinux; use `:rw` otherwise.)_

###### **Docker (BuildKit)**

```bash
docker buildx build \
  --secret id=GITHUB_TOKEN,env=GITHUB_TOKEN \
  -t my-image .
```

For local BuildKit cache:

```bash
docker buildx build \
  --secret id=GITHUB_TOKEN,env=GITHUB_TOKEN \
  --cache-from type=local,src=/tmp/.buildkit-cache \
  --cache-to type=local,dest=/tmp/.buildkit-cache,mode=max \
  -t my-image .
```

---

### Verify the token is **not** in the final image

```bash
podman run --rm my-image cat /run/secrets/GITHUB_TOKEN
# Output: "No such file or directory" – ✅ safe
```

---

### Important

- Never `echo` the token in your Dockerfile; it may leak in build logs.
- The cache directory must be the same across builds for reuse (the `id=mise-cache` ensures this in CI; on local, use the same host path).

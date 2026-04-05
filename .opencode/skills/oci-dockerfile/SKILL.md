---
name: oci-dockerfile
description: Create OCI compliant and optimized Dockerfiles with multi-stage builds, minimal base images, proper layer caching, and security best practices
license: MIT
---

## What I do

Write Dockerfiles that follow OCI (Open Container Initiative) image spec best practices for security, size, and build efficiency.

## Core principles

### OCI compliance

- Use `FROM --platform=$BUILDPLATFORM` for multi-arch builds when applicable
- Set `OCI_LABELS`: `org.opencontainers.image.title`, `org.opencontainers.image.description`, `org.opencontainers.image.version`, `org.opencontainers.image.source`, `org.opencontainers.image.vendor`, `org.opencontainers.image.licenses`
- Avoid deprecated Dockerfile instructions
- Use JSON array syntax for `ENTRYPOINT` and `CMD` (exec form, not shell form)
- Define `EXPOSE` for documentation (does not publish ports)
- Use `HEALTHCHECK` for container orchestration compatibility

### Optimization

- **Multi-stage builds**: Separate build and runtime stages to minimize final image
- **Minimal base images**: Prefer `alpine`, `distroless`, or `scratch` for runtime
- **Layer caching**: Order instructions from least to most frequently changed
- **Combine RUN commands**: Chain with `&&` and clean package manager caches in the same layer
- **Use `.dockerignore`**: Exclude `.git`, `node_modules`, `__pycache__`, `.env`, IDE files
- **Copy only what's needed**: Copy dependency files first, install, then copy source

### Security

- **Non-root user**: Create and switch to a non-root user with `USER`
- **No secrets in layers**: Use BuildKit secrets (`--mount=type=secret`) or build args (not for sensitive data)
- **Pin versions**: Pin base image tags to SHA digests when possible
- **Minimal attack surface**: Remove unnecessary packages, shells, and tools from runtime image
- **Read-only filesystem**: Design for `--read-only` container runtime where possible
- **No `ADD` for remote URLs**: Use `COPY` for local files, `curl`/`wget` for remote (better caching and transparency)

## When to use me

Use this skill when creating or refactoring Dockerfiles for production use.

## Patterns

### Multi-stage build template

```dockerfile
# syntax=docker/dockerfile:1

# ---- build stage ----
FROM --platform=$BUILDPLATFORM node:22-alpine AS build
WORKDIR /build
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# ---- runtime stage ----
FROM node:22-alpine AS runtime

# OCI labels
LABEL org.opencontainers.image.title="my-app" \
      org.opencontainers.image.description="My application" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.source="https://github.com/org/repo" \
      org.opencontainers.image.vendor="org" \
      org.opencontainers.image.licenses="MIT"

# Non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=build --chown=appuser:appgroup /build/dist ./dist
COPY --from=build --chown=appuser:appgroup /build/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /build/package.json ./

USER appuser

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]

ENTRYPOINT ["node"]
CMD ["dist/index.js"]
```

### Go multi-stage (distroless)

```dockerfile
# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags="-s -w" -o /app/server .

FROM gcr.io/distroless/static:nonroot
LABEL org.opencontainers.image.title="go-service" \
      org.opencontainers.image.description="Go microservice" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.source="https://github.com/org/repo"

COPY --from=build --chown=nonroot:nonroot /app/server /server

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD ["/server", "health"]
ENTRYPOINT ["/server"]
```

### Python (optimized)

```dockerfile
# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM python:3.13-slim AS build
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.13-slim AS runtime

LABEL org.opencontainers.image.title="python-app" \
      org.opencontainers.image.description="Python application" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.source="https://github.com/org/repo"

RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app
COPY --from=build /install /usr/local
COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]

ENTRYPOINT ["python"]
CMD ["-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Checklist

- [ ] Multi-stage build separates build and runtime
- [ ] Minimal base image for runtime (alpine/slim/distroless)
- [ ] OCI labels present
- [ ] Non-root user configured
- [ ] Versions pinned (base image, dependencies)
- [ ] Dependency files copied before source (layer caching)
- [ ] Package manager cache cleaned in same RUN layer
- [ ] JSON exec form for ENTRYPOINT/CMD
- [ ] HEALTHCHECK defined
- [ ] EXPOSE documented
- [ ] No secrets baked into image
- [ ] `.dockerignore` covers unnecessary files
- [ ] COPY used instead of ADD (unless extracting tarballs)

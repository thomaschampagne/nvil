#!/bin/bash

set -eo pipefail

# Defaults
arg_file_path="./build-args.default.conf"
github_token_file=""
image=""
docker_file="" # Required: Set Dockerfile via --docker-file

# Container runtime selection: docker or podman. Defaults to podman if available, otherwise docker.
runner=""

# Help message
show_help() {
    cat << 'EOF'
Usage: $0 [--image IMAGE] [--arg-file PATH] [--gh-token-file PATH] [--runner RUNNER] [--docker-file FILE] [--help]

Options:
  --image IMAGE           Set image name and tag (format: image:tag)
  --arg-file PATH         Set arg file path (default: ./build-args.default.conf)
  --gh-token-file PATH    Path to a file containing the GitHub token (passed as a build secret)
  --runner RUNNER         Container runner to use (docker or podman). If not specified, uses podman if available, otherwise docker.
  --docker-file FILE      Set Dockerfile path 
  --help                  Show this help message
EOF
    exit 0
}

# Parse arguments manually for better portability
while [[ $# -gt 0 ]]; do
    case "$1" in
        --image=*)
            image="${1#*=}"
            shift
            ;;
        --arg-file=*)
            arg_file_path="${1#*=}"
            shift
            ;;
        --gh-token-file=*)
            github_token_file="${1#*=}"
            shift
            ;;
        --runner=*)
            runner="${1#*=}"
            shift
            ;;
        --docker-file=*)
            docker_file="${1#*=}"
            shift
            ;;
        --image)
            image="$2"
            shift 2
            ;;
        --arg-file)
            arg_file_path="$2"
            shift 2
            ;;
        --gh-token-file)
            github_token_file="$2"
            shift 2
            ;;
        --runner)
            runner="$2"
            shift 2
            ;;
        -h | --help)
            show_help
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$image" ]; then
    echo "Error: --image is required" >&2
    exit 1
fi

if [ -z "$docker_file" ]; then
    echo "Error: --docker-file is required" >&2
    exit 1
fi

if [ -z "$github_token_file" ]; then
    echo "Error: --gh-token-file is required" >&2
    exit 1
fi

if [ ! -f "$github_token_file" ]; then
    echo "Error: --gh-token-file '$github_token_file' does not exist" >&2
    exit 1
fi

# Validate runner selection
if [ -n "$runner" ]; then
    # Check if specified runner exists and is executable
    if ! runner_path=$(type -P "$runner") || [ -z "$runner_path" ]; then
        echo "Error: Specified runner '$runner' not found or not executable. Please install $runner or choose a different runner." >&2
        exit 1
    fi
else
    # Auto-detect runner: prefer podman, fallback to docker
    if runner_path=$(type -P podman) && [ -n "$runner_path" ]; then
        runner="podman"
    elif runner_path=$(type -P docker) && [ -n "$runner_path" ]; then
        runner="docker"
    else
        echo "Error: Neither podman nor docker is installed. Please install one of them." >&2
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Host environment checks
# ---------------------------------------------------------------------------

# 1. Linux only (real Linux or WSL2). podman.exe/docker.exe (Windows native)
#    run a separate engine in their own VM: images built there are invisible
#    to the WSL2 engine and vice versa, and --secret src= breaks (mixed
#    POSIX/Windows separators). Run from inside WSL2 instead.
case "$(uname -s)" in
    Linux) : ;;
    *)
        cat >&2 << 'EOF'
Error: this script must run on Linux (real Linux or WSL2).

Detected a Windows shell (Git-Bash/MSYS). The Windows podman.exe runs its
own engine in a separate VM, so images built here would be invisible to the
WSL2 podman engine and vice versa. Run the build from inside WSL2 instead:

    wsl.exe --cd "C:\\path\\to\\workspace" bash nvil.img.make.sh <same args>
EOF
        exit 1
        ;;
esac

# 2. Must run as root. The build is rootful: the rootful podman engine and its
#    socket (/run/podman/podman.sock) are what let the Windows host reach the
#    WSL2 podman store for image sync.
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: this script must run as root (current uid: $(id -u), need 0)." >&2
    echo "Re-run with: sudo \"$0\" $*" >&2
    exit 1
fi

# 3. Podman only: ensure podman.socket services running. The socket is how the
#    Windows host (podman-remote / Podman Desktop) syncs images with WSL2.
if [ "$runner" = "podman" ]; then
    if ! systemctl is-active --quiet podman.socket; then
        echo "Enabling + starting podman.socket (system)..."
        systemctl enable --now podman.socket
    fi
    if systemctl is-active --quiet podman.socket; then
        echo "OK: podman.socket (system, /run/podman/podman.sock) active."
    else
        echo "Warning: podman.socket (system) not active. Windows host image sync will be unavailable." >&2
    fi

    if XDG_RUNTIME_DIR=/run/user/0 systemctl --user enable --now podman.socket >/dev/null 2>&1; then
        echo "OK: podman.socket (user, /run/user/0/podman/podman.sock) enabled."
    else
        echo "Note: user-level podman.socket not started (no root user systemd session). Not required when Windows connects to the rootful socket."
    fi
fi

echo "Using container runner: $runner"

image_name="${image%:*}"

# Remove existing container if it exists for the image being built
if $runner ps -a --format '{{.Names}}' | grep -q "^${image_name}$"; then
    echo "Removing existing container: $image_name"
    $runner rm -f "$image_name"
    echo "Container removed."
else
    echo "No existing container found with name: $image_name"
fi

# Build image
echo "Building image: $image"

# GITHUB_TOKEN is passed to the build as a secret file (--secret ...,src=),
# not env=. This works identically on Linux (docker/podman) and Windows
# (podman.exe via Git-Bash/MSYS): env= forces podman/buildah to compute its
# own internal temp path, which breaks on Windows (mixed POSIX/Windows
# separators). Caller supplies the file directly via --gh-token-file.
$runner build \
    --build-arg OCI_BUILD_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg OCI_VERSION=$(date +%Y.%m.%d) \
    --build-arg-file "$arg_file_path" \
    --secret id=GITHUB_TOKEN,src="$github_token_file" \
    -f "$docker_file" \
    -t "$image" .
echo "Image built successfully: $image"

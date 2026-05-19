#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE="$SCRIPT_DIR/Dockerfile"
IMAGE_NAME="picosa:latest"
PRIVATE_MODE=1

[ -f "$SCRIPT_DIR/.env" ] && set -a && . "$SCRIPT_DIR/.env" && set +a

# Use the basename of the directory picosa is invoked from
PI_SESSION_DIR="$(basename "$(pwd)")"

show_help() {
    cat <<EOF
Usage: picosa.sh [OPTIONS] [PI_ARGS...]

Containerized pi.dev sandbox with optional network isolation (picosa).

Runs pi in a Docker container with filesystem/process sandboxing
via pi-sandbox. By default (no flags), a fully offline mode is used.
With online/public flags, external internet access is preserved.

The current directory is mounted at /workspace/<session-dir>/ (pi's working directory).

Options:
  Offline mode (default):
    --private, --offline, --closed, --lan
                           Block all external network access.
                           LAN + Docker host access preserved.
  Online mode:
    --public, --online, --open, --web
                           Allow sandbox-restricted internet access.
  --build                  Force-rebuild the picosa image.
  --help, -h              Show this help.

Environment variables:
  OLLAMA_BASE_URL       Override the Ollama API endpoint inside the container.
                        Default: http://host.docker.internal:11434/v1
  OLLAMA_DEFAULT_MODEL  Set a default Ollama model for the pi agent.

Shell shortcuts: add to ~/.bashrc and/or ~/.zshrc:

  picosa() { ${SCRIPT_DIR}/picosa.sh "\$@"; }
  picosaweb() { ${SCRIPT_DIR}/picosa.sh --web "\$@"; }

EOF
}

ensure_image() {
    if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        echo "Building picosa image…"
        docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" "$SCRIPT_DIR"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --private|--offline|--closed|--lan)
            PRIVATE_MODE=1
            shift
            ;;
        --public|--online|--open|--web)
            PRIVATE_MODE=0
            shift
            ;;
        --build)
            echo "Building picosa image…"
            docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" "$SCRIPT_DIR"
            exit 0
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

ensure_image

docker run --rm -it \
    --add-host host.docker.internal:host-gateway \
    -e HOME=/root \
    -e PI_WORKSPACE=/workspace/$PI_SESSION_DIR \
    --security-opt seccomp=unconfined \
    --cap-add SYS_ADMIN \
    --cap-add NET_ADMIN \
    -w /workspace/$PI_SESSION_DIR \
    -v "$SCRIPT_DIR/config:/config:ro" \
    -v "$SCRIPT_DIR/skills:/root/.pi/agent/skills" \
    -v "$SCRIPT_DIR/extensions:/root/.pi/agent/extensions" \
    -v "$(pwd):/workspace/$PI_SESSION_DIR" \
    -e PI_SKIP_VERSION_CHECK=1 \
    -e PRIVATE_MODE="$PRIVATE_MODE" \
    ${OLLAMA_BASE_URL:+-e OLLAMA_BASE_URL="$OLLAMA_BASE_URL"} \
    ${OLLAMA_DEFAULT_MODEL:+-e OLLAMA_DEFAULT_MODEL="$OLLAMA_DEFAULT_MODEL"} \
    "$IMAGE_NAME" \
    "$@"

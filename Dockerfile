FROM node:22-bookworm-slim

# System dependencies (pi, pi-sandbox, and firewall support)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ripgrep \
    fd-find \
    bubblewrap \
    git \
    curl \
    socat \
    ca-certificates \
    iptables \
    python3 \
    python3-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf "$(which fdfind)" /usr/local/bin/fd \
    && curl -LsSf https://astral.sh/uv/install.sh | sh 2>&1 \
    && ln -sf "$HOME/.local/bin/uv" /usr/local/bin/uv \
    && ln -sf "$HOME/.local/bin/uvx" /usr/local/bin/uvx \
    && ln -sf "$HOME/.local/bin/uvpip" /usr/local/bin/uvpip

# Install pi coding agent and sandbox extension
RUN npm install -g @earendil-works/pi-coding-agent
RUN npm install -g pi-sandbox

# Prepare fixed directories
RUN mkdir -p /root/.pi/agent /config /workspace

# Set up entrypoint & directories
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV HOME=/root
WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]

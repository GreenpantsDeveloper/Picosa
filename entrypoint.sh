#!/bin/bash
set -e
export HOME=/root

PI_CONFIG_DIR="$HOME/.pi/agent"
mkdir -p "$PI_CONFIG_DIR"

# Copy config files from /config into the agent config directory
for f in /config/*.json; do
    [ -f "$f" ] && cp "$f" "$PI_CONFIG_DIR/$(basename "$f")"
done

# Select the correct APPEND_SYSTEM for the current mode
# Prefers mode-specific files; falls back to a generic APPEND_SYSTEM.md for backward compat
if [ "${PRIVATE_MODE:-0}" = "1" ]; then
    if [ -f /config/APPEND_SYSTEM.offline.md ]; then
        cp /config/APPEND_SYSTEM.offline.md "$PI_CONFIG_DIR/APPEND_SYSTEM.md"
    elif [ -f /config/APPEND_SYSTEM.md ]; then
        cp /config/APPEND_SYSTEM.md "$PI_CONFIG_DIR/APPEND_SYSTEM.md"
    fi
else
    if [ -f /config/APPEND_SYSTEM.online.md ]; then
        cp /config/APPEND_SYSTEM.online.md "$PI_CONFIG_DIR/APPEND_SYSTEM.md"
    elif [ -f /config/APPEND_SYSTEM.md ]; then
        cp /config/APPEND_SYSTEM.md "$PI_CONFIG_DIR/APPEND_SYSTEM.md"
    fi
fi

# Inject environment variables into models.json template
export OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://host.docker.internal:11434/v1}"
export OLLAMA_DEFAULT_MODEL="${OLLAMA_DEFAULT_MODEL}"
if [ -f "$PI_CONFIG_DIR/models.json" ]; then
    sed -i \
        -e "s|\${OLLAMA_BASE_URL}|$OLLAMA_BASE_URL|g" \
        -e "s|\${OLLAMA_DEFAULT_MODEL}|$OLLAMA_DEFAULT_MODEL|g" \
        "$PI_CONFIG_DIR/models.json"
fi

# Apply firewall restrictions in private mode, or allow full network access otherwise
if [ "${PRIVATE_MODE:-0}" = "1" ]; then
    iptables -F OUTPUT 2>/dev/null || true
    iptables -P OUTPUT DROP
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -d 10.0.0.0/8     -j ACCEPT
    iptables -A OUTPUT -d 172.16.0.0/12  -j ACCEPT
    iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
    iptables -A OUTPUT -d 169.254.0.0/16 -j ACCEPT
    iptables -A OUTPUT -j REJECT --reject-with icmp-net-unreachable
    ip6tables -F OUTPUT 2>/dev/null || true
    ip6tables -P OUTPUT DROP
    ip6tables -A OUTPUT -o lo -j ACCEPT
    ip6tables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    ip6tables -A OUTPUT -d fe80::/10  -j ACCEPT
    ip6tables -A OUTPUT -d fc00::/7   -j ACCEPT
    ip6tables -A OUTPUT -d ::1/128    -j ACCEPT
    ip6tables -A OUTPUT -j REJECT

    # Block iptables binaries so rules can't be modified at runtime
    IPTABLES_BINS=(
        /usr/sbin/iptables /usr/sbin/iptables-save /usr/sbin/iptables-restore
        /usr/sbin/ip6tables /usr/sbin/ip6tables-save /usr/sbin/ip6tables-restore
        /usr/sbin/iptables-legacy /usr/sbin/iptables-nft
        /usr/sbin/ip6tables-legacy /usr/sbin/ip6tables-nft
        /usr/sbin/xtables-legacy-multi /usr/sbin/xtables-nft-multi
        /usr/sbin/nft
    )
    for bin in "${IPTABLES_BINS[@]}"; do
        [ -e "$bin" ] && rm -f "$bin"
    done

    # Remove any additional firewall binaries from the system
    find /usr/sbin /usr/bin /sbin /bin -name '*iptables*' -delete 2>/dev/null || true
    find /usr/sbin /usr/bin /sbin /bin -name '*ip6tables*' -delete 2>/dev/null || true
    find /usr/sbin /usr/bin /sbin /bin -name '*nft*' -type f -delete 2>/dev/null || true
    find /usr/sbin /usr/bin /sbin /bin -name 'xtables*' -delete 2>/dev/null || true

    rm -rf /usr/lib/x86_64-linux-gnu/xtables 2>/dev/null || true
    rm -rf /usr/lib/aarch64-linux-gnu/xtables 2>/dev/null || true
fi

# Execute pi with any passed arguments
exec pi "$@"

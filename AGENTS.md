# `picosa` Sandbox Overview

This repository provides a containerized, sandboxed environment for the `pi.dev` coding agent.

## Key Components
- **Agent**: `@earendil-works/pi-coding-agent`
- **Sandbox**: `pi-sandbox` for filesystem and network isolation
- **Environment**: Docker container (`node:22-bookworm-slim`)
- **Workspace**: Files reside in `/workspace`
- **Configuration**: Read-only config located in `/config`

## Notes
- Global skills for the pi agent go into this repository's `skills/` directory.
- Global extensions for the pi agent go into this repository's `extensions/` directory.
- **Network**: Two-layer control (Host-level via `PRIVATE_MODE` and `pi-sandbox` allowlists).
- **Guidelines**: Do not modify `/config` or attempt to bypass sandbox/firewall rules.

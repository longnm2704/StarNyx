#!/usr/bin/env bash

set -euo pipefail

# Launch Codex with a project-local GitHub MCP configuration.
# This avoids asking every contributor to edit ~/.codex/config.toml
# just to work on this repository.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env.github-mcp"

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI is not installed or not available in PATH." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required to run the GitHub MCP server." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running. Start Docker Desktop and try again." >&2
  exit 1
fi

if [[ -f "$ENV_FILE" ]]; then
  # Load local project secrets for MCP without committing them.
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

if [[ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]]; then
  echo "Set GITHUB_PERSONAL_ACCESS_TOKEN in .env.github-mcp or your shell before launching Codex." >&2
  exit 1
fi

GITHUB_MCP_IMAGE="${GITHUB_MCP_IMAGE:-ghcr.io/github/github-mcp-server}"

# Codex loads MCP servers from configuration values. We inject those
# values at launch time via -c so the setup stays local to this repo.
codex_args=(
  -C "$PROJECT_ROOT"
  -c 'mcp_servers.github.command="docker"'
  -c "mcp_servers.github.args=[\"run\",\"-i\",\"--rm\",\"-e\",\"GITHUB_PERSONAL_ACCESS_TOKEN\",\"${GITHUB_MCP_IMAGE}\"]"
  -c "mcp_servers.github.env={ GITHUB_PERSONAL_ACCESS_TOKEN = \"${GITHUB_PERSONAL_ACCESS_TOKEN}\" }"
)

if [[ -n "${GITHUB_HOST:-}" ]]; then
  # Repositories on GitHub Enterprise or custom domains must pass
  # GITHUB_HOST so the MCP server talks to the correct API host.
  codex_args=(
    -C "$PROJECT_ROOT"
    -c 'mcp_servers.github.command="docker"'
    -c "mcp_servers.github.args=[\"run\",\"-i\",\"--rm\",\"-e\",\"GITHUB_PERSONAL_ACCESS_TOKEN\",\"-e\",\"GITHUB_HOST\",\"${GITHUB_MCP_IMAGE}\"]"
    -c "mcp_servers.github.env={ GITHUB_PERSONAL_ACCESS_TOKEN = \"${GITHUB_PERSONAL_ACCESS_TOKEN}\", GITHUB_HOST = \"${GITHUB_HOST}\" }"
  )
fi

exec codex "${codex_args[@]}" "$@"

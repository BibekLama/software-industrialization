#!/usr/bin/env bash
set -euo pipefail

NETWORK_NAME="${NETWORK_NAME:-sw_infra_net}"

if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  echo "Network '$NETWORK_NAME' does not exist. Nothing to do."
  exit 0
fi

ATTACHED=$(docker network inspect "$NETWORK_NAME" \
  --format '{{range .Containers}}{{.Name}} {{end}}')

if [ -n "${ATTACHED// /}" ]; then
  echo "Cannot remove '$NETWORK_NAME'. Containers still attached: $ATTACHED"
  echo "Stop them first (docker compose down in each stack), then rerun."
  exit 1
fi

docker network rm "$NETWORK_NAME"
echo "Network '$NETWORK_NAME' removed."
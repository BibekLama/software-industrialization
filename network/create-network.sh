#!/usr/bin/env bash
set -euo pipefail

NETWORK_NAME="${NETWORK_NAME:-sw_infra_net}"

if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  echo "Network '$NETWORK_NAME' already exists."
else
  docker network create --driver bridge "$NETWORK_NAME"
  echo "Network '$NETWORK_NAME' created."
fi
#!/bin/bash
set -euo pipefail

source .env

if [ -z "$RPC_URL" ]; then
  echo "Error: RPC_URL is not set in the environment."
  exit 1
fi

if [ -z "$ANVIL_PORT" ]; then
  echo "Error: ANVIL_PORT is not set in the environment."
  exit 1
fi

ANVIL_RPC_URL="http://localhost:$ANVIL_PORT"
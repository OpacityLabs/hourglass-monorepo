#!/bin/bash
set -euo pipefail

source env.sh

# Check anvil is alive
if ! cast chain-id --rpc-url $ANVIL_RPC_URL; then
  echo "Error: Anvil is not running on port $ANVIL_PORT."
  exit 1
fi

DEPLOYER=$(cast wallet new --json)
DEPLOYER_PRIVATE_KEY=$(echo $DEPLOYER | jq -r '.[0].private_key')
DEPLOYER_ADDRESS=$(echo $DEPLOYER | jq -r '.[0].address')

AVS=$(cast wallet new --json)
AVS_PRIVATE_KEY=$(echo $AVS | jq -r '.[0].private_key')
AVS_ADDRESS=$(echo $AVS | jq -r '.[0].address')

ETH=$(cast to-hex $(cast to-wei 1))

cast rpc anvil_setBalance $DEPLOYER_ADDRESS $ETH --rpc-url $ANVIL_RPC_URL

cast rpc anvil_setBalance $AVS_ADDRESS $ETH --rpc-url $ANVIL_RPC_URL


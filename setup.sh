#!/bin/bash
set -euo pipefail

source env.sh

# Check anvil is alive
if ! cast chain-id --rpc-url $ANVIL_RPC_URL; then
  echo "Error: Anvil is not running on port $ANVIL_PORT."
  exit 1
fi

# TODO: logic to check if wallets.json already exists and if it does, use the existing wallets

DEPLOYER=$(cast wallet new --json | jq -c '.[0]')
DEPLOYER_PRIVATE_KEY=$(echo $DEPLOYER | jq -r '.private_key')
DEPLOYER_ADDRESS=$(echo $DEPLOYER | jq -r '.address')

AVS=$(cast wallet new --json | jq -c '.[0]')
AVS_PRIVATE_KEY=$(echo $AVS | jq -r '.private_key')
AVS_ADDRESS=$(echo $AVS | jq -r '.address')

ETH=$(cast to-hex $(cast to-wei 1))

cast rpc anvil_setBalance $DEPLOYER_ADDRESS $ETH --rpc-url $ANVIL_RPC_URL

cast rpc anvil_setBalance $AVS_ADDRESS $ETH --rpc-url $ANVIL_RPC_URL

echo "DEPLOYER: $DEPLOYER"
echo "AVS: $AVS"

RESULT=$(jq -n --argjson deployer $DEPLOYER --argjson avs $AVS '{"deployer": $deployer, "avs": $avs}')

echo $RESULT | jq '.' > wallets.json

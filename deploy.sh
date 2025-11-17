#!/bin/bash
set -euo pipefail

source env.sh

# Check anvil is alive
if ! cast chain-id --rpc-url $ANVIL_RPC_URL; then
  echo "Error: Anvil is not running on port $ANVIL_PORT."
  exit 1
fi

CHAIN_ID=$(cast chain-id --rpc-url $ANVIL_RPC_URL)
WALLETS=$(cat wallets.json)

cd contracts/lib/hourglass-monorepo/contracts/

AVS_ADDRESS=$(echo $WALLETS | jq -r '.avs.address')
PRIVATE_KEY_DEPLOYER=$(echo $WALLETS | jq -r '.deployer.private_key')

# Step 1:
# Deploy AVS L1 Contracts:
# https://github.com/Layr-Labs/hourglass-monorepo/blob/master/contracts/script/local/DeployAVSL1Contracts.s.sol

PRIVATE_KEY_DEPLOYER=$PRIVATE_KEY_DEPLOYER forge script DeployAVSL1Contracts \
    --rpc-url $ANVIL_RPC_URL \
    --broadcast \
    --sig "run(address)" \
    $AVS_ADDRESS

DEPLOYMENT=$(cat ./broadcast/DeployAVSL1Contracts.s.sol/$CHAIN_ID/run-latest.json)
echo $DEPLOYMENT

# Step 2:
# Setup AVS L1:
# https://github.com/Layr-Labs/hourglass-monorepo/blob/master/contracts/script/local/SetupAVSL1.s.sol

# PRIVATE_KEY_AVS=$PRIVATE_KEY_AVS forge script SetupAVSL1 --rpc-url http://localhost:8545 --broadcast --sig "run(address)" 0xb22aD3B20a365dfDB30b26B2F335Ac1Ae5866E27
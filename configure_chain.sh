#!/bin/bash
set -exu

NETWORK=testnet

WHITELISTED_HEX_PRIVATE_KEY="$(cat .whitelisted_account_unarmored_hex)"                                 # replace with the hex private key of the whitelisted account
WHITELISTED_ADDRESS="allo1xw354nrfpsw6x3sf7aqnrek0wluyx58zv2uc75"
WHITELISTED_ACC_NAME="whitelisted-0"

WEIGHT_CADENCE=10800
INFERENCE_CADENCE=61
NODE_RPC_URL=https://allora-rpc.$NETWORK.allora.network:443

# ADDRESSES=("alloaddress1" "alloaddress2" "alloaddressX")
KEYRING_BACKEND=test
HOME_DIR=./data

# import and fund a whitelisted account to run topic txs
if allorad keys --home=${HOME_DIR} --keyring-backend $KEYRING_BACKEND show $WHITELISTED_ACC_NAME >/dev/null 2>&1 ; then
    echo "$WHITELISTED_ACC_NAME - account already imported"
else
    allorad keys import-hex --home=$HOME_DIR --keyring-backend $KEYRING_BACKEND $WHITELISTED_ACC_NAME $WHITELISTED_HEX_PRIVATE_KEY
fi

curl -Lvvv https://faucet.$NETWORK.allora.network/send/$NETWORK/$WHITELISTED_ADDRESS

# create, fund and activate all topics
# ETH Prediction
yes | allorad --home=$HOME_DIR tx emissions push-topic $WHITELISTED_ADDRESS "ETH 24h Prediction" bafybeih6yjjjf2v7qp3wm6hodvjcdljj7galu7dufirvcekzip5gd7bthq eth-price-weights-calc.wasm $WEIGHT_CADENCE bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm allora-inference-function.wasm $INFERENCE_CADENCE "ETH" --node=$NODE_RPC_URL
yes | allorad --home=$HOME_DIR tx emissions request-inference $WHITELISTED_ADDRESS \
    '{"nonce": "1","topic_id":"1","cadence":"60","max_price_per_inference":"1","bid_amount":"10000","timestamp_valid_until":"'$(date -d "$(date -d '1 day' +%Y-%m-%d)" +%s)'"}' \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK
yes | allorad --home=$HOME_DIR tx emissions reactivate-topic $WHITELISTED_ADDRESS 1 \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK

# Yuga Index
yes | allorad --home=$HOME_DIR tx emissions push-topic $WHITELISTED_ADDRESS "Upshot Yuga Index Valuation" bafybeih6yjjjf2v7qp3wm6hodvjcdljj7galu7dufirvcekzip5gd7bthq eth-price-weights-calc.wasm $WEIGHT_CADENCE bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm allora-inference-function.wasm $INFERENCE_CADENCE "yuga" \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK
yes | allorad --home=$HOME_DIR tx emissions request-inference $WHITELISTED_ADDRESS  '{"nonce": "2","topic_id":"2","cadence":"60","max_price_per_inference":"1","bid_amount":"10000","timestamp_valid_until":"'$(date -d "$(date -d '1 day' +%Y-%m-%d)" +%s)'"}' \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK
yes | allorad --home=$HOME_DIR tx emissions reactivate-topic $WHITELISTED_ADDRESS 2 \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK

# NFT Appraisals
yes | allorad --home=$HOME_DIR tx emissions push-topic $WHITELISTED_ADDRESS "NFT appraisals topic" "bafybeie64jdoxioewcng7fy3mgx3n2xly6soffolxywrw4htpt4r3aen34" "nft-appraisals-weights-calc.wasm" $WEIGHT_CADENCE "bafybeihvikwjuqtijpurgsyiv5uwmmzg7ksibcwx6s3gjmkneasdn5kndy" "nft-appraisals-inference.wasm" $INFERENCE_CADENCE "0x42069abfe407c60cf4ae4112bedead391dba1cdb/2921" \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK
yes | allorad --home=$HOME_DIR tx emissions  request-inference $WHITELISTED_ADDRESS  '{"nonce": "3","topic_id":"3","cadence":"60","max_price_per_inference":"1","bid_amount":"10000","timestamp_valid_until":"'$(date -d "$(date -d '1 day' +%Y-%m-%d)" +%s)'"}' \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK
yes | allorad --home=$HOME_DIR tx emissions reactivate-topic $WHITELISTED_ADDRESS 3 \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK

# Watch Prices
yes | allorad --home=$HOME_DIR  tx emissions push-topic $WHITELISTED_ADDRESS "Watches price appraisals topic" "bafybeicq5emepge5obvzf2si6wfskxtyjlagchub5inar3l577ixawn3vi" "watch-prices-weights-calc.wasm" $WEIGHT_CADENCE "bafybeifmz4hyk63eynmwmx3htfrshb3egpgl77xmqa2pjuxgimmzssa5ai" "watch-prices-inference.wasm" $INFERENCE_CADENCE "0x75F9F22D1070fDd56bD1DDF2DB4d65aB0F759431/51" \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK
yes | allorad --home=$HOME_DIR tx emissions  request-inference $WHITELISTED_ADDRESS '{"nonce": "4","topic_id":"4","cadence":"60","max_price_per_inference":"1","bid_amount":"10000","timestamp_valid_until":"'$(date -d "$(date -d '1 day' +%Y-%m-%d)" +%s)'"}' \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK
yes | allorad --home=$HOME_DIR tx emissions reactivate-topic $WHITELISTED_ADDRESS 4 \
    --node=$NODE_RPC_URL --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id $NETWORK

# # fund head account and workers account
# for address in "${ADDRESSES[@]}"; do
#     echo "funding address: $address"
#     curl -Lvvv https://faucet.$NETWORK.allora.network/send/$NETWORK/$address
# done

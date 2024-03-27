#!/bin/bash

NETWORK=edgenet
KEYRING_BACKEND=test
HOME_DIR=/data

WHITELISTED_ADDRESS=allo1shzv768qrxaextjwz0aj6nzhm3cyy4pdug8jy6
WHITELISTED_HEX_PRIVATE_KEY=<pk>                                 # replace with the hex private key of the whitelisted account
WEIGHT_CADENCE=10800
INFERENCE_CADENCE=61
NODE_RPC_URL=https://allora-rpc.edgenet.allora.network:443
ADDRESSES=("alloaddress1" "alloaddress2" "alloaddressX")

# import and fund a whitelisted account to run topic txs
allorad keys import-hex --home=$HOME_DIR --keyring-backend $KEYRING_BACKEND whitelisted-0 $WHITELISTED_HEX_PRIVATE_KEY --node=$NODE_RPC_URL
curl -Lvvv https://faucet.edgenet.allora.network/send/edgenet/$WHITELISTED_ADDRESS

# create, fund and activate all topics
# ETH Prediction
yes | allorad tx emissions push-topic --home=$HOME_DIR --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id=$NETWORK $WHITELISTED_ADDRESS "ETH 24h Prediction" bafybeih6yjjjf2v7qp3wm6hodvjcdljj7galu7dufirvcekzip5gd7bthq eth-price-weights-calc.wasm $WEIGHT_CADENCE bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm allora-inference-function.wasm $INFERENCE_CADENCE "ETH" --node=$NODE_RPC_URL
yes | allorad  tx emissions  request-inference $WHITELISTED_ADDRESS  '{"nonce": "1","topic_id":"1","cadence":"60","max_price_per_inference":"1","bid_amount":"10000","timestamp_valid_until":"'$(date -d "$(date -d '1 day' +%Y-%m-%d)" +%s)'"} --node=$NODE_RPC_URL
yes | allorad tx emissions reactivate-topic $WHITELISTED_ADDRESS 1 --node=$NODE_RPC_URL

# Yuga Index
yes | allorad tx emissions push-topic --home=$HOME_DIR --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id=$NETWORK $WHITELISTED_ADDRESS "Upshot Yuga Index Valuation" bafybeih6yjjjf2v7qp3wm6hodvjcdljj7galu7dufirvcekzip5gd7bthq eth-price-weights-calc.wasm $WEIGHT_CADENCE bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm allora-inference-function.wasm $INFERENCE_CADENCE "yuga" --node=$NODE_RPC_URL
yes | allorad  tx emissions  request-inference $WHITELISTED_ADDRESS  '{"nonce": "2","topic_id":"2","cadence":"60","max_price_per_inference":"1","bid_amount":"10000","timestamp_valid_until":"'$(date -d "$(date -d '1 day' +%Y-%m-%d)" +%s)'"} --node=$NODE_RPC_URL
yes | allorad tx emissions reactivate-topic $WHITELISTED_ADDRESS 2 --node=$NODE_RPC_URL

# NFT Appraisals
yes | allorad tx emissions push-topic --home=$HOME_DIR --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id=$NETWORK $WHITELISTED_ADDRESS "NFT appraisals topic" "bafybeie64jdoxioewcng7fy3mgx3n2xly6soffolxywrw4htpt4r3aen34" "nft-appraisals-weights-calc.wasm" $WEIGHT_CADENCE "bafybeihvikwjuqtijpurgsyiv5uwmmzg7ksibcwx6s3gjmkneasdn5kndy" "nft-appraisals-inference.wasm" $INFERENCE_CADENCE "0x42069abfe407c60cf4ae4112bedead391dba1cdb/2921" --node=$NODE_RPC_URL
yes | allorad  tx emissions  request-inference $WHITELISTED_ADDRESS  '{"nonce": "3","topic_id":"3","cadence":"60","max_price_per_inference":"1","bid_amount":"10000","timestamp_valid_until":"'$(date -d "$(date -d '1 day' +%Y-%m-%d)" +%s)'"} --node=$NODE_RPC_URL
yes | allorad tx emissions reactivate-topic $WHITELISTED_ADDRESS 3 --node=$NODE_RPC_URL

# Watch Prices
yes | allorad tx emissions push-topic --home=$HOME_DIR --keyring-backend=$KEYRING_BACKEND --keyring-dir=$HOME_DIR --chain-id=$NETWORK $WHITELISTED_ADDRESS "Watches price appraisals topic" "bafybeicq5emepge5obvzf2si6wfskxtyjlagchub5inar3l577ixawn3vi" "watch-prices-weights-calc.wasm" $WEIGHT_CADENCE "bafybeifmz4hyk63eynmwmx3htfrshb3egpgl77xmqa2pjuxgimmzssa5ai" "watch-prices-inference.wasm" $INFERENCE_CADENCE "0x75F9F22D1070fDd56bD1DDF2DB4d65aB0F759431/51"
yes | allorad  tx emissions  request-inference $WHITELISTED_ADDRESS  '{"nonce": "4","topic_id":"4","cadence":"60","max_price_per_inference":"1","bid_amount":"10000","timestamp_valid_until":"'$(date -d "$(date -d '1 day' +%Y-%m-%d)" +%s)'"}
yes | allorad tx emissions reactivate-topic $WHITELISTED_ADDRESS 4

# fund head account and workers account
for address in "${ADDRESSES[@]}"; do
    echo "funding address: $address"
    curl -Lvvv https://faucet.$NETWORK.allora.network/send/edgenet/$address
done

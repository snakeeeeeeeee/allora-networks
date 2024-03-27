#!/bin/bash
set -eu

CLUSTER_DEPLOYED="staging-us-east-1"
CHAIN_ID="devnet"
AWS_REGION="us-east-1"

# ALLORAD="/usr/local/bin/allorad"
ALLORAD=$(which allorad)
keyringBackend=test

echo "initializing head configs"
docker run -it --entrypoint=bash -v "./head":/data 696230526504.dkr.ecr.us-east-1.amazonaws.com/allora-inference-base:dev-latest -c "mkdir -p /data/key && cd /data/key && allora-keys"
cat ./head/key/priv.bin | base64 > ./head/key/priv.base64

headKeySecret="${CLUSTER_DEPLOYED}--${CHAIN_ID}-heads--head-0--p2p-privatekey"
echo "saving head p2p privatekey to $headKeySecret"
if aws secretsmanager describe-secret --secret-id $headKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
    aws secretsmanager put-secret-value \
        --secret-id $headKeySecret --region $AWS_REGION \
        --secret-string file://head/key/priv.base64
else
    aws secretsmanager create-secret \
        --name $headKeySecret --region $AWS_REGION \
        --description "head priv.bin in base 64" \
        --secret-string file://head/key/priv.base64
fi

echo "generating allora account key for head"
$ALLORAD --home=./head keys add head --keyring-backend $keyringBackend > ./head/head.account_info 2>&1
headAlloraAccExport=$($ALLORAD --home=./head keys export head --unarmored-hex --unsafe --keyring-backend $keyringBackend)

headAlloraKeySecret="${CLUSTER_DEPLOYED}--${CHAIN_ID}-heads--head-0--allora-key"
echo "saving head allora key to $headAlloraKeySecret"
if aws secretsmanager describe-secret --secret-id $headAlloraKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
    aws secretsmanager put-secret-value \
        --secret-id $headAlloraKeySecret --region $AWS_REGION \
        --secret-string "$headAlloraAccExport"
else
    aws secretsmanager create-secret \
        --name $headAlloraKeySecret --region $AWS_REGION \
        --description "head allorad account's key export" \
        --secret-string "$headAlloraAccExport"
fi

# Array of worker names
workers=("coin-prediction" "coin-prediction-randomized" "index-provider" "nft-appraisals" "watch-prices" "coin-prediction-reputer")

for worker in "${workers[@]}"; do
    echo "generating allora account key for $worker"
    mkdir -p ./$worker
    $ALLORAD --home=./$worker keys add $worker --keyring-backend $keyringBackend > ./$worker/$worker.account_info 2>&1
    workerAlloraAccExport=$($ALLORAD --home=./$worker keys export $worker --unarmored-hex --unsafe --keyring-backend $keyringBackend)

    workerAlloraKeySecret="${CHAIN_ID}--$worker--allora-account"
    echo "saving $worker allora key to $workerAlloraKeySecret"
    if aws secretsmanager describe-secret --secret-id $workerAlloraKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
        aws secretsmanager put-secret-value \
            --secret-id $workerAlloraKeySecret --region $AWS_REGION \
            --secret-string "$workerAlloraAccExport"
    else
        aws secretsmanager create-secret \
            --name $workerAlloraKeySecret --region $AWS_REGION \
            --description "$worker allorad account's key export" \
            --secret-string "$workerAlloraAccExport"
    fi
done

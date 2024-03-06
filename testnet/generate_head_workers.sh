#!/bin/bash
set -eu

CLUSTER_DEPLOYED="prod-us-east-1"
CHAIN_ID="testnet"
AWS_REGION="us-east-1"

ALLORAD="/usr/local/bin/allorad"
keyringBackend=test

# echo "initializing head configs"
# docker run -it --entrypoint=bash -v "./head":/data 696230526504.dkr.ecr.us-east-1.amazonaws.com/allora-inference-base:dev-latest -c "mkdir -p /data/key && cd /data/key && allora-keys"
# cat ./head/key/priv.bin | base64 > ./head/key/priv.base64

# headKeySecret="${CLUSTER_DEPLOYED}--${CHAIN_ID}-heads--head-0--p2p-privatekey"
# echo "saving head p2p privatekey to $headKeySecret"
# if aws secretsmanager describe-secret --secret-id $headKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
#     aws secretsmanager put-secret-value \
#         --secret-id $headKeySecret --region $AWS_REGION \
#         --secret-string file://head/key/priv.base64
# else
#     aws secretsmanager create-secret \
#         --name $headKeySecret --region $AWS_REGION \
#         --description "head priv.bin in base 64" \
#         --secret-string file://head/key/priv.base64
# fi

# echo "generating allora account key for head"
# $ALLORAD --home=./head keys add head --keyring-backend $keyringBackend > ./head/head.account_info 2>&1
# headAlloraAccExport=$($ALLORAD --home=./head keys export head --unarmored-hex --unsafe --keyring-backend $keyringBackend)

# headAlloraKeySecret="${CLUSTER_DEPLOYED}--${CHAIN_ID}-heads--head-0--allora-key"
# echo "saving head allora key to $headAlloraKeySecret"
# if aws secretsmanager describe-secret --secret-id $headAlloraKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
#     aws secretsmanager put-secret-value \
#         --secret-id $headAlloraKeySecret --region $AWS_REGION \
#         --secret-string "$headAlloraAccExport"
# else
#     aws secretsmanager create-secret \
#         --name $headAlloraKeySecret --region $AWS_REGION \
#         --description "head allorad account's key export" \
#         --secret-string "$headAlloraAccExport"
# fi


# echo "generating allora account key for coin-prediction"
# mkdir -p ./coin-prediction
# $ALLORAD --home=./coin-prediction keys add coin-prediction --keyring-backend $keyringBackend > ./coin-prediction/coin-prediction.account_info 2>&1
# cpAlloraAccExport=$($ALLORAD --home=./coin-prediction keys export coin-prediction --unarmored-hex --unsafe --keyring-backend $keyringBackend)

# cpAlloraKeySecret="${CHAIN_ID}--coin-prediction--allora-account"
# echo "saving coin prediction allora key to $cpAlloraKeySecret"
# if aws secretsmanager describe-secret --secret-id $cpAlloraKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
#     aws secretsmanager put-secret-value \
#         --secret-id $cpAlloraKeySecret --region $AWS_REGION \
#         --secret-string "$cpAlloraAccExport"
# else
#     aws secretsmanager create-secret \
#         --name $cpAlloraKeySecret --region $AWS_REGION \
#         --description "coin prediction allorad account's key export" \
#         --secret-string "$cpAlloraAccExport"
# fi

# echo "generating allora account key for coin-prediction-randomized"
# mkdir -p ./coin-prediction-randomized
# $ALLORAD --home=./coin-prediction-randomized keys add coin-prediction-randomized --keyring-backend $keyringBackend > ./coin-prediction-randomized/coin-prediction-randomized.account_info 2>&1
# cprAlloraAccExport=$($ALLORAD --home=./coin-prediction-randomized keys export coin-prediction-randomized --unarmored-hex --unsafe --keyring-backend $keyringBackend)

# cprAlloraKeySecret="${CHAIN_ID}--coin-prediction-randomized--allora-account"
# echo "saving coin prediction randomized allora key to $cprAlloraKeySecret"
# if aws secretsmanager describe-secret --secret-id $cprAlloraKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
#     aws secretsmanager put-secret-value \
#         --secret-id $cprAlloraKeySecret --region $AWS_REGION \
#         --secret-string "$cprAlloraAccExport"
# else
#     aws secretsmanager create-secret \
#         --name $cprAlloraKeySecret --region $AWS_REGION \
#         --description "coin prediction randomized allorad account's key export" \
#         --secret-string "$cprAlloraAccExport"
# fi

# echo "generating allora account key for index-provider"
# mkdir -p ./index-provider
# $ALLORAD --home=./index-provider keys add index-provider --keyring-backend $keyringBackend > ./index-provider/index-provider.account_info 2>&1
# indexProviderAlloraAccExport=$($ALLORAD --home=./index-provider keys export index-provider --unarmored-hex --unsafe --keyring-backend $keyringBackend)

# indexProvAlloraKeySecret="${CHAIN_ID}--index-provider--allora-account"
# echo "saving index-provider allora key to $indexProvAlloraKeySecret"
# if aws secretsmanager describe-secret --secret-id $indexProvAlloraKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
#     aws secretsmanager put-secret-value \
#         --secret-id $indexProvAlloraKeySecret --region $AWS_REGION \
#         --secret-string "$indexProviderAlloraAccExport"
# else
#     aws secretsmanager create-secret \
#         --name $indexProvAlloraKeySecret --region $AWS_REGION \
#         --description "index-provider allorad account's key export" \
#         --secret-string "$indexProviderAlloraAccExport"
# fi

echo "generating allora account key for nft-appraisals"
mkdir -p ./nft-appraisals
$ALLORAD --home=./nft-appraisals keys add nft-appraisals --keyring-backend $keyringBackend > ./nft-appraisals/nft-appraisals.account_info 2>&1
nftAppraisalsAlloraAccExport=$($ALLORAD --home=./nft-appraisals keys export nft-appraisals --unarmored-hex --unsafe --keyring-backend $keyringBackend)

nftAppraisalsAlloraKeySecret="${CHAIN_ID}--nft-appraisals--allora-account"
echo "saving nft-appraisals allora key to $nftAppraisalsAlloraKeySecret"
if aws secretsmanager describe-secret --secret-id $nftAppraisalsAlloraKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
    aws secretsmanager put-secret-value \
        --secret-id $nftAppraisalsAlloraKeySecret --region $AWS_REGION \
        --secret-string "$nftAppraisalsAlloraAccExport"
else
    aws secretsmanager create-secret \
        --name $nftAppraisalsAlloraKeySecret --region $AWS_REGION \
        --description "nft-appraisals allorad account's key export" \
        --secret-string "$nftAppraisalsAlloraAccExport"
fi

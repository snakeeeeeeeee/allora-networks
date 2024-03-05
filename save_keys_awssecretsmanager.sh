#!/bin/bash
set -eux

CHAIN_ID="edgenet"     #* Chain to sync
VALIDATOR_NUMBER=3     #! Allign with the value in the CHAIN/generate_genesis.sh
valPreffix="val"       #! Allign with the value in the CHAIN/generate_genesis.sh
faucetAccount="faucet" #! Allign with the value in the CHAIN/generate_genesis.sh
keyringBackend=test    #! Allign with the value in the CHAIN/generate_genesis.sh

export AWS_PAGER=""    #* To disable pagination

AWS_REGION="us-east-1"
ARGOCD_CLUSTER_VALIDATORS_DEPLOYED="prod-us-east-1"

ALLORAD="/usr/local/bin/allorad"

savedSecrets=""

for ((i=0; i<$VALIDATOR_NUMBER; i++)); do
    valName="${valPreffix}${i}"

    secretPref="${ARGOCD_CLUSTER_VALIDATORS_DEPLOYED}--${CHAIN_ID}-validators--validator-${i}"

    alloraKeySecret="${secretPref}--allora-account"
    alloraAccExport=$($ALLORAD --home=$CHAIN_ID keys export $valName --unarmored-hex --unsafe --keyring-backend $keyringBackend)
    echo "Save $valName Allora account to $alloraKeySecret"

    if aws secretsmanager describe-secret --secret-id $alloraKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
        aws secretsmanager put-secret-value \
            --secret-id $alloraKeySecret --region $AWS_REGION \
            --secret-string "$alloraAccExport"
    else
        aws secretsmanager create-secret \
            --name $alloraKeySecret --region $AWS_REGION \
            --description "$valName allorad account's key export" \
            --secret-string "$alloraAccExport"
    fi

    savedSecrets="${savedSecrets}, $alloraKeySecret"

    valKeySecret="${secretPref}--priv_validator_key"
    echo "Save $valName priv_validator_key to $valKeySecret"

    if aws secretsmanager describe-secret --secret-id $valKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
        aws secretsmanager put-secret-value \
            --secret-id $valKeySecret --region $AWS_REGION \
            --secret-string file://${CHAIN_ID}/${valName}/config/priv_validator_key.json
    else
        aws secretsmanager create-secret \
            --name $valKeySecret --region $AWS_REGION \
            --description "$valName validators's priv_validator_key.json" \
            --secret-string file://${CHAIN_ID}/${valName}/config/priv_validator_key.json
    fi

    savedSecrets="${savedSecrets}, $valKeySecret"

    valKeySecret="${secretPref}--node_key"
    echo "Save $valName priv_validator_key to $valKeySecret"
    if aws secretsmanager describe-secret --secret-id $valKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
        aws secretsmanager put-secret-value \
            --secret-id $valKeySecret --region $AWS_REGION \
            --secret-string file://${CHAIN_ID}/${valName}/config/node_key.json
    else
        aws secretsmanager create-secret \
            --name $valKeySecret --region $AWS_REGION \
            --description "$valName validators's node_key.json" \
            --secret-string file://${CHAIN_ID}/${valName}/config/node_key.json
    fi
    savedSecrets="${savedSecrets}, $valKeySecret"

done

echo "Save FAUCET account"

alloraKeySecret="${CHAIN_ID}-faucet--allora-account"
alloraAccExport=$($ALLORAD --home=$CHAIN_ID keys export $faucetAccount --unarmored-hex --unsafe --keyring-backend $keyringBackend)
echo "Save $faucetAccount Allora account to $alloraKeySecret"

if aws secretsmanager describe-secret --secret-id $alloraKeySecret --region $AWS_REGION > /dev/null 2>&1 ; then
    aws secretsmanager put-secret-value \
        --secret-id $alloraKeySecret --region $AWS_REGION \
        --secret-string "$alloraAccExport"
else
    aws secretsmanager create-secret \
        --name $alloraKeySecret --region $AWS_REGION \
        --description "$faucetAccount allorad account's key export" \
        --force-overwrite-replica-secret \
        --secret-string "$alloraAccExport"
fi

savedSecrets="${savedSecrets}, $alloraKeySecret"

echo "Keys saved/updated to AWS secret manager: ${savedSecrets}"

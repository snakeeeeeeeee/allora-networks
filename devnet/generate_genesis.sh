#!/bin/bash
set -eu

CHAIN_ID="devnet"
DENOM="uallo"
VALIDATOR_TOKENS=1000000
FAUCET_TOKENS=1000000000000000000
VALIDATOR_NUMBER=1    #! Used in save_keys_awssecretsmanager.sh

ALLORAD=$(which allorad)
keyringBackend=test

faucetAccount="faucet"

valPreffix="val"       #! Used in save_keys_awssecretsmanager.sh  
alloraHome="./"
gentxDir=${alloraHome}/gentxs
mkdir -p $gentxDir

# echo "$alloraHome"
$ALLORAD --home=$alloraHome init mymoniker --chain-id $CHAIN_ID --default-denom ${DENOM}

#Create validators account
for ((i=0; i<$VALIDATOR_NUMBER; i++)); do
    valName="${valPreffix}${i}"

    echo "Generate $valName account"
    $ALLORAD --home=$alloraHome keys add $valName \
        --keyring-backend $keyringBackend > $valName.account_info 2>&1

    echo "Fund $valName account to genesis"
    $ALLORAD --home=$alloraHome genesis add-genesis-account \
        $valName ${VALIDATOR_TOKENS}${DENOM} \
        --keyring-backend $keyringBackend
done

echo "Generate $faucetAccount account"
$ALLORAD --home=$alloraHome keys add $faucetAccount \
    --keyring-backend $keyringBackend > $faucetAccount.account_info 2>&1

echo "Fund $faucetAccount account"
$ALLORAD --home=$alloraHome genesis add-genesis-account \
    $faucetAccount ${FAUCET_TOKENS}${DENOM} \
    --keyring-backend $keyringBackend

for ((i=0; i<$VALIDATOR_NUMBER; i++)); do
    echo "Initializing Validator $i"

    valName="${valPreffix}${i}"
    valHome="./$valName"
    mkdir -p $valHome

    $ALLORAD --home=$valHome init $valName --chain-id $CHAIN_ID --default-denom ${DENOM}

    # Symlink genesis to have the accounts
    gln -sfr config/genesis.json $valHome/config/genesis.json

    # Symlink keyring-test to have keys
    gln -sfr keyring-test $valHome/keyring-test

    $ALLORAD --home=$valHome genesis gentx $valName ${VALIDATOR_TOKENS}${DENOM} \
        --chain-id $CHAIN_ID --keyring-backend $keyringBackend \
        --moniker="$valName" \
        --from=$valName \
        --output-document $gentxDir/$valName.json
done

$ALLORAD --home=$alloraHome genesis collect-gentxs --gentx-dir $gentxDir

cp $alloraHome/config/genesis.json $alloraHome

echo "$CHAIN_ID genesis generated."

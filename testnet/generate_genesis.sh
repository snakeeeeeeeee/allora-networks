#!/bin/bash
set -eu

CHAIN_ID="testnet"
DENOM="uallo"

UPSHOT_WALLET_NAME="upshot"
UPSHOT_WALLET_TOKENS=$(echo '99*10^18' | bc)
FAUCET_WALLET_NAME="faucet"
FAUCET_WALLET_TOKENS=$(echo '10^18' | bc)

VALIDATOR_TOKENS=$(echo '(10^26 - 100*10^18)/3' | bc)
VALIDATOR_NUMBER=3                         #! Used in save_keys_awssecretsmanager.sh
COMMON_HOME_DIR="${COMMON_HOME_DIR:-$(pwd)}"

allorad=$(which allorad)
keyringBackend=test

valPreffix="validator"                      #! Used in save_keys_awssecretsmanager.sh
genesisHome="$COMMON_HOME_DIR/genesis"
gentxDir=${genesisHome}/gentxs
mkdir -p $gentxDir

$allorad --home=$genesisHome init mymoniker --chain-id $CHAIN_ID --default-denom ${DENOM}

#Create validators account
for ((i=0; i<$VALIDATOR_NUMBER; i++)); do
    valName="${valPreffix}${i}"

    echo "Generate $valName account"
    $allorad --home=$genesisHome keys add $valName \
        --keyring-backend $keyringBackend > $COMMON_HOME_DIR/$valName.account_info 2>&1

    echo "Fund $valName account to genesis"
    $allorad --home=$genesisHome genesis add-genesis-account \
        $valName ${VALIDATOR_TOKENS}${DENOM} \
        --keyring-backend $keyringBackend
done

echo "Generate $UPSHOT_WALLET_NAME account"
$allorad --home=$genesisHome keys add $UPSHOT_WALLET_NAME \
    --keyring-backend $keyringBackend > $COMMON_HOME_DIR/$UPSHOT_WALLET_NAME.account_info 2>&1

echo "Fund $UPSHOT_WALLET_NAME account"
$allorad --home=$genesisHome genesis add-genesis-account \
    $UPSHOT_WALLET_NAME ${UPSHOT_WALLET_TOKENS}${DENOM} \
    --keyring-backend $keyringBackend

echo "Generate $FAUCET_WALLET_NAME account"
$allorad --home=$genesisHome keys add $FAUCET_WALLET_NAME \
    --keyring-backend $keyringBackend > $COMMON_HOME_DIR/$FAUCET_WALLET_NAME.account_info 2>&1

echo "Fund $FAUCET_WALLET_NAME account"
$allorad --home=$genesisHome genesis add-genesis-account \
    $FAUCET_WALLET_NAME ${FAUCET_WALLET_TOKENS}${DENOM} \
    --keyring-backend $keyringBackend

for ((i=0; i<$VALIDATOR_NUMBER; i++)); do
    echo "Initializing Validator $i"

    valName="${valPreffix}${i}"
    valHome="$COMMON_HOME_DIR/$valName"
    mkdir -p $valHome

    $allorad --home=$valHome init $valName --chain-id $CHAIN_ID --default-denom ${DENOM}

    # Symlink genesis to have the accounts
    ln -sfr $genesisHome/config/genesis.json $valHome/config/genesis.json

    # Symlink keyring-test to have keys
    ln -sfr $genesisHome/keyring-test $valHome/keyring-test

    $allorad --home=$valHome genesis gentx $valName ${VALIDATOR_TOKENS}${DENOM} \
        --chain-id $CHAIN_ID --keyring-backend $keyringBackend \
        --moniker="$valName" \
        --from=$valName \
        --output-document $gentxDir/$valName.json
done

$allorad --home=$genesisHome genesis collect-gentxs --gentx-dir $gentxDir

cp $genesisHome/config/genesis.json $COMMON_HOME_DIR

echo "$CHAIN_ID genesis generated."

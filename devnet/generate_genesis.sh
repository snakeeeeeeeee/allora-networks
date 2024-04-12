#!/bin/bash
set -eu

CHAIN_ID="devnet"
DENOM="uallo"

UPSHOT_WALLET_NAME="upshot"
UPSHOT_WALLET_TOKENS=$(echo '99*10^18' | bc)
FAUCET_WALLET_NAME="faucet"
FAUCET_WALLET_TOKENS=$(echo '10^18' | bc)

VALIDATOR_TOKENS=$(echo '(10^26 - 100*10^18)/3' | bc)
VALIDATOR_NUMBER=3                    

allorad=$(which allorad)
keyringBackend=test

valPreffix="val" 
alloraHome="./"
gentxDir=${alloraHome}/gentxs
mkdir -p $gentxDir

# echo "$alloraHome"
$allorad --home=$alloraHome init mymoniker --chain-id $CHAIN_ID --default-denom ${DENOM}

#Create validators account
for ((i=0; i<$VALIDATOR_NUMBER; i++)); do
    valName="${valPreffix}${i}"

    echo "Generate $valName account"
    $allorad --home=$alloraHome keys add $valName \
        --keyring-backend $keyringBackend > $valName.account_info 2>&1

    echo "Fund $valName account to genesis"
    $allorad --home=$alloraHome genesis add-genesis-account \
        $valName ${VALIDATOR_TOKENS}${DENOM} \
        --keyring-backend $keyringBackend
done

echo "Generate $UPSHOT_WALLET_NAME account"
$allorad --home=$alloraHome keys add $UPSHOT_WALLET_NAME \
    --keyring-backend $keyringBackend > $UPSHOT_WALLET_NAME.account_info 2>&1

echo "Fund $UPSHOT_WALLET_NAME account"
$allorad --home=$alloraHome genesis add-genesis-account \
    $UPSHOT_WALLET_NAME ${UPSHOT_WALLET_TOKENS}${DENOM} \
    --keyring-backend $keyringBackend

echo "Generate $FAUCET_WALLET_NAME account"
$allorad --home=$alloraHome keys add $FAUCET_WALLET_NAME \
    --keyring-backend $keyringBackend > $FAUCET_WALLET_NAME.account_info 2>&1

echo "Fund $FAUCET_WALLET_NAME account"
$allorad --home=$alloraHome genesis add-genesis-account \
    $FAUCET_WALLET_NAME ${FAUCET_WALLET_TOKENS}${DENOM} \
    --keyring-backend $keyringBackend

for ((i=0; i<$VALIDATOR_NUMBER; i++)); do
    echo "Initializing Validator $i"

    valName="${valPreffix}${i}"
    valHome="./$valName"
    mkdir -p $valHome

    $allorad --home=$valHome init $valName --chain-id $CHAIN_ID --default-denom ${DENOM}

    # Symlink genesis to have the accounts
    gln -sfr config/genesis.json $valHome/config/genesis.json

    # Symlink keyring-test to have keys
    gln -sfr keyring-test $valHome/keyring-test

    $allorad --home=$valHome genesis gentx $valName ${VALIDATOR_TOKENS}${DENOM} \
        --chain-id $CHAIN_ID --keyring-backend $keyringBackend \
        --moniker="$valName" \
        --from=$valName \
        --output-document $gentxDir/$valName.json
done

$allorad --home=$alloraHome genesis collect-gentxs --gentx-dir $gentxDir

cp $alloraHome/config/genesis.json $alloraHome

echo "$CHAIN_ID genesis generated."

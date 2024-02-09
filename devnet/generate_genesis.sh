#!/bin/bash
set -exu

chainId="devnet"
APP_HOME="/data/tmp"
KEYRING_BACKEND=test
DENOM="uallo"

ALLORAD="/usr/local/bin/allorad"

mkdir -p $APP_HOME
#! If you run docker with -u `...` it need a writable HOME
export HOME=$APP_HOME

echo "Initializing Appchain"
allorad --home=$APP_HOME config set client chain-id $chainId
allorad --home=$APP_HOME config set client keyring-backend $KEYRING_BACKEND
allorad --home=$APP_HOME init mymoniker --chain-id $chainId --default-denom ${DENOM}

echo "Import Validators accounts"
validators2ImportFile="validators2import.txt"
fundsValidators=1000000

i=0
GENTXDIR=${APP_HOME}/config/genesis_txs
mkdir -p $GENTXDIR

cat $validators2ImportFile | while read v; do

    valName="validator$i"
    echo "Importing $valName"

    # allorad --home=$APP_HOME keys import-hex \
    #     --keyring-backend $KEYRING_BACKEND \
    #     "validator$i" $v

    allorad --home=$APP_HOME genesis add-genesis-account $valName ${fundsValidators}${DENOM} --keyring-backend $KEYRING_BACKEND
    allorad --home=$APP_HOME genesis gentx $valName ${fundsValidators}${DENOM} \
        --chain-id $chainId --keyring-backend $KEYRING_BACKEND \
        --moniker="$valName" \
        --from=$valName \
        --output-document $GENTXDIR/$valName.json

    i=$((i+1));
done

allorad --home=$APP_HOME genesis collect-gentxs --gentx-dir $GENTXDIR

echo "The genesis is in $APP_HOME/config"


        # --pubkey=$(allorad --home=$APP_HOME keys --keyring-backend=$KEYRING_BACKEND show $valNamez --pubkey) \

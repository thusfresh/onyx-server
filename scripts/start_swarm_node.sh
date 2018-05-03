#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <data-directory> <port=30999> <wsport=8546>"
  exit 1
fi

GIT_TAG="swarm-network-rewrite"
DATADIR="$1"
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
EXT_DEPS_DIR="$SCRIPTPATH/external_deps"
GODIR="$EXT_DEPS_DIR/go-ethereum"
PORT=${2:-30999}
WSPORT=${3:-8546}

mkdir -p "$EXT_DEPS_DIR"

if [[ ! -e $GODIR ]]; then
    echo "cloning the go-ethereum repo"
    cd "$EXT_DEPS_DIR"
    git clone --depth 1 https://github.com/ethersphere/go-ethereum.git -b $GIT_TAG
fi

cd "$GODIR"
# doing the fetch here and now makes sure that we can change the chosen
# commit hash without the risk of breaking the script
git fetch --depth 1 origin $GIT_TAG
git checkout $GIT_TAG
make geth
make swarm

if [[ ! -e $DATADIR/keystore ]]; then
  mkdir -p $DATADIR
  passphrase=`openssl rand -base64 32`
  echo $passphrase > $DATADIR/password
  $GODIR/build/bin/geth --datadir $DATADIR account new --password $DATADIR/password
fi

which jq
if [ $? -eq 0 ]
then
    KEY=$(jq --raw-output '.address' $DATADIR/keystore/*)
else
    printf "\n\nERROR: jq is required to run the startup script\n\n"
    exit 1
fi

$GODIR/build/bin/swarm \
<<<<<<< HEAD
    --store.size 1 \
    --store.cache.size 1 \
    --port $PORT \
    --datadir $DATADIR \
    --password $DATADIR/password \
    --verbosity 4 \
    --bzzaccount $KEY \
    --bootnodes enode://867ba5f6ac80bec876454caa80c3d5b64579828bd434a972bd8155060cac36226ba6e4599d955591ebdd1b2670da13cbaba3878928f3cd23c55a4e469a927870@13.79.37.4:30399 \
=======
    --datadir $GODIR/$DATADIR \
    --password $GODIR/$DATADIR/password \
    --verbosity 4 \
    --bzzaccount $KEY \
    --ens-api '' \
    --pss \
    --bzznetworkid 922 \
    --bootnodes enode://e834e83b4ed693b98d1a31d47b54f75043734c6c77d81137830e657e8b005a8f13b4833efddbd534f2c06636574d1305773648f1f39dd16c5145d18402c6bca3@52.51.239.180:30399 \
>>>>>>> one-click-deploy
    --ws \
    --wsport $WSPORT \
    --wsorigins '*'

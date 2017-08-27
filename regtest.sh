#!/bin/bash

# load code from regtestlib
. regtestlib.sh

for arg in $@
do
	case $arg in
		"-noipfs")
			noipfs=1
			;;
		"-nogeth")
			nogeth=1
			;;
		"-nobtc")
			nobtc=1
			;;
		"-nozec")
			nozec=1
			;;
	esac
done

trap cleanup EXIT

start_ipfs
start_bitcoin
start_zcash
#start_geth

btcaddr=$(btccli getnewaddress)
zecaddr=$(zeccli getnewaddress)
ethaddr=$(gethexec 'personal.newAccount("foo")' | tr -d '"')

echo "addrs:" $btcaddr $zecaddr $ethaddr


genmoreblocks() {
	while true
	do
		btccli generate 1 > /dev/null
		zeccli generate 1 > /dev/null
		sleep 1
	done
}

# continually 'mine'
genmoreblocks &

echo "blockchains activated! sleeping foreverish..."
sleep 10000000

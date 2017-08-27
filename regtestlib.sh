#!/bin/bash


export IPFS_PATH=$(mktemp -d)
BITCOINDIR=$(pwd)/bitcoindir
ZCASHDIR=$(pwd)/zcashdir
GETHDIR=$(pwd)/gethdir

if [ -z "$IPFS_API" ]; then
	export IPFS_API="localhost:5001"
fi

fail() {
	echo $@
	exit 1
}

btccli() {
	bitcoin-cli -datadir="$BITCOINDIR" -regtest -rpcserialversion=0 -rpcuser=user -rpcpassword=password $@
}

start_bitcoin() {
	if ! [ -z $nobtc ]; then return; fi
	echo "Starting bitcoin..."
	mkdir "$BITCOINDIR"
	bitcoind -datadir="$BITCOINDIR" -rpcserialversion=0 -regtest -rpcuser=user -rpcpassword=password  &
	echo $! > bitcoin_pid
	sleep 5
	for i in `seq 101`
	do
		printf "bitcoin block generate %d\r" $i
		btccli generate 1 > /dev/null
	done
	echo ""
}

stop_bitcoin() {
	if ! [ -z $nobtc ]; then return; fi
	if [ -e bitcoin_pid ]; then kill $(cat bitcoin_pid); fi
	rm -f bitcoin_pid
	rm -rf "$BITCOINDIR"
}

zeccli() {
	zcash-cli -datadir="$ZCASHDIR" -regtest $@
}

start_zcash() {
	if ! [ -z $nozec ]; then return; fi
	echo "Starting zcash..."
	mkdir "$ZCASHDIR"
	echo "rpcuser=user" > "$ZCASHDIR/zcash.conf"
	echo "rpcpassword=password" >> "$ZCASHDIR/zcash.conf"
	zcashd -datadir="$ZCASHDIR" -regtest -listen=0 &
	echo $! > zcash_pid
	sleep 5
	for i in `seq 101`
	do
		printf "zcash block generate %d\r" $i
		zeccli generate 1 > /dev/null
	done
	echo ""
}

stop_zcash() {
	if ! [ -z $nozec ]; then return; fi
	if [ -e zcash_pid ]; then kill $(cat zcash_pid); fi
	rm -f zcash_pid
	rm -rf "$ZCASHDIR"
}

gethexec() {
	geth --exec="$@" attach "$GETHDIR/geth.ipc"
}

start_geth() {
	if ! [ -z $nogeth ]; then return; fi
	echo "Starting geth..."
	mkdir "$GETHDIR"
	geth --datadir="$GETHDIR" --dev --ws 2> geth.log &
	echo $! > geth_pid
	sleep 5
	ethaddr=$(gethexec "personal.newAccount('foo')")
	gethexec "personal.unlockAccount(eth.accounts[0],'foo',0)"
	gethexec "miner.start()"
	echo "eth addr is" $ethaddr
}

stop_geth() {
	if ! [ -z "$nogeth" ]; then return; fi
	if [ -e geth_pid ]; then kill $(cat geth_pid); fi
	rm -rf "$GETHDIR"
	rm -f geth_pid 
}

start_ipfs() {
	if ! [ -z "$noipfs" ]; then return; fi
	ipfs init
	ipfs daemon --offline > ipfs.log &
	sleep 1
	echo $! > ipfs_pid
	kill -0 $(cat ipfs_pid) || fail "failed to start ipfs"
}

kill_ipfs() {
	if ! [ -z "${noipfs:-}" ]; then return; fi
	kill $(cat ipfs_pid)
	rm ipfs_pid
	rm -rf $IPFS_PATH
}


cleanup() {
	kill_ipfs
	stop_bitcoin
	stop_zcash
	stop_geth
}

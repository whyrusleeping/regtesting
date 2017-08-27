# regtesting

caution, readme WIP.

## Usage
Make sure you have bitcoind/-cli and zcashd/-cli installed and in your path,
then run `./regtest.sh`.  It should start up bitcoin and zcash (and geth too,
but its currently disabled in the script) in regtest mode, and start mining
blocks.

Once they are running, you can interact with the daemons via the api, or the
cli. I have made a couple helper scripts `btcc`, `zecc`, and `ethc` that
hopefully make the command line invocations a little easier.

Pressing ctrl-C on the regtest.sh process should properly shut everything down.

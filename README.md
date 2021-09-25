# FlightSurety

FlightSurety is a sample application project for Udacity's Blockchain course.

## Install

This repository contains Smart Contract code in Solidity (using Truffle), tests (also using Truffle), dApp scaffolding (using HTML, CSS and JS) and server app scaffolding.

To install, download or clone the repo, then:

`npm install`
`truffle compile`

## Develop Client

To run truffle tests:

`truffle test ./test/flightSurety.js`
`truffle test ./test/oracles.js`

To use the dapp:

`truffle migrate`
`npm run dapp`

To view dapp:

`http://localhost:8000`

## Develop Server

`npm run server`
`truffle test ./test/oracles.js`

## Deploy

To build dapp for prod:
`npm run dapp:prod`

Deploy the contents of the ./dapp folder

## Notes
 when Running the frontend
 `http://localhost:8000`
 the flightID should be entered in bytes32 format or you will get error for exampple use below:
 `0x0000000000000000000000000000000000000000000000000000000000000043`

 Note : The frontend doesnt detect from which metamask account you choose to send

 To Find which address had been used go to contract.js file and change it manaully 

 `// Senders Account`

 `Origin = "0x627306090abaB3A6e1400e9345bC60c78a8BEf57";`

 `airlineAccount = "0xf17f52151EbEF6C7334FAD080c5704D77216b732";`

 `passengerAccount = "0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef";`
 


## Resources

* [How does Ethereum work anyway?](https://medium.com/@preethikasireddy/how-does-ethereum-work-anyway-22d1df506369)
* [BIP39 Mnemonic Generator](https://iancoleman.io/bip39/)
* [Truffle Framework](http://truffleframework.com/)
* [Ganache Local Blockchain](http://truffleframework.com/ganache/)
* [Remix Solidity IDE](https://remix.ethereum.org/)
* [Solidity Language Reference](http://solidity.readthedocs.io/en/v0.4.24/)
* [Ethereum Blockchain Explorer](https://etherscan.io/)
* [Web3Js Reference](https://github.com/ethereum/wiki/wiki/JavaScript-API)
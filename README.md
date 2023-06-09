## Table of Contents

- [Task Description](#task-description)
- [Tasks Included](#tasks-included)
- [Technologies Included](#technologies-included)
- [Hardhat Setup](#hardhat-setup)
- [Testing](#testing)

## Task Description

-Develop a smart contract-based escrow system for secure and automated payments in a peer-to-peer marketplace. -The system should include features such as dispute resolution and multi-signature transactions.

## Technologies Included

- Solidity for smart contracts
- Hardhat for compiling, testing and deploying contract on testnet sepolia
- Chai framework for testing contract functions on hardhat
- ethers.js library to deploy contract and for event listening

## Hardhat Setup

Run npm install hardhat to install hardhat.

```
npm install hardhat
```

Run npm install '@nomiclabs/hardhat-etherscan' to install hardhat plugin for verifying contracts on etherscan.

```
npm install '@nomiclabs/hardhat-etherscan'
```

Run npm i @nomiclabs/hardhat-ethers to install plugin which brings Hardhat the Ethereum library ethers.js, which allows to interact with the Ethereum blockchain

```
Run npm i @nomiclabs/hardhat-ethers
```

Run npx hardhat to run the hardhat in application.

```
npx hardhat
```

This project demonstrates an hardhat use case, integrating other tools commonly used alongside Hardhat in the ecosystem.

Try running some of the following tasks:

Run npx hardhat compile to compile all contracts.

```
npx hardhat compile
```

Run npx hardhat run scripts/deploy.js --network sepolia to deploy contracts on network sepolia.

```
npx hardhat run scripts/deploy.js --network sepolia
```

Run npx hardhat verify --network sepolia <deployed contract address> to verify the deployed contracts on network sepolia.

```
npx hardhat verify --network sepolia <deployed contract address>

```

## Testing

Run npx hardhat test --network hardhat for unit testing smart contract on hardhat

```
npx hardhat test
```

Expecting Test result.

```

  Escrow
    ✔ should create a new escrow (77ms)
    ✔ should deposit funds into an existing escrow (41ms)
    ✔ should release funds from an escrow to the seller (60ms)
    ✔ should initiate a dispute for an escrow (39ms)
    ✔ should resolve a dispute for an escrow (91ms)


  5 passing

```

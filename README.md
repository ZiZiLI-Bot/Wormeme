# Wormeme

EVM Smart Contracts and SVM Programs facilitate the buying, selling, or creation of meme tokens directly on Solana, simplifying and accelerating the process. You can pay fees and swap tokens directly with your ERC20 or ETH tokens.

## Features

- Easy swap meme tokens on solana network
- Create new meme token on solana with any token you have (ETH, USDT, USDC, W, ...)
- High Security and Performance with Cross-Chain Messaging Wormhole

## How to work - Process for Creating or Purchasing Meme Tokens on Solana

1. **Deposit Tokens to EVM Contract**  
   Users on the EVM network can deposit ETH or supported ERC20 tokens into the contract. Once deposited, the tokens are "locked" in the contract, securing the funds for the next steps.

2. **Send Message Through Wormhole**  
   After the deposit is completed, the contract will call the `sendMessage` method to send a message to the Solana network via the Wormhole Core. This message includes the necessary information for the user's request to create or purchase a token.

3. **Process on the Solana Network**  
   The program on the Solana network (SVM) receives the message from Wormhole. Once received, the program will perform the following steps:

   - Withdraw a specified amount of SOL from the program’s Vault (pre-configured) to proceed with the token purchase or creation as requested.
   - Deliver the meme tokens to the user's account on Solana, completing the transaction.

By leveraging Wormhole and integrating with Solana, this setup allows users on the EVM network to seamlessly interact to create or purchase tokens on Solana, expanding cross-chain interoperability.

![Alt text](https://api.minio.chuhung.com/demo/Screenshot%202024-11-03%20100156.png 'DEMO')

## Install

Wormeme requires:

- [Node.js](https://nodejs.org/) v20+ to run.
- Anchor, Rust, Solana CLI

---

- EVM

```sh
cd evm
yarn
forge install wormhole-foundation/wormhole-solidity-sdk
npx hardhat compile
```

- SVM

```sh
cd svm
yarn anchor build
```

## Resource

[Wormhole Core Contracts](https://wormhole.com/docs/build/contract-integrations/core-contracts/)
[Hardhat documents](https://hardhat.org/)
[Anchor documents](https://www.anchor-lang.com/)

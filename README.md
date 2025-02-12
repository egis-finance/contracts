# Egis Finance Shared Security Contracts Core

This repository contains the core smart contracts for Egis Finance's shared security infrastructure.  This MVP provides a staking pool and a reward distribution mechanism.

## Contracts

- **`EgisPool.sol`**: This contract manages the staking pool.  Users can stake ETH to become operators and participate in securing the system. Operators can register EVEs (External Verification Entities) and claim rewards.

- **`EgisRewards.sol`**: This library contains functions for calculating rewards based on operator stake and total staked amount.  It ensures fair and precise reward distribution.

## Usage

The contracts are built using Foundry.  To get started:

1. **Clone the repository:** `git clone <repository_url>`
2. **Install Foundry:** Follow the instructions at [https://book.getfoundry.sh/](https://book.getfoundry.sh/)
3. **Install dependencies:** `forge install`
4. **Build the contracts:** `forge build`
5. **Run the tests:** `forge test`

## Testing

[![Tests](https://github.com/egis-finance/contracts/actions/workflows/test.yml/badge.svg)](https://github.com/egis-finance/contracts/actions/workflows/test.yml)


## License

MIT License


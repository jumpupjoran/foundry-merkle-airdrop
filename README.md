# Merkle Airdrop Project

This repository contains a gas-optimized airdrop project that enables users to claim tokens without paying the gas fee themselves. We achieve gas savings by utilizing a Merkle tree to verify eligibility, thus minimizing unnecessary storage and costs.

- [Merkle Airdrop Project](#merkle-airdrop-project)
  - [Getting Started](#getting-started)
    - [Requirements](#requirements)
    - [Quickstart](#quickstart)
    - [Generate Merkle Proofs](#generate-merkle-proofs)
    - [Deploy to Anvil](#deploy-to-anvil)
    - [Sign Claim](#sign-claim)
    - [Updating `Interact.s.sol`](#updating-interactssol)
    - [Execute the claim](#execute-the-claim)
    - [check the balance](#check-the-balance)
  - [Disclaimer](#disclaimer)
    - [License](#license)

## Getting Started

### Requirements

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
  Confirm installation by running `git --version`.
- [Foundry](https://getfoundry.sh/)  
  Confirm installation by running `forge --version`.

  ### Quickstart

1. Clone the repository:

   ```bash
   git clone https://github.com/jumpupjoran/foundry-merkle-airdrop
   cd merkle-airdrop
   ```

2. install dependencies an build:
   ```bash
    make  # or `forge install && forge build` if you don’t have Make
   ```

### Generate Merkle Proofs

To update the Merkle tree with a new set of addresses and generate proofs:

1. Modify the `whitelist` array in `GenerateInput.s.sol` if you want to use a custom list.
2. Run:
   ```bash
   make merkle
   ```
3. Retrieve the Merkle root from `output.json` and update `s_merkleRoot` in `DeployMerkleAirdrop.s.sol`.

### Deploy to Anvil

To deploy the contracts locally:

1. Start a local Anvil node:

   ```bash
   make anvil
   ```

2. In a new terminal, deploy the contracts:

   ```bash
   make deploy
   ```

### Sign Claim

1. Prepare the claim signature in a separate terminal:

```bash
make sign
```

### Updating `Interact.s.sol`

1. Copy the signature bytes (without the 0x prefix) and update `SIGNATURE` in Interact.s.sol accordingly.
2. Copy the merkle proofs of the account you want to claim with and paste them in to `PROOF_ONE` and`PROOF_TWO` in `Interact.s.sol`.

### Execute the claim

```bash
make claim
```

### check the balance

Verify the balance of the claiming address:

```bash
make balance
```

---

## Disclaimer

This project was developed as part of the [Cyfrin Updraft Advanced Foundry Course](https://updraft.cyfrin.io/).

**Note:** This code is intended for educational purposes and has not undergone extensive testing. It is not recommended for use with real funds.

### License

This project is licensed under the MIT License.

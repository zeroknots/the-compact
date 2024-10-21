# The Compact 🤝
 - **Compact** *[noun]*: an agreement or covenant between two or more parties.
 - **Compact** *[transitive verb]*: to make up by connecting or combining.
 - **Compact** *[adjective]*: occupying a small volume by reason of efficient use of space.

> :warning: This is an early-stage contract under active development; it has not yet been properly tested, reviewed, or audited.

## Summary
The Compact is an ownerless ERC6909 contract that facilitates the voluntary formation (and, if necessary, eventual dissolution) of resource locks.

Resource locks are entered into by ERC20 or native token holders, called the "sponsor". Once a resource lock has been established, sponsors can commit to allow interested parties to claim their tokens through an "arbiter" indicated by the sponsor that attests to the specified conditions having been met.

These resource locks are mediated by "allocators" who are tasked with attesting to the availability of the underlying token balances and preserving the balances required for the commitments they have attested to; in other words, allocators ensure that sponsors do not "double-spend," transfer, or withdraw any token balances that are already committed to a specific intent.

Once a sponsor and their designated allocator have both committed to a claimable token condition, a "claimant" may then immediately perform the attached condition (such as delivering another token on some destination chain) and then claim the allocated tokens by calling the associated arbiter, which will verify and mediate the terms and conditions of the intent and relay the confirmation to The Compact.

The Compact effectively "activates" any deposited tokens to be instantly spent or swapped across arbitrary, asynchronous environments as long as:
 - the claimant is confident that the allocator is sound and will not leave the resource lock underallocated,
 - the sponsor and the claimant are both confident that the arbiter is sound and will not report erroneously, and
 - the sponsor is confident that the allocator will not unduly censor fully allocated requests.

Sponsors have recourse from potential censorship in the form of a "forced withdrawal." When depositing tokens into a resource lock, the sponsor provides a "reset period" as a parameter. Then, the sponsor can initiate a forced withdrawal at any point; after the reset period has elapsed, the full token balance can be withdrawn regardless of any pending claims on their balance. In the case of cross-chain swaps, reset periods only need to be long enough for the claim to finalize (generally some multiple of the slowest blockchain involved in the swap).

Claimants must bear varying degrees of trust assumptions with regards to allocators, with the potential design space including reputation-based systems, trusted execution environments, smart-contract-based systems, or even dedicated rollups. The Compact takes a neutral stance on implementations of both allocators and arbiters, and instead treats them both as a "black box" but each with a simple and consistent interface.

## Setup
```
# install foundry if needed
$ curl -L https://foundry.paradigm.xyz | bash

# clone repo
$ git clone git@github.com:Uniswap/the-compact.git && cd the-compact

# install dependencies & libraries
$ forge install

# run basic tests
$ forge test
```

## Usage
### 1) Register an Allocator
To begin using The Compact, an allocator must first be registered on the contract. Anyone can register any account as an allocator by calling the `__register` function as long as one of the following requirements are met:
 - the allocator being registered is the caller
 - the allocator being registered is a contract with code deployed to it
 - a `CREATE2` address derivation proof for the allocator's address is provided as part of the call.

Once an allocator has been registered on a given chain for the first time, it will be assigned a 92-bit "allocator ID" that resource locks will use to reference it.

> Note that multiple allocators may register the same allocator ID across different chains if their addresses are very similar; a mechanic for collision resistance is available whereby the number of leading zero "nibbles" above three is encoded in the first four bits of the allocator ID. This implies that any allocator with nine leading zero bytes has a unique allocator ID.

A given allocator only needs to be registered once per chain and can then be utilized by many different resource locks.

The allocator's primary function is to ensure that any resource locks it is assigned to are not "double-spent" — this entails ensuring that sufficient unallocated balance is available before cosigning on any requests to withdraw or transfer the balance or to sponsor a claim on that balance, and also ensuring that nonces are not reused.

### 2) Deposit tokens
To enter into The Compact and create resource locks, a depositor begins by selecting for their four preferred properties for the lock:
 - the underlying token held in the resource lock
 - the allocator tasked with cosigning on claims against the resource locks and ensuring that the resource lock is not "double-spent" in any capacity, indicated by its registered allocator ID
 - the "scope" of the resource lock (either spendable on any chain or limited to a single chain, with a default option of being spendable on any chain)
 - the "reset period" for forceably exiting the lock and withdrawing the funds without the allocator's approval (one of eight preset values ranging from one second to thirty days, with a default option of ten minutes)

Each unique combination of these four properties is represented by a fungible ERC6909 tokenID.

Depending on the selected properties of the resource lock, the number of tokens being placed into resource locks, and the source of token allowances for those tokens, the depositor then calls one of seven `deposit` functions:
 - a basic, payable deposit function that uses native tokens and the default scope and reset period parameters and supplies an allocator for the resource lock, where the caller is the recipient of the 6909 tokens representing ownership of the lock
 - a basic, non-payable deposit function that supplies an ERC20 token (with sufficient allowance set directly on The Compact) and amount to deposit in the resource lock, along with an allocator and the default scope and reset period parameters, where the caller is the recipient of the 6909 tokens representing ownership of the lock
 - a payable deposit function that uses native tokens and specifies the allocator, the scope, the reset period, and the recipient of the 6909 tokens representing ownership of the lock
  - a non-payable deposit function that supplies an ERC20 token (with sufficient allowance set directly on The Compact) and amount to deposit in the resource lock, and that specifies the allocator, the scope, the reset period, and the recipient of the 6909 tokens representing ownership of the lock
 - a payable deposit function that specifies an array of 6909 IDs representing resource locks and deposit amounts for each id (with sufficient allowance set directly on The Compact for each ERC20 token) and the recipient of the 6909 tokens representing ownership of each lock
 - a non-payable deposit function that supplies an ERC20 token, amount, and associated Permit2 signature data (with sufficient allowance set on Permit2), and that specifies the allocator, the scope, the reset period, and the recipient of the 6909 tokens representing ownership of the lock (all of which are included as part of the Permit2 witness)
 - a payable deposit function that supplies an array of tokens and amounts (including an optional native token followed by any number of ERC20 tokens), and associated Permit2 batch signature data (with sufficient allowance set on Permit2 for each ERC20 token), and that specifies the allocator, the scope, the reset period, and the recipient of the 6909 tokens representing ownership of each lock (all of which are included as part of the Permit2 witness).

 > For ERC20 deposits, the amount of 6909 tokens minted is based on the actual token balance change after making the deposit, not the supplied amount; this enables support for making deposits of fee-on-transfer tokens where the fee is deducted from the recipient.

As long as allocators generally operate in an honest and reliable manner, this is the only direct interaction that end users will need to take; furthermore, in the case of the Permit2 deposit methods, the interaction can be made in a gasless fashion (where another party relays the signed message on behalf of the depositor).

### 3a) Forced Withdrawals
...
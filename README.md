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

 > For ERC20 deposits, the amount of 6909 tokens minted is based on the change in the actual token balance held by The Compact after making the deposit, not the supplied amount; this enables support for making deposits of fee-on-transfer tokens where the fee is deducted from the recipient.

As long as allocators generally operate in an honest and reliable manner, this is the only direct interaction that end users will need to take; furthermore, in the case of the Permit2 deposit methods, the interaction can be made in a gasless fashion (where another party relays the signed message on behalf of the depositor).

### X) Perform a Forced Withdrawal
At any point after depositing tokens, if an allocator goes down or refuses to cosign for a given claim against a resource lock, the depositor can initiate and process a forced withdrawal subject to the reset period on the resource lock.

First, the depositor calls `enableForcedWithdrawal` and supplies the ID of the associated resource lock. At this point, their allocator will almost certainly cease cosigning for any sponsored claims from that depositor, and fillers will similarly avoid fulfilling new claim requests, but any inflight claims will still be able to be processed as long as the reset period on the resource lock is sufficient.

Next, the depositor calls `forcedWithdrawal` and supplies the id, amount, and recipient; assuming the reset period has transpired from the point when the forced withdrawal was enabled, the underlying tokens will be sent to the recipient and a corresponding amount of 6909 tokens held by the caller will be burned.

 > For ERC20 withdrawals, the amount of 6909 tokens burned is based on the change in the actual token balance held by The Compact after making the withdrawal, not the supplied amount; this enables support for making withdrawals of fee-on-transfer tokens where the fee is deducted from the sender.

 Finally, if the original depositor wants to "reactivate" the resource lock, they can call `disableForcedWithdrawal` and supply the ID of the resource lock, returning the lock to the default state and preventing forced withdrawals until it is reactivated again.

### Y) Perform a Standard Transfer
Each ERC6909 token ID representing a specific set of resource lock parameters can be transferred like any other token; however, there is one additional requirement that must be met. The Compact will perform a call to the allocator before performing the transfer, and that allocator must attest to the transfer before it can proceed; this is necessary to prevent the invalidation of inflight claims on the resource lock.

```solidity
interface IAllocator {
    // Called on standard transfers; must return this function selector (0x1a808f91).
    function attest(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external returns (bytes4);
}
```

> Note: this is a stateful callback; care must be taken on the part of the allocator to avoid situations that could lead to an overallocated outcome via reentrancy or other unintended side effects.

 ### 3) Sign a Compact
 In the default case, the owner and allocator of a resource lock both agree on a given course of action and attest to it by signing one of three EIP-712 payloads:
  - a **Compact** deals with a specific resource lock and designates an **arbiter** tasked with verifying that the necessary conditions have been met choosing which accounts will receive the tokens and in what quantities
  - a **BatchCompact** deals with a set of resource locks on a single chain and also designates an arbiter
  - a **MultichainCompact** deals with a set of resource locks across multiple chains and designates a distinct arbiter for each chain.

In this context, the owner is referred to as the **sponsor** as they are sponsoring a claim against the resource lock, and the beneficiary or recipient of the claim is referred to as the **claimant**.

```solidity
// Message signed by the sponsor that specifies the conditions under which their
// tokens can be claimed; the specified arbiter verifies that those conditions
// have been met and specifies a set of beneficiaries that will receive up to the
// specified amount of tokens.
struct Compact {
    address arbiter; // The account tasked with verifying and submitting the claim.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 amount; // The amount of ERC6909 tokens to allocate.
    // Optional witness may follow.
}

// Message signed by the sponsor that specifies the conditions under which a set of
// tokens, each sharing an allocator, can be claimed; the specified arbiter verifies
// that those conditions have been met and specifies a set of beneficiaries that will
// receive up to the specified amounts of each token.
struct BatchCompact {
    address arbiter; // The account tasked with verifying and submitting the claim.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    uint256[2][] idsAndAmounts; // The allocated token IDs and amounts.
    // Optional witness may follow.
}

// A multichain compact can declare tokens and amounts to allocate from multiple chains,
// each designated by their chainId. Any allocated tokens must designate the Multichain
// scope. Each allocation may designate a unique arbiter for the chain in question.
struct Allocation {
    address arbiter; // The account tasked with verifying and submitting the claim.
    uint256 chainId;
    uint256[2][] idsAndAmounts; // The allocated token IDs and amounts.
    // Optional witness may follow.
}

// Message signed by the sponsor that specifies the conditions under which a set of
// tokens across a number of different chains can be claimed; the specified arbiter on
// each chain verifies that those conditions have been met and specifies a set of
// beneficiaries that will receive up to the specified amounts of each token.
struct MultichainCompact {
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    Allocation[] allocations;
}
```

To be considered valid, each compact must meet the following requirements:
 - the arbiter must submit the call (`arbiter == msg.sender`)
 - the sponsor must sign the EIP-712 payload (either ECDSA or EIP-1271) or submit the call (i.e. `arbiter == sponsor`)
 - the allocator must sign the EIP-712 payload (either ECDSA or EIP-1271) or a qualified payload referencing it, or submit the call (i.e. `arbiter == allocator`)
 - the compact cannot be expired (`expires > block.timestamp`)
 - the nonce cannot have been used previously

Once this payload has been signed by both the sponsor and the allocator (or at least by one party if the other is the intended caller), a claim can be submitted against it by the designated arbiter using a wide variety of functions (104 to be exact) depending on the type of compact and the intended result.

### 4 Submit a Claim
...
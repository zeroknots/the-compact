# The Compact 🤝
**Compact** *[noun]*: an agreement or covenant between two or more parties.
**Compact** *[transitive verb]*: to make up by connecting or combining.
**Compact** *[adjective]*: occupying a small volume by reason of efficient use of space.

> :warning: This is an early-stage contract under active development; it has not yet been properly tested, reviewed, or audited.

## Summary
The Compact is an ownerless ERC6909 contract that facilitates the voluntary formation (and, if necessary, involuntary dissolution) of "resource locks."

Resource locks are entered into by ERC20 or native token holders. Once a resource lock has been established, holders can commit to allow interested parties to claim their tokens once an "oracle" indicated by the token holder has attested to the specified conditions.

These resource locks are mediated by "allocators" who are tasked with attesting to the availability of the underlying token balances and preserving the balances required for the commitments they have attested to; in other words, allocators ensure that token holders do not "double-spend," transfer, or withdraw any token balances that are already committed to a specific intent.

Once a token holder and their designated allocator have both committed to a claimable token condition, a "claimant" may then immediately perform the attached condition (such as delivering another token on some destination chain) and then claim the allocated tokens upon attestation from the oracle mediating that condition.

The Compact effectively "activates" any deposited tokens to be instantly spent or swapped across arbitrary, asynchronous environments as long as:
 - the claimant is confident that the allocator is sound and will not leave the resource lock underallocated,
 - the token owner and the claimant are both confident that the oracle is sound and will not report erroneously, and
 - the token owner is confident that the allocator will not unduly censor fully allocated requests.

Token owners have recourse from potential censorship in the form of a "forced withdrawal." When depositing tokens into a resource lock, the token owner provides a "reset period" as a parameter. Then, the token owner can initiate a forced withdrawal at any point; after the reset period has elapsed, the full token balance can be withdrawn regardless of any pending claims on their balance. In the case of cross-chain swaps, reset periods only need to be long enough for the claim to finalize (generally some multiple of the slowest blockchain involved in the swap).

Claimants must bear varying degrees of trust assumptions with regards to allocators, with the potential design space including reputation-based systems, trusted execution environments, smart-contract-based systems, or even dedicated rollups. The Compact takes a neutral stance on implementations of both allocators and oracles, and instead treats them both as a "black box" but each with a simple and consistent interface.

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

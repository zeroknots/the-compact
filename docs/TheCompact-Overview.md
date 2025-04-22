# The Compact — Overview

The Compact is an ownerless ERC6909 contract that facilitates the voluntary formation and mediation of reusable "resource locks." It enables tokens to be credibly committed to be spent in exchange for performing actions across arbitrary, asynchronous environments, and claimed once the specified conditions have been met.

This document provides a detailed overview of the interfaces in The Compact protocol (Version 1), including their functions and how they interact with each other.

## Table of Contents

1. [ITheCompact](#ithecompact) - Core Interface
2. [ITheCompactClaims](#ithecompactclaims) - Claims Interface
3. [IAllocator](#iallocator) - Allocator Interface
4. [IEmissary](#iemissary) - Emissary Interface
5. [Key Concepts](#key-concepts) - Detailed explanation of core concepts
   - [Resource Locks](#resource-locks)
   - [Allocators](#allocators)
   - [Arbiters](#arbiters)
   - [Emissaries](#emissaries)
   - [Forced Withdrawals](#forced-withdrawals)
   - [Registration](#registration)
   - [Claimant Structure](#claimant-structure)

## ITheCompact

The core interface for The Compact protocol, which is an ownerless ERC6909 contract that facilitates the voluntary formation and mediation of reusable "resource locks".

Resource locks are entered into by ERC20 or native token holders (called the **depositor**). Once a resource lock has been established, the owner of the ERC6909 token representing a resource lock can act as a **sponsor** and create a **compact**. A compact is a commitment allowing interested parties to claim their tokens through the sponsor's indicated **arbiter**. The arbiter is then responsible for processing the claim once it has attested to the specified conditions of the compact having been met.

### Overview

ITheCompact provides functions for:
- Making deposits (native tokens, ERC20 tokens)
- Performing allocated transfers and withdrawals
- Initiating and performing forced withdrawals
- Registering compact claim hashes and typehashes
- Assigning emissaries as a fallback for verifying compacts
- Registering allocators
- Enabling allocators to consume nonces directly

### Key Events

```solidity
event Claim(
    address indexed sponsor, 
    address indexed allocator, 
    address indexed arbiter, 
    bytes32 claimHash, 
    uint256 nonce
);
```
Emitted when a claim is processed. This event is triggered when any of the claim functions in ITheCompactClaims are successfully executed. It provides information about who sponsored the claim, which allocator mediated it, which arbiter processed it, the claim hash, and the nonce consumed.

```solidity
event NonceConsumedDirectly(address indexed allocator, uint256 nonce);
```
Emitted when an allocator directly consumes a nonce by calling the `consume` function. This prevents the nonce from being used in future claims and is a way for allocators to proactively invalidate pending compacts without disclosing their contents.

```solidity
event ForcedWithdrawalStatusUpdated(
    address indexed account, 
    uint256 indexed id, 
    bool activating, 
    uint256 withdrawableAt
);
```
Emitted when the forced withdrawal status for a resource lock changes. This happens when a sponsor calls `enableForcedWithdrawal` (activating = true) or `disableForcedWithdrawal` (activating = false). The withdrawableAt timestamp indicates when the forced withdrawal will become executable.

```solidity
event CompactRegistered(address indexed sponsor, bytes32 claimHash, bytes32 typehash);
```
Emitted when a compact is registered directly through one of the registration functions. This event is triggered by calls to `register`, `registerMultiple`, or any of the combined deposit and register functions. It provides information about the sponsor, the claim hash, and the typehash of the registered compact.

```solidity
event AllocatorRegistered(uint96 allocatorId, address allocator);
```
Emitted when a new allocator is registered through the `__registerAllocator` function. This event provides the unique allocatorId assigned to the allocator and the allocator's address.

```solidity
event EmissaryAssigned(address indexed sponsor, bytes12 indexed lockTag, address emissary);
```
Emitted when a sponsor assigns an emissary for a specific lock tag by calling the `assignEmissary` function. This event provides information about the sponsor, the lock tag, and the assigned emissary address.

### Deposit Functions

#### Native Token Deposits

```solidity
function depositNative(bytes12 lockTag, address recipient) external payable returns (uint256 id);
```
Deposits native tokens into a resource lock with custom reset period and scope parameters. The ERC6909 token amount received by the recipient will match the amount of native tokens sent with the transaction.

#### ERC20 Token Deposits

```solidity
function depositERC20(
    address token, 
    bytes12 lockTag, 
    uint256 amount, 
    address recipient
) external returns (uint256 id);
```
Deposits ERC20 tokens into a resource lock with custom reset period and scope parameters. The caller must directly approve The Compact to transfer a sufficient amount of the ERC20 token on its behalf.

#### Batch Deposits

```solidity
function batchDeposit(
    uint256[2][] calldata idsAndAmounts, 
    address recipient
) external payable returns (bool);
```
Deposits multiple tokens in a single transaction. The first entry in idsAndAmounts can optionally represent native tokens by providing the null address and an amount matching msg.value.

#### Permit2 Deposits

```solidity
function depositERC20ViaPermit2(
    ISignatureTransfer.PermitTransferFrom calldata permit,
    address depositor,
    bytes12 lockTag,
    address recipient,
    bytes calldata signature
) external returns (uint256 id);
```
Deposits ERC20 tokens using Permit2 authorization. The depositor must approve Permit2 to transfer the tokens on its behalf unless the token automatically grants approval to Permit2.

```solidity
function batchDepositViaPermit2(
    address depositor,
    ISignatureTransfer.TokenPermissions[] calldata permitted,
    DepositDetails calldata details,
    address recipient,
    bytes calldata signature
) external payable returns (uint256[] memory ids);
```
Deposits multiple tokens using Permit2 authorization in a single transaction.

### Transfer Functions

```solidity
function allocatedTransfer(AllocatedTransfer calldata transfer) external returns (bool);
```
Transfers or withdraws ERC6909 tokens to multiple recipients with allocator approval.

```solidity
function allocatedBatchTransfer(AllocatedBatchTransfer calldata transfer) external returns (bool);
```
Transfers or withdraws ERC6909 tokens from multiple resource locks to multiple recipients with allocator approval.

### Registration Functions

```solidity
function register(bytes32 claimHash, bytes32 typehash) external returns (bool);
```
Registers a claim hash and its associated EIP-712 typehash. The registered claim hash will remain valid for the duration of the shortest reset period across all locks on the compact.

```solidity
function registerMultiple(bytes32[2][] calldata claimHashesAndTypehashes) external returns (bool);
```
Registers multiple claim hashes and their associated EIP-712 typehashes in a single call.

```solidity
function registerFor(
    address sponsor,
    address token,
    bytes12 lockTag,
    uint256 amount,
    address arbiter,
    uint256 nonce,
    uint256 expires,
    bytes32 typehash,
    bytes32 witness,
    bytes calldata sponsorSignature
) external returns (uint256 id, bytes32 claimHash);
```
Registers a claim on behalf of a sponsor with their signature.

```solidity
function registerBatchFor(
    address sponsor,
    uint256[2][] calldata idsAndAmounts,
    address arbiter,
    uint256 nonce,
    uint256 expires,
    bytes32 typehash,
    bytes32 witness,
    bytes calldata sponsorSignature
) external returns (bytes32 claimHash);
```
Registers a batch claim on behalf of a sponsor with their signature.

### Combined Deposit and Registration Functions

The interface provides several functions that combine deposit and registration operations:

```solidity
function depositNativeAndRegister(
    bytes12 lockTag, 
    bytes32 claimHash, 
    bytes32 typehash
) external payable returns (uint256 id);

function depositNativeAndRegisterFor(
    address recipient,
    bytes12 lockTag,
    address arbiter,
    uint256 nonce,
    uint256 expires,
    bytes32 typehash,
    bytes32 witness
) external payable returns (uint256 id, bytes32 claimhash);

function depositERC20AndRegister(
    address token,
    bytes12 lockTag,
    uint256 amount,
    bytes32 claimHash,
    bytes32 typehash
) external returns (uint256 id);

function depositERC20AndRegisterFor(
    address recipient,
    address token,
    bytes12 lockTag,
    uint256 amount,
    address arbiter,
    uint256 nonce,
    uint256 expires,
    bytes32 typehash,
    bytes32 witness
) external returns (uint256 id, bytes32 claimhash);

function batchDepositAndRegisterMultiple(
    uint256[2][] calldata idsAndAmounts,
    bytes32[2][] calldata claimHashesAndTypehashes
) external payable returns (bool);

function batchDepositAndRegisterFor(
    address recipient,
    uint256[2][] calldata idsAndAmounts,
    address arbiter,
    uint256 nonce,
    uint256 expires,
    bytes32 typehash,
    bytes32 witness
) external payable returns (bytes32 claimhash);
```

There are also Permit2 versions of these combined functions:

```solidity
function depositERC20AndRegisterViaPermit2(
    ISignatureTransfer.PermitTransferFrom calldata permit,
    address depositor,
    bytes12 lockTag,
    bytes32 claimHash,
    CompactCategory compactCategory,
    string calldata witness,
    bytes calldata signature
) external returns (uint256 id);

function batchDepositAndRegisterViaPermit2(
    address depositor,
    ISignatureTransfer.TokenPermissions[] calldata permitted,
    DepositDetails calldata details,
    bytes32 claimHash,
    CompactCategory compactCategory,
    string calldata witness,
    bytes calldata signature
) external payable returns (uint256[] memory ids);
```

### Forced Withdrawal Functions

```solidity
function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt);
```
Initiates a forced withdrawal for a resource lock. Once enabled, forced withdrawals can be executed after the reset period has elapsed.

```solidity
function disableForcedWithdrawal(uint256 id) external returns (bool);
```
Disables a previously enabled forced withdrawal for a resource lock.

```solidity
function forcedWithdrawal(
    uint256 id, 
    address recipient, 
    uint256 amount
) external returns (bool);
```
Executes a forced withdrawal from a resource lock after the reset period has elapsed.

### Emissary Functions

```solidity
function assignEmissary(bytes12 lockTag, address emissary) external returns (bool);
```
Assigns an emissary for the caller that has authority to authorize claims where that caller is the sponsor.

```solidity
function scheduleEmissaryAssignment(bytes12 lockTag) external returns (uint256 emissaryAssignmentAvailableAt);
```
Schedules a future emissary assignment for a specific lock tag.

### Allocator Functions

```solidity
function consume(uint256[] calldata nonces) external returns (bool);
```
Consumes allocator nonces. Only callable by a registered allocator.

```solidity
function __registerAllocator(
    address allocator, 
    bytes calldata proof
) external returns (uint96 allocatorId);
```
Registers an allocator. Can be called by anyone if one of three conditions is met: the caller is the allocator address being registered, the allocator address contains code, or a proof is supplied representing valid create2 deployment parameters.

### View Functions

```solidity
function getLockDetails(uint256 id)
    external
    view
    returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope, bytes12 lockTag);
```
Retrieves the details of a resource lock.

```solidity
function getRegistrationStatus(address sponsor, bytes32 claimHash, bytes32 typehash)
    external
    view
    returns (bool isActive, uint256 registrationTimestamp);
```
Checks the registration status of a compact.

```solidity
function getForcedWithdrawalStatus(address account, uint256 id)
    external
    view
    returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt);
```
Checks the forced withdrawal status of a resource lock for a given account.

```solidity
function getEmissaryStatus(address sponsor, bytes12 lockTag)
    external
    view
    returns (EmissaryStatus status, uint256 emissaryAssignmentAvailableAt, address currentEmissary);
```
Gets the current emissary status for an allocator.

```solidity
function hasConsumedAllocatorNonce(uint256 nonce, address allocator) external view returns (bool consumed);
```
Checks whether a specific nonce has been consumed by an allocator.

```solidity
function getRequiredWithdrawalFallbackStipends()
    external
    view
    returns (uint256 nativeTokenStipend, uint256 erc20TokenStipend);
```
Gets required stipends for releasing tokens as a fallback on claims where withdrawals do not succeed.

```solidity
function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator);
```
Returns the domain separator of the contract.

```solidity
function name() external pure returns (string memory);
```
Returns the name of the contract.

### Errors

```solidity
error InvalidToken(address token);
error Expired(uint256 expiration);
error InvalidSignature();
error PrematureWithdrawal(uint256 id);
error ForcedWithdrawalAlreadyDisabled(address account, uint256 id);
error UnallocatedTransfer(address operator, address from, address to, uint256 id, uint256 amount);
error InvalidBatchAllocation();
error InvalidRegistrationProof(address allocator);
error InvalidBatchDepositStructure();
error AllocatedAmountExceeded(uint256 allocatedAmount, uint256 providedAmount);
error InvalidScope(uint256 id);
error InvalidDepositTokenOrdering();
error InvalidDepositBalanceChange();
error Permit2CallFailed();
error ReentrantCall(address existingCaller);
```

## ITheCompactClaims

The claims interface for The Compact protocol, which provides endpoints for settling compacts.

### Overview

ITheCompactClaims provides functions for processing different types of claims:
- Standard single-chain claims
- Batch claims for multiple resource locks on a single chain
- Multichain claims for the notarized chain
- Multichain claims for exogenous chains
- Batch multichain claims for the notarized chain
- Batch multichain claims for exogenous chains

### Multichain and Exogenous Claims

The Compact protocol supports compacts that span multiple chains through its multichain claim system. This system is built around the concept of "elements" in a MultichainCompact structure.

#### MultichainCompact Structure

A `MultichainCompact` contains:
- The sponsor's address
- A nonce for replay protection
- An expiration timestamp
- An array of `Element` structures

Each `Element` in the array represents a specific chain and contains:
- An arbiter for that chain
- The chain ID
- An array of resource lock IDs and amounts
- A mandate (witness data)

```solidity
struct MultichainCompact {
    address sponsor;
    uint256 nonce;
    uint256 expires;
    Element[] elements;
}

struct Element {
    address arbiter;
    uint256 chainId;
    uint256[2][] idsAndAmounts;
    // Mandate (witness) must follow.
}
```

#### Notarized vs. Exogenous Claims

When a sponsor signs a MultichainCompact, they sign it against the domain of the first chain in the elements array. This first chain is considered the "notarized" chain.

1. **Notarized Chain Claims**:
   - The first element in the array corresponds to the notarized chain
   - Claims against this chain use the `multichainClaim` or `batchMultichainClaim` functions
   - The domain used for signature verification matches the one used when signing the compact

2. **Exogenous Chain Claims**:
   - All other elements in the array correspond to exogenous chains
   - Claims against these chains use the `exogenousClaim` or `exogenousBatchClaim` functions
   - These functions require additional parameters:
     - `chainIndex`: Indicates which exogenous chain is being claimed (0 for the first exogenous chain, 1 for the second, etc.)
     - `notarizedChainId`: The chain ID of the notarized chain (used to reconstruct the domain for signature verification)
     - `additionalChains`: An array of element hashes from all chains except the one being claimed

#### Scope Requirement for Exogenous Claims

A critical requirement for exogenous claims is that the resource locks must have a **multichain scope**. This is because:

1. Resource locks with a single-chain scope are restricted to be used only on their original chain
2. Exogenous claims involve cross-chain operations, so they require resource locks that are explicitly marked as usable across multiple chains
3. The multichain scope signals that the sponsor has acknowledged and approved the cross-chain usage of their tokens

If a resource lock does not have a multichain scope, it cannot be used in an exogenous claim, and any attempt to do so will result in an `InvalidScope` error.

#### Claim Processing Flow

When processing a multichain claim:

1. The arbiter on each chain calls the appropriate claim function with the relevant portion of the MultichainCompact
2. For the notarized chain, the signature is verified directly against the chain's domain
3. For exogenous chains, the signature is verified by reconstructing the domain of the notarized chain
4. Each claim is processed independently on its respective chain, but they all reference the same underlying MultichainCompact

This architecture allows for complex cross-chain operations while maintaining security through proper signature verification and scope restrictions.

### Functions

```solidity
function claim(Claim calldata claimPayload) external returns (bytes32 claimHash);
```
Processes a standard single-chain claim.

```solidity
function batchClaim(BatchClaim calldata claimPayload) external returns (bytes32 claimHash);
```
Processes a batch claim for multiple resource locks on a single chain.

```solidity
function multichainClaim(MultichainClaim calldata claimPayload) external returns (bytes32 claimHash);
```
Processes a multichain claim for the notarized chain (where domain matches the one signed for).

```solidity
function exogenousClaim(ExogenousMultichainClaim calldata claimPayload) external returns (bytes32 claimHash);
```
Processes a multichain claim for an exogenous chain (not the notarized chain).

```solidity
function batchMultichainClaim(BatchMultichainClaim calldata claimPayload) external returns (bytes32 claimHash);
```
Processes a batch multichain claim for multiple resource locks on the notarized chain.

```solidity
function exogenousBatchClaim(ExogenousBatchMultichainClaim calldata claimPayload) external returns (bytes32 claimHash);
```
Processes a batch multichain claim for multiple resource locks on an exogenous chain.

## IAllocator

The allocator interface for The Compact protocol, which is responsible for mediating resource locks and authorizing claims.

### Overview

Each resource lock is mediated by an **allocator**, tasked with attesting to the availability of the underlying token balances and preserving the balances required for the commitments they have attested to. In other words, an allocator ensures that sponsors do not "double-spend," transfer, or withdraw any token balances that are already committed to a specific compact.

The allocator's primary function is to ensure that any resource locks it is assigned to are not "double-spent" — this entails ensuring that sufficient unallocated balance is available before cosigning on any requests to withdraw or transfer the balance or to sponsor a claim on that balance, and also ensuring that nonces are not reused.

IAllocator provides functions for:
- Validating transfers
- Authorizing claims
- Checking if claims are authorized

Allocators can also call a `consume` method at any point to consume nonces so that they cannot be used again.

### Functions

```solidity
function attest(
    address operator, 
    address from, 
    address to, 
    uint256 id, 
    uint256 amount
) external returns (bytes4);
```
Called on standard transfers to validate the transfer. Must return the function selector (0x1a808f91).

```solidity
function authorizeClaim(
    bytes32 claimHash,
    address arbiter,
    address sponsor,
    uint256 nonce,
    uint256 expires,
    uint256[2][] calldata idsAndAmounts,
    bytes calldata allocatorData
) external returns (bytes4);
```
Authorizes a claim. Called from The Compact as part of claim processing. Must return the function selector (0x7bb023f7).

```solidity
function isClaimAuthorized(
    bytes32 claimHash,
    address arbiter,
    address sponsor,
    uint256 nonce,
    uint256 expires,
    uint256[2][] calldata idsAndAmounts,
    bytes calldata allocatorData
) external view returns (bool);
```
Checks if given allocatorData authorizes a claim. Intended to be called offchain.

## IEmissary

The emissary interface for The Compact protocol, which is responsible for verifying claims on behalf of sponsors.

### Overview

The emissary provides a fallback signer in case an EIP-1271 signature gets updated or an underlying EIP-7702 delegation that leverages EIP-1271 is changed by the account in question. This is particularly useful for smart contract accounts or other accounts that can change their signing mechanism at will, as otherwise these accounts can break equivocation after the mandate of a given compact has been fulfilled but before it has been claimed.

IEmissary provides a function for verifying claims on behalf of sponsors.

### Functions

```solidity
function verifyClaim(
    address sponsor, 
    bytes32 claimHash, 
    bytes calldata signature, 
    bytes12 lockTag
) external view returns (bytes4);
```
Verifies a claim. Called from The Compact as part of claim processing. Must return the function selector (0xcd4d6588).

## Key Concepts

### Resource Locks

Resource locks are the fundamental building blocks of The Compact protocol. They are created when a depositor places tokens (either native tokens or ERC20 tokens) into The Compact contract. Each resource lock has four key properties:

1. The **underlying token** held in the resource lock
2. The **allocator** tasked with cosigning on claims against the resource locks
3. The **scope** of the resource lock (either spendable on any chain or limited to a single chain)
4. The **reset period** for forcibly exiting the lock and withdrawing the funds without the allocator's approval

#### Fee-on-Transfer Token Handling

The Compact has special handling for fee-on-transfer tokens (tokens that deduct a fee from the transferred amount):

- **For deposits**: The amount of ERC6909 tokens minted to the recipient is based on the actual balance change in The Compact contract before and after the deposit, not the amount specified in the deposit function. This ensures that the ERC6909 tokens accurately represent the actual tokens held in the resource lock. This means that if a token deducts a fee from the recipient during withdrawal, the depositor will receive back fewer ERC6909 tokens burned than the amount of underlying tokens provided.

- **For withdrawals**: Similarly, the amount of ERC6909 tokens burned from the sender is based on the actual balance change in The Compact contract before and after the withdrawal. This means that if a token deducts a fee from the sender during withdrawal, the sender will receive back fewer underlying tokens than the amount of ERC6909 tokens burned.

This balance-based accounting ensures that The Compact maintains an accurate representation of the underlying tokens actually held in each resource lock, regardless of any fees that might be applied during transfers.

Each unique combination of these four properties is represented by a fungible ERC6909 tokenID. The owner of these ERC6909 tokens can act as a sponsor and create compacts.

Each allocator must be registered by calling the `__registerAllocator` function, which will assign them a unique allocatorId (this value will be consistent for a given account address regardless of the chain on which it has been registered). The scope, reset period, and allocatorId on a given resource lock are then packed to create a **lock tag** that encapsulates the full set of information about a given lock aside from the underlying token; this lock tag is then used throughout various interfaces (including alongside the recipient as part of claimants on processed claims) to succinctly communicate which resource lock is relevant to the task at hand.

### Allocators

Allocators play a critical role in The Compact protocol by ensuring the integrity of resource locks. Their responsibilities include:

1. **Preventing double-spending**: Ensuring that sponsors don't commit the same tokens to multiple compacts
2. **Validating transfers**: Attesting to transfers of ERC6909 tokens to prevent invalidation of inflight claims
3. **Authorizing claims**: Cosigning on claims against resource locks
4. **Nonce management**: Ensuring nonces are not reused and consuming nonces when necessary

The trust assumptions around allocators are important:
- Claimants must trust that the allocator is sound and will not leave the resource lock underallocated
- Sponsors must trust that the allocator will not unduly censor fully allocated requests

Allocators can be implemented in various ways, including reputation-based systems, trusted execution environments, smart-contract-based systems, or even dedicated rollups. The Compact takes a neutral stance on implementations, enabling support for a wide variety of potential applications.

### Arbiters

Arbiters are responsible for verifying and submitting claims. When a sponsor creates a compact, they designate an arbiter who will:

1. Verify that the specified conditions of the compact have been met
2. Process the claim by calling the appropriate function on The Compact
3. Specify which accounts will receive the tokens and in what quantities

The trust assumptions around arbiters are also important:
- Sponsors must trust that the arbiter is sound and will not process claims where the conditions were not successfully met
- Claimants must trust that the arbiter is sound and will not fail to process claims where the conditions were successfully met

### Emissaries

Emissaries provide a fallback verification mechanism for sponsors. They are particularly useful for:

1. Smart contract accounts that may need to update their EIP-1271 signature verification logic
2. Accounts using EIP-7702 delegation that leverages EIP-1271 which might be changed
3. Situations where the sponsor wants to delegate claim verification to another entity

The emissary is assigned for a specific lock tag and uses the reset period on that lock tag to block reassignment for the duration of that reset period. This ensures that once an emissary is assigned, another assignment cannot be made until the reset period has elapsed.

### Forced Withdrawals

Forced withdrawals provide a safety mechanism for sponsors in case an allocator goes down or refuses to cosign for a claim. The process works as follows:

1. The sponsor calls `enableForcedWithdrawal` for a specific resource lock
2. After the reset period has elapsed, the sponsor can call `forcedWithdrawal` to withdraw their tokens
3. The sponsor can also call `disableForcedWithdrawal` to reactivate the resource lock if desired

This mechanism ensures that sponsors always have recourse from potential censorship by allocators. The reset period only needs to be long enough for legitimate claims to finalize (generally some multiple of the slowest blockchain involved in the swap).

### Registration

Registration is an alternative to the signature-based flow for creating compacts. Instead of requiring signatures from the sponsor and allocator, the sponsor can register a compact by submitting a "claim hash" along with the typehash of the underlying compact.

This approach supports more advanced functionality, such as:
- Sponsors without the ability to sign (like protocols or DAOs)
- Smart wallet / EIP-7702-enabled sponsors with their own authorization or batching logic
- Chained deposit & register operations

When registering a compact directly, a duration is either explicitly provided or inferred from the reset period on the corresponding deposit. The registered compact becomes inactive once that duration elapses.

### EIP-712 Payloads

The Compact protocol uses EIP-712 typed structured data for creating and verifying signatures. There are three main types of payloads that can be signed to create a compact:

#### 1. Compact

The basic `Compact` payload is used for single resource lock operations on a single chain:

```solidity
struct Compact {
    address arbiter;    // The account tasked with verifying and submitting the claim.
    address sponsor;    // The account to source the tokens from.
    uint256 nonce;      // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires;    // The time at which the claim expires.
    uint256 id;         // The token ID of the ERC6909 token to allocate.
    uint256 amount;     // The amount of ERC6909 tokens to allocate.
    Mandate mandate;    // Witness data used by the arbiter as part of claim processing.
}
```

#### 2. BatchCompact

The `BatchCompact` payload is used when a sponsor wants to allocate multiple resource locks on a single chain:

```solidity
struct BatchCompact {
    address arbiter;            // The account tasked with verifying and submitting the claim.
    address sponsor;            // The account to source the tokens from.
    uint256 nonce;              // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires;            // The time at which the claim expires.
    uint256[2][] idsAndAmounts; // The allocated token IDs and amounts.
    Mandate mandate;            // Witness data used by the arbiter as part of claim processing.
}
```

#### 3. MultichainCompact

The `MultichainCompact` payload is used for cross-chain operations, allowing a sponsor to allocate resource locks across multiple chains:

```solidity
struct MultichainCompact {
    address sponsor;     // The account to source the tokens from.
    uint256 nonce;       // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires;     // The time at which the claim expires.
    Element[] elements;  // Arbiter, chainId, ids & amounts, and mandate for each chain.
}

struct Element {
    address arbiter;            // The account tasked with verifying and submitting the claim.
    uint256 chainId;            // The chainId where the tokens are located.
    uint256[2][] idsAndAmounts; // The allocated token IDs and amounts.
    Mandate mandate;            // Witness data used by the arbiter as part of claim processing.
}
```

The EIP-712 typehash for these structures is constructed dynamically based on the typestring fragments defined in the code; empty Mandate structs will result in a typestring that does not contain witness data.

#### Permit2 Integration Payloads

The Compact also supports integration with Permit2 for gasless deposits. These use additional EIP-712 structures:

1. **CompactDeposit**: Used for basic Permit2 deposits
   ```solidity
   // keccak256(bytes("CompactDeposit(bytes12 lockTag,address recipient)"))
   bytes32 constant PERMIT2_DEPOSIT_WITNESS_FRAGMENT_HASH = 0xaced9f7c53bfda31d043cbef88f9ee23b8171ec904889af3d5d0b9b81914a404;
   ```

2. **Activation**: Used to combine deposits with compact registration
   ```solidity
   // keccak256(bytes("Activation(uint256 id,Compact compact)Compact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256 id,uint256 amount,Mandate mandate)Mandate(...)"))
   ```

3. **BatchActivation**: Used for batch deposits with compact registration
   ```solidity
   // keccak256(bytes("BatchActivation(uint256[] ids,Compact compact)Compact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256 id,uint256 amount,Mandate mandate)Mandate(...)"))
   ```

#### Signature Verification

When a compact is created through signatures, the following verification process occurs:

1. The sponsor signs the appropriate EIP-712 payload (Compact, BatchCompact, or MultichainCompact)
2. The allocator provides an interface as well as any additional `allocatorData` to provide supplimentary verification
3. When the arbiter submits the claim, The Compact verifies both the sponsor and the allocator portion of the claim. For the sponsor:
   - First, onchain registration is checked; if registered, it is valid
   - Next, the caller is checked; if the caller is the sponsor, it is valid
   - Then, ECDSA signature verification is attempted; if it succeeds, it is valid
   - Subsequently, EIP-1271 `isValidSignature` is called with half of remaining gas; if it succeeds, it is valid
   - Finally, for sponsors with assigned emissaries, the emissary's `verifyClaim` function is called; if it succeeds, it is valid

This approach ensures that both the sponsor and allocator have authorized the compact, providing security against unauthorized claims. Note that sponsors do not have authority to "cancel" a compact; only allocators have the authority to cancel (as they are the entities bearing the trust assumption to uphold equivocation guarantees on behalf of claimants that fulfill the mandate of a given compact).

### Witness Structure

The witness mechanism in The Compact allows for extending the basic compact structures with additional data that can be used to specify conditions or parameters for the claim. This is particularly important for more complex use cases where additional context is needed.

#### Witness Format

The witness is always structured as a "Mandate" appended to the end of the compact in question. For example, if the basic compact typestring is:

```
Compact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256 id,uint256 amount)
```

With a witness, it becomes:

```
Compact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256 id,uint256 amount,Mandate mandate)Mandate(...)
```

The arguments *inside* the Mandate struct (including any nested structs) are provided as the witness typestring. For example, if the Mandate struct contains:

```
Mandate(uint256 witnessArgument, bytes32 anotherArgument)
```

Then the witness typestring provided would be:

```
uint256 witnessArgument, bytes32 anotherArgument
```

#### Nested Structs in Witnesses

Since EIP-712 requires that all nested structs are ordered alphanumerically after the top-level struct, it's recommended to prefix any nested structs with "Mandate" (like MandateA, MandateB, etc.) to ensure they appear in the correct order in the final typestring.

For example, if your witness includes nested structs:

```
Mandate(MandateCondition condition,uint256 witnessArgument)MandateCondition(bool required,uint256 value)
```

Then the provided witness typestring would contain this payload, omitting the parent Mandate struct and any trailing parenthesis:

```
MandateCondition condition,uint256 witnessArgument)MandateCondition(bool required,uint256 value
```

#### Witness Processing

The Compact doesn't evaluate the contents of the witness itself - this is up to the arbiter to interpret and act upon. However, The Compact does use:

1. The hash of the witness (provided as `bytes32 witness` in claim functions)
2. The full, reconstructed EIP-712 typestring including the supplied typestring fragment

These are used to derive the final claim hash and validate the compact during claim processing. This allows for flexible, application-specific conditions to be attached to each compact while maintaining core security guarantees within the protocol.

### Claimant Structure

In The Compact V1, the recipient is encoded alongside the `lockTag` in the `claimant` field of each `Component` struct in the `claimants` array. This encoding allows for more flexible claim processing by determining the action to take for each claimant based on the encoded information.

#### Encoding Structure

The `claimant` field in the `Component` struct is a uint256 value that packs both the recipient address and a lockTag (or special flags) into a single value:

```
claimant = (lockTag << 160) | recipient
```

Where:
- `lockTag` is a bytes12 value that contains the allocatorId, reset period, and scope
- `recipient` is the address that will receive the tokens

#### Processing Options

When a claim is processed, The Compact examines the encoded claimant value to determine how to handle the transfer:

1. **Direct 6909 Transfers**: 
   - If the lockTag portion is zero, The Compact performs a direct ERC6909 token transfer to the recipient.
   - This is useful for simple transfers where the recipient wants to receive the ERC6909 tokens directly.
   - Example: A user wants to receive ERC6909 tokens representing a resource lock without any conversion or withdrawal.

2. **Converting Between Resource Locks**: 
   - If the lockTag portion contains a valid lockTag (not zero and not the special withdrawal flag), The Compact converts the tokens from one resource lock to another.
   - This allows for moving tokens between different resource locks with different properties (e.g., changing the allocator, reset period, or scope).
   - Example: Converting tokens from a resource lock with a 10-minute reset period to one with a 1-day reset period, or changing from a single-chain scope to a multichain scope.

3. **Processing Withdrawals**: 
   - If the lockTag portion contains a special withdrawal flag, The Compact attempts to withdraw the underlying tokens to the recipient.
   - The withdrawal process extracts the actual tokens (native or ERC20) from the resource lock and sends them to the recipient.
   - Example: A user wants to receive the actual USDC tokens from a USDC resource lock rather than the ERC6909 tokens representing that lock.

#### Withdrawal Fallback Mechanism

To prevent griefing by claimants via malicious receive hooks or callbacks during claim processing, The Compact implements a withdrawal fallback mechanism:

1. When a withdrawal is attempted as part of a claim, The Compact first tries to execute the withdrawal using half of the available gas.
2. If the withdrawal fails (e.g., due to a token with unusual behavior or gas limitations), The Compact will automatically fall back to a direct 6909 transfer instead.
3. This fallback only occurs if there is sufficient gas remaining (above a benchmarked stipend amount).
4. The required stipend amounts for both native token and ERC20 token withdrawals can be queried using the `getRequiredWithdrawalFallbackStipends` function.

This fallback mechanism ensures that claims can still be processed even if there are issues with the underlying token and that one claimant cannot prevent a claim from being processed by other claimants via manipulation of receive hooks or other callbacks.

## Key Data Structures

### AllocatedTransfer

```solidity
struct AllocatedTransfer {
    bytes allocatorData; // Authorization from the allocator.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the transfer or withdrawal expires.
    uint256 id; // The token ID of the ERC6909 token to transfer or withdraw.
    Component[] recipients; // The recipients and amounts of each transfer.
}
```

### Claim

```solidity
struct Claim {
    bytes allocatorData; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    Component[] claimants; // The claim recipients and amounts; specified by the arbiter.
}
```

### Component

```solidity
struct Component {
    uint256 claimant; // The lockTag + recipient of the transfer or withdrawal.
    uint256 amount; // The amount of tokens to transfer or withdraw.
}
```

### BatchClaim

```solidity
struct BatchClaim {
    bytes allocatorData; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    BatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}
```

### MultichainClaim

```solidity
struct MultichainClaim {
    bytes allocatorData; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32[] additionalChains; // The allocation hashes from additional chains.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    Component[] claimants; // The claim recipients and amounts; specified by the arbiter.
}
```

### ExogenousMultichainClaim

```solidity
struct ExogenousMultichainClaim {
    bytes allocatorData; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32[] additionalChains; // The allocation hashes from additional chains.
    uint256 chainIndex; // The index after which to insert the current allocation hash.
    uint256 notarizedChainId; // The chain id used to sign the multichain claim.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    Component[] claimants; // The claim recipients and amounts; specified by the arbiter.
}
```

### BatchMultichainClaim

```solidity
struct BatchMultichainClaim {
    bytes allocatorData; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32[] additionalChains; // The allocation hashes from additional chains.
    BatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}
```

### ExogenousBatchMultichainClaim

```solidity
struct ExogenousBatchMultichainClaim {
    bytes allocatorData; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32[] additionalChains; // The allocation hashes from additional chains.
    uint256 chainIndex; // The index after which to insert the current allocation hash.
    uint256 notarizedChainId; // The chain id used to sign the multichain claim.
    BatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

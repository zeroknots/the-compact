// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { SplitComponent } from "./Components.sol";

struct BasicTransfer {
    uint256 expires; // The time at which the transfer or withdrawal expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to transfer or withdraw.
    uint256 amount; // The token amount to transfer or withdraw.
    address recipient; // The recipient of the transfer or withdrawal.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct SplitTransfer {
    uint256 expires; // The time at which the transfer or withdrawal expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to transfer or withdraw.
    SplitComponent[] recipients; // The recipients and amounts of each transfer.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct Claim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    address claimant; // The claim recipient; specified by the arbiter.
    uint256 amount; // The claimed token amount; specified by the arbiter.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    address claimant; // The claim recipient; specified by the arbiter.
    uint256 amount; // The claimed token amount; specified by the arbiter.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct ClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    address claimant; // The claim recipient; specified by the arbiter.
    uint256 amount; // The claimed token amount; specified by the arbiter.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    address claimant; // The claim recipient; specified by the arbiter.
    uint256 amount; // The claimed token amount; specified by the arbiter.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct SplitClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    SplitComponent[] claimants; // The claim recipients and amounts; specified by the arbiter.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct SplitClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    SplitComponent[] claimants; // The claim recipients and amounts; specified by the arbiter.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedSplitClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    SplitComponent[] claimants; // The claim recipients and amounts; specified by the arbiter.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedSplitClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    SplitComponent[] claimants; // The claim recipients and amounts; specified by the arbiter.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

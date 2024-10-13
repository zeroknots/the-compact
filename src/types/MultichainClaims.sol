// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BatchClaimComponent, SplitBatchClaimComponent } from "./Components.sol";

struct MultichainClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    uint256 chainIndex;
    bytes32[] otherChains;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct QualifiedMultichainClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct MultichainClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    uint256 chainIndex;
    bytes32[] otherChains;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct QualifiedMultichainClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct SplitMultichainClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    uint256 chainIndex;
    bytes32[] otherChains;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct SplitMultichainClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    uint256 chainIndex;
    bytes32[] otherChains;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct QualifiedSplitMultichainClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct QualifiedSplitMultichainClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct ExogenousMultichainClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct ExogenousQualifiedMultichainClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct ExogenousMultichainClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct ExogenousQualifiedMultichainClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct ExogenousSplitMultichainClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct ExogenousSplitMultichainClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct ExogenousQualifiedSplitMultichainClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct ExogenousQualifiedSplitMultichainClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

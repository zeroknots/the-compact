// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BatchClaimComponent, SplitBatchClaimComponent } from "./Components.sol";

struct MultichainClaim {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    uint256 chainIndex;
    bytes32[] otherChains;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct QualifiedMultichainClaim {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct MultichainClaimWithWitness {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    uint256 chainIndex;
    bytes32[] otherChains;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct QualifiedMultichainClaimWithWitness {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
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
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    uint256 chainIndex;
    bytes32[] otherChains;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct SplitMultichainClaimWithWitness {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    uint256 chainIndex;
    bytes32[] otherChains;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct QualifiedSplitMultichainClaim {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct QualifiedSplitMultichainClaimWithWitness {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct ExogenousMultichainClaim {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct ExogenousQualifiedMultichainClaim {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct ExogenousMultichainClaimWithWitness {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    BatchClaimComponent[] claims; // IDs and amounts.
    address claimant; // The claim recipient; specified by the arbiter.
}

struct ExogenousQualifiedMultichainClaimWithWitness {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
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
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct ExogenousSplitMultichainClaimWithWitness {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct ExogenousQualifiedSplitMultichainClaim {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct ExogenousQualifiedSplitMultichainClaimWithWitness {
    bytes allocatorSignature; // Authorization from the allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes32 witness; // Hash of the witness data.
    string witnessTypestring; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    uint256 chainIndex;
    bytes32[] otherChains;
    uint256 notarizedChainId;
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

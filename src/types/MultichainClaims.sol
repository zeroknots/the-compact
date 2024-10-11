// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BatchClaimComponent, SplitBatchClaimComponent } from "./Components.sol";

struct MultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct MultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct SplitMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct SplitMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedSplitMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedSplitMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct ExogenousMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims;
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct ExogenousQualifiedMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims;
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct ExogenousMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims;
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct ExogenousQualifiedMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct ExogenousSplitMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct ExogenousSplitMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct ExogenousQualifiedSplitMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct ExogenousQualifiedSplitMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

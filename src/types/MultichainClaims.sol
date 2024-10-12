// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BatchClaimComponent, SplitBatchClaimComponent } from "./Components.sol";

struct MultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    BatchClaimComponent[] claims;
    uint256 chainIndex;
    bytes32[] otherChains;
}

struct QualifiedMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    BatchClaimComponent[] claims;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
}

struct MultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    BatchClaimComponent[] claims;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
}

struct QualifiedMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
}

struct SplitMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 chainIndex;
    bytes32[] otherChains;
}

struct SplitMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
}

struct QualifiedSplitMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
}

struct QualifiedSplitMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
}

struct ExogenousMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    BatchClaimComponent[] claims;
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
}

struct ExogenousQualifiedMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    BatchClaimComponent[] claims;
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
}

struct ExogenousMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    BatchClaimComponent[] claims;
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
}

struct ExogenousQualifiedMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
}

struct ExogenousSplitMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
}

struct ExogenousSplitMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
}

struct ExogenousQualifiedSplitMultichainClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
}

struct ExogenousQualifiedSplitMultichainClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    uint256 notarizedChainId;
    uint256 chainIndex;
    bytes32[] otherChains;
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {
    SplitByIdComponent,
    TransferComponent,
    BatchClaimComponent,
    SplitTransferComponent,
    SplitBatchClaimComponent
} from "./Components.sol";

struct BatchTransfer {
    uint256 expires; // The time at which the transfer or withdrawal expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    TransferComponent[] transfers; // The token IDs, amounts, and recipients.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct SplitBatchTransfer {
    uint256 expires; // The time at which the transfer or withdrawal expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitByIdComponent[] transfers; // The recipients and amounts of each transfer for each ID.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct BatchClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedBatchClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct BatchClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedBatchClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct SplitBatchClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct SplitBatchClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedSplitBatchClaim {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

struct QualifiedSplitBatchClaimWithWitness {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    bytes allocatorSignature; // Authorization from the allocator.
}

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
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the transfer or withdrawal expires.
    bytes allocatorSignature; // Authorization from the allocator.
    TransferComponent[] transfers; // The token IDs, amounts, and recipients.
}

struct SplitBatchTransfer {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the transfer or withdrawal expires.
    bytes allocatorSignature; // Authorization from the allocator.
    SplitByIdComponent[] transfers; // The recipients and amounts of each transfer for each ID.
}

struct BatchClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
}

struct QualifiedBatchClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
}

struct BatchClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
}

struct QualifiedBatchClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    BatchClaimComponent[] claims; // IDs, amounts, and claimants.
}

struct SplitBatchClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct SplitBatchClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct QualifiedSplitBatchClaim {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

struct QualifiedSplitBatchClaimWithWitness {
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    bytes allocatorSignature; // Authorization from the allocator.
    address sponsor; // The account to source the tokens from.
    bytes sponsorSignature; // Authorization from the sponsor.
    bytes32 witness; // Hash of the witness data.
    string witnessTypeString; // Witness typestring appended to existing typestring.
    bytes32 qualificationTypehash; // Typehash of the qualification payload.
    bytes qualificationPayload; // Data used to derive qualification hash.
    SplitBatchClaimComponent[] claims; // The claim token IDs, recipients and amounts.
}

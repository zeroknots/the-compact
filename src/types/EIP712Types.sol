// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Message signed by the owner that specifies the conditions under which their
// tokens can be allocated; the specified oracle verifies that those conditions
// have been met, enabling an allocatee to claim the specified token amount.
struct Allocation {
    address owner; // The account to source the allocation from.
    uint256 startTime; // The time at which the allocation can be released.
    uint256 endTime; // The time at which the allocation expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 amount; // The amount of ERC6909 tokens to allocate.
    address claimant; // The allocation recipient (no address: any recipient)
    address oracle; // The account enforcing whether to release allocated funds.
    bytes oracleFixedData; // The fixed data payload provided to the oracle.
}

// keccak256("Allocation(address owner,uint256 startTime,uint256 endTime,uint256 nonce,uint256 id,uint256 amount,address claimant,address oracle,bytes oracleFixedData)")
bytes32 constant ALLOCATION_TYPEHASH = 0x332b96efcdc96931e9c671e47db4a873af3efa03557c9c2b93f4eb5f85587c15;

// Message signed by the allocator that confirms that a given allocation does
// not result in an over-allocated state for the token owner, and that modifies
// the conditions of the allocation where applicable.
struct AllocationAuthorization {
    // bytes32 allocationHash; // signed but not explicitly supplied as a parameter
    uint256 startTime; // The time at which the allocation authorization becomes valid.
    uint256 endTime; // The time at which the allocation authorization expires.
    address claimant; // The allocation recipient (no address: any recipient)
    uint256 amountReduction; // The amount by which the claimable tokens will be reduced.
}

// keccak256("AllocationAuthorization(bytes32 allocationHash,uint256 startTime,uint256 endTime,address claimant,uint256 amountReduction)")
bytes32 constant ALLOCATION_AUTHORIZATION_TYPEHASH = 0x9d7957a907b00fac8de3a22c078f7f0409c40a085d5c51f7a371cf3291563692;

// Message signed by the allocator that confirms that a given withdrawal does
// not result in an over-allocated state for the token owner, and that enables
// the owner to directly withdraw their tokens to an arbitrary recipient.
struct WithdrawalAuthorization {
    address owner; // The account to source the withdrawal from.
    uint256 expiration; // The time at which the withdrawal expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to use for the withdrawal.
    uint256 amount; // The amount of underlying tokens to withdraw.
}

// keccak256("WithdrawalAuthorization(address owner,uint256 expiration,uint256 nonce,uint256 id,uint256 amount)")
bytes32 constant WITHDRAWAL_AUTHORIZATION_TYPEHASH = 0xe8ddf15cb7ca4c43508ca754003eb19691666659efea41674f94eef9311cea83;

// Message signed by both the token owner and the allocator that expresses the
// intention to perform a withdrawal to a specific recipient and confirms that a
// given withdrawal does not result in an over-allocated state for the token owner,
// and that enables an arbitrary account to perform the withdrawal and receive a
// pledged amount of tokens as compensation.
struct DelegatedWithdrawal {
    address owner; // The account to source the withdrawal from.
    uint256 startTime; // The time at which the withdrawal can be released.
    uint256 endTime; // The time at which the withdrawal expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 token to use for the withdrawal.
    uint256 amount; // The amount of underlying tokens to withdraw.
    address recipient; // The withdrawal recipient.
    uint256 pledge; // The maximum payment to a keeper that initiates the withdrawal.
}

// keccak256("DelegatedWithdrawal(address owner,uint256 startTime,uint256 endTime,uint256 nonce,uint256 id,uint256 amount,address recipient,uint256 pledge)")
bytes32 constant DELEGATED_WITHDRAWAL_TYPEHASH = 0x4500e9eeb2d9479ee76ef8d1eaa3f2a58acd5a783fdcc66ac7d6beab87147770;

// Message signed by the allocator that confirms that a given transfer does
// not result in an over-allocated state for the token owner, and that enables
// the owner to directly transfer their tokens to an arbitrary recipient.
struct TransferAuthorization {
    address owner; // The token owner to enable the transfer for.
    uint256 expiration; // The time at which the transfer expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 tokens to transfer.
    uint256 amount; // The amount of ERC6909 tokens to transfer.
}

// keccak256("TransferAuthorization(address owner,uint256 expiration,uint256 nonce,uint256 id,uint256 amount)")
bytes32 constant TRANSFER_AUTHORIZATION_TYPEHASH = 0x133283649d13b9fb62bd3e61ca2c22c2ffa47bbc9c1e45a1b4907081a27adeb1;

struct DelegatedTransfer {
    address owner; // The account to perform the transfer from.
    uint256 startTime; // The time at which the transfer can be performed.
    uint256 endTime; // The time at which the transfer expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 id; // The token ID of the ERC6909 tokens to transfer.
    uint256 amount; // The amount of ERC6909 tokens to transfer.
    address recipient; // The recipient of the transfer.
    uint256 pledge; // The maximum payment to a keeper that initiates the transfer.
}

// keccak256("DelegatedTransfer(address owner,uint256 startTime,uint256 endTime,uint256 nonce,uint256 id,uint256 amount,address recipient,uint256 pledge)")
bytes32 constant DELEGATED_TRANSFER_TYPEHASH = 0x02a1a148b3d717493ad30699c0dfdc6e576338dc5c5c3de643fae9a53f20a46a;

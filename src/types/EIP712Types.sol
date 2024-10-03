// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Message signed by the owner that specifies the conditions under which their
// tokens can be allocated; the specified oracle verifies that those conditions
// have been met, enabling an allocatee to claim the specified token amount.
struct Allocation {
    address owner; // The account to source the allocation from.
    uint256 startTime; // The time at which the allocation can be released.
    uint256 endTime; // The time at which the allocation expires.
    bytes32 salt; // A parameter to promote uniqueness and irreversibility.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 amount; // The amount of ERC6909 tokens to allocate.
    address allocatee; // The allocation recipient (no address: any recipient)
    address oracle; // The account enforcing whether to release allocated funds.
    bytes oracleFixedData; // The fixed data payload provided to the oracle.
}

// keccak256("Allocation(address owner,uint256 startTime,uint256 endTime,bytes32 salt,uint256 id,uint256 amount,address allocatee,address oracle,bytes oracleFixedData)")
bytes32 constant ALLOCATION_TYPEHASH = 0xf181a5004b8ddd6d6d06e2df399d7e5f9edf308da0c9ff114b3eca3cbe232607;

// Message signed by the allocator that confirms that a given allocation does
// not result in an over-allocated state for the token owner, and that modifies
// the conditions of the allocation where applicable.
struct AllocationAuthorization {
    // bytes32 allocationHash; // signed but not explicitly supplied as a parameter
    uint256 startTime; // The time at which the allocation authorization becomes valid.
    uint256 endTime; // The time at which the allocation authorization expires.
    address assignedAllocatee; // The allocation recipient (no address: any recipient)
    uint256 amountReduction; // The amount by which the claimable tokens will be reduced.
}

// keccak256("AllocationAuthorization(bytes32 allocationHash,uint256 startTime,uint256 endTime,address assignedAllocatee,uint256 amountReduction)")
bytes32 constant ALLOCATION_AUTHORIZATION_TYPEHASH = 0x7104d916fcff1b1de3f1523f7f121a0a2e731d463b04b91972aa6c6be2fedf71;

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
    uint256 nonce; // A parameter to enforce replay protection, scoped to token owner.
    uint256 id; // The token ID of the ERC6909 token to use for the withdrawal.
    uint256 amount; // The amount of underlying tokens to withdraw.
    address recipient; // The withdrawal recipient.
    uint256 pledge; // The maximum payment to a keeper that initiates the withdrawal.
}

// keccak256("DelegatedWithdrawal(address owner,uint256 startTime,uint256 endTime,uint256 nonce,uint256 id,uint256 amount,address recipient,uint256 pledge)")
bytes32 constant DELEGATED_WITHDRAWAL_TYPEHASH = 0x4500e9eeb2d9479ee76ef8d1eaa3f2a58acd5a783fdcc66ac7d6beab87147770;

// Message signed by the allocator that enables token transfers and withdrawals for
// a given token owner for a window of time without requiring additional approval.
// Overrides any existing bypass state.
struct BypassAuthorization {
    address owner; // The token owner to enable the bypass for.
    uint256 expiration; // The time at which the withdrawal expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
}

// keccak256("BypassAuthorization(address owner,uint256 expiration,uint256 nonce)")
bytes32 constant BYPASS_AUTHORIZATION_TYPEHASH = 0x4d94159be1b1adcd02090bf6eb3b3db124dd7c7c9e1ce3a368643c691ea9b998;

// Message signed by the allocator that confirms that a given transfer does
// not result in an over-allocated state for the token owner, and that enables
// the owner to directly transfer their tokens to an arbitrary recipient.
struct TransferAuthorization {
    address owner;
    uint256 expiration; // The time at which the withdrawal expires.
    uint256 nonce;
    uint256 id;
    uint256 amount;
}

// keccak256("TransferAuthorization(address owner,uint256 expiration,uint256 nonce,uint256 id,uint256 amount)")
bytes32 constant TRANSFER_AUTHORIZATION_TYPEHASH = 0x133283649d13b9fb62bd3e61ca2c22c2ffa47bbc9c1e45a1b4907081a27adeb1;

struct DelegatedTransfer {
    address owner;
    uint256 startTime;
    uint256 endTime;
    uint256 nonce;
    uint256 id;
    uint256 amount;
    address recipient;
    uint256 pledge;
}

// keccak256("DelegatedTransfer(address owner,uint256 startTime,uint256 endTime,uint256 nonce,uint256 id,uint256 amount,address recipient,uint256 pledge)")
bytes32 constant DELEGATED_TRANSFER_TYPEHASH = 0x02a1a148b3d717493ad30699c0dfdc6e576338dc5c5c3de643fae9a53f20a46a;

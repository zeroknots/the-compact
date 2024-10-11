// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Message signed by the sponsor that specifies the conditions under which their
// tokens can be claimed; the specified arbiter verifies that those conditions
// have been met and specifies a set of beneficiaries that will receive up to the
// specified amount of tokens.
struct Compact {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    address arbiter; // The account tasked with verifying and submitting the claim.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 amount; // The amount of ERC6909 tokens to allocate.
        // Optional witness may follow.
}

// keccak256("Compact(address sponsor,uint256 expires,uint256 nonce,address arbiter,uint256 id,uint256 amount)")
bytes32 constant COMPACT_TYPEHASH =
    0x785a1adffe0b8aa759a74fc3f1bfc82ce28cdab56907a9e1251400181de85b7a;

// abi.decode(bytes("Compact(address sponsor,uint256 "), (bytes32))
bytes32 constant COMPACT_TYPESTRING_FRAGMENT_ONE =
    0x436f6d7061637428616464726573732073706f6e736f722c75696e7432353620;

// abi.decode(bytes("expires,uint256 nonce,address ar"), (bytes32))
bytes32 constant COMPACT_TYPESTRING_FRAGMENT_TWO =
    0x657870697265732c75696e74323536206e6f6e63652c61646472657373206172;

// abi.decode(bytes("biter,uint256 id,uint256 amount,"), (bytes32))
bytes32 constant COMPACT_TYPESTRING_FRAGMENT_THREE =
    0x62697465722c75696e743235362069642c75696e7432353620616d6f756e742c;

// Message signed by the sponsor that specifies the conditions under which a set of
// tokens, each sharing an allocator, can be claimed; the specified arbiter verifies
// that those conditions have been met and specifies a set of beneficiaries that will
// receive up to the specified amounts of each token.
struct BatchCompact {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    address arbiter; // The account tasked with verifying and submitting the claim.
    uint256[2][] idsAndAmounts; // The allocated token IDs and amounts.
        // Optional witness may follow.
}

// keccak256("BatchCompact(address sponsor,uint256 expires,uint256 nonce,address arbiter,uint256[2][] idsAndAmounts)")
bytes32 constant BATCH_COMPACT_TYPEHASH =
    0xfbab4df27768e9704f32c4acc9aa5196346c45840cdbcfd357b10b8eedab9547;

// abi.decode(bytes("BatchCompact(address sponsor,uin"), (bytes32))
bytes32 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE =
    0x4261746368436f6d7061637428616464726573732073706f6e736f722c75696e;

// abi.decode(bytes("t256 expires,uint256 nonce,addre"), (bytes32))
bytes32 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO =
    0x7432353620657870697265732c75696e74323536206e6f6e63652c6164647265;

// abi.decode(bytes("ss arbiter,uint256[2][] idsAndAm"), (bytes32))
bytes32 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE =
    0x737320617262697465722c75696e743235365b325d5b5d20696473416e64416d;

// abi.decode(bytes("ounts,"), (bytes6))
bytes6 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR = 0x6f756e74732c;

// A multichain compact can declare tokens and amounts to allocate from multiple chains,
// each designated by their chainId. Any allocated tokens must designate the Multichain
// scope. Each allocation may designate a unique arbiter for the chain in question.
struct Allocation {
    uint256 chainId;
    address arbiter; // The account tasked with verifying and submitting the claim.
    uint256[2][] idsAndAmounts; // The allocated token IDs and amounts.
        // Optional witness may follow.
}

// keccak256("Allocation(uint256 chainId,address arbiter,uint256[2][] idsAndAmounts)")
bytes32 constant ALLOCATION_TYPEHASH =
    0xa91c511929d172f286631ee8926f8c5d9398d508f3b0aa4939740713f10b72c8;

// abi.decode(bytes("Allocation(uint256 chainId,addre"), (bytes32))
bytes32 constant ALLOCATION_TYPESTRING_FRAGMENT_ONE =
    0x416c6c6f636174696f6e2875696e7432353620636861696e49642c6164647265;

// abi.decode(bytes("ss arbiter,uint256[2][] idsAndAm"), (bytes32))
bytes32 constant ALLOCATION_TYPESTRING_FRAGMENT_TWO =
    0x737320617262697465722c75696e743235365b325d5b5d20696473416e64416d;

// abi.decode(bytes("ounts,"), (bytes6))
bytes6 constant ALLOCATION_TYPESTRING_FRAGMENT_THREE = 0x6f756e74732c;

// Message signed by the sponsor that specifies the conditions under which a set of
// tokens across a number of different chains can be claimed; the specified arbiter on
// each chain verifies that those conditions have been met and specifies a set of
// beneficiaries that will receive up to the specified amounts of each token.
struct MultichainCompact {
    address sponsor; // The account to source the tokens from.
    uint256 expires; // The time at which the claim expires.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    Allocation[] allocations;
}

// keccak256("MultichainCompact(address sponsor,uint256 expires,uint256 nonce,Allocation[] allocations)Allocation(uint256 chainId,address arbiter,uint256[2][] idsAndAmounts)")
bytes32 constant MULTICHAIN_COMPACT_TYPEHASH =
    0x161e4c356136a00b95b614d3f6c15b3cee016a1565506416db570225e92e9e83;

// abi.decode(bytes("MultichainCompact(address sponso"), (bytes32))
bytes32 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE =
    0x4d756c7469636861696e436f6d7061637428616464726573732073706f6e736f;

// abi.decode(bytes("r,uint256 expires,uint256 nonce,"), (bytes32))
bytes32 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO =
    0x722c75696e7432353620657870697265732c75696e74323536206e6f6e63652c;

// abi.decode(bytes("Allocation[] allocations)"), (bytes25))
bytes25 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE =
    0x416c6c6f636174696f6e5b5d20616c6c6f636174696f6e7329;

// The allocator can optionally attest to arbitrary parameters. Any EIP-712 data
// type can be utilized as long as the first argument is the message hash of the
// associated compact signed by the sponsor, which will be supplied by The Compact.
// If additional parameters are not required, the allocator instead signs the same
// payload as the sponsor.

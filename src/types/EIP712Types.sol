// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Message signed by the sponsor that specifies the conditions under which their
// tokens can be claimed; the specified arbiter verifies that those conditions
// have been met and specifies a set of beneficiaries that will receive up to the
// specified amount of tokens.
struct Compact {
    address arbiter; // The account tasked with verifying and submitting the claim.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 amount; // The amount of ERC6909 tokens to allocate.
        // Optional witness may follow.
}

// keccak256("Compact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256 id,uint256 amount)")
bytes32 constant COMPACT_TYPEHASH =
    0xcdca950b17b5efc016b74b912d8527dfba5e404a688cbc3dab16cb943287fec2;

// abi.decode(bytes("Compact(address arbiter,address "), (bytes32))
bytes32 constant COMPACT_TYPESTRING_FRAGMENT_ONE =
    0x436f6d70616374286164647265737320617262697465722c6164647265737320;

// abi.decode(bytes("sponsor,uint256 nonce,uint256 ex"), (bytes32))
bytes32 constant COMPACT_TYPESTRING_FRAGMENT_TWO =
    0x73706f6e736f722c75696e74323536206e6f6e63652c75696e74323536206578;

// abi.decode(bytes("pires,uint256 id,uint256 amount,"), (bytes32))
bytes32 constant COMPACT_TYPESTRING_FRAGMENT_THREE =
    0x70697265732c75696e743235362069642c75696e7432353620616d6f756e742c;

// Message signed by the sponsor that specifies the conditions under which a set of
// tokens, each sharing an allocator, can be claimed; the specified arbiter verifies
// that those conditions have been met and specifies a set of beneficiaries that will
// receive up to the specified amounts of each token.
struct BatchCompact {
    address arbiter; // The account tasked with verifying and submitting the claim.
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    uint256[2][] idsAndAmounts; // The allocated token IDs and amounts.
        // Optional witness may follow.
}

// keccak256("BatchCompact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256[2][] idsAndAmounts)")
bytes32 constant BATCH_COMPACT_TYPEHASH =
    0x5a7fee8000a237929ef9be08f2933c4b4f320b00b38809f3c7aa104d5421049f;

// abi.decode(bytes("BatchCompact(address arbiter,add"), (bytes32))
bytes32 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE =
    0x4261746368436f6d70616374286164647265737320617262697465722c616464;
//abi.decode(bytes("BatchCompact(address arbiter,add"), (bytes32));

// abi.decode(bytes("ress sponsor,uint256 nonce,uint2"), (bytes32))
bytes32 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO =
    0x726573732073706f6e736f722c75696e74323536206e6f6e63652c75696e7432;
//abi.decode(bytes("ress sponsor,uint256 nonce,uint2"), (bytes32));

// abi.decode(bytes("56 expires,uint256[2][] idsAndAm"), (bytes32))
bytes32 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE =
    0x353620657870697265732c75696e743235365b325d5b5d20696473416e64416d;
//abi.decode(bytes("56 expires,uint256[2][] idsAndAm"), (bytes32));

// uint48(abi.decode(bytes("ounts,"), (bytes6)))
uint48 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR = 0x6f756e74732c;

// A multichain compact can declare tokens and amounts to allocate from multiple chains,
// each designated by their chainId. Any allocated tokens must designate the Multichain
// scope. Each allocation may designate a unique arbiter for the chain in question.
struct Allocation {
    address arbiter; // The account tasked with verifying and submitting the claim.
    uint256 chainId;
    uint256[2][] idsAndAmounts; // The allocated token IDs and amounts.
        // Optional witness may follow.
}

// keccak256("Allocation(address arbiter,uint256 chainId,uint256[2][] idsAndAmounts)")
bytes32 constant ALLOCATION_TYPEHASH =
    0x0f45f7853f78f307081d912de4b372d85725f696a9b9a4b5138a5a1d72b340e0;

// abi.decode(bytes("Allocation(address arbiter,uint2"), (bytes32))
bytes32 constant ALLOCATION_TYPESTRING_FRAGMENT_ONE =
    abi.decode(bytes("Allocation(address arbiter,uint2"), (bytes32));

// abi.decode(bytes("56 chainId,uint256[2][] idsAndAm"), (bytes32))
bytes32 constant ALLOCATION_TYPESTRING_FRAGMENT_TWO =
    abi.decode(bytes("56 chainId,uint256[2][] idsAndAm"), (bytes32));

// abi.decode(bytes("ounts,"), (bytes6))
bytes6 constant ALLOCATION_TYPESTRING_FRAGMENT_THREE = 0x6f756e74732c;

// Message signed by the sponsor that specifies the conditions under which a set of
// tokens across a number of different chains can be claimed; the specified arbiter on
// each chain verifies that those conditions have been met and specifies a set of
// beneficiaries that will receive up to the specified amounts of each token.
struct MultichainCompact {
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    Allocation[] allocations;
}

// keccak256("MultichainCompact(address sponsor,uint256 nonce,uint256 expires,Allocation[] allocations)Allocation(address arbiter,uint256 chainId,uint256[2][] idsAndAmounts)")
bytes32 constant MULTICHAIN_COMPACT_TYPEHASH =
    0x99704ffe7f2b23b270b03ab25ea2e37b1694622eb999ddcbf45d32d9b1a38c9c;

// abi.decode(bytes("MultichainCompact(address sponso"), (bytes32))
bytes32 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE =
    0x4d756c7469636861696e436f6d7061637428616464726573732073706f6e736f;

// abi.decode(bytes("r,uint256 nonce,uint256 expires,"), (bytes32))
bytes32 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO =
    abi.decode(bytes("r,uint256 nonce,uint256 expires,"), (bytes32));

// abi.decode(bytes("Allocation[] allocations)"), (bytes25))
bytes25 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE =
    0x416c6c6f636174696f6e5b5d20616c6c6f636174696f6e7329;

// The allocator can optionally attest to arbitrary parameters. Any EIP-712 data
// type can be utilized as long as the first argument is the message hash of the
// associated compact signed by the sponsor, which will be supplied by The Compact.
// If additional parameters are not required, the allocator instead signs the same
// payload as the sponsor.

/// @dev `keccak256(bytes("CompactDeposit(address depositor,address allocator,uint8 resetPeriod,uint8 scope,address recipient)"))`.
bytes32 constant PERMIT2_WITNESS_FRAGMENT_HASH =
    0x0091bfc8f1539e204529602051ae82f3e6c6f0f86d0227c9ea890616cedbe646;

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

// keccak256(bytes("Compact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256 id,uint256 amount)"))
bytes32 constant COMPACT_TYPEHASH = 0xcdca950b17b5efc016b74b912d8527dfba5e404a688cbc3dab16cb943287fec2;

// abi.decode(bytes("Compact(address arbiter,address "), (bytes32))
bytes32 constant COMPACT_TYPESTRING_FRAGMENT_ONE = 0x436f6d70616374286164647265737320617262697465722c6164647265737320;

// abi.decode(bytes("sponsor,uint256 nonce,uint256 ex"), (bytes32))
bytes32 constant COMPACT_TYPESTRING_FRAGMENT_TWO = 0x73706f6e736f722c75696e74323536206e6f6e63652c75696e74323536206578;

// abi.decode(bytes("pires,uint256 id,uint256 amount,"), (bytes32))
bytes32 constant COMPACT_TYPESTRING_FRAGMENT_THREE = 0x70697265732c75696e743235362069642c75696e7432353620616d6f756e742c;

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

// keccak256(bytes("BatchCompact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256[2][] idsAndAmounts)"))
bytes32 constant BATCH_COMPACT_TYPEHASH = 0x5a7fee8000a237929ef9be08f2933c4b4f320b00b38809f3c7aa104d5421049f;

// abi.decode(bytes("BatchCompact(address arbiter,add"), (bytes32))
bytes32 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE = 0x4261746368436f6d70616374286164647265737320617262697465722c616464;

// abi.decode(bytes("ress sponsor,uint256 nonce,uint2"), (bytes32))
bytes32 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO = 0x726573732073706f6e736f722c75696e74323536206e6f6e63652c75696e7432;

// abi.decode(bytes("56 expires,uint256[2][] idsAndAm"), (bytes32))
bytes32 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE = 0x353620657870697265732c75696e743235365b325d5b5d20696473416e64416d;

// uint48(abi.decode(bytes("ounts,"), (bytes6)))
uint48 constant BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR = 0x6f756e74732c;

// A multichain compact can declare tokens and amounts to allocate from multiple chains,
// each designated by their chainId. Any allocated tokens on an exogenous domain (e.g. all
// but the first segment) must designate the Multichain scope. Each segment may designate
// a unique arbiter for the chain in question. Note that the witness data is distinct for
// each segment, but all segments must share the same EIP-712 witness typestring.
struct Segment {
    address arbiter; // The account tasked with verifying and submitting the claim.
    uint256 chainId; // The chainId where the tokens are located.
    uint256[2][] idsAndAmounts; // The allocated token IDs and amounts.
        // Optional witness may follow.
}

// keccak256(bytes("Segment(address arbiter,uint256 chainId,uint256[2][] idsAndAmounts)"))
bytes32 constant SEGMENT_TYPEHASH = 0x295feb095767cc67d7e74695da0adaddede54d7b7194a8a5426fe8f0351e0337;

// Message signed by the sponsor that specifies the conditions under which a set of
// tokens across a number of different chains can be claimed; the specified arbiter on
// each chain verifies that those conditions have been met and specifies a set of
// beneficiaries that will receive up to the specified amounts of each token.
struct MultichainCompact {
    address sponsor; // The account to source the tokens from.
    uint256 nonce; // A parameter to enforce replay protection, scoped to allocator.
    uint256 expires; // The time at which the claim expires.
    Segment[] segments; // Arbiter, chainId, ids & amounts, and witness for each chain.
}

// keccak256(bytes("MultichainCompact(address sponsor,uint256 nonce,uint256 expires,Segment[] segments)Segment(address arbiter,uint256 chainId,uint256[2][] idsAndAmounts)"))
bytes32 constant MULTICHAIN_COMPACT_TYPEHASH = 0x5ca9a66b8bbf0d2316e90dfa3df465f0790b277b25393a3ef4d67e1f50865057;

// abi.decode(bytes("MultichainCompact(address sponso"), (bytes32))
bytes32 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE = 0x4d756c7469636861696e436f6d7061637428616464726573732073706f6e736f;

// abi.decode(bytes("r,uint256 nonce,uint256 expires,"), (bytes32))
bytes32 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO = 0x722c75696e74323536206e6f6e63652c75696e7432353620657870697265732c;

// abi.decode(bytes("Segment[] segments)Segment(addre"), (bytes32))
bytes32 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE = 0x5365676d656e745b5d207365676d656e7473295365676d656e74286164647265;

// abi.decode(bytes("ss arbiter,uint256 chainId,uint2"), (bytes32))
bytes32 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FOUR = 0x737320617262697465722c75696e7432353620636861696e49642c75696e7432;

// uint152(abi.decode(bytes("56[2][] idsAndAmounts,"), (uint176)))
uint176 constant MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FIVE = 0x35365b325d5b5d20696473416e64416d6f756e74732c;

// The allocator can optionally attest to arbitrary parameters. Any EIP-712 data
// type can be utilized as long as the first argument is the message hash of the
// associated compact signed by the sponsor, which will be supplied by The Compact.
// If additional parameters are not required, the allocator instead signs the same
// payload as the sponsor.

// An Emissary is an account that is authorized by a sponsor to register claims.
// This could be a contract that facilitates the creation of dynamic claims, or
// could relay multichain claims registerd on other domains.
struct EmissaryAssignment {
    address emissary; // The account to assign as the emissary.
    uint256 nonce; // A parameter to enforce replay protection, scoped to sponsor.
    uint256 expires; // The time at which the assignment expires.
    bool assigned; // Whether to assign the emissary or to unassign them.
}

// keccak256(bytes("EmissaryAssignment(address emissary,uint256 nonce,uint256 expires)"))
bytes32 constant EMISSARY_ASSIGNMENT_TYPEHASH = 0x5ca9a66b8bbf0d2316e90dfa3df465f0790b277b25393a3ef4d67e1f50865057;

/// @dev `keccak256(bytes("CompactDeposit(address depositor,address allocator,uint8 resetPeriod,uint8 scope,address recipient)"))`.
bytes32 constant PERMIT2_DEPOSIT_WITNESS_FRAGMENT_HASH = 0x0091bfc8f1539e204529602051ae82f3e6c6f0f86d0227c9ea890616cedbe646;

/// @dev `keccak256(bytes("PermitWitnessTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline,Activation witness)Activation(uint256 id,Compact compact)Compact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256 id,uint256 amount)TokenPermissions(address token,uint256 amount)"))`.
bytes32 constant PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPEHASH = 0xf653f659d3a9d0c2d3b3e901b5f71b67ad949a927c0c27b41dcdf4ecddd9b489;

// abi.decode(bytes("PermitWitnessTransferFrom(TokenP"), (bytes32))
bytes32 constant PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_ONE = 0x5065726d69745769746e6573735472616e7366657246726f6d28546f6b656e50;

// abi.decode(bytes("ermissions permitted,address spe"), (bytes32))
bytes32 constant PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_TWO = 0x65726d697373696f6e73207065726d69747465642c6164647265737320737065;

// abi.decode(bytes("nder,uint256 nonce,uint256 deadl"), (bytes32))
bytes32 constant PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_THREE = 0x6e6465722c75696e74323536206e6f6e63652c75696e7432353620646561646c;

// abi.decode(bytes("ine,Activation witness)Activatio"), (bytes32))
bytes32 constant PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_FOUR = 0x696e652c41637469766174696f6e207769746e6573732941637469766174696f;

// abi.decode(bytes("n(uint256 id,Compact compact)Com"), (bytes32))
bytes32 constant PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_FIVE = 0x6e2875696e743235362069642c436f6d7061637420636f6d7061637429436f6d;

// abi.decode(bytes("pact(address arbiter,address spo"), (bytes32))
bytes32 constant PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_SIX = 0x70616374286164647265737320617262697465722c616464726573732073706f;

// abi.decode(bytes("nsor,uint256 nonce,uint256 expir"), (bytes32))
bytes32 constant PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_SEVEN = 0x6e736f722c75696e74323536206e6f6e63652c75696e74323536206578706972;

// abi.decode(bytes("es,uint256 id,uint256 amount,"), (uint232))
uint232 constant PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_EIGHT = 0x65732c75696e743235362069642c75696e7432353620616d6f756e742c;

/// @dev `keccak256(bytes("PermitBatchWitnessTransferFrom(TokenPermissions[] permitted,address spender,uint256 nonce,uint256 deadline,BatchActivation witness)BatchActivation(uint256[] ids,BatchCompact compact)BatchCompact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256[2][] idsAndAmounts)TokenPermissions(address token,uint256 amount)"))`.
bytes32 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPEHASH = 0x95e426a66b0811209294f67c0bf2ae0aab045490466d04cd6bf18cb70295c0ad;

// abi.decode(bytes("PermitBatchWitnessTransferFrom(T"), (bytes32))
bytes32 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_ONE = 0x5065726d697442617463685769746e6573735472616e7366657246726f6d2854;

// abi.decode(bytes("okenPermissions[] permitted,addr"), (bytes32))
bytes32 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_TWO = 0x6f6b656e5065726d697373696f6e735b5d207065726d69747465642c61646472;

// abi.decode(bytes("ess spender,uint256 nonce,uint25"), (bytes32))
bytes32 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_THREE = 0x657373207370656e6465722c75696e74323536206e6f6e63652c75696e743235;

// abi.decode(bytes("6 deadline,BatchActivation witne"), (bytes32))
bytes32 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_FOUR = 0x3620646561646c696e652c426174636841637469766174696f6e207769746e65;

// abi.decode(bytes("ss)BatchActivation(uint256[] ids"), (bytes32))
bytes32 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_FIVE = 0x737329426174636841637469766174696f6e2875696e743235365b5d20696473;

// abi.decode(bytes(",BatchCompact compact)BatchCompa"), (bytes32))
bytes32 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_SIX = 0x2c4261746368436f6d7061637420636f6d70616374294261746368436f6d7061;

// abi.decode(bytes("ct(address arbiter,address spons"), (bytes32))
bytes32 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_SEVEN = 0x6374286164647265737320617262697465722c616464726573732073706f6e73;

// abi.decode(bytes("or,uint256 nonce,uint256 expires"), (bytes32))
bytes32 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_EIGHT = 0x6f722c75696e74323536206e6f6e63652c75696e743235362065787069726573;

// abi.decode(bytes(",uint256[2][] idsAndAmounts,"), (uint224))
uint224 constant PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_NINE = 0x2c75696e743235365b325d5b5d20696473416e64416d6f756e74732c;

/// @dev `keccak256(bytes("PermitBatchWitnessTransferFrom(TokenPermissions[] permitted,address spender,uint256 nonce,uint256 deadline,MultichainActivation witness)MultichainActivation(uint256[] ids,MultichainCompact compact)MultichainCompact(address sponsor,uint256 nonce,uint256 expires,Segment[] segments)Segment(address arbiter,uint256 chainId,uint256[2][] idsAndAmounts)TokenPermissions(address token,uint256 amount)"))`.
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPEHASH = 0xf90692f1da409b7329958cb54b2cd161e836e166b68c456b279b086ca53d43e1;

// abi.decode(bytes("PermitBatchWitnessTransferFrom(T"), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_ONE = 0x5065726d697442617463685769746e6573735472616e7366657246726f6d2854;

// abi.decode(bytes("okenPermissions[] permitted,addr"), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_TWO = 0x6f6b656e5065726d697373696f6e735b5d207065726d69747465642c61646472;

// abi.decode(bytes("ess spender,uint256 nonce,uint25"), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_THREE = 0x657373207370656e6465722c75696e74323536206e6f6e63652c75696e743235;

// abi.decode(bytes("6 deadline,MultichainActivation "), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_FOUR = 0x3620646561646c696e652c4d756c7469636861696e41637469766174696f6e20;

// abi.decode(bytes("witness)MultichainActivation(uin"), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_FIVE = 0x7769746e657373294d756c7469636861696e41637469766174696f6e2875696e;

// abi.decode(bytes("t256[] ids,MultichainCompact com"), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_SIX = 0x743235365b5d206964732c4d756c7469636861696e436f6d7061637420636f6d;

// abi.decode(bytes("pact)MultichainCompact(address s"), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_SEVEN = 0x70616374294d756c7469636861696e436f6d7061637428616464726573732073;

// abi.decode(bytes("ponsor,uint256 nonce,uint256 exp"), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_EIGHT = 0x706f6e736f722c75696e74323536206e6f6e63652c75696e7432353620657870;

// abi.decode(bytes("ires,Segment[] segments)Segment("), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_NINE = 0x697265732c5365676d656e745b5d207365676d656e7473295365676d656e7428;

// abi.decode(bytes("address arbiter,uint256 chainId,"), (bytes32))
bytes32 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_TEN = 0x6164647265737320617262697465722c75696e7432353620636861696e49642c;

// abi.decode(bytes("uint256[2][] idsAndAmounts,"), (uint216))
uint216 constant PERMIT2_MULTICHAIN_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_ELEVEN = 0x75696e743235365b325d5b5d20696473416e64416d6f756e74732c;

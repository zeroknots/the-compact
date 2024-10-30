// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ITheCompact } from "./interfaces/ITheCompact.sol";
import { ITheCompactClaims } from "./interfaces/ITheCompactClaims.sol";
import { CompactCategory } from "./types/CompactCategory.sol";
import { Lock } from "./types/Lock.sol";
import { Scope } from "./types/Scope.sol";
import { ResetPeriod } from "./types/ResetPeriod.sol";
import { ForcedWithdrawalStatus } from "./types/ForcedWithdrawalStatus.sol";
import { ConsumerLib } from "./lib/ConsumerLib.sol";
import { IdLib } from "./lib/IdLib.sol";
import { EfficiencyLib } from "./lib/EfficiencyLib.sol";
import { FunctionCastLib } from "./lib/FunctionCastLib.sol";
import { HashLib } from "./lib/HashLib.sol";
import { ValidityLib } from "./lib/ValidityLib.sol";
import { Extsload } from "./lib/Extsload.sol";
import { ERC6909 } from "solady/tokens/ERC6909.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { IPermit2 } from "permit2/src/interfaces/IPermit2.sol";
import { Tstorish } from "tstorish/Tstorish.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";
import {
    BasicTransfer,
    SplitTransfer,
    BasicClaim,
    QualifiedClaim,
    ClaimWithWitness,
    QualifiedClaimWithWitness,
    SplitClaim,
    SplitClaimWithWitness,
    QualifiedSplitClaim,
    QualifiedSplitClaimWithWitness
} from "./types/Claims.sol";

import {
    BatchTransfer,
    SplitBatchTransfer,
    BatchClaim,
    QualifiedBatchClaim,
    BatchClaimWithWitness,
    QualifiedBatchClaimWithWitness,
    SplitBatchClaim,
    SplitBatchClaimWithWitness,
    QualifiedSplitBatchClaim,
    QualifiedSplitBatchClaimWithWitness
} from "./types/BatchClaims.sol";

import {
    MultichainClaim,
    QualifiedMultichainClaim,
    MultichainClaimWithWitness,
    QualifiedMultichainClaimWithWitness,
    SplitMultichainClaim,
    SplitMultichainClaimWithWitness,
    QualifiedSplitMultichainClaim,
    QualifiedSplitMultichainClaimWithWitness,
    ExogenousMultichainClaim,
    ExogenousQualifiedMultichainClaim,
    ExogenousMultichainClaimWithWitness,
    ExogenousQualifiedMultichainClaimWithWitness,
    ExogenousSplitMultichainClaim,
    ExogenousSplitMultichainClaimWithWitness,
    ExogenousQualifiedSplitMultichainClaim,
    ExogenousQualifiedSplitMultichainClaimWithWitness
} from "./types/MultichainClaims.sol";

import {
    BatchMultichainClaim,
    QualifiedBatchMultichainClaim,
    BatchMultichainClaimWithWitness,
    QualifiedBatchMultichainClaimWithWitness,
    SplitBatchMultichainClaim,
    SplitBatchMultichainClaimWithWitness,
    QualifiedSplitBatchMultichainClaim,
    QualifiedSplitBatchMultichainClaimWithWitness,
    ExogenousBatchMultichainClaim,
    ExogenousQualifiedBatchMultichainClaim,
    ExogenousBatchMultichainClaimWithWitness,
    ExogenousQualifiedBatchMultichainClaimWithWitness,
    ExogenousSplitBatchMultichainClaim,
    ExogenousSplitBatchMultichainClaimWithWitness,
    ExogenousQualifiedSplitBatchMultichainClaim,
    ExogenousQualifiedSplitBatchMultichainClaimWithWitness
} from "./types/BatchMultichainClaims.sol";

import {
    COMPACT_TYPEHASH,
    BATCH_COMPACT_TYPEHASH,
    MULTICHAIN_COMPACT_TYPEHASH,
    PERMIT2_DEPOSIT_WITNESS_FRAGMENT_HASH,
    PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_ONE,
    PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_TWO,
    PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_ONE,
    PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_TWO,
    TOKEN_PERMISSIONS_TYPESTRING_FRAGMENT_ONE,
    TOKEN_PERMISSIONS_TYPESTRING_FRAGMENT_TWO,
    COMPACT_ACTIVATION_TYPEHASH,
    BATCH_COMPACT_ACTIVATION_TYPEHASH,
    MULTICHAIN_COMPACT_ACTIVATION_TYPEHASH,
    COMPACT_BATCH_ACTIVATION_TYPEHASH,
    BATCH_COMPACT_BATCH_ACTIVATION_TYPEHASH,
    MULTICHAIN_COMPACT_BATCH_ACTIVATION_TYPEHASH,
    PERMIT2_ACTIVATION_COMPACT_TYPESTRING_FRAGMENT_ONE,
    PERMIT2_ACTIVATION_COMPACT_TYPESTRING_FRAGMENT_TWO,
    PERMIT2_ACTIVATION_COMPACT_TYPESTRING_FRAGMENT_THREE,
    PERMIT2_ACTIVATION_COMPACT_TYPESTRING_FRAGMENT_FOUR,
    PERMIT2_ACTIVATION_BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE,
    PERMIT2_ACTIVATION_BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO,
    PERMIT2_ACTIVATION_BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE,
    PERMIT2_ACTIVATION_BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR,
    PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
    PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
    PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
    PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FOUR,
    PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FIVE,
    PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_SIX
} from "./types/EIP712Types.sol";

import { SplitComponent, TransferComponent, SplitByIdComponent, BatchClaimComponent, SplitBatchClaimComponent } from "./types/Components.sol";

import { IAllocator } from "./interfaces/IAllocator.sol";
import { MetadataRenderer } from "./lib/MetadataRenderer.sol";

/**
 * @title The Compact
 * @custom:version 0 (early-stage proof-of-concept)
 * @author 0age (0age.eth)
 * @notice The Compact is an ownerless ERC6909 contract that facilitates the voluntary
 *         formation (and, if necessary, involuntary dissolution) of "resource locks."
 *         This contract has not yet been properly tested, audited, or reviewed.
 */
contract TheCompact is ITheCompact, ITheCompactClaims, ERC6909, Tstorish {
    using HashLib for address;
    using HashLib for bytes32;
    using HashLib for uint256;
    using HashLib for BasicTransfer;
    using HashLib for SplitTransfer;
    using HashLib for BasicClaim;
    using HashLib for QualifiedClaim;
    using HashLib for ClaimWithWitness;
    using HashLib for QualifiedClaimWithWitness;
    using HashLib for SplitClaim;
    using HashLib for SplitClaimWithWitness;
    using HashLib for QualifiedSplitClaim;
    using HashLib for QualifiedSplitClaimWithWitness;
    using HashLib for BatchTransfer;
    using HashLib for SplitBatchTransfer;
    using HashLib for BatchClaim;
    using HashLib for QualifiedBatchClaim;
    using HashLib for BatchClaimWithWitness;
    using HashLib for QualifiedBatchClaimWithWitness;
    using HashLib for SplitBatchClaim;
    using HashLib for SplitBatchClaimWithWitness;
    using HashLib for QualifiedSplitBatchClaim;
    using HashLib for QualifiedSplitBatchClaimWithWitness;
    using HashLib for MultichainClaim;
    using HashLib for QualifiedMultichainClaim;
    using HashLib for MultichainClaimWithWitness;
    using HashLib for QualifiedMultichainClaimWithWitness;
    using HashLib for SplitMultichainClaim;
    using HashLib for SplitMultichainClaimWithWitness;
    using HashLib for QualifiedSplitMultichainClaim;
    using HashLib for QualifiedSplitMultichainClaimWithWitness;
    using HashLib for ExogenousMultichainClaim;
    using HashLib for ExogenousQualifiedMultichainClaim;
    using HashLib for ExogenousMultichainClaimWithWitness;
    using HashLib for ExogenousQualifiedMultichainClaimWithWitness;
    using HashLib for ExogenousSplitMultichainClaim;
    using HashLib for ExogenousSplitMultichainClaimWithWitness;
    using HashLib for ExogenousQualifiedSplitMultichainClaim;
    using HashLib for ExogenousQualifiedSplitMultichainClaimWithWitness;
    using HashLib for BatchMultichainClaim;
    using HashLib for QualifiedBatchMultichainClaim;
    using HashLib for BatchMultichainClaimWithWitness;
    using HashLib for QualifiedBatchMultichainClaimWithWitness;
    using HashLib for SplitBatchMultichainClaim;
    using HashLib for SplitBatchMultichainClaimWithWitness;
    using HashLib for QualifiedSplitBatchMultichainClaim;
    using HashLib for QualifiedSplitBatchMultichainClaimWithWitness;
    using HashLib for ExogenousBatchMultichainClaim;
    using HashLib for ExogenousQualifiedBatchMultichainClaim;
    using HashLib for ExogenousBatchMultichainClaimWithWitness;
    using HashLib for ExogenousQualifiedBatchMultichainClaimWithWitness;
    using HashLib for ExogenousSplitBatchMultichainClaim;
    using HashLib for ExogenousSplitBatchMultichainClaimWithWitness;
    using HashLib for ExogenousQualifiedSplitBatchMultichainClaim;
    using HashLib for ExogenousQualifiedSplitBatchMultichainClaimWithWitness;
    using IdLib for uint96;
    using IdLib for uint256;
    using IdLib for address;
    using IdLib for Lock;
    using IdLib for ResetPeriod;
    using IdLib for CompactCategory;
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    using ConsumerLib for uint256;
    using EfficiencyLib for bool;
    using EfficiencyLib for uint256;
    using ValidityLib for address;
    using ValidityLib for uint96;
    using ValidityLib for uint256;
    using ValidityLib for bytes32;
    using FunctionCastLib for function(bytes32, address, BasicTransfer calldata) internal;
    using FunctionCastLib for function(TransferComponent[] memory, uint256) internal returns (address);
    using FunctionCastLib for function(bytes32, BasicClaim calldata, address) internal view;
    using FunctionCastLib for function(bytes32, bytes32, QualifiedClaim calldata, address) internal view;
    using FunctionCastLib for function(QualifiedClaim calldata) internal returns (bytes32, address);
    using FunctionCastLib for function(QualifiedClaimWithWitness calldata) internal returns (bytes32, address);
    using FunctionCastLib for function(bytes32, uint256, uint256, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using FunctionCastLib for function(bytes32, uint256, uint256, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using FunctionCastLib for function(bytes32, bytes32, uint256, uint256, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using FunctionCastLib for function(bytes32, bytes32, uint256, uint256, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);

    address private constant _PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    uint256 private constant _REENTRANCY_GUARD_SLOT = 0x929eee149b4bd21268;

    /// @dev `keccak256(bytes("Transfer(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE = 0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    /// @dev `keccak256(bytes("Claim(address,address,address,bytes32)"))`.
    uint256 private constant _CLAIM_EVENT_SIGNATURE = 0x770c32a2314b700d6239ee35ba23a9690f2fceb93a55d8c753e953059b3b18d4;

    uint32 private constant _ATTEST_SELECTOR = 0x1a808f91;
    uint32 private constant _PERMIT_WITNESS_TRANSFER_FROM_SELECTOR = 0x137c29fe;
    uint32 private constant _BATCH_PERMIT_WITNESS_TRANSFER_FROM_SELECTOR = 0xfe8ec1a7;

    // Rage-quit functionality (TODO: optimize storage layout)
    mapping(address => mapping(uint256 => uint256)) private _cutoffTime;

    // TODO: optimize
    mapping(address => mapping(bytes32 => bytes32)) private _registeredClaimHashes;

    uint256 private immutable _INITIAL_CHAIN_ID;
    bytes32 private immutable _INITIAL_DOMAIN_SEPARATOR;
    MetadataRenderer private immutable _METADATA_RENDERER;
    bool private immutable _PERMIT2_INITIALLY_DEPLOYED;

    constructor() {
        _INITIAL_CHAIN_ID = block.chainid;
        _INITIAL_DOMAIN_SEPARATOR = block.chainid.toNotarizedDomainSeparator();
        _METADATA_RENDERER = new MetadataRenderer();
        _PERMIT2_INITIALLY_DEPLOYED = _checkPermit2Deployment();
    }

    function deposit(address allocator) external payable returns (uint256 id) {
        id = address(0).toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        _deposit(msg.sender, id, msg.value);
    }

    function depositAndRegister(address allocator, bytes32 claimHash, bytes32 typehash) external payable returns (uint256 id) {
        id = address(0).toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        _deposit(msg.sender, id, msg.value);

        _register(msg.sender, claimHash, typehash);
    }

    function deposit(address token, address allocator, uint256 amount) external returns (uint256) {
        return _performBasicERC20Deposit(token, allocator, amount, msg.sender);
    }

    function depositAndRegister(address token, address allocator, uint256 amount, bytes32 claimHash, bytes32 typehash) external returns (uint256 id) {
        id = _performBasicERC20Deposit(token, allocator, amount, msg.sender);

        _register(msg.sender, claimHash, typehash);
    }

    function _performBasicERC20Deposit(address token, address allocator, uint256 amount, address recipient) internal returns (uint256 id) {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);
        id = token.excludingNative().toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        _transferAndDeposit(token, msg.sender, id, amount);
        _clearTstorish(_REENTRANCY_GUARD_SLOT);
    }

    function deposit(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient) external payable returns (uint256 id) {
        id = address(0).toIdIfRegistered(scope, resetPeriod, allocator);

        _deposit(recipient, id, msg.value);
    }

    function deposit(address token, address allocator, ResetPeriod resetPeriod, Scope scope, uint256 amount, address recipient) external returns (uint256 id) {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);
        id = token.excludingNative().toIdIfRegistered(scope, resetPeriod, allocator);

        _transferAndDeposit(token, recipient, id, amount);
        _clearTstorish(_REENTRANCY_GUARD_SLOT);
    }

    function deposit(uint256[2][] calldata idsAndAmounts, address recipient) external payable returns (bool) {
        return _processBatchDeposit(idsAndAmounts, recipient);
    }

    function depositAndRegister(uint256[2][] calldata idsAndAmounts, bytes32[2][] calldata claimHashesAndTypehashes) external payable returns (bool) {
        _registerFor(msg.sender, claimHashesAndTypehashes);

        return _processBatchDeposit(idsAndAmounts, msg.sender);
    }

    function deposit(
        address token,
        uint256, // amount
        uint256, // nonce
        uint256, // deadline
        address, // depositor
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        address recipient,
        bytes calldata signature
    ) external returns (uint256) {
        bytes32 witness = _deriveCompactDepositWitnessHash(0xa4);

        (uint256 id, uint256 initialBalance, uint256 m, uint256 typestringMemoryLocation) = _setReentrancyLockAndStartPreparingPermit2Call(token, allocator, resetPeriod, scope);

        _insertCompactDepositTypestringAt(typestringMemoryLocation);

        assembly ("memory-safe") {
            mstore(add(m, 0x100), witness)
        }

        _writeSignatureAndPerformPermit2Call(m, uint256(0x140).asStubborn(), uint256(0x200).asStubborn(), signature);

        _checkBalanceAndDeposit(token, recipient, id, initialBalance);

        _clearTstorish(_REENTRANCY_GUARD_SLOT);

        return id;
    }

    function _deriveCompactDepositWitnessHash(uint256 calldataOffset) internal pure returns (bytes32 witnessHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // NOTE: none of these arguments are sanitized; the assumption is that they have to
            // match the signed values anyway, so *should* be fine not to sanitize them but could
            // optionally check that there are no dirty upper bits on any of them.
            mstore(m, PERMIT2_DEPOSIT_WITNESS_FRAGMENT_HASH)
            calldatacopy(add(m, 0x20), calldataOffset, 0x80) // allocator, resetPeriod, scope, recipient
            witnessHash := keccak256(m, 0xa0)
        }
    }

    function depositAndRegister(
        address token,
        uint256, // amount
        uint256, // nonce
        uint256, // deadline
        address depositor, // also recipient
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        bytes32 claimHash,
        CompactCategory compactCategory,
        string calldata witness,
        bytes calldata signature
    ) external returns (uint256) {
        (uint256 id, uint256 initialBalance, uint256 m, uint256 typestringMemoryLocation) = _setReentrancyLockAndStartPreparingPermit2Call(token, allocator, resetPeriod, scope);

        (bytes32 activationTypehash, bytes32 compactTypehash) = _writeWitnessAndGetTypehashes(typestringMemoryLocation, compactCategory, witness, bool(false).asStubborn());

        _deriveAndWriteWitnessHash(activationTypehash, id, claimHash, m, 0x100);

        uint256 signatureOffsetValue;
        assembly ("memory-safe") {
            signatureOffsetValue := and(add(mload(add(m, 0x160)), 0x17f), not(0x1f))
        }

        _writeSignatureAndPerformPermit2Call(m, uint256(0x140).asStubborn(), signatureOffsetValue, signature);

        _checkBalanceAndDeposit(token, depositor, id, initialBalance);

        _register(depositor, claimHash, compactTypehash);

        _clearTstorish(_REENTRANCY_GUARD_SLOT);

        return id;
    }

    function _writeSignatureAndPerformPermit2Call(uint256 m, uint256 signatureOffsetLocation, uint256 signatureOffsetValue, bytes calldata signature) internal {
        bool isPermit2Deployed = _isPermit2Deployed();
        assembly ("memory-safe") {
            mstore(add(m, signatureOffsetLocation), signatureOffsetValue) // signature offset

            let signatureLength := signature.length
            let signatureMemoryOffset := add(m, add(0x20, signatureOffsetValue))

            mstore(signatureMemoryOffset, signatureLength)
            calldatacopy(add(signatureMemoryOffset, 0x20), signature.offset, signatureLength)

            if iszero(and(isPermit2Deployed, call(gas(), _PERMIT2, 0, add(m, 0x1c), add(0x24, add(signatureOffsetValue, signatureLength)), 0, 0))) {
                // bubble up if the call failed and there's data
                // NOTE: consider evaluating remaining gas to protect against revert bombing
                if returndatasize() {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }

                // revert Permit2CallFailed();
                mstore(0, 0x7f28c61e)
                revert(0x1c, 0x04)
            }
        }
    }

    function _deriveAndWriteWitnessHash(bytes32 activationTypehash, uint256 idOrIdsHash, bytes32 claimHash, uint256 memoryPointer, uint256 offset) internal pure {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(0, activationTypehash)
            mstore(0x20, idOrIdsHash)
            mstore(0x40, claimHash)
            mstore(add(memoryPointer, offset), keccak256(0, 0x60))
            mstore(0x40, m)
        }
    }

    function deposit(
        address, // depositor
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        uint256, // nonce
        uint256, // deadline
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        address recipient,
        bytes calldata signature
    ) external payable returns (uint256[] memory ids) {
        uint256 totalTokensLessInitialNative;
        bool firstUnderlyingTokenIsNative;
        uint256[] memory initialTokenBalances;
        (totalTokensLessInitialNative, firstUnderlyingTokenIsNative, ids, initialTokenBalances) = _preprocessAndPerformInitialNativeDeposit(permitted, allocator, resetPeriod, scope, recipient);

        bytes32 witness = _deriveCompactDepositWitnessHash(0x84);

        (uint256 m, uint256 typestringMemoryLocation) = _beginPreparingBatchDepositPermit2Calldata(totalTokensLessInitialNative, firstUnderlyingTokenIsNative);

        unchecked {
            _insertCompactDepositTypestringAt(typestringMemoryLocation);
        }

        uint256 signatureOffsetValue;
        assembly ("memory-safe") {
            mstore(add(m, 0x80), witness)
            signatureOffsetValue := add(0x220, mul(totalTokensLessInitialNative, 0x80))
        }

        _writeSignatureAndPerformPermit2Call(m, uint256(0xc0).asStubborn(), signatureOffsetValue, signature);

        _verifyBalancesAndPerformDeposits(ids, permitted, initialTokenBalances, recipient, firstUnderlyingTokenIsNative);
    }

    function _insertCompactDepositTypestringAt(uint256 memoryLocation) internal pure {
        assembly ("memory-safe") {
            mstore(memoryLocation, 0x96)
            mstore(add(memoryLocation, 0x20), 0x436f6d706163744465706f736974207769746e65737329436f6d706163744465)
            mstore(add(memoryLocation, 0x40), 0x706f736974286164647265737320616c6c6f6361746f722c75696e7438207265)
            mstore(add(memoryLocation, 0x60), 0x736574506572696f642c75696e74382073636f70652c61646472657373207265)
            mstore(add(memoryLocation, 0x96), 0x20746f6b656e2c75696e7432353620616d6f756e7429)
            mstore(add(memoryLocation, 0x80), 0x63697069656e7429546f6b656e5065726d697373696f6e732861646472657373)
        }
    }

    function _beginPreparingBatchDepositPermit2Calldata(uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative) internal view returns (uint256 m, uint256 typestringMemoryLocation) {
        assembly ("memory-safe") {
            m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            let tokenChunk := mul(totalTokensLessInitialNative, 0x40)
            let twoTokenChunks := shl(1, tokenChunk)

            let permittedCalldataLocation := add(add(0x24, calldataload(0x24)), mul(firstUnderlyingTokenIsNative, 0x40))

            mstore(m, _BATCH_PERMIT_WITNESS_TRANSFER_FROM_SELECTOR)
            mstore(add(m, 0x20), 0xc0) // permitted offset
            mstore(add(m, 0x40), add(0x140, tokenChunk)) // details offset
            mstore(add(m, 0x60), calldataload(0x04)) // depositor
            // 0x80 => witnessHash
            mstore(add(m, 0xa0), add(0x160, twoTokenChunks)) // witness offset
            // 0xc0 => signatureOffset
            mstore(add(m, 0xe0), 0x60) // permitted tokens relative offset
            mstore(add(m, 0x100), calldataload(0x44)) // nonce
            mstore(add(m, 0x120), calldataload(0x64)) // deadline
            mstore(add(m, 0x140), totalTokensLessInitialNative) // permitted.length

            calldatacopy(add(m, 0x160), permittedCalldataLocation, tokenChunk) // permitted data

            let detailsOffset := add(add(m, 0x160), tokenChunk)
            mstore(detailsOffset, totalTokensLessInitialNative) // details.length

            // details data
            let starting := add(detailsOffset, 0x20)
            let next := add(detailsOffset, 0x40)
            let end := mul(totalTokensLessInitialNative, 0x40)
            for { let i := 0 } lt(i, end) { i := add(i, 0x40) } {
                mstore(add(starting, i), address())
                mstore(add(next, i), calldataload(add(permittedCalldataLocation, add(0x20, i))))
            }

            typestringMemoryLocation := add(m, add(0x180, twoTokenChunks))

            // TODO: strongly consider allocating memory here as the inline assembly scope
            // is being left (it *should* be fine for now as the function between assembly
            // blocks does not allocate any new memory).
        }
    }

    function _preprocessAndPerformInitialNativeDeposit(ISignatureTransfer.TokenPermissions[] calldata permitted, address allocator, ResetPeriod resetPeriod, Scope scope, address recipient)
        internal
        returns (uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative, uint256[] memory ids, uint256[] memory initialTokenBalances)
    {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);

        uint256 totalTokens = permitted.length;
        assembly ("memory-safe") {
            let permittedOffset := permitted.offset
            firstUnderlyingTokenIsNative := iszero(shr(96, shl(96, calldataload(permittedOffset))))

            // Revert if:
            //  * the array is empty
            //  * the callvalue is zero but the first token is native
            //  * the callvalue is nonzero but the first token is non-native
            //  * the first token is non-native and the callvalue doesn't equal the first amount
            if or(iszero(totalTokens), or(eq(firstUnderlyingTokenIsNative, iszero(callvalue())), and(firstUnderlyingTokenIsNative, iszero(eq(callvalue(), calldataload(add(permittedOffset, 0x20)))))))
            {
                // revert InvalidBatchDepositStructure()
                mstore(0, 0xca0fc08e)
                revert(0x1c, 0x04)
            }
        }

        uint256 initialId = address(0).toIdIfRegistered(scope, resetPeriod, allocator);
        ids = new uint256[](totalTokens);
        if (firstUnderlyingTokenIsNative) {
            _deposit(recipient, initialId, msg.value);
            ids[0] = initialId;
        }

        unchecked {
            totalTokensLessInitialNative = totalTokens - firstUnderlyingTokenIsNative.asUint256();
        }

        initialTokenBalances = _prepareIdsAndGetBalances(ids, totalTokensLessInitialNative, firstUnderlyingTokenIsNative, permitted, initialId);
    }

    function depositAndRegister(
        address depositor,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        uint256, // nonce
        uint256, // deadline
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        bytes32 claimHash,
        CompactCategory compactCategory,
        string calldata witness,
        bytes calldata signature
    ) external payable returns (uint256[] memory ids) {
        uint256 totalTokensLessInitialNative;
        bool firstUnderlyingTokenIsNative;
        uint256[] memory initialTokenBalances;
        (totalTokensLessInitialNative, firstUnderlyingTokenIsNative, ids, initialTokenBalances) = _preprocessAndPerformInitialNativeDeposit(permitted, allocator, resetPeriod, scope, depositor);

        uint256 idsHash;
        assembly ("memory-safe") {
            idsHash := keccak256(add(ids, 0x20), shl(5, add(totalTokensLessInitialNative, firstUnderlyingTokenIsNative)))
        }

        (uint256 m, uint256 typestringMemoryLocation) = _beginPreparingBatchDepositPermit2Calldata(totalTokensLessInitialNative, firstUnderlyingTokenIsNative);

        (bytes32 activationTypehash, bytes32 compactTypehash) = _writeWitnessAndGetTypehashes(typestringMemoryLocation, compactCategory, witness, bool(true).asStubborn());

        _deriveAndWriteWitnessHash(activationTypehash, idsHash, claimHash, m, 0x80);

        uint256 signatureOffsetValue;
        assembly ("memory-safe") {
            let witnessLength := witness.length
            let totalWitnessMemoryOffset := and(add(add(0xf3, add(witnessLength, iszero(iszero(witnessLength)))), add(mul(eq(compactCategory, 1), 0x0b), mul(eq(compactCategory, 2), 0x40))), not(0x1f))
            signatureOffsetValue := add(add(0x180, mul(totalTokensLessInitialNative, 0x80)), totalWitnessMemoryOffset)
        }

        _writeSignatureAndPerformPermit2Call(m, uint256(0xc0).asStubborn(), signatureOffsetValue, signature);

        _verifyBalancesAndPerformDeposits(ids, permitted, initialTokenBalances, depositor, firstUnderlyingTokenIsNative);

        _register(depositor, claimHash, compactTypehash);
    }

    function allocatedTransfer(BasicTransfer calldata transfer) external returns (bool) {
        return _processBasicTransfer(transfer, _release);
    }

    function allocatedWithdrawal(BasicTransfer calldata withdrawal) external returns (bool) {
        return _processBasicTransfer(withdrawal, _withdraw);
    }

    function allocatedTransfer(SplitTransfer calldata transfer) external returns (bool) {
        return _processSplitTransfer(transfer, _release);
    }

    function allocatedWithdrawal(SplitTransfer calldata withdrawal) external returns (bool) {
        return _processSplitTransfer(withdrawal, _withdraw);
    }

    function allocatedTransfer(BatchTransfer calldata transfer) external returns (bool) {
        return _processBatchTransfer(transfer, _release);
    }

    function allocatedWithdrawal(BatchTransfer calldata withdrawal) external returns (bool) {
        return _processBatchTransfer(withdrawal, _withdraw);
    }

    function allocatedTransfer(SplitBatchTransfer calldata transfer) external returns (bool) {
        return _processSplitBatchTransfer(transfer, _release);
    }

    function allocatedWithdrawal(SplitBatchTransfer calldata withdrawal) external returns (bool) {
        return _processSplitBatchTransfer(withdrawal, _withdraw);
    }

    function claim(BasicClaim calldata claimPayload) external returns (bool) {
        return _processBasicClaim(claimPayload, _release);
    }

    function claimAndWithdraw(BasicClaim calldata claimPayload) external returns (bool) {
        return _processBasicClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedClaim(claimPayload, _withdraw);
    }

    function claim(ClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(SplitClaim calldata claimPayload) external returns (bool) {
        return _processSplitClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitClaim calldata claimPayload) external returns (bool) {
        return _processSplitClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitClaim(claimPayload, _withdraw);
    }

    function claim(SplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(BatchClaim calldata claimPayload) external returns (bool) {
        return _processBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(BatchClaim calldata claimPayload) external returns (bool) {
        return _processBatchClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedBatchClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedBatchClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchClaim(claimPayload, _withdraw);
    }

    function claim(BatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(BatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(SplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchClaim(claimPayload, _withdraw);
    }

    function claim(SplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(MultichainClaim calldata claimPayload) external returns (bool) {
        return _processMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(MultichainClaim calldata claimPayload) external returns (bool) {
        return _processMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousQualifiedMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedMultichainClaim(claimPayload, _withdraw);
    }

    function claim(MultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(MultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(SplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processSplitMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processSplitMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousSplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousSplitMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousSplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousSplitMultichainClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousQualifiedSplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedSplitMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedSplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedSplitMultichainClaim(claimPayload, _withdraw);
    }

    function claim(SplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousSplitMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousSplitMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousQualifiedSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedSplitMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedSplitMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(BatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(BatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousQualifiedBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(BatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(BatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousQualifiedBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(SplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousSplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousSplitBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousSplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousSplitBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousQualifiedSplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedSplitBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedSplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedSplitBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(SplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousSplitBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousSplitBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedSplitBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedSplitBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt) {
        // overflow check not necessary as reset period is capped
        unchecked {
            withdrawableAt = block.timestamp + id.toResetPeriod().toSeconds();
        }

        _cutoffTime[msg.sender][id] = withdrawableAt;

        emit ForcedWithdrawalEnabled(msg.sender, id, withdrawableAt);
    }

    function disableForcedWithdrawal(uint256 id) external returns (bool) {
        if (_cutoffTime[msg.sender][id] == 0) {
            assembly ("memory-safe") {
                // revert ForcedWithdrawalAlreadyDisabled(msg.sender, id)
                mstore(0, 0xe632dbad)
                mstore(0x20, caller())
                mstore(0x40, id)
                revert(0x1c, 0x44)
            }
        }

        delete _cutoffTime[msg.sender][id];

        emit ForcedWithdrawalDisabled(msg.sender, id);

        return true;
    }

    function forcedWithdrawal(uint256 id, address recipient, uint256 amount) external returns (bool) {
        uint256 withdrawableAt = _cutoffTime[msg.sender][id];

        if ((withdrawableAt == 0).or(withdrawableAt > block.timestamp)) {
            assembly ("memory-safe") {
                // revert PrematureWithdrawal(id)
                mstore(0, 0x9287bcb0)
                mstore(0x20, id)
                revert(0x1c, 0x24)
            }
        }

        return _withdraw(msg.sender, recipient, id, amount);
    }

    function register(bytes32 claimHash, bytes32 typehash) external returns (bool) {
        _register(msg.sender, claimHash, typehash);
        return true;
    }

    function _register(address sponsor, bytes32 claimHash, bytes32 typehash) internal {
        _registeredClaimHashes[sponsor][claimHash] = typehash;
        emit CompactRegistered(sponsor, claimHash, typehash);
    }

    function register(bytes32[2][] calldata claimHashesAndTypehashes) external returns (bool) {
        return _registerFor(msg.sender, claimHashesAndTypehashes);
    }

    function _registerFor(address sponsor, bytes32[2][] calldata claimHashesAndTypehashes) internal returns (bool) {
        unchecked {
            uint256 totalClaimHashes = claimHashesAndTypehashes.length;
            for (uint256 i = 0; i < totalClaimHashes; ++i) {
                bytes32[2] calldata claimHashAndTypehash = claimHashesAndTypehashes[i];
                _register(sponsor, claimHashAndTypehash[0], claimHashAndTypehash[1]);
            }
        }

        return true;
    }

    function consume(uint256[] calldata nonces) external returns (bool) {
        // NOTE: this may not be necessary, consider removing
        msg.sender.usingAllocatorId().mustHaveARegisteredAllocator();

        unchecked {
            uint256 noncesLength = nonces.length;
            for (uint256 i = 0; i < noncesLength; ++i) {
                nonces[i].consumeNonceAsAllocator(msg.sender);
            }
        }

        return true;
    }

    function __registerAllocator(address allocator, bytes calldata proof) external returns (uint96 allocatorId) {
        allocator = uint256(uint160(allocator)).asSanitizedAddress();
        if (!allocator.canBeRegistered(proof)) {
            assembly ("memory-safe") {
                // revert InvalidRegistrationProof(allocator)
                mstore(0, 0x4e7f492b)
                mstore(0x20, allocator)
                revert(0x1c, 0x24)
            }
        }

        allocatorId = allocator.register();
    }

    function getForcedWithdrawalStatus(address account, uint256 id) external view returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt) {
        forcedWithdrawalAvailableAt = _cutoffTime[account][id];

        assembly ("memory-safe") {
            status := mul(iszero(iszero(forcedWithdrawalAvailableAt)), sub(2, gt(forcedWithdrawalAvailableAt, timestamp())))
        }
    }

    function getLockDetails(uint256 id) external view returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope) {
        token = id.toToken();
        allocator = id.toAllocatorId().toRegisteredAllocator();
        resetPeriod = id.toResetPeriod();
        scope = id.toScope();
    }

    function hasConsumedAllocatorNonce(uint256 nonce, address allocator) external view returns (bool consumed) {
        consumed = allocator.hasConsumedAllocatorNonce(nonce);
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator) {
        return _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
    }

    /// @dev Returns the symbol for token `id`.
    function name(uint256 id) public view virtual override returns (string memory) {
        return _METADATA_RENDERER.name(id);
    }

    /// @dev Returns the symbol for token `id`.
    function symbol(uint256 id) public view virtual override returns (string memory) {
        return _METADATA_RENDERER.symbol(id);
    }

    /// @dev Returns the Uniform Resource Identifier (URI) for token `id`.
    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return _METADATA_RENDERER.uri(id.toLock(), id);
    }

    /// @dev Returns the name for the contract.
    function name() external pure returns (string memory) {
        // Return the name of the contract.
        assembly ("memory-safe") {
            mstore(0x20, 0x20)
            mstore(0x4b, 0x0b54686520436f6d70616374)
            return(0x20, 0x60)
        }
    }

    function _processBatchDeposit(uint256[2][] calldata idsAndAmounts, address recipient) internal returns (bool) {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);
        uint256 totalIds = idsAndAmounts.length;
        bool firstUnderlyingTokenIsNative;
        uint256 id;

        assembly ("memory-safe") {
            let idsAndAmountsOffset := idsAndAmounts.offset
            id := calldataload(idsAndAmountsOffset)
            firstUnderlyingTokenIsNative := iszero(shr(96, shl(96, id)))
            // Revert if:
            //  * the array is empty
            //  * the callvalue is zero but the first token is native
            //  * the callvalue is nonzero but the first token is non-native
            //  * the first token is non-native and the callvalue doesn't equal the first amount
            if or(iszero(totalIds), or(eq(firstUnderlyingTokenIsNative, iszero(callvalue())), and(firstUnderlyingTokenIsNative, iszero(eq(callvalue(), calldataload(add(idsAndAmountsOffset, 0x20)))))))
            {
                // revert InvalidBatchDepositStructure()
                mstore(0, 0xca0fc08e)
                revert(0x1c, 0x04)
            }
        }

        uint96 currentAllocatorId = id.toRegisteredAllocatorId();

        if (firstUnderlyingTokenIsNative) {
            _deposit(recipient, id, msg.value);
        }

        unchecked {
            for (uint256 i = firstUnderlyingTokenIsNative.asUint256(); i < totalIds; ++i) {
                uint256[2] calldata idAndAmount = idsAndAmounts[i];
                id = idAndAmount[0];
                uint256 amount = idAndAmount[1];

                uint96 newAllocatorId = id.toAllocatorId();
                if (newAllocatorId != currentAllocatorId) {
                    newAllocatorId.mustHaveARegisteredAllocator();
                    currentAllocatorId = newAllocatorId;
                }

                _transferAndDeposit(id.toToken(), recipient, id, amount);
            }
        }

        _clearTstorish(_REENTRANCY_GUARD_SLOT);

        return true;
    }

    function _notExpiredAndSignedByAllocator(bytes32 messageHash, address allocator, BasicTransfer calldata transferPayload) internal {
        transferPayload.expires.later();

        messageHash.signedBy(allocator, transferPayload.allocatorSignature, _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID));

        _emitClaim(msg.sender, messageHash, allocator);
    }

    function _processBasicTransfer(BasicTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        _notExpiredAndSignedByAllocator(transfer.toMessageHash(), transfer.id.toRegisteredAllocatorWithConsumed(transfer.nonce), transfer);

        return operation(msg.sender, transfer.recipient, transfer.id, transfer.amount);
    }

    function _processSplitTransfer(SplitTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        _notExpiredAndSignedByAllocator.usingSplitTransfer()(transfer.toMessageHash(), transfer.id.toRegisteredAllocatorWithConsumed(transfer.nonce), transfer);

        uint256 totalSplits = transfer.recipients.length;
        unchecked {
            for (uint256 i = 0; i < totalSplits; ++i) {
                SplitComponent calldata component = transfer.recipients[i];
                operation(msg.sender, component.claimant, transfer.id, component.amount);
            }
        }

        return true;
    }

    function _processBatchTransfer(BatchTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        _notExpiredAndSignedByAllocator.usingBatchTransfer()(transfer.toMessageHash(), _deriveConsistentAllocatorAndConsumeNonce(transfer.transfers, transfer.nonce), transfer);

        unchecked {
            uint256 totalTransfers = transfer.transfers.length;
            for (uint256 i = 0; i < totalTransfers; ++i) {
                TransferComponent calldata component = transfer.transfers[i];
                operation(msg.sender, transfer.recipient, component.id, component.amount);
            }
        }

        return true;
    }

    function _processSplitBatchTransfer(SplitBatchTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        _notExpiredAndSignedByAllocator.usingSplitBatchTransfer()(
            transfer.toMessageHash(), _deriveConsistentAllocatorAndConsumeNonce.usingSplitByIdComponent()(transfer.transfers, transfer.nonce), transfer
        );

        unchecked {
            uint256 totalIds = transfer.transfers.length;
            uint256 id;
            for (uint256 i = 0; i < totalIds; ++i) {
                SplitByIdComponent calldata component = transfer.transfers[i];
                id = component.id;
                SplitComponent[] calldata portions = component.portions;
                uint256 totalPortions = portions.length;
                for (uint256 j = 0; j < totalPortions; ++j) {
                    SplitComponent calldata portion = portions[j];
                    operation(msg.sender, portion.claimant, id, portion.amount);
                }
            }
        }

        return true;
    }

    function _processSimpleClaim(bytes32 messageHash, uint256 calldataPointer, uint256 offsetToId, bytes32 typehash, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0), typehash, operation);
    }

    function _processSimpleSplitClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processSplitClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0), typehash, operation);
    }

    function _processSimpleBatchClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0), typehash, operation);
    }

    function _processBatchClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processBatchClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0), typehash, operation);
    }

    function _processSimpleSplitBatchClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processSplitBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0), typehash, operation);
    }

    function _processSplitBatchClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processSplitBatchClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0), typehash, operation);
    }

    function _processClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, operation);
    }

    function _processClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0), typehash, operation);
    }

    function _processSplitClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processSplitClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0), typehash, operation);
    }

    function _validate(uint96 allocatorId, bytes32 messageHash, bytes32 qualificationMessageHash, uint256 calldataPointer, bytes32 sponsorDomainSeparator, bytes32 typehash)
        internal
        returns (address sponsor)
    {
        bytes calldata allocatorSignature;
        bytes calldata sponsorSignature;
        uint256 nonce;
        uint256 expires;

        assembly ("memory-safe") {
            let allocatorSignaturePtr := add(calldataPointer, calldataload(calldataPointer))
            allocatorSignature.offset := add(0x20, allocatorSignaturePtr)
            allocatorSignature.length := calldataload(allocatorSignaturePtr)

            let sponsorSignaturePtr := add(calldataPointer, calldataload(add(calldataPointer, 0x20)))
            sponsorSignature.offset := add(0x20, sponsorSignaturePtr)
            sponsorSignature.length := calldataload(sponsorSignaturePtr)

            sponsor := shr(96, shl(96, calldataload(add(calldataPointer, 0x40))))
            nonce := calldataload(add(calldataPointer, 0x60))
            expires := calldataload(add(calldataPointer, 0x80))
        }

        expires.later();

        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(nonce);

        bytes32 domainSeparator = _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
        assembly ("memory-safe") {
            sponsorDomainSeparator := add(sponsorDomainSeparator, mul(iszero(sponsorDomainSeparator), domainSeparator))
        }

        if ((sponsorDomainSeparator != domainSeparator).or(sponsorSignature.length != 0) || _registeredClaimHashes[sponsor][messageHash] != typehash) {
            messageHash.signedBy(sponsor, sponsorSignature, sponsorDomainSeparator);
        }
        qualificationMessageHash.signedBy(allocator, allocatorSignature, domainSeparator);

        _emitClaim(sponsor, messageHash, allocator);
    }

    function _processSplitClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processSplitClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, operation);
    }

    function _processBatchClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, operation);
    }

    function _processSplitBatchClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processSplitBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, operation);
    }

    function _processClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        uint256 id;
        uint256 allocatedAmount;
        address claimant;
        uint256 amount;

        assembly ("memory-safe") {
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))
            claimant := shr(96, shl(96, calldataload(add(calldataPointerWithOffset, 0x40))))
            amount := calldataload(add(calldataPointerWithOffset, 0x60))
        }

        _ensureValidScope(sponsorDomainSeparator, id);

        amount.withinAllocated(allocatedAmount);

        return operation(_validate(id.toAllocatorId(), messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash), claimant, id, amount);
    }

    function _processSplitClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        uint256 id;
        uint256 allocatedAmount;
        SplitComponent[] calldata claimants;

        assembly ("memory-safe") {
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))

            let claimantsPtr := add(calldataPointer, calldataload(add(calldataPointerWithOffset, 0x40)))
            claimants.offset := add(0x20, claimantsPtr)
            claimants.length := calldataload(claimantsPtr)
        }

        address sponsor = _validate(id.toAllocatorId(), messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash);

        _ensureValidScope(sponsorDomainSeparator, id);

        return _verifyAndProcessSplitComponents(sponsor, id, allocatedAmount, claimants, operation);
    }

    function _ensureValidScope(bytes32 sponsorDomainSeparator, uint256 id) internal pure {
        assembly ("memory-safe") {
            if iszero(or(iszero(sponsorDomainSeparator), iszero(shr(255, id)))) {
                // revert InvalidScope(id)
                mstore(0, 0xa06356f5)
                mstore(0x20, id)
                revert(0x1c, 0x24)
            }
        }
    }

    function _processBatchClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        BatchClaimComponent[] calldata claims;
        address claimant;
        assembly ("memory-safe") {
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)
            let claimsPtr := add(calldataPointer, calldataload(calldataPointerWithOffset))
            claims.offset := add(0x20, claimsPtr)
            claims.length := calldataload(claimsPtr)

            claimant := calldataload(add(calldataPointerWithOffset, 0x20))
        }

        uint96 firstAllocatorId = claims[0].id.toAllocatorId();

        address sponsor = _validate(firstAllocatorId, messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash);

        uint256 totalClaims = claims.length;

        assembly ("memory-safe") {
            if iszero(totalClaims) {
                // revert InvalidBatchAllocation()
                mstore(0, 0x3a03d3bb)
                revert(0x1c, 0x04)
            }
        }

        // TODO: many of the bounds checks on these array accesses can be skipped as an optimization
        BatchClaimComponent calldata component = claims[0];
        uint256 id = component.id;
        uint256 amount = component.amount;
        uint256 errorBuffer = (component.allocatedAmount < amount).or((sponsorDomainSeparator != bytes32(0)).and(id.toScope() == Scope.ChainSpecific)).asUint256();

        operation(sponsor, claimant, id, amount);

        unchecked {
            for (uint256 i = 1; i < totalClaims; ++i) {
                component = claims[i];
                id = component.id;
                amount = component.amount;
                errorBuffer |=
                    (id.toAllocatorId() != firstAllocatorId).or(component.allocatedAmount < amount).or((sponsorDomainSeparator != bytes32(0)).and(id.toScope() == Scope.ChainSpecific)).asUint256();

                operation(sponsor, claimant, id, amount);
            }

            if (errorBuffer.asBool()) {
                for (uint256 i = 0; i < totalClaims; ++i) {
                    component = claims[i];
                    component.amount.withinAllocated(component.allocatedAmount);
                    id = component.id;
                    _ensureValidScope(sponsorDomainSeparator, component.id);
                }

                assembly ("memory-safe") {
                    // revert InvalidBatchAllocation()
                    mstore(0, 0x3a03d3bb)
                    revert(0x1c, 0x04)
                }
            }
        }

        return true;
    }

    function _processSplitBatchClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        SplitBatchClaimComponent[] calldata claims;
        assembly ("memory-safe") {
            let claimsPtr := add(calldataPointer, calldataload(add(calldataPointer, offsetToId)))
            claims.offset := add(0x20, claimsPtr)
            claims.length := calldataload(claimsPtr)
        }

        uint96 firstAllocatorId = claims[0].id.toAllocatorId();

        address sponsor = _validate(firstAllocatorId, messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash);

        uint256 totalClaims = claims.length;
        uint256 errorBuffer = (totalClaims == 0).asUint256();
        uint256 id;

        unchecked {
            for (uint256 i = 0; i < totalClaims; ++i) {
                SplitBatchClaimComponent calldata claimComponent = claims[i];
                id = claimComponent.id;
                errorBuffer |= (id.toAllocatorId() != firstAllocatorId).or((sponsorDomainSeparator != bytes32(0)).and(id.toScope() == Scope.ChainSpecific)).asUint256();

                _verifyAndProcessSplitComponents(sponsor, id, claimComponent.allocatedAmount, claimComponent.portions, operation);
            }

            if (errorBuffer.asBool()) {
                for (uint256 i = 0; i < totalClaims; ++i) {
                    _ensureValidScope(sponsorDomainSeparator, claims[i].id);
                }

                assembly ("memory-safe") {
                    // revert InvalidBatchAllocation()
                    mstore(0, 0x3a03d3bb)
                    revert(0x1c, 0x04)
                }
            }
        }

        return true;
    }

    function _processBasicClaim(BasicClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleClaim.usingBasicClaim()(claimPayload.toMessageHash(), claimPayload, 0xa0, _typehashes(uint256(0).asStubborn()), operation);
    }

    function _processQualifiedClaim(QualifiedClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processClaimWithQualification.usingQualifiedClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, _typehashes(uint256(0).asStubborn()), operation);
    }

    function _processClaimWithWitness(ClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleClaim.usingClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedClaimWithWitness(QualifiedClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processClaimWithQualification.usingQualifiedClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    function _processMultichainClaim(MultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleClaim.usingMultichainClaim()(claimPayload.toMessageHash(), claimPayload, 0xc0, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processQualifiedMultichainClaim(QualifiedMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processClaimWithQualification.usingQualifiedMultichainClaim()(messageHash, qualificationMessageHash, claimPayload, 0x100, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processMultichainClaimWithWitness(MultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleClaim.usingMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedMultichainClaimWithWitness(QualifiedMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processClaimWithQualification.usingQualifiedMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    function _processQualifiedSplitBatchMultichainClaim(QualifiedSplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x100, _typehashes(uint256(1).asStubborn()), operation
        );
    }

    function _processSplitBatchMultichainClaimWithWitness(SplitBatchMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleSplitBatchClaim.usingSplitBatchMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedSplitBatchMultichainClaimWithWitness(
        QualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    function _processSplitMultichainClaim(SplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleSplitClaim.usingSplitMultichainClaim()(claimPayload.toMessageHash(), claimPayload, 0xc0, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processQualifiedSplitMultichainClaim(QualifiedSplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualification.usingQualifiedSplitMultichainClaim()(messageHash, qualificationMessageHash, claimPayload, 0x100, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processSplitMultichainClaimWithWitness(SplitMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleSplitClaim.usingSplitMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedSplitMultichainClaimWithWitness(
        QualifiedSplitMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualification.usingQualifiedSplitMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    function _processBatchMultichainClaim(BatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleBatchClaim.usingBatchMultichainClaim()(claimPayload.toMessageHash(), claimPayload, 0xc0, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processQualifiedBatchMultichainClaim(QualifiedBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualification.usingQualifiedBatchMultichainClaim()(messageHash, qualificationMessageHash, claimPayload, 0x100, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processBatchMultichainClaimWithWitness(BatchMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleBatchClaim.usingBatchMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedBatchMultichainClaimWithWitness(
        QualifiedBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualification.usingQualifiedBatchMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    function _processExogenousQualifiedBatchMultichainClaim(
        ExogenousQualifiedBatchMultichainClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedBatchMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousBatchMultichainClaimWithWitness(
        ExogenousBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processBatchClaimWithSponsorDomain.usingExogenousBatchMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousQualifiedBatchMultichainClaimWithWitness(
        ExogenousQualifiedBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedBatchMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _typehashes(uint256 i) internal pure returns (bytes32 typehash) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(0, COMPACT_TYPEHASH)
            mstore(0x20, BATCH_COMPACT_TYPEHASH)
            mstore(0x40, MULTICHAIN_COMPACT_TYPEHASH)
            typehash := mload(shl(5, i))
            mstore(0x40, m)
        }
    }

    function _processExogenousMultichainClaim(ExogenousMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processClaimWithSponsorDomain.usingExogenousMultichainClaim()(
            claimPayload.toMessageHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processSplitBatchMultichainClaim(SplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSimpleSplitBatchClaim.usingSplitBatchMultichainClaim()(claimPayload.toMessageHash(), claimPayload, 0xc0, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processExogenousMultichainClaimWithWitness(ExogenousMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return
            _processClaimWithSponsorDomain.usingExogenousMultichainClaimWithWitness()(messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation);
    }

    function _processExogenousQualifiedMultichainClaim(ExogenousQualifiedMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousQualifiedSplitMultichainClaim(
        ExogenousQualifiedSplitMultichainClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousQualifiedMultichainClaimWithWitness(
        ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousSplitMultichainClaim(ExogenousSplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSplitClaimWithSponsorDomain.usingExogenousSplitMultichainClaim()(
            claimPayload.toMessageHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousSplitMultichainClaimWithWitness(
        ExogenousSplitMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitClaimWithSponsorDomain.usingExogenousSplitMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousQualifiedSplitMultichainClaimWithWitness(
        ExogenousQualifiedSplitMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousBatchMultichainClaim(ExogenousBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processBatchClaimWithSponsorDomain.usingExogenousBatchMultichainClaim()(
            claimPayload.toMessageHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousSplitBatchMultichainClaim(ExogenousSplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSplitBatchClaimWithSponsorDomain.usingExogenousSplitBatchMultichainClaim()(
            claimPayload.toMessageHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousQualifiedSplitBatchMultichainClaim(
        ExogenousQualifiedSplitBatchMultichainClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitBatchMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousSplitBatchMultichainClaimWithWitness(
        ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithSponsorDomain.usingExogenousSplitBatchMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousQualifiedSplitBatchMultichainClaimWithWitness(
        ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitBatchMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processSplitClaim(SplitClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleSplitClaim.usingSplitClaim()(claimPayload.toMessageHash(), claimPayload, 0xa0, _typehashes(uint256(0).asStubborn()), operation);
    }

    function _processQualifiedSplitClaim(QualifiedSplitClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualification.usingQualifiedSplitClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, _typehashes(uint256(0).asStubborn()), operation);
    }

    function _processSplitClaimWithWitness(SplitClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleSplitClaim.usingSplitClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedSplitClaimWithWitness(QualifiedSplitClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualification.usingQualifiedSplitClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    function _processBatchClaim(BatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleBatchClaim.usingBatchClaim()(claimPayload.toMessageHash(), claimPayload, 0xa0, _typehashes(uint256(1).asStubborn()), operation);
    }

    function _processSplitBatchClaim(SplitBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleSplitBatchClaim.usingSplitBatchClaim()(claimPayload.toMessageHash(), claimPayload, 0xa0, _typehashes(uint256(1).asStubborn()), operation);
    }

    function _processQualifiedSplitBatchClaim(QualifiedSplitBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, _typehashes(uint256(1).asStubborn()), operation);
    }

    function _processQualifiedSplitBatchClaimWithWitness(QualifiedSplitBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    function _processSplitBatchClaimWithWitness(SplitBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleSplitBatchClaim.usingSplitBatchClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedBatchClaim(QualifiedBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualification.usingQualifiedBatchClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, _typehashes(uint256(1).asStubborn()), operation);
    }

    function _processBatchClaimWithWitness(BatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleBatchClaim.usingBatchClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedBatchClaimWithWitness(QualifiedBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualification.usingQualifiedBatchClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    function _verifyBalancesAndPerformDeposits(
        uint256[] memory ids,
        ISignatureTransfer.TokenPermissions[] calldata permittedTokens,
        uint256[] memory initialTokenBalances,
        address recipient,
        bool firstUnderlyingTokenIsNative
    ) internal {
        uint256 tokenBalance;
        uint256 initialBalance;
        uint256 errorBuffer;
        uint256 totalTokensLessInitialNative = initialTokenBalances.length;

        unchecked {
            for (uint256 i = 0; i < totalTokensLessInitialNative; ++i) {
                tokenBalance = permittedTokens[i + firstUnderlyingTokenIsNative.asUint256()].token.balanceOf(address(this));
                initialBalance = initialTokenBalances[i];
                errorBuffer |= (initialBalance >= tokenBalance).asUint256();

                _deposit(recipient, ids[i + firstUnderlyingTokenIsNative.asUint256()], tokenBalance - initialBalance);
            }
        }

        assembly ("memory-safe") {
            if errorBuffer {
                // revert InvalidDepositBalanceChange()
                mstore(0, 0x426d8dcf)
                revert(0x1c, 0x04)
            }
        }

        _clearTstorish(_REENTRANCY_GUARD_SLOT);
    }

    function _verifyAndProcessSplitComponents(
        address sponsor,
        uint256 id,
        uint256 allocatedAmount,
        SplitComponent[] calldata claimants,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        uint256 totalClaims = claimants.length;
        uint256 spentAmount = 0;
        uint256 errorBuffer = (totalClaims == 0).asUint256();

        unchecked {
            for (uint256 i = 0; i < totalClaims; ++i) {
                SplitComponent calldata component = claimants[i];
                uint256 amount = component.amount;

                uint256 updatedSpentAmount = amount + spentAmount;
                errorBuffer |= (updatedSpentAmount < spentAmount).asUint256();
                spentAmount = updatedSpentAmount;

                operation(sponsor, component.claimant, id, amount);
            }
        }

        errorBuffer |= (allocatedAmount < spentAmount).asUint256();
        assembly ("memory-safe") {
            if errorBuffer {
                // revert AllocatedAmountExceeded(allocatedAmount, amount);
                mstore(0, 0x3078b2f6)
                mstore(0x20, allocatedAmount)
                mstore(0x40, spentAmount)
                revert(0x1c, 0x44)
            }
        }

        return true;
    }

    // NOTE: all tokens must be supplied in ascending order and cannot be duplicated.
    function _prepareIdsAndGetBalances(
        uint256[] memory ids,
        uint256 totalTokensLessInitialNative,
        bool firstUnderlyingTokenIsNative,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        uint256 id
    ) internal view returns (uint256[] memory tokenBalances) {
        unchecked {
            tokenBalances = new uint256[](totalTokensLessInitialNative);

            address token;
            uint256 candidateId;
            uint256 errorBuffer;

            for (uint256 i = 0; i < totalTokensLessInitialNative; ++i) {
                token = permitted[i + firstUnderlyingTokenIsNative.asUint256()].token;
                candidateId = id.withReplacedToken(token);
                errorBuffer |= (candidateId <= id).asUint256();
                id = candidateId;

                ids[i + firstUnderlyingTokenIsNative.asUint256()] = id;

                tokenBalances[i] = token.balanceOf(address(this));
            }

            assembly ("memory-safe") {
                if errorBuffer {
                    // revert InvalidDepositTokenOrdering()
                    mstore(0, 0x0f2f1e51)
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    function _deriveConsistentAllocatorAndConsumeNonce(TransferComponent[] memory components, uint256 nonce) internal returns (address allocator) {
        uint256 totalComponents = components.length;

        uint256 errorBuffer = (components.length == 0).asUint256();

        // TODO: bounds checks on these array accesses can be skipped as an optimization
        uint96 allocatorId = components[0].id.toAllocatorId();

        allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(nonce);

        unchecked {
            for (uint256 i = 1; i < totalComponents; ++i) {
                errorBuffer |= (components[i].id.toAllocatorId() != allocatorId).asUint256();
            }
        }

        assembly ("memory-safe") {
            if errorBuffer {
                // revert InvalidBatchAllocation()
                mstore(0, 0x3a03d3bb)
                revert(0x1c, 0x04)
            }
        }
    }

    function _emitClaim(address sponsor, bytes32 messageHash, address allocator) internal {
        assembly ("memory-safe") {
            mstore(0, messageHash)
            log4(0, 0x20, _CLAIM_EVENT_SIGNATURE, shr(0x60, shl(0x60, sponsor)), shr(0x60, shl(0x60, allocator)), caller())
        }
    }

    function _setReentrancyLockAndStartPreparingPermit2Call(address token, address allocator, ResetPeriod resetPeriod, Scope scope)
        internal
        returns (uint256 id, uint256 initialBalance, uint256 m, uint256 typestringMemoryLocation)
    {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);
        id = token.excludingNative().toIdIfRegistered(scope, resetPeriod, allocator);

        initialBalance = token.balanceOf(address(this));

        assembly ("memory-safe") {
            m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, _PERMIT_WITNESS_TRANSFER_FROM_SELECTOR)
            calldatacopy(add(m, 0x20), 0x04, 0x80) // token, amount, nonce, deadline
            mstore(add(m, 0xa0), address())
            mstore(add(m, 0xc0), calldataload(0x24)) // amount
            mstore(add(m, 0xe0), calldataload(0x84)) // depositor
            mstore(add(m, 0x120), 0x140)
            typestringMemoryLocation := add(m, 0x160)

            // TODO: strongly consider allocating memory here as the inline assembly scope
            // is being left (it *should* be fine for now as the function between assembly
            // blocks does not allocate any new memory).
        }
    }

    /// @dev Moves token `id` from `from` to `to` without checking
    //  allowances or _beforeTokenTransfer / _afterTokenTransfer hooks.
    function _release(address from, address to, uint256 id, uint256 amount) internal returns (bool) {
        assembly ("memory-safe") {
            /// Compute the balance slot and load its value.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, from)
            mstore(0x00, id)
            let fromBalanceSlot := keccak256(0x00, 0x40)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if insufficient or zero balance.
            if or(iszero(amount), gt(amount, fromBalance)) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))
            // Compute the balance slot of `to`.
            mstore(0x14, to)
            mstore(0x00, id)
            let toBalanceSlot := keccak256(0x00, 0x40)
            let toBalanceBefore := sload(toBalanceSlot)
            let toBalanceAfter := add(toBalanceBefore, amount)
            // Revert if the balance overflows.
            if lt(toBalanceAfter, toBalanceBefore) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            // Store the updated balance of `to`.
            sstore(toBalanceSlot, toBalanceAfter)
            // Emit the {Transfer} event.
            mstore(0x00, caller())
            mstore(0x20, amount)
            // forgefmt: disable-next-line
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, shr(0x60, shl(0x60, from)), shr(0x60, shl(0x60, to)), id)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x34, 0x00)
        }

        return true;
    }

    /// @dev Transfers `amount` of `token` and mints the resulting balance change of `id` to `to`.
    /// Emits a {Transfer} event.
    function _transferAndDeposit(address token, address to, uint256 id, uint256 amount) internal {
        uint256 initialBalance = token.balanceOf(address(this));

        token.safeTransferFrom(msg.sender, address(this), amount);

        _checkBalanceAndDeposit(token, to, id, initialBalance);
    }

    /// @dev Retrieves a token balance, compares against `initialBalance`, and mints the resulting balance
    /// change of `id` to `to`. Emits a {Transfer} event.
    function _checkBalanceAndDeposit(address token, address to, uint256 id, uint256 initialBalance) internal {
        uint256 tokenBalance = token.balanceOf(address(this));

        assembly ("memory-safe") {
            if iszero(lt(initialBalance, tokenBalance)) {
                // revert InvalidDepositBalanceChange()
                mstore(0, 0x426d8dcf)
                revert(0x1c, 0x04)
            }
        }

        unchecked {
            _deposit(to, id, tokenBalance - initialBalance);
        }
    }

    /// @dev Mints `amount` of token `id` to `to` without checking transfer hooks.
    /// Emits a {Transfer} event.
    function _deposit(address to, uint256 id, uint256 amount) internal {
        assembly ("memory-safe") {
            // Compute the balance slot.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, to)
            mstore(0x00, id)
            let toBalanceSlot := keccak256(0x00, 0x40)
            // Add and store the updated balance
            let toBalanceBefore := sload(toBalanceSlot)
            let toBalanceAfter := add(toBalanceBefore, amount)
            // Revert if the balance overflows.
            if lt(toBalanceAfter, toBalanceBefore) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, toBalanceAfter)

            let recipient := shr(0x60, shl(0x60, to))

            // Emit the {Transfer} and {Deposit} events.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0, 0x40, _TRANSFER_EVENT_SIGNATURE, 0, recipient, id)
        }
    }

    /// @dev Burns `amount` token `id` from `from` without checking transfer hooks and sends
    /// the corresponding underlying tokens to `to`. Emits a {Transfer} event.
    function _withdraw(address from, address to, uint256 id, uint256 amount) internal returns (bool) {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);
        address token = id.toToken();

        if (token == address(0)) {
            to.safeTransferETH(amount);
        } else {
            uint256 initialBalance = token.balanceOf(address(this));
            token.safeTransfer(to, amount);
            // NOTE: if the balance increased, this will underflow to a massive number causing
            // the burn to fail; furthermore, this scenario would indicate a very broken token
            unchecked {
                amount = initialBalance - token.balanceOf(address(this));
            }
        }

        assembly ("memory-safe") {
            // Compute the balance slot.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, from)
            mstore(0x00, id)
            let fromBalanceSlot := keccak256(0x00, 0x40)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))

            let account := shr(0x60, shl(0x60, from))

            // Emit the {Transfer} and {Withdrawal} events.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, account, 0, id)
        }

        _clearTstorish(_REENTRANCY_GUARD_SLOT);

        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 id, uint256 amount) internal virtual override {
        address allocator = id.toAllocator();

        assembly ("memory-safe") {
            from := shr(0x60, shl(0x60, from))
            to := shr(0x60, shl(0x60, to))

            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.
            mstore(0, 0) // make sure scratch space is cleared just to be safe.
            let dataStart := add(m, 0x1c)

            mstore(m, _ATTEST_SELECTOR)
            mstore(add(m, 0x20), caller())
            mstore(add(m, 0x40), from)
            mstore(add(m, 0x60), to)
            mstore(add(m, 0x80), id)
            mstore(add(m, 0xa0), amount)
            let success := call(gas(), allocator, 0, dataStart, 0xa4, 0, 0x20)
            if iszero(eq(mload(0), shl(224, _ATTEST_SELECTOR))) {
                // bubble up if the call failed and there's data
                // NOTE: consider evaluating remaining gas to protect against revert bombing
                if iszero(or(success, iszero(returndatasize()))) {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }

                // revert UnallocatedTransfer(msg.sender, from, to, id, amount)
                mstore(m, 0x014c9310)
                revert(dataStart, 0xa4)
            }
        }
    }

    function _isPermit2Deployed() internal view returns (bool) {
        if (_PERMIT2_INITIALLY_DEPLOYED) {
            return true;
        }

        return _checkPermit2Deployment();
    }

    function _checkPermit2Deployment() internal view returns (bool permit2Deployed) {
        assembly ("memory-safe") {
            permit2Deployed := iszero(iszero(extcodesize(_PERMIT2)))
        }
    }

    function _writeWitnessAndGetTypehashes(uint256 memoryLocation, CompactCategory category, string calldata witness, bool usingBatch)
        internal
        pure
        returns (bytes32 activationTypehash, bytes32 compactTypehash)
    {
        assembly ("memory-safe") {
            function writeWitnessAndGetTypehashes(memLocation, c, witnessOffset, witnessLength, usesBatch) -> derivedActivationTypehash, derivedCompactTypehash {
                let memoryOffset := add(memLocation, 0x20)

                let activationStart
                let categorySpecificStart
                if iszero(usesBatch) {
                    // 1a. prepare initial Activation witness string at offset
                    mstore(add(memoryOffset, 0x09), PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_TWO)
                    mstore(memoryOffset, PERMIT2_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_ONE)

                    activationStart := add(memoryOffset, 0x13)
                    categorySpecificStart := add(memoryOffset, 0x29)
                }

                if iszero(activationStart) {
                    // 1b. prepare initial BatchActivation witness string at offset
                    mstore(add(memoryOffset, 0x16), PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_TWO)
                    mstore(memoryOffset, PERMIT2_BATCH_DEPOSIT_WITH_ACTIVATION_TYPESTRING_FRAGMENT_ONE)

                    activationStart := add(memoryOffset, 0x18)
                    categorySpecificStart := add(memoryOffset, 0x36)
                }

                // 2. prepare activation witness string at offset
                let categorySpecificEnd
                if iszero(c) {
                    mstore(categorySpecificStart, PERMIT2_ACTIVATION_COMPACT_TYPESTRING_FRAGMENT_ONE)
                    mstore(add(categorySpecificStart, 0x20), PERMIT2_ACTIVATION_COMPACT_TYPESTRING_FRAGMENT_TWO)
                    mstore(add(categorySpecificStart, 0x50), PERMIT2_ACTIVATION_COMPACT_TYPESTRING_FRAGMENT_FOUR)
                    mstore(add(categorySpecificStart, 0x40), PERMIT2_ACTIVATION_COMPACT_TYPESTRING_FRAGMENT_THREE)
                    categorySpecificEnd := add(categorySpecificStart, 0x70)
                    categorySpecificStart := add(categorySpecificStart, 0x10)
                }

                if iszero(sub(c, 1)) {
                    mstore(categorySpecificStart, PERMIT2_ACTIVATION_BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE)
                    mstore(add(categorySpecificStart, 0x20), PERMIT2_ACTIVATION_BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO)
                    mstore(add(categorySpecificStart, 0x5b), PERMIT2_ACTIVATION_BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR)
                    mstore(add(categorySpecificStart, 0x40), PERMIT2_ACTIVATION_BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE)
                    categorySpecificEnd := add(categorySpecificStart, 0x7b)
                    categorySpecificStart := add(categorySpecificStart, 0x15)
                }

                if iszero(categorySpecificEnd) {
                    mstore(categorySpecificStart, PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE)
                    mstore(add(categorySpecificStart, 0x20), PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO)
                    mstore(add(categorySpecificStart, 0x40), PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE)
                    mstore(add(categorySpecificStart, 0x60), PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FOUR)
                    mstore(add(categorySpecificStart, 0x70), PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_SIX)
                    mstore(add(categorySpecificStart, 0x60), PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FIVE)
                    categorySpecificEnd := add(categorySpecificStart, 0x90)
                    categorySpecificStart := add(categorySpecificStart, 0x1a)
                }

                // 3. handle no-witness cases
                if iszero(witnessLength) {
                    let indexWords := shl(5, c)

                    mstore(add(categorySpecificEnd, 0x0e), TOKEN_PERMISSIONS_TYPESTRING_FRAGMENT_TWO)
                    mstore(sub(categorySpecificEnd, 1), TOKEN_PERMISSIONS_TYPESTRING_FRAGMENT_ONE)
                    mstore(memLocation, sub(add(categorySpecificEnd, 0x2e), memoryOffset))

                    let m := mload(0x40)

                    if iszero(usesBatch) {
                        mstore(0, COMPACT_ACTIVATION_TYPEHASH)
                        mstore(0x20, BATCH_COMPACT_ACTIVATION_TYPEHASH)
                        mstore(0x40, MULTICHAIN_COMPACT_ACTIVATION_TYPEHASH)
                        derivedActivationTypehash := mload(indexWords)
                    }

                    if iszero(derivedActivationTypehash) {
                        mstore(0, COMPACT_BATCH_ACTIVATION_TYPEHASH)
                        mstore(0x20, BATCH_COMPACT_BATCH_ACTIVATION_TYPEHASH)
                        mstore(0x40, MULTICHAIN_COMPACT_BATCH_ACTIVATION_TYPEHASH)
                        derivedActivationTypehash := mload(indexWords)
                    }

                    mstore(0, COMPACT_TYPEHASH)
                    mstore(0x20, BATCH_COMPACT_TYPEHASH)
                    mstore(0x40, MULTICHAIN_COMPACT_TYPEHASH)
                    derivedCompactTypehash := mload(indexWords)

                    mstore(0x40, m)
                    leave
                }

                // 4. insert the supplied compact witness
                calldatacopy(categorySpecificEnd, witnessOffset, witnessLength)

                // 5. insert tokenPermissions
                let tokenPermissionsFragmentStart := add(categorySpecificEnd, witnessLength)
                mstore(add(tokenPermissionsFragmentStart, 0x0e), TOKEN_PERMISSIONS_TYPESTRING_FRAGMENT_TWO)
                mstore(sub(tokenPermissionsFragmentStart, 1), TOKEN_PERMISSIONS_TYPESTRING_FRAGMENT_ONE)
                mstore(memLocation, sub(add(tokenPermissionsFragmentStart, 0x2e), memoryOffset))

                // 6. derive the activation typehash
                derivedActivationTypehash := keccak256(activationStart, sub(tokenPermissionsFragmentStart, activationStart))

                // 7. derive the compact typehash
                derivedCompactTypehash := keccak256(categorySpecificStart, sub(tokenPermissionsFragmentStart, categorySpecificStart))
            }

            activationTypehash, compactTypehash := writeWitnessAndGetTypehashes(memoryLocation, category, witness.offset, witness.length, usingBatch)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BatchTransfer, SplitBatchTransfer } from "../types/BatchClaims.sol";
import { BasicTransfer, SplitTransfer } from "../types/Claims.sol";
import { CompactCategory } from "../types/CompactCategory.sol";
import { SplitComponent, TransferComponent, SplitByIdComponent } from "../types/Components.sol";
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
    PERMIT2_ACTIVATION_MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_SIX,
    COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_ONE,
    COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_TWO,
    COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_THREE,
    COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_FOUR,
    COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_FIVE
} from "../types/EIP712Types.sol";
import { Lock } from "../types/Lock.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

import { ConsumerLib } from "./ConsumerLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { FunctionCastLib } from "./FunctionCastLib.sol";
import { HashLib } from "./HashLib.sol";
import { IdLib } from "./IdLib.sol";
import { MetadataRenderer } from "./MetadataRenderer.sol";
import { ValidityLib } from "./ValidityLib.sol";

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { Tstorish } from "tstorish/Tstorish.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";

contract InternalLogic is Tstorish {
    using HashLib for address;
    using HashLib for bytes32;
    using HashLib for uint256;
    using HashLib for BasicTransfer;
    using HashLib for SplitTransfer;
    using HashLib for BatchTransfer;
    using HashLib for SplitBatchTransfer;
    using IdLib for uint96;
    using IdLib for uint256;
    using IdLib for address;
    using IdLib for Lock;
    using IdLib for ResetPeriod;
    using SafeTransferLib for address;
    using ConsumerLib for uint256;
    using EfficiencyLib for bool;
    using EfficiencyLib for bytes32;
    using EfficiencyLib for uint256;
    using ValidityLib for address;
    using ValidityLib for uint96;
    using ValidityLib for uint256;
    using ValidityLib for bytes32;
    using FunctionCastLib for function(bytes32, address, BasicTransfer calldata) internal;

    address private constant _PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    uint256 private constant _REENTRANCY_GUARD_SLOT = 0x929eee149b4bd21268;

    /// @dev `keccak256(bytes("Transfer(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE = 0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    /// @dev `keccak256(bytes("Claim(address,address,address,bytes32)"))`.
    uint256 private constant _CLAIM_EVENT_SIGNATURE = 0x770c32a2314b700d6239ee35ba23a9690f2fceb93a55d8c753e953059b3b18d4;

    /// @dev `keccak256(bytes("CompactRegistered(address,bytes32,bytes32,uint256)"))`.
    uint256 private constant _COMPACT_REGISTERED_SIGNATURE = 0xf78a2f33ff80ef4391f7449c748dc2d577a62cd645108f4f4069f4a7e0635b6a;

    /// @dev `keccak256(bytes("ForcedWithdrawalStatusUpdated(address,uint256,bool,uint256)"))`.
    uint256 private constant _FORCED_WITHDRAWAL_STATUS_UPDATED_SIGNATURE = 0xe27f5e0382cf5347965fc81d5c81cd141897fe9ce402d22c496b7c2ddc84e5fd;

    uint32 private constant _ATTEST_SELECTOR = 0x1a808f91;
    uint32 private constant _PERMIT_WITNESS_TRANSFER_FROM_SELECTOR = 0x137c29fe;
    uint32 private constant _BATCH_PERMIT_WITNESS_TRANSFER_FROM_SELECTOR = 0xfe8ec1a7;

    // slot: keccak256(_FORCED_WITHDRAWAL_ACTIVATIONS_SCOPE ++ account ++ id) => activates
    uint256 private constant _FORCED_WITHDRAWAL_ACTIVATIONS_SCOPE = 0x41d0e04b;

    // slot: keccak256(_ACTIVE_REGISTRATIONS_SCOPE ++ sponsor ++ claimHash ++ typehash) => expires
    uint256 private constant _ACTIVE_REGISTRATIONS_SCOPE = 0x68a30dd0;

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

    function _performBasicNativeTokenDeposit(address allocator) internal returns (uint256 id) {
        id = address(0).toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        _deposit(msg.sender, id, msg.value);
    }

    function _processBatchDeposit(uint256[2][] calldata idsAndAmounts, address recipient) internal {
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
        _notExpiredAndSignedByAllocator.usingSplitBatchTransfer()(transfer.toMessageHash(), _deriveConsistentAllocatorAndConsumeNonce(transfer.transfers, transfer.nonce), transfer);

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

    function _setReentrancyGuard() internal {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);
    }

    function _clearReentrancyGuard() internal {
        _clearTstorish(_REENTRANCY_GUARD_SLOT);
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

    function _performBasicERC20Deposit(address token, address allocator, uint256 amount) internal returns (uint256 id) {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);
        id = token.excludingNative().toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        _transferAndDeposit(token, msg.sender, id, amount);
        _clearTstorish(_REENTRANCY_GUARD_SLOT);
    }

    function _deriveConsistentAllocatorAndConsumeNonce(TransferComponent[] calldata components, uint256 nonce) internal returns (address allocator) {
        uint256 totalComponents = components.length;

        uint256 errorBuffer = (totalComponents == 0).asUint256();

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

    function _deriveConsistentAllocatorAndConsumeNonce(SplitByIdComponent[] calldata components, uint256 nonce) internal returns (address allocator) {
        uint256 totalComponents = components.length;

        uint256 errorBuffer = (totalComponents == 0).asUint256();

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

    function _emitForcedWithdrawalStatusUpdatedEvent(uint256 id, uint256 withdrawableAt) internal {
        assembly ("memory-safe") {
            mstore(0, iszero(iszero(withdrawableAt)))
            mstore(0x20, withdrawableAt)
            log3(0, 0x40, _FORCED_WITHDRAWAL_STATUS_UPDATED_SIGNATURE, caller(), id)
        }
    }

    function _register(address sponsor, bytes32 claimHash, bytes32 typehash, uint256 duration) internal {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(add(m, 0x14), sponsor)
            mstore(m, _ACTIVE_REGISTRATIONS_SCOPE)
            mstore(add(m, 0x34), claimHash)
            mstore(add(m, 0x54), typehash)
            let cutoffSlot := keccak256(add(m, 0x1c), 0x58)

            let expires := add(timestamp(), duration)
            if or(lt(expires, sload(cutoffSlot)), gt(duration, 0x278d00)) {
                // revert InvalidRegistrationDuration(uint256 duration)
                mstore(0, 0x1f9a96f4)
                mstore(0x20, duration)
                revert(0x1c, 0x24)
            }

            sstore(cutoffSlot, expires)
            mstore(add(m, 0x74), expires)
            log2(add(m, 0x34), 0x60, _COMPACT_REGISTERED_SIGNATURE, shr(0x60, shl(0x60, sponsor)))
        }
    }

    function _registerWithDefaults(bytes32 claimHash, bytes32 typehash) internal {
        _register(msg.sender, claimHash, typehash, uint256(0x258).asStubborn());
    }

    function _registerBatch(bytes32[2][] calldata claimHashesAndTypehashes, uint256 duration) internal returns (bool) {
        unchecked {
            uint256 totalClaimHashes = claimHashesAndTypehashes.length;
            for (uint256 i = 0; i < totalClaimHashes; ++i) {
                bytes32[2] calldata claimHashAndTypehash = claimHashesAndTypehashes[i];
                _register(msg.sender, claimHashAndTypehash[0], claimHashAndTypehash[1], duration);
            }
        }

        return true;
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

    function _preprocessAndPerformInitialNativeDeposit(ISignatureTransfer.TokenPermissions[] calldata permitted, address recipient)
        internal
        returns (uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative, uint256[] memory ids, uint256[] memory initialTokenBalances)
    {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);

        uint256 totalTokens = permitted.length;
        address allocator;
        ResetPeriod resetPeriod;
        Scope scope;
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

            // NOTE: these may need to be sanitized if toIdIfRegistered doesn't already handle for it
            allocator := calldataload(0x84)
            resetPeriod := calldataload(0xa4)
            scope := calldataload(0xc4)
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

    function _setReentrancyLockAndStartPreparingPermit2Call(address token) internal returns (uint256 id, uint256 initialBalance, uint256 m, uint256 typestringMemoryLocation) {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);

        address allocator;
        ResetPeriod resetPeriod;
        Scope scope;
        assembly ("memory-safe") {
            allocator := calldataload(0xa4)
            resetPeriod := calldataload(0xc4)
            scope := calldataload(0xe4)
        }

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

    function _ensureAttested(address from, address to, uint256 id, uint256 amount) internal {
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

    function _beginPreparingBatchDepositPermit2Calldata(uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative) internal view returns (uint256 m, uint256 typestringMemoryLocation) {
        assembly ("memory-safe") {
            m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            let tokenChunk := shl(6, totalTokensLessInitialNative)
            let twoTokenChunks := shl(1, tokenChunk)

            let permittedCalldataLocation := add(add(0x24, calldataload(0x24)), shl(6, firstUnderlyingTokenIsNative))

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
            let end := shl(6, totalTokensLessInitialNative)
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

    function _getRegistrationStatus(address sponsor, bytes32 claimHash, bytes32 typehash) internal view returns (uint256 expires) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(add(m, 0x14), sponsor)
            mstore(m, _ACTIVE_REGISTRATIONS_SCOPE)
            mstore(add(m, 0x34), claimHash)
            mstore(add(m, 0x54), typehash)
            expires := sload(keccak256(add(m, 0x1c), 0x58))
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

    function _domainSeparator() internal view returns (bytes32) {
        return _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
    }

    /// @dev Returns the symbol for token `id`.
    function _name(uint256 id) internal view returns (string memory) {
        return _METADATA_RENDERER.name(id);
    }

    /// @dev Returns the symbol for token `id`.
    function _symbol(uint256 id) internal view returns (string memory) {
        return _METADATA_RENDERER.symbol(id);
    }

    /// @dev Returns the Uniform Resource Identifier (URI) for token `id`.
    function _tokenURI(uint256 id) internal view returns (string memory) {
        return _METADATA_RENDERER.uri(id.toLock(), id);
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

    function _insertCompactDepositTypestringAt(uint256 memoryLocation) internal pure {
        assembly ("memory-safe") {
            mstore(memoryLocation, 0x96)
            mstore(add(memoryLocation, 0x20), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_ONE)
            mstore(add(memoryLocation, 0x40), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_TWO)
            mstore(add(memoryLocation, 0x60), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_THREE)
            mstore(add(memoryLocation, 0x96), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_FIVE)
            mstore(add(memoryLocation, 0x80), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_FOUR)
        }
    }

    function _getCutoffTimeSlot(address account, uint256 id) internal pure returns (uint256 cutoffTimeSlotLocation) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(0x14, account)
            mstore(0, _FORCED_WITHDRAWAL_ACTIVATIONS_SCOPE)
            mstore(0x34, id)
            cutoffTimeSlotLocation := keccak256(0x1c, 0x38)
            mstore(0x40, m)
        }
    }
}

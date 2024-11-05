// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { CompactCategory } from "../types/CompactCategory.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

import { DepositLogic } from "./DepositLogic.sol";
import { DepositViaPermit2Lib } from "./DepositViaPermit2Lib.sol";
import { RegistrationLib } from "./RegistrationLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { IdLib } from "./IdLib.sol";
import { ValidityLib } from "./ValidityLib.sol";

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";

/**
 * @title DepositViaPermit2Logic
 * @notice Inherited contract implementing internal functions with logic for processing
 * token deposits via permit2. These deposits leverage Permit2 witness data to either
 * indicate the parameters of the lock to deposit into and the recipient of the deposit,
 * or the parameters of the compact to register alongside the deposit. Deposits can also
 * involve a single ERC20 token or a batch of tokens in a single Permit2 authorization.
 * @dev IMPORTANT NOTE: this logic operates directly on unallocated memory, and reads
 * directly from fixed calldata offsets; proceed with EXTREME caution when making any
 * modifications to either this logic contract (including the insertion of new logic) or
 * to the associated permit2 deposit function interfaces!
 */
contract DepositViaPermit2Logic is DepositLogic {
    using DepositViaPermit2Lib for bytes32;
    using DepositViaPermit2Lib for uint256;
    using IdLib for uint256;
    using IdLib for address;
    using IdLib for ResetPeriod;
    using EfficiencyLib for bool;
    using EfficiencyLib for uint256;
    using RegistrationLib for address;
    using ValidityLib for address;
    using SafeTransferLib for address;

    uint32 private constant _PERMIT_WITNESS_TRANSFER_FROM_SELECTOR = 0x137c29fe;
    uint32 private constant _BATCH_PERMIT_WITNESS_TRANSFER_FROM_SELECTOR = 0xfe8ec1a7;

    address private constant _PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    function _depositViaPermit2(address token, address recipient, bytes calldata signature) internal returns (uint256) {
        bytes32 witness = uint256(0xa4).asStubborn().deriveCompactDepositWitnessHash();

        (uint256 id, uint256 initialBalance, uint256 m, uint256 typestringMemoryLocation) = _setReentrancyLockAndStartPreparingPermit2Call(token);

        typestringMemoryLocation.insertCompactDepositTypestring();

        assembly ("memory-safe") {
            mstore(add(m, 0x100), witness)
        }

        _writeSignatureAndPerformPermit2Call(m, uint256(0x140).asStubborn(), uint256(0x200).asStubborn(), signature);

        _checkBalanceAndDeposit(token, recipient, id, initialBalance);

        _clearReentrancyGuard();

        return id;
    }

    function _depositAndRegisterViaPermit2(
        address token,
        address depositor, // also recipient
        ResetPeriod resetPeriod,
        bytes32 claimHash,
        CompactCategory compactCategory,
        string calldata witness,
        bytes calldata signature
    ) internal returns (uint256) {
        (uint256 id, uint256 initialBalance, uint256 m, uint256 typestringMemoryLocation) = _setReentrancyLockAndStartPreparingPermit2Call(token);

        (bytes32 activationTypehash, bytes32 compactTypehash) = typestringMemoryLocation.writeWitnessAndGetTypehashes(compactCategory, witness, bool(false).asStubborn());

        activationTypehash.deriveAndWriteWitnessHash(id, claimHash, m, 0x100);

        uint256 signatureOffsetValue;
        assembly ("memory-safe") {
            signatureOffsetValue := and(add(mload(add(m, 0x160)), 0x17f), not(0x1f))
        }

        _writeSignatureAndPerformPermit2Call(m, uint256(0x140).asStubborn(), signatureOffsetValue, signature);

        _checkBalanceAndDeposit(token, depositor, id, initialBalance);

        depositor.registerCompact(claimHash, compactTypehash, resetPeriod);

        _clearReentrancyGuard();

        return id;
    }

    function _depositBatchViaPermit2(ISignatureTransfer.TokenPermissions[] calldata permitted, address recipient, bytes calldata signature) internal returns (uint256[] memory) {
        (uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative, uint256[] memory ids, uint256[] memory initialTokenBalances) = _preprocessAndPerformInitialNativeDeposit(permitted, recipient);

        bytes32 witness = uint256(0x84).asStubborn().deriveCompactDepositWitnessHash();

        (uint256 m, uint256 typestringMemoryLocation) = totalTokensLessInitialNative.beginPreparingBatchDepositPermit2Calldata(firstUnderlyingTokenIsNative);

        unchecked {
            typestringMemoryLocation.insertCompactDepositTypestring();
        }

        uint256 signatureOffsetValue;
        assembly ("memory-safe") {
            mstore(add(m, 0x80), witness)
            signatureOffsetValue := add(0x220, shl(7, totalTokensLessInitialNative))
        }

        _writeSignatureAndPerformPermit2Call(m, uint256(0xc0).asStubborn(), signatureOffsetValue, signature);

        _verifyBalancesAndPerformDeposits(ids, permitted, initialTokenBalances, recipient, firstUnderlyingTokenIsNative);

        return ids;
    }

    function _depositBatchAndRegisterViaPermit2(
        address depositor,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        ResetPeriod resetPeriod,
        bytes32 claimHash,
        CompactCategory compactCategory,
        string calldata witness,
        bytes calldata signature
    ) internal returns (uint256[] memory) {
        (uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative, uint256[] memory ids, uint256[] memory initialTokenBalances) = _preprocessAndPerformInitialNativeDeposit(permitted, depositor);

        uint256 idsHash;
        assembly ("memory-safe") {
            idsHash := keccak256(add(ids, 0x20), shl(5, add(totalTokensLessInitialNative, firstUnderlyingTokenIsNative)))
        }

        (uint256 m, uint256 typestringMemoryLocation) = totalTokensLessInitialNative.beginPreparingBatchDepositPermit2Calldata(firstUnderlyingTokenIsNative);

        (bytes32 activationTypehash, bytes32 compactTypehash) = typestringMemoryLocation.writeWitnessAndGetTypehashes(compactCategory, witness, bool(true).asStubborn());

        activationTypehash.deriveAndWriteWitnessHash(idsHash, claimHash, m, 0x80);

        uint256 signatureOffsetValue;
        assembly ("memory-safe") {
            let witnessLength := witness.length
            let totalWitnessMemoryOffset := and(add(add(0xf3, add(witnessLength, iszero(iszero(witnessLength)))), add(mul(eq(compactCategory, 1), 0x0b), shl(6, eq(compactCategory, 2)))), not(0x1f))
            signatureOffsetValue := add(add(0x180, shl(7, totalTokensLessInitialNative)), totalWitnessMemoryOffset)
        }

        _writeSignatureAndPerformPermit2Call(m, uint256(0xc0).asStubborn(), signatureOffsetValue, signature);

        _verifyBalancesAndPerformDeposits(ids, permitted, initialTokenBalances, depositor, firstUnderlyingTokenIsNative);

        depositor.registerCompact(claimHash, compactTypehash, resetPeriod);

        return ids;
    }

    function _preprocessAndPerformInitialNativeDeposit(ISignatureTransfer.TokenPermissions[] calldata permitted, address recipient)
        private
        returns (uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative, uint256[] memory ids, uint256[] memory initialTokenBalances)
    {
        _setReentrancyGuard();

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
            if or(iszero(totalTokens), or(eq(firstUnderlyingTokenIsNative, iszero(callvalue())), and(firstUnderlyingTokenIsNative, iszero(eq(callvalue(), calldataload(add(permittedOffset, 0x20))))))) {
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

    function _setReentrancyLockAndStartPreparingPermit2Call(address token) private returns (uint256 id, uint256 initialBalance, uint256 m, uint256 typestringMemoryLocation) {
        _setReentrancyGuard();

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

            // NOTE: strongly consider allocating memory here as the inline assembly scope
            // is being left (it *should* be fine for now as the function between assembly
            // blocks does not allocate any new memory).
        }
    }

    function _writeSignatureAndPerformPermit2Call(uint256 m, uint256 signatureOffsetLocation, uint256 signatureOffsetValue, bytes calldata signature) private {
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

    function _verifyBalancesAndPerformDeposits(
        uint256[] memory ids,
        ISignatureTransfer.TokenPermissions[] calldata permittedTokens,
        uint256[] memory initialTokenBalances,
        address recipient,
        bool firstUnderlyingTokenIsNative
    ) private {
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

        _clearReentrancyGuard();
    }

    // NOTE: all tokens must be supplied in ascending order and cannot be duplicated.
    function _prepareIdsAndGetBalances(uint256[] memory ids, uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative, ISignatureTransfer.TokenPermissions[] calldata permitted, uint256 id)
        private
        view
        returns (uint256[] memory tokenBalances)
    {
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { CompactCategory } from "../types/CompactCategory.sol";
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
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

import { DepositLogic } from "./DepositLogic.sol";
import { RegistrationLib } from "./RegistrationLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { IdLib } from "./IdLib.sol";
import { ValidityLib } from "./ValidityLib.sol";

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";

contract DepositViaPermit2Logic is DepositLogic {
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
        bytes32 witness = _deriveCompactDepositWitnessHash(uint256(0xa4).asStubborn());

        (uint256 id, uint256 initialBalance, uint256 m, uint256 typestringMemoryLocation) = _setReentrancyLockAndStartPreparingPermit2Call(token);

        _insertCompactDepositTypestringAt(typestringMemoryLocation);

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

        (bytes32 activationTypehash, bytes32 compactTypehash) = _writeWitnessAndGetTypehashes(typestringMemoryLocation, compactCategory, witness, bool(false).asStubborn());

        _deriveAndWriteWitnessHash(activationTypehash, id, claimHash, m, 0x100);

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
        (uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative, uint256[] memory ids, uint256[] memory initialTokenBalances) =
            _preprocessAndPerformInitialNativeDeposit(permitted, recipient);

        bytes32 witness = _deriveCompactDepositWitnessHash(uint256(0x84).asStubborn());

        (uint256 m, uint256 typestringMemoryLocation) = _beginPreparingBatchDepositPermit2Calldata(totalTokensLessInitialNative, firstUnderlyingTokenIsNative);

        unchecked {
            _insertCompactDepositTypestringAt(typestringMemoryLocation);
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
        (uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative, uint256[] memory ids, uint256[] memory initialTokenBalances) =
            _preprocessAndPerformInitialNativeDeposit(permitted, depositor);

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
    function _prepareIdsAndGetBalances(
        uint256[] memory ids,
        uint256 totalTokensLessInitialNative,
        bool firstUnderlyingTokenIsNative,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        uint256 id
    ) private view returns (uint256[] memory tokenBalances) {
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

    function _beginPreparingBatchDepositPermit2Calldata(uint256 totalTokensLessInitialNative, bool firstUnderlyingTokenIsNative) private view returns (uint256 m, uint256 typestringMemoryLocation) {
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

            // NOTE: strongly consider allocating memory here as the inline assembly scope
            // is being left (it *should* be fine for now as the function between assembly
            // blocks does not allocate any new memory).
        }
    }

    function _writeWitnessAndGetTypehashes(uint256 memoryLocation, CompactCategory category, string calldata witness, bool usingBatch)
        private
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

    function _deriveAndWriteWitnessHash(bytes32 activationTypehash, uint256 idOrIdsHash, bytes32 claimHash, uint256 memoryPointer, uint256 offset) private pure {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(0, activationTypehash)
            mstore(0x20, idOrIdsHash)
            mstore(0x40, claimHash)
            mstore(add(memoryPointer, offset), keccak256(0, 0x60))
            mstore(0x40, m)
        }
    }

    function _deriveCompactDepositWitnessHash(uint256 calldataOffset) private pure returns (bytes32 witnessHash) {
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

    function _insertCompactDepositTypestringAt(uint256 memoryLocation) private pure {
        assembly ("memory-safe") {
            mstore(memoryLocation, 0x96)
            mstore(add(memoryLocation, 0x20), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_ONE)
            mstore(add(memoryLocation, 0x40), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_TWO)
            mstore(add(memoryLocation, 0x60), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_THREE)
            mstore(add(memoryLocation, 0x96), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_FIVE)
            mstore(add(memoryLocation, 0x80), COMPACT_DEPOSIT_TYPESTRING_FRAGMENT_FOUR)
        }
    }
}

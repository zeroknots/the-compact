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
import { HashLib } from "./lib/HashLib.sol";
import { ValidityLib } from "./lib/ValidityLib.sol";
import { Extsload } from "./lib/Extsload.sol";
import { ERC6909 } from "solady/tokens/ERC6909.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { IPermit2 } from "permit2/src/interfaces/IPermit2.sol";
import { Tstorish } from "tstorish/Tstorish.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";
import { BasicTransfer, SplitTransfer } from "./types/Claims.sol";

import { BatchTransfer, SplitBatchTransfer } from "./types/BatchClaims.sol";

import { COMPACT_TYPEHASH } from "./types/EIP712Types.sol";

import { SplitComponent, TransferComponent, SplitByIdComponent, BatchClaimComponent, SplitBatchClaimComponent } from "./types/Components.sol";

import { IAllocator } from "./interfaces/IAllocator.sol";
import { MetadataRenderer } from "./lib/MetadataRenderer.sol";

import { ClaimProcessor } from "./lib/ClaimProcessor.sol";

/**
 * @title The Compact
 * @custom:version 0 (early-stage proof-of-concept)
 * @author 0age (0age.eth)
 * @notice The Compact is an ownerless ERC6909 contract that facilitates the voluntary
 *         formation (and, if necessary, involuntary dissolution) of "resource locks."
 *         This contract has not yet been properly tested, audited, or reviewed.
 */
contract TheCompact is ITheCompact, ClaimProcessor, ERC6909 {
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

    function deposit(address allocator) external payable returns (uint256 id) {
        id = _performBasicNativeTokenDeposit(allocator);
    }

    function depositAndRegister(address allocator, bytes32 claimHash, bytes32 typehash) external payable returns (uint256 id) {
        id = _performBasicNativeTokenDeposit(allocator);

        _registerWithDefaults(claimHash, typehash);
    }

    function deposit(address token, address allocator, uint256 amount) external returns (uint256) {
        return _performBasicERC20Deposit(token, allocator, amount);
    }

    function depositAndRegister(address token, address allocator, uint256 amount, bytes32 claimHash, bytes32 typehash) external returns (uint256 id) {
        id = _performBasicERC20Deposit(token, allocator, amount);

        _registerWithDefaults(claimHash, typehash);
    }

    function deposit(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient) external payable returns (uint256 id) {
        id = address(0).toIdIfRegistered(scope, resetPeriod, allocator);

        _deposit(recipient, id, msg.value);
    }

    function deposit(address token, address allocator, ResetPeriod resetPeriod, Scope scope, uint256 amount, address recipient) external returns (uint256 id) {
        _setReentrancyGuard();
        id = token.excludingNative().toIdIfRegistered(scope, resetPeriod, allocator);

        _transferAndDeposit(token, recipient, id, amount);
        _clearReentrancyGuard();
    }

    function deposit(uint256[2][] calldata idsAndAmounts, address recipient) external payable returns (bool) {
        _processBatchDeposit(idsAndAmounts, recipient);

        return true;
    }

    function depositAndRegister(uint256[2][] calldata idsAndAmounts, bytes32[2][] calldata claimHashesAndTypehashes, uint256 duration) external payable returns (bool) {
        _processBatchDeposit(idsAndAmounts, msg.sender);

        _registerBatch(claimHashesAndTypehashes, duration);

        return true;
    }

    function deposit(
        address token,
        uint256, // amount
        uint256, // nonce
        uint256, // deadline
        address, // depositor
        address, // allocator
        ResetPeriod, // resetPeriod
        Scope, //scope
        address recipient,
        bytes calldata signature
    ) external returns (uint256) {
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

    function depositAndRegister(
        address token,
        uint256, // amount
        uint256, // nonce
        uint256, // deadline
        address depositor, // also recipient
        address, // allocator
        ResetPeriod resetPeriod,
        Scope, //scope
        bytes32 claimHash,
        CompactCategory compactCategory,
        string calldata witness,
        bytes calldata signature
    ) external returns (uint256) {
        (uint256 id, uint256 initialBalance, uint256 m, uint256 typestringMemoryLocation) = _setReentrancyLockAndStartPreparingPermit2Call(token);

        (bytes32 activationTypehash, bytes32 compactTypehash) = _writeWitnessAndGetTypehashes(typestringMemoryLocation, compactCategory, witness, bool(false).asStubborn());

        _deriveAndWriteWitnessHash(activationTypehash, id, claimHash, m, 0x100);

        uint256 signatureOffsetValue;
        assembly ("memory-safe") {
            signatureOffsetValue := and(add(mload(add(m, 0x160)), 0x17f), not(0x1f))
        }

        _writeSignatureAndPerformPermit2Call(m, uint256(0x140).asStubborn(), signatureOffsetValue, signature);

        _checkBalanceAndDeposit(token, depositor, id, initialBalance);

        _register(depositor, claimHash, compactTypehash, resetPeriod.toSeconds());

        _clearReentrancyGuard();

        return id;
    }

    function deposit(
        address, // depositor
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        uint256, // nonce
        uint256, // deadline
        address, // allocator
        ResetPeriod, // resetPeriod
        Scope, //scope
        address recipient,
        bytes calldata signature
    ) external payable returns (uint256[] memory ids) {
        uint256 totalTokensLessInitialNative;
        bool firstUnderlyingTokenIsNative;
        uint256[] memory initialTokenBalances;
        (totalTokensLessInitialNative, firstUnderlyingTokenIsNative, ids, initialTokenBalances) = _preprocessAndPerformInitialNativeDeposit(permitted, recipient);

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
    }

    function depositAndRegister(
        address depositor,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        uint256, // nonce
        uint256, // deadline
        address, // allocator
        ResetPeriod resetPeriod,
        Scope, //scope
        bytes32 claimHash,
        CompactCategory compactCategory,
        string calldata witness,
        bytes calldata signature
    ) external payable returns (uint256[] memory) {
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

        _register(depositor, claimHash, compactTypehash, resetPeriod.toSeconds());

        return ids;
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

    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt) {
        // overflow check not necessary as reset period is capped
        unchecked {
            withdrawableAt = block.timestamp + id.toResetPeriod().toSeconds();
        }

        uint256 cutoffTimeSlotLocation = _getCutoffTimeSlot(msg.sender, id);
        assembly ("memory-safe") {
            sstore(cutoffTimeSlotLocation, withdrawableAt)
        }

        _emitForcedWithdrawalStatusUpdatedEvent(id, withdrawableAt);
    }

    function disableForcedWithdrawal(uint256 id) external returns (bool) {
        uint256 cutoffTimeSlotLocation = _getCutoffTimeSlot(msg.sender, id);

        assembly ("memory-safe") {
            if iszero(sload(cutoffTimeSlotLocation)) {
                // revert ForcedWithdrawalAlreadyDisabled(msg.sender, id)
                mstore(0, 0xe632dbad)
                mstore(0x20, caller())
                mstore(0x40, id)
                revert(0x1c, 0x44)
            }

            sstore(cutoffTimeSlotLocation, 0)
        }

        _emitForcedWithdrawalStatusUpdatedEvent(id, uint256(0).asStubborn());

        return true;
    }

    function forcedWithdrawal(uint256 id, address recipient, uint256 amount) external returns (bool) {
        uint256 cutoffTimeSlotLocation = _getCutoffTimeSlot(msg.sender, id);

        assembly ("memory-safe") {
            let withdrawableAt := sload(cutoffTimeSlotLocation)
            if or(iszero(withdrawableAt), gt(withdrawableAt, timestamp())) {
                // revert PrematureWithdrawal(id)
                mstore(0, 0x9287bcb0)
                mstore(0x20, id)
                revert(0x1c, 0x24)
            }
        }

        return _withdraw(msg.sender, recipient, id, amount);
    }

    function register(bytes32 claimHash, bytes32 typehash, uint256 duration) external returns (bool) {
        _register(msg.sender, claimHash, typehash, duration);
        return true;
    }

    function getRegistrationStatus(address sponsor, bytes32 claimHash, bytes32 typehash) external view returns (bool isActive, uint256 expires) {
        expires = _getRegistrationStatus(sponsor, claimHash, typehash);
        isActive = expires > block.timestamp;
    }

    function register(bytes32[2][] calldata claimHashesAndTypehashes, uint256 duration) external returns (bool) {
        return _registerBatch(claimHashesAndTypehashes, duration);
    }

    function consume(uint256[] calldata nonces) external returns (bool) {
        // NOTE: this may not be necessary, consider removing
        msg.sender.usingAllocatorId().mustHaveARegisteredAllocator();

        unchecked {
            uint256 i;

            assembly ("memory-safe") {
                i := nonces.offset
            }

            uint256 end = i + (nonces.length << 5);
            uint256 nonce;
            for (; i < end; i += 0x20) {
                assembly ("memory-safe") {
                    nonce := calldataload(i)
                }
                nonce.consumeNonceAsAllocator(msg.sender);
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
        uint256 cutoffTimeSlotLocation = _getCutoffTimeSlot(account, id);
        assembly ("memory-safe") {
            forcedWithdrawalAvailableAt := sload(cutoffTimeSlotLocation)
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

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparator();
    }

    /// @dev Returns the symbol for token `id`.
    function name(uint256 id) public view virtual override returns (string memory) {
        return _name(id);
    }

    /// @dev Returns the symbol for token `id`.
    function symbol(uint256 id) public view virtual override returns (string memory) {
        return _symbol(id);
    }

    /// @dev Returns the Uniform Resource Identifier (URI) for token `id`.
    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return _tokenURI(id);
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

    function _beforeTokenTransfer(address from, address to, uint256 id, uint256 amount) internal virtual override {
        _ensureAttested(from, to, id, amount);
    }
}

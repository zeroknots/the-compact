// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ITheCompact } from "./interfaces/ITheCompact.sol";
import { Lock } from "./types/Lock.sol";
import { Scope } from "./types/Scope.sol";
import { ResetPeriod } from "./types/ResetPeriod.sol";
import { ForcedWithdrawalStatus } from "./types/ForcedWithdrawalStatus.sol";
import { IdLib } from "./lib/IdLib.sol";
import { ConsumerLib } from "./lib/ConsumerLib.sol";
import { EfficiencyLib } from "./lib/EfficiencyLib.sol";
import { MetadataLib } from "./lib/MetadataLib.sol";
import { ERC6909 } from "solady/tokens/ERC6909.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { SignatureCheckerLib } from "solady/utils/SignatureCheckerLib.sol";
import { IPermit2 } from "permit2/src/interfaces/IPermit2.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";
import {
    Allocation,
    AllocationAuthorization,
    BatchAllocation,
    BatchAllocationAuthorization,
    ALLOCATION_TYPEHASH,
    ALLOCATION_AUTHORIZATION_TYPEHASH,
    BATCH_ALLOCATION_TYPEHASH,
    BATCH_ALLOCATION_AUTHORIZATION_TYPEHASH,
    TRANSFER_AUTHORIZATION_TYPEHASH,
    DELEGATED_TRANSFER_TYPEHASH,
    WITHDRAWAL_AUTHORIZATION_TYPEHASH,
    DELEGATED_WITHDRAWAL_TYPEHASH
} from "./types/EIP712Types.sol";
import { IOracle } from "./interfaces/IOracle.sol";
import { IAllocator } from "./interfaces/IAllocator.sol";
import { MetadataRenderer } from "./lib/MetadataRenderer.sol";

/**
 * @title The Compact
 * @custom:version 1 (early-stage proof-of-concept)
 * @author 0age (0age.eth)
 * @notice The Compact is an ownerless ERC6909 contract that facilitates the voluntary
 *         formation (and, if necessary, involuntary dissolution) of "resource locks."
 *         This contract has not yet been properly tested, audited, or reviewed.
 */
contract TheCompact is ITheCompact, ERC6909 {
    using IdLib for uint96;
    using IdLib for uint256;
    using IdLib for address;
    using IdLib for Lock;
    using IdLib for ResetPeriod;
    using MetadataLib for address;
    using ConsumerLib for uint256;
    using SafeTransferLib for address;
    using SignatureCheckerLib for address;
    using FixedPointMathLib for uint256;
    using EfficiencyLib for bool;
    using EfficiencyLib for uint256;

    IPermit2 private constant _PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    /// @dev `keccak256(bytes("CompactDeposit(address depositor,address allocator,uint8 resetPeriod,uint8 scope,address recipient)"))`.
    bytes32 private constant _PERMIT2_WITNESS_FRAGMENT_HASH =
        0x0091bfc8f1539e204529602051ae82f3e6c6f0f86d0227c9ea890616cedbe646;

    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    /// @dev `keccak256(bytes("Transfer(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE =
        0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    /// @dev `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`.
    bytes32 private constant _DOMAIN_TYPEHASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev `keccak256(bytes("The Compact"))`.
    bytes32 private constant _NAME_HASH =
        0x5e6f7b4e1ac3d625bac418bc955510b3e054cb6cc23cc27885107f080180b292;

    /// @dev `keccak256("1")`.
    bytes32 private constant _VERSION_HASH =
        0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    // Rage-quit functionality (TODO: optimize storage layout)
    mapping(address => mapping(uint256 => uint256)) private _cutoffTime;

    uint256 private immutable _INITIAL_CHAIN_ID;
    bytes32 private immutable _INITIAL_DOMAIN_SEPARATOR;
    MetadataRenderer private immutable _METADATA_RENDERER;

    constructor() {
        _INITIAL_CHAIN_ID = block.chainid;
        _INITIAL_DOMAIN_SEPARATOR = keccak256(
            abi.encode(_DOMAIN_TYPEHASH, _NAME_HASH, _VERSION_HASH, block.chainid, address(this))
        );
        _METADATA_RENDERER = new MetadataRenderer();
    }

    function deposit(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient)
        external
        payable
        returns (uint256 id)
    {
        Lock memory lock = address(0).toLock(allocator, resetPeriod, scope);
        id = lock.toId();

        _deposit(msg.sender, recipient, id, msg.value);
    }

    function deposit(
        address token,
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        uint256 amount,
        address recipient
    ) external returns (uint256 id) {
        if (token == address(0)) {
            revert InvalidToken(token);
        }

        Lock memory lock = token.toLock(allocator, resetPeriod, scope);
        id = lock.toId();

        token.safeTransferFrom(msg.sender, address(this), amount);

        _deposit(msg.sender, recipient, id, amount);
    }

    function deposit(
        address depositor,
        address token,
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        uint256 amount,
        address recipient,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external returns (uint256 id) {
        if (token == address(0)) {
            revert InvalidToken(token);
        }

        Lock memory lock = token.toLock(allocator, resetPeriod, scope);
        id = lock.toId();

        ISignatureTransfer.SignatureTransferDetails memory signatureTransferDetails =
        ISignatureTransfer.SignatureTransferDetails({ to: address(this), requestedAmount: amount });

        ISignatureTransfer.TokenPermissions memory tokenPermissions =
            ISignatureTransfer.TokenPermissions({ token: token, amount: amount });

        ISignatureTransfer.PermitTransferFrom memory permitTransferFrom = ISignatureTransfer
            .PermitTransferFrom({ permitted: tokenPermissions, nonce: nonce, deadline: deadline });

        bytes32 witness = keccak256(
            abi.encode(
                _PERMIT2_WITNESS_FRAGMENT_HASH, depositor, allocator, resetPeriod, scope, recipient
            )
        );

        _PERMIT2.permitWitnessTransferFrom(
            permitTransferFrom,
            signatureTransferDetails,
            depositor,
            witness,
            "CompactDeposit witness)CompactDeposit(address depositor,address allocator,uint8 resetPeriod,uint8 scope,address recipient)TokenPermissions(address token,uint256 amount)",
            signature
        );

        _deposit(depositor, recipient, id, amount);
    }

    function claim(
        Allocation calldata allocation,
        AllocationAuthorization calldata allocationAuthorization,
        bytes calldata oracleVariableData,
        bytes calldata ownerSignature,
        bytes calldata allocatorSignature
    ) external returns (address claimant, uint256 claimAmount) {
        (claimant, claimAmount) = _processClaim(
            allocation,
            allocationAuthorization,
            oracleVariableData,
            ownerSignature,
            allocatorSignature
        );

        _release(allocation.owner, claimant, allocation.id, claimAmount);
    }

    function claim(
        BatchAllocation calldata batchAllocation,
        BatchAllocationAuthorization calldata batchAllocationAuthorization,
        bytes calldata oracleVariableData,
        bytes calldata ownerSignature,
        bytes calldata allocatorSignature
    ) external returns (address claimant, uint256[] memory claimAmounts) {
        (claimant, claimAmounts) = _processBatchClaim(
            batchAllocation,
            batchAllocationAuthorization,
            oracleVariableData,
            ownerSignature,
            allocatorSignature
        );

        uint256 totalIds = batchAllocation.ids.length;
        address owner = batchAllocation.owner;
        unchecked {
            for (uint256 i = 0; i < totalIds; ++i) {
                // TODO: skip bounds checks on array accesses
                _release(owner, claimant, batchAllocation.ids[i], claimAmounts[i]);
            }
        }
    }

    // Note: this can be frontrun since anyone can call claim
    function claimAndWithdraw(
        Allocation calldata allocation,
        AllocationAuthorization calldata allocationAuthorization,
        bytes calldata oracleVariableData,
        bytes calldata ownerSignature,
        bytes calldata allocatorSignature,
        address recipient
    ) external returns (uint256 claimAmount) {
        address claimant;
        (claimant, claimAmount) = _processClaim(
            allocation,
            allocationAuthorization,
            oracleVariableData,
            ownerSignature,
            allocatorSignature
        );

        if (msg.sender != claimant) {
            revert CallerNotClaimant();
        }

        _withdraw(allocation.owner, recipient, allocation.id, claimAmount);
    }

    function allocatedTransfer(
        uint256 id,
        uint256 amount,
        uint256 nonce,
        uint256 expiration,
        address recipient,
        bytes memory allocatorSignature
    ) external returns (bool) {
        _assertValidTime(expiration);

        address allocator = id.toAllocator();
        nonce.consumeNonce(allocator);

        bytes32 messageHash = _getAuthorizedTransferMessageHash(expiration, nonce, id, amount);
        _assertValidSignature(messageHash, allocatorSignature, allocator);

        return _release(msg.sender, recipient, id, amount);
    }

    function allocatedTransferFrom(
        address owner,
        uint256 id,
        uint256 amount,
        uint256 nonce,
        uint256 startTime,
        uint256 endTime,
        address recipient,
        uint256 pledge,
        bytes memory ownerSignature,
        bytes memory allocatorSignature
    ) external returns (bool) {
        _assertValidTime(startTime, endTime);

        address allocator = id.toAllocator();
        nonce.consumeNonce(allocator);

        bytes32 messageHash = _getDelegatedTransferMessageHash(
            owner, startTime, endTime, nonce, id, amount, recipient, pledge
        );
        _assertValidSignature(messageHash, ownerSignature, owner);
        _assertValidSignature(messageHash, allocatorSignature, allocator);

        _processPledge(owner, id, pledge, startTime, endTime);

        return _release(owner, recipient, id, amount);
    }

    function allocatedWithdrawal(
        uint256 id,
        uint256 amount,
        uint256 nonce,
        uint256 expiration,
        address recipient,
        bytes memory allocatorSignature
    ) external returns (bool) {
        _assertValidTime(expiration);

        address allocator = id.toAllocator();
        nonce.consumeNonce(allocator);

        bytes32 messageHash = _getAuthorizedWithdrawalMessageHash(expiration, nonce, id, amount);
        _assertValidSignature(messageHash, allocatorSignature, allocator);

        _withdraw(msg.sender, recipient, id, amount);

        return true;
    }

    function allocatedWithdrawalFrom(
        address owner,
        uint256 id,
        uint256 amount,
        uint256 nonce,
        uint256 startTime,
        uint256 endTime,
        address recipient,
        uint256 pledge,
        bytes memory ownerSignature,
        bytes memory allocatorSignature
    ) external returns (bool) {
        _assertValidTime(startTime, endTime);

        address allocator = id.toAllocator();
        nonce.consumeNonce(allocator);

        bytes32 messageHash = _getDelegatedWithdrawalMessageHash(
            owner, startTime, endTime, nonce, id, amount, recipient, pledge
        );
        _assertValidSignature(messageHash, ownerSignature, owner);
        _assertValidSignature(messageHash, allocatorSignature, allocator);

        _processPledge(owner, id, pledge, startTime, endTime);

        _withdraw(owner, recipient, id, amount);

        return true;
    }

    function __register(address allocator, bytes calldata proof)
        external
        returns (uint96 allocatorId)
    {
        if (!allocator.canBeRegistered(proof)) {
            revert InvalidRegistrationProof(allocator);
        }

        allocatorId = allocator.register();
    }

    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt) {
        withdrawableAt = block.timestamp + id.toResetPeriod().toSeconds();

        _cutoffTime[msg.sender][id] = withdrawableAt;

        emit ForcedWithdrawalEnabled(msg.sender, id, withdrawableAt);
    }

    function disableForcedWithdrawal(uint256 id) external returns (bool) {
        if (_cutoffTime[msg.sender][id] == 0) {
            revert ForcedWithdrawalAlreadyDisabled(msg.sender, id);
        }

        delete _cutoffTime[msg.sender][id];

        emit ForcedWithdrawalDisabled(msg.sender, id);

        return true;
    }

    function forcedWithdrawal(uint256 id, address recipient)
        external
        returns (uint256 withdrawnAmount)
    {
        uint256 withdrawableAt = _cutoffTime[msg.sender][id];

        if ((withdrawableAt == 0).or(withdrawableAt > block.timestamp)) {
            revert PrematureWithdrawal(id);
        }

        withdrawnAmount = balanceOf(msg.sender, id);

        _withdraw(msg.sender, recipient, id, withdrawnAmount);
    }

    function getForcedWithdrawalStatus(address account, uint256 id)
        external
        view
        returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt)
    {
        forcedWithdrawalAvailableAt = _cutoffTime[account][id];

        if (forcedWithdrawalAvailableAt == 0) {
            status = ForcedWithdrawalStatus.Disabled;
        } else if (forcedWithdrawalAvailableAt > block.timestamp) {
            status = ForcedWithdrawalStatus.Pending;
        } else {
            status = ForcedWithdrawalStatus.Enabled;
        }
    }

    function getLockDetails(uint256 id)
        external
        view
        returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope)
    {
        Lock memory lock = id.toLock();
        token = lock.token;
        allocator = lock.allocator;
        resetPeriod = lock.resetPeriod;
        scope = lock.scope;
    }

    function check(uint256 nonce, address allocator) external view returns (bool consumed) {
        return nonce.isConsumedBy(allocator);
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator) {
        uint256 initialChainId = _INITIAL_CHAIN_ID;
        domainSeparator = _INITIAL_DOMAIN_SEPARATOR;

        assembly ("memory-safe") {
            // Prepare the domain separator, rederiving it if necessary.
            if xor(chainid(), initialChainId) {
                let m := mload(0x40) // Grab the free memory pointer.
                mstore(m, _DOMAIN_TYPEHASH)
                mstore(add(m, 0x20), _NAME_HASH)
                mstore(add(m, 0x40), _VERSION_HASH)
                mstore(add(m, 0x60), chainid())
                mstore(add(m, 0x80), address())
                domainSeparator := keccak256(m, 0xa0)
            }
        }
    }

    function extsload(bytes32 slot) external view returns (bytes32) {
        assembly ("memory-safe") {
            mstore(0, sload(slot))
            return(0, 0x20)
        }
    }

    function extsload(bytes32 startSlot, uint256 nSlots) external view returns (bytes32[] memory) {
        assembly ("memory-safe") {
            let memptr := mload(0x40)
            let start := memptr
            // A left bit-shift of 5 is equivalent to multiplying by 32 but costs less gas.
            let length := shl(5, nSlots)
            // The abi offset of dynamic array in the returndata is 32.
            mstore(memptr, 0x20)
            // Store the length of the array returned
            mstore(add(memptr, 0x20), nSlots)
            // update memptr to the first location to hold a result
            memptr := add(memptr, 0x40)
            let end := add(memptr, length)
            for { } 1 { } {
                mstore(memptr, sload(startSlot))
                memptr := add(memptr, 0x20)
                startSlot := add(startSlot, 1)
                if iszero(lt(memptr, end)) { break }
            }
            return(start, sub(end, start))
        }
    }

    function extsload(bytes32[] calldata slots) external view returns (bytes32[] memory) {
        assembly ("memory-safe") {
            let memptr := mload(0x40)
            let start := memptr
            // for abi encoding the response - the array will be found at 0x20
            mstore(memptr, 0x20)
            // next we store the length of the return array
            mstore(add(memptr, 0x20), slots.length)
            // update memptr to the first location to hold an array entry
            memptr := add(memptr, 0x40)
            // A left bit-shift of 5 is equivalent to multiplying by 32 but costs less gas.
            let end := add(memptr, shl(5, slots.length))
            let calldataptr := slots.offset
            for { } 1 { } {
                mstore(memptr, sload(calldataload(calldataptr)))
                memptr := add(memptr, 0x20)
                calldataptr := add(calldataptr, 0x20)
                if iszero(lt(memptr, end)) { break }
            }
            return(start, sub(end, start))
        }
    }

    /// @dev Returns the symbol for token `id`.
    function name(uint256 id) public view virtual override returns (string memory) {
        return string.concat("Compact ", id.toToken().readNameWithDefaultValue());
    }

    /// @dev Returns the symbol for token `id`.
    function symbol(uint256 id) public view virtual override returns (string memory) {
        return string.concat(unicode"🤝-", id.toToken().readSymbolWithDefaultValue());
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

    function _processClaim(
        Allocation calldata allocation,
        AllocationAuthorization calldata allocationAuthorization,
        bytes calldata oracleVariableData,
        bytes calldata ownerSignature,
        bytes calldata allocatorSignature
    ) internal returns (address claimant, uint256 claimAmount) {
        _assertValidTime(allocation.startTime, allocation.endTime);
        _assertValidTime(allocationAuthorization.startTime, allocationAuthorization.endTime);

        if (allocationAuthorization.amountReduction >= allocation.amount) {
            revert InvalidAmountReduction(
                allocation.amount, allocationAuthorization.amountReduction
            );
        }

        address allocator = allocation.id.toAllocator();
        allocation.nonce.consumeNonce(allocator);
        bytes32 allocationMessageHash = _getAllocationMessageHash(allocation);
        _assertValidSignature(allocationMessageHash, ownerSignature, allocation.owner);
        bytes32 allocationAuthorizationMessageHash =
            _getAllocationAuthorizationMessageHash(allocationAuthorization, allocationMessageHash);
        _assertValidSignature(allocationAuthorizationMessageHash, allocatorSignature, allocator);
        (address oracleClaimant, uint256 oracleClaimAmount) = IOracle(allocation.oracle).attest(
            allocationMessageHash, allocation.oracleFixedData, oracleVariableData
        );

        claimant =
            _deriveClaimant(allocation.claimant, allocationAuthorization.claimant, oracleClaimant);

        unchecked {
            claimAmount =
                oracleClaimAmount.min(allocation.amount - allocationAuthorization.amountReduction);
        }

        emit Claim(allocation.owner, claimant, allocation.id, allocationMessageHash, claimAmount);
    }

    function _processBatchClaim(
        BatchAllocation calldata batchAllocation,
        BatchAllocationAuthorization calldata batchAllocationAuthorization,
        bytes calldata oracleVariableData,
        bytes calldata ownerSignature,
        bytes calldata allocatorSignature
    ) internal returns (address claimant, uint256[] memory claimAmounts) {
        _assertValidTime(batchAllocation.startTime, batchAllocation.endTime);
        _assertValidTime(
            batchAllocationAuthorization.startTime, batchAllocationAuthorization.endTime
        );

        uint256 totalIds = batchAllocation.ids.length;
        if (
            (totalIds == 0).or(totalIds != batchAllocation.amounts.length).or(
                totalIds != batchAllocationAuthorization.amountReductions.length
            )
        ) {
            revert InvalidBatchAllocation();
        }

        // TODO: skip the bounds check on this array access
        uint96 allocatorId = batchAllocation.ids[0].toAllocatorId();
        address allocator = allocatorId.toRegisteredAllocator();
        batchAllocation.nonce.consumeNonce(allocator);
        bytes32 batchAllocationMessageHash = _getBatchAllocationMessageHash(batchAllocation);
        _assertValidSignature(batchAllocationMessageHash, ownerSignature, batchAllocation.owner);
        bytes32 batchAllocationAuthorizationMessageHash =
        _getBatchAllocationAuthorizationMessageHash(
            batchAllocationAuthorization, batchAllocationMessageHash
        );
        _assertValidSignature(
            batchAllocationAuthorizationMessageHash, allocatorSignature, allocator
        );
        (address oracleClaimant, uint256[] memory oracleClaimAmounts) = IOracle(
            batchAllocation.oracle
        ).attestBatch(
            batchAllocationMessageHash, batchAllocation.oracleFixedData, oracleVariableData
        );

        claimant = _deriveClaimant(
            batchAllocation.claimant, batchAllocationAuthorization.claimant, oracleClaimant
        );

        claimAmounts = _deriveClaimAmountsAndEmitEvents(
            batchAllocation,
            batchAllocationAuthorization,
            batchAllocationMessageHash,
            totalIds,
            allocatorId,
            claimant,
            oracleClaimAmounts
        );
    }

    function _deriveClaimAmountsAndEmitEvents(
        BatchAllocation calldata batchAllocation,
        BatchAllocationAuthorization calldata batchAllocationAuthorization,
        bytes32 batchAllocationMessageHash,
        uint256 totalIds,
        uint96 allocatorId,
        address claimant,
        uint256[] memory oracleClaimAmounts
    ) internal returns (uint256[] memory claimAmounts) {
        claimAmounts = new uint256[](totalIds);

        // TODO: many of the bounds checks on these array accesses can be skipped as an optimization
        uint256 id = batchAllocation.ids[0];
        uint256 originalAmount = batchAllocation.amounts[0];
        uint256 amountReduction = batchAllocationAuthorization.amountReductions[0];
        uint256 claimAmount = oracleClaimAmounts[0].min(originalAmount - amountReduction);
        claimAmounts[0] = claimAmount;
        emit Claim(batchAllocation.owner, claimant, id, batchAllocationMessageHash, claimAmount);
        uint256 errorBuffer = (
            batchAllocationAuthorization.amountReductions[0] >= batchAllocation.amounts[0]
        ).or(totalIds != oracleClaimAmounts.length).asUint256();
        unchecked {
            for (uint256 i = 1; i < totalIds; ++i) {
                id = batchAllocation.ids[i];
                originalAmount = batchAllocation.amounts[i];
                amountReduction = batchAllocationAuthorization.amountReductions[i];
                errorBuffer |= (amountReduction >= originalAmount).or(
                    id.toAllocatorId() != allocatorId
                ).asUint256();
                claimAmount = oracleClaimAmounts[i].min(originalAmount - amountReduction);
                claimAmounts[i] = claimAmount;
                emit Claim(
                    batchAllocation.owner, claimant, id, batchAllocationMessageHash, claimAmount
                );
            }
        }
        if (errorBuffer.asBool()) {
            // TODO: extract more informative error by deriving the reason for the failure
            revert InvalidBatchAllocation();
        }
    }

    /// @dev Moves token `id` from `from` to `to` without checking
    //  allowances or _beforeTokenTransfer / _afterTokenTransfer hooks.
    function _release(address from, address to, uint256 id, uint256 amount)
        internal
        returns (bool)
    {
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

    /// @dev Mints `amount` of token `id` to `to` without checking transfer hooks.
    /// Emits {Transfer} and {Deposit} events.
    function _deposit(address from, address to, uint256 id, uint256 amount) internal virtual {
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
            // Emit the {Transfer} event.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, 0, shr(0x60, shl(0x60, to)), id)
        }

        emit Deposit(from, to, id, amount);
    }

    /// @dev Burns `amount` token `id` from `from` without checking transfer hooks and sends
    /// the corresponding underlying tokens to `to`. Emits {Transfer} & {Withdrawal} events.
    function _withdraw(address from, address to, uint256 id, uint256 amount) internal virtual {
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
            // Emit the {Transfer} event.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, shr(0x60, shl(0x60, from)), 0, id)
        }

        address token = id.toToken();
        if (token == address(0)) {
            to.safeTransferETH(amount);
        } else {
            token.safeTransfer(to, amount);
        }

        emit Withdrawal(from, to, id, amount);
    }

    function _assertValidTime(uint256 startTime, uint256 endTime) internal view {
        assembly ("memory-safe") {
            if or(gt(startTime, timestamp()), iszero(gt(endTime, timestamp()))) {
                // revert InvalidTime(startTime, endTime);
                mstore(0, 0x21ccfeb7)
                mstore(0x20, startTime)
                mstore(0x40, endTime)
                revert(0x1c, 0x44)
            }
        }
    }

    function _assertValidTime(uint256 expiration) internal view {
        assembly ("memory-safe") {
            if iszero(gt(expiration, timestamp())) {
                // revert Expired(expiration);
                mstore(0, 0xf80dbaea)
                mstore(0x20, expiration)
                revert(0x1c, 0x24)
            }
        }
    }

    function _assertValidSignature(
        bytes32 messageHash,
        bytes memory signature,
        address expectedSigner
    ) internal view {
        // NOTE: analyze whether the signature check can safely be skipped in all
        // cases where the caller is the expected signer.
        if (msg.sender != expectedSigner) {
            if (!expectedSigner.isValidSignatureNow(_getDomainHash(messageHash), signature)) {
                revert InvalidSignature();
            }
        }
    }

    function _deriveClaimant(
        address allocationClaimant,
        address allocationAuthorizationClaimant,
        address oracleClaimant
    ) internal pure returns (address claimant) {
        assembly ("memory-safe") {
            // clean upper dirty bits just in case
            let a := shr(0x60, shl(0x60, allocationClaimant))
            let b := shr(0x60, shl(0x60, allocationAuthorizationClaimant))
            let c := shr(0x60, shl(0x60, oracleClaimant))

            // all these things need to be true:
            // 1) a != 0 || b != 0 || c != 0
            // 2) a == b || a == 0 || b == 0
            // 3) a == c || a == 0 || c == 0
            // 4) b == c || b == 0 || c == 0
            let valid :=
                and(
                    and(iszero(iszero(or(or(a, b), c))), or(eq(a, b), or(iszero(a), iszero(b)))),
                    and(or(eq(a, c), or(iszero(a), iszero(c))), or(eq(b, c), or(iszero(b), iszero(c))))
                )

            if iszero(valid) {
                // `InvalidClaimant(address providerClaimant, address allocatorClaimant, address oracleClaimant)`
                mstore(0, 0xeeaed345)
                mstore(0x20, a)
                mstore(0x40, b)
                mstore(0x60, c)
                revert(0x1c, 0x64)
            }

            // a + (iszero(a) * b) + (iszero(a) * iszero(b) * c)
            // this gives the first non-zero address among a, b, or c
            claimant := add(add(a, mul(iszero(a), b)), mul(and(iszero(a), iszero(b)), c))
        }
    }

    function _getDomainHash(bytes32 messageHash) internal view returns (bytes32 domainHash) {
        uint256 initialChainId = _INITIAL_CHAIN_ID;
        bytes32 domainSeparator = _INITIAL_DOMAIN_SEPARATOR;

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer.

            // Prepare the 712 prefix.
            mstore(0, 0x1901)

            // Prepare the domain separator, rederiving it if necessary.
            if xor(chainid(), initialChainId) {
                mstore(m, _DOMAIN_TYPEHASH)
                mstore(add(m, 0x20), _NAME_HASH)
                mstore(add(m, 0x40), _VERSION_HASH)
                mstore(add(m, 0x60), chainid())
                mstore(add(m, 0x80), address())
                domainSeparator := keccak256(m, 0xa0)
            }

            mstore(0x20, domainSeparator)

            // Prepare the message hash and compute the domain hash.
            mstore(0x40, messageHash)
            domainHash := keccak256(0x1e, 0x42)

            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    function _processPledge(
        address owner,
        uint256 id,
        uint256 maxPledge,
        uint256 startTime,
        uint256 endTime
    ) internal {
        uint256 currentPledge = _deriveCurrentPledgeAmount(maxPledge, startTime, endTime);

        if (currentPledge != 0) {
            _release(owner, msg.sender, id, currentPledge);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 id, uint256 amount)
        internal
        virtual
        override
    {
        if (IAllocator(id.toAllocator()).attest(from, to, id, amount) != IAllocator.attest.selector)
        {
            revert UnallocatedTransfer(from, to, id, amount);
        }
    }

    function _deriveCurrentPledgeAmount(uint256 maxPledge, uint256 startTime, uint256 endTime)
        internal
        view
        returns (uint256)
    {
        return (maxPledge * (block.timestamp - startTime)) / (endTime - startTime);
    }

    function _getAllocationMessageHash(Allocation memory allocation)
        internal
        pure
        returns (bytes32 messageHash)
    {
        messageHash = keccak256(
            abi.encode(
                ALLOCATION_TYPEHASH,
                allocation.owner,
                allocation.startTime,
                allocation.endTime,
                allocation.nonce,
                allocation.id,
                allocation.amount,
                allocation.claimant,
                allocation.oracle,
                keccak256(allocation.oracleFixedData)
            )
        );
    }

    function _getBatchAllocationMessageHash(BatchAllocation memory batchAllocation)
        internal
        pure
        returns (bytes32 messageHash)
    {
        messageHash = keccak256(
            abi.encode(
                BATCH_ALLOCATION_TYPEHASH,
                batchAllocation.owner,
                batchAllocation.startTime,
                batchAllocation.endTime,
                batchAllocation.nonce,
                keccak256(abi.encode(batchAllocation.ids)),
                keccak256(abi.encode(batchAllocation.amounts)),
                batchAllocation.claimant,
                batchAllocation.oracle,
                keccak256(batchAllocation.oracleFixedData)
            )
        );
    }

    function _getAllocationAuthorizationMessageHash(
        AllocationAuthorization memory allocationAuthorization,
        bytes32 allocationMessageHash
    ) internal pure returns (bytes32 messageHash) {
        messageHash = keccak256(
            abi.encode(
                ALLOCATION_AUTHORIZATION_TYPEHASH,
                allocationMessageHash,
                allocationAuthorization.startTime,
                allocationAuthorization.endTime,
                allocationAuthorization.claimant,
                allocationAuthorization.amountReduction
            )
        );
    }

    function _getBatchAllocationAuthorizationMessageHash(
        BatchAllocationAuthorization memory batchAllocationAuthorization,
        bytes32 batchAllocationMessageHash
    ) internal pure returns (bytes32 messageHash) {
        messageHash = keccak256(
            abi.encode(
                BATCH_ALLOCATION_AUTHORIZATION_TYPEHASH,
                batchAllocationMessageHash,
                batchAllocationAuthorization.startTime,
                batchAllocationAuthorization.endTime,
                batchAllocationAuthorization.claimant,
                keccak256(abi.encode(batchAllocationAuthorization.amountReductions))
            )
        );
    }

    function _getAuthorizedTransferMessageHash(
        uint256 expiration,
        uint256 nonce,
        uint256 id,
        uint256 amount
    ) internal view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, TRANSFER_AUTHORIZATION_TYPEHASH)
            mstore(add(m, 0x20), caller())
            mstore(add(m, 0x40), expiration)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), id)
            mstore(add(m, 0xa0), amount)
            messageHash := keccak256(m, 0xc0)
        }
    }

    function _getDelegatedTransferMessageHash(
        address owner,
        uint256 startTime,
        uint256 endTime,
        uint256 nonce,
        uint256 id,
        uint256 amount,
        address recipient,
        uint256 pledge
    ) internal pure returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, DELEGATED_TRANSFER_TYPEHASH)
            mstore(add(m, 0x20), shr(0x60, shl(0x60, owner)))
            mstore(add(m, 0x40), startTime)
            mstore(add(m, 0x60), endTime)
            mstore(add(m, 0x80), nonce)
            mstore(add(m, 0xa0), id)
            mstore(add(m, 0xc0), amount)
            mstore(add(m, 0xe0), shr(0x60, shl(0x60, recipient)))
            mstore(add(m, 0x100), pledge)
            messageHash := keccak256(m, 0x120)
        }
    }

    function _getAuthorizedWithdrawalMessageHash(
        uint256 expiration,
        uint256 nonce,
        uint256 id,
        uint256 amount
    ) internal view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, WITHDRAWAL_AUTHORIZATION_TYPEHASH)
            mstore(add(m, 0x20), caller())
            mstore(add(m, 0x40), expiration)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), id)
            mstore(add(m, 0xa0), amount)
            messageHash := keccak256(m, 0xc0)
        }
    }

    function _getDelegatedWithdrawalMessageHash(
        address owner,
        uint256 startTime,
        uint256 endTime,
        uint256 nonce,
        uint256 id,
        uint256 amount,
        address recipient,
        uint256 pledge
    ) internal pure returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, DELEGATED_WITHDRAWAL_TYPEHASH)
            mstore(add(m, 0x20), shr(0x60, shl(0x60, owner)))
            mstore(add(m, 0x40), startTime)
            mstore(add(m, 0x60), endTime)
            mstore(add(m, 0x80), nonce)
            mstore(add(m, 0xa0), id)
            mstore(add(m, 0xc0), amount)
            mstore(add(m, 0xe0), shr(0x60, shl(0x60, recipient)))
            mstore(add(m, 0x100), pledge)
            messageHash := keccak256(m, 0x120)
        }
    }
}

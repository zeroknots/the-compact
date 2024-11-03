// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BatchTransfer, SplitBatchTransfer } from "../types/BatchClaims.sol";
import { BasicTransfer, SplitTransfer } from "../types/Claims.sol";
import { SplitComponent, TransferComponent, SplitByIdComponent } from "../types/Components.sol";

import { ClaimHashLib } from "./ClaimHashLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { EventLib } from "./EventLib.sol";
import { FunctionCastLib } from "./FunctionCastLib.sol";
import { IdLib } from "./IdLib.sol";
import { SharedLogic } from "./SharedLogic.sol";
import { ValidityLib } from "./ValidityLib.sol";

/**
 * @title TransferLogic
 * @notice Inherited contract implementing internal functions with logic for processing
 * allocated token transfers and withdrawals. These calls are submitted directly by the
 * sponsor and therefore only need to be independently authorized by the allocator. To
 * construct the authorizing Compact or BatchCompact payload, the arbiter is set as the
 * sponsor.
 */
contract TransferLogic is SharedLogic {
    using ClaimHashLib for BasicTransfer;
    using ClaimHashLib for SplitTransfer;
    using ClaimHashLib for BatchTransfer;
    using ClaimHashLib for SplitBatchTransfer;
    using IdLib for uint256;
    using EfficiencyLib for bool;
    using EventLib for address;
    using ValidityLib for uint96;
    using ValidityLib for uint256;
    using ValidityLib for bytes32;
    using FunctionCastLib for function(bytes32, address, BasicTransfer calldata) internal;

    // bytes4(keccak256("attest(address,address,address,uint256,uint256)")).
    uint32 private constant _ATTEST_SELECTOR = 0x1a808f91;

    /**
     * @notice Internal function for processing a basic allocated transfer or withdrawal.
     * Validates the allocator signature, checks expiration, consumes the nonce, and executes
     * the transfer or withdrawal operation for a single recipient.
     * @param transfer  A BasicTransfer struct containing signature, nonce, expiry, and transfer details.
     * @param operation Function pointer to either _release or _withdraw for executing the claim.
     * @return          Whether the transfer or withdrawal was successfully processed.
     */
    function _processBasicTransfer(BasicTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        // Derive hash, validate expiry, consume nonce, and check allocator signature.
        _notExpiredAndSignedByAllocator(transfer.toClaimHash(), transfer.id.toRegisteredAllocatorWithConsumed(transfer.nonce), transfer);

        // Perform the transfer or withdrawal.
        return operation(msg.sender, transfer.recipient, transfer.id, transfer.amount);
    }

    /**
     * @notice Internal function for processing a split transfer or withdrawal. Validates the
     * allocator signature, checks expiration, consumes the nonce, and executes the transfer
     * or withdrawal operation targeting multiple recipients from a single resource lock.
     * @param transfer  A SplitTransfer struct containing signature, nonce, expiry, and split transfer details.
     * @param operation Function pointer to either _release or _withdraw for executing the claim.
     * @return          Whether the transfer was successfully processed.
     */
    function _processSplitTransfer(SplitTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        // Derive hash, validate expiry, consume nonce, and check allocator signature.
        _notExpiredAndSignedByAllocator.usingSplitTransfer()(transfer.toClaimHash(), transfer.id.toRegisteredAllocatorWithConsumed(transfer.nonce), transfer);

        // Retrieve the total number of components.
        uint256 totalSplits = transfer.recipients.length;

        unchecked {
            // Iterate over each additional component in calldata.
            for (uint256 i = 0; i < totalSplits; ++i) {
                // Navigate to location of the component in calldata.
                SplitComponent calldata component = transfer.recipients[i];

                // Perform the transfer or withdrawal for the portion.
                operation(msg.sender, component.claimant, transfer.id, component.amount);
            }
        }

        return true;
    }

    /**
     * @notice Internal function for processing a batch transfer or withdrawal. Validates the
     * allocator signature, checks expiration, consumes the nonce, ensures consistent allocator
     * across all resource locks, and executes the transfer or withdrawal operation for a single
     * recipient from multiple resource locks.
     * @param transfer  A BatchTransfer struct containing signature, nonce, expiry, and batch transfer details.
     * @param operation Function pointer to either _release or _withdraw for executing the claim.
     * @return          Whether the transfer was successfully processed.
     */
    function _processBatchTransfer(BatchTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        // Derive hash, validate expiry, consume nonce, and check allocator signature.
        _notExpiredAndSignedByAllocator.usingBatchTransfer()(transfer.toClaimHash(), _deriveConsistentAllocatorAndConsumeNonce(transfer.transfers, transfer.nonce), transfer);

        // Retrieve the total number of components.
        uint256 totalTransfers = transfer.transfers.length;

        unchecked {
            // Iterate over each component in calldata.
            for (uint256 i = 0; i < totalTransfers; ++i) {
                // Navigate to location of the component in calldata.
                TransferComponent calldata component = transfer.transfers[i];

                // Perform the transfer or withdrawal for the component.
                operation(msg.sender, transfer.recipient, component.id, component.amount);
            }
        }

        return true;
    }

    /**
     * @notice Internal function for processing a split batch transfer or withdrawal. Validates
     * the allocator signature, checks expiration, consumes the nonce, ensures consistent
     * allocator across all resource locks, and executes the transfer or withdrawal operation
     * for multiple recipients from multiple resource locks.
     * @param transfer  A SplitBatchTransfer struct containing signature, nonce, expiry, and split batch transfer details.
     * @param operation Function pointer to either _release or _withdraw for executing the claim.
     * @return          Whether the transfer was successfully processed.
     */
    function _processSplitBatchTransfer(SplitBatchTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        // Derive hash, validate expiry, consume nonce, and check allocator signature.
        _notExpiredAndSignedByAllocator.usingSplitBatchTransfer()(transfer.toClaimHash(), _deriveConsistentAllocatorAndConsumeNonceWithSplit(transfer.transfers, transfer.nonce), transfer);

        // Declare a variable for tracking the id of each component.
        uint256 id;

        // Retrieve the total number of components.
        uint256 totalIds = transfer.transfers.length;

        unchecked {
            // Iterate over each component in calldata.
            for (uint256 i = 0; i < totalIds; ++i) {
                // Navigate to location of the component in calldata.
                SplitByIdComponent calldata component = transfer.transfers[i];

                // Retrieve the id for the component.
                id = component.id;

                // Navigate to location of component portions in calldata.
                SplitComponent[] calldata portions = component.portions;

                // Retrieve the total number of portions on the component.
                uint256 totalPortions = portions.length;

                // Iterate over each portion in calldata.
                for (uint256 j = 0; j < totalPortions; ++j) {
                    // Navigate to the location of the portion in calldata.
                    SplitComponent calldata portion = portions[j];

                    // Perform the transfer or withdrawal for the portion.
                    operation(msg.sender, portion.claimant, id, portion.amount);
                }
            }
        }

        return true;
    }

    /**
     * @notice Internal function for ensuring a transfer has been attested by its allocator.
     * Makes a call to the allocator's attest function and reverts if the attestation fails
     * due to a reverted call or due to the call not returning the required magic value. Note
     * that this call is stateful.
     * @param from    The account transferring tokens.
     * @param to      The account receiving tokens.
     * @param id      The ERC6909 token identifier of the resource lock.
     * @param amount  The amount of tokens being transferred.
     */
    function _ensureAttested(address from, address to, uint256 id, uint256 amount) internal {
        // Derive the allocator address from the supplied id.
        address allocator = id.toAllocator();

        assembly ("memory-safe") {
            // Sanitize from and to addresses.
            from := shr(0x60, shl(0x60, from))
            to := shr(0x60, shl(0x60, to))

            // Retrieve the free memory pointer; memory will be left dirtied.
            let m := mload(0x40)

            // Ensure sure initial scratch space is cleared as an added precaution.
            mstore(0, 0)

            // Derive offset to start of data for the call from memory pointer.
            let dataStart := add(m, 0x1c)

            // Prepare calldata: attest(caller(), from, to, id, amount).
            mstore(m, _ATTEST_SELECTOR)
            mstore(add(m, 0x20), caller())
            mstore(add(m, 0x40), from)
            mstore(add(m, 0x60), to)
            mstore(add(m, 0x80), id)
            mstore(add(m, 0xa0), amount)

            // Perform call to allocator and write response to scratch space.
            let success := call(gas(), allocator, 0, dataStart, 0xa4, 0, 0x20)

            // Revert if the required magic value was not received back.
            if iszero(eq(mload(0), shl(224, _ATTEST_SELECTOR))) {
                // Bubble up revert if the call failed and there's data.
                // NOTE: consider evaluating remaining gas to protect against revert bombing.
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

    /**
     * @notice Private function that checks expiration, verifies the allocator's signature,
     * and emits a claim event.
     * @param messageHash     The EIP-712 hash of the transfer message.
     * @param allocator       The address of the allocator.
     * @param transferPayload The BasicTransfer struct containing signature and expiry.
     */
    function _notExpiredAndSignedByAllocator(bytes32 messageHash, address allocator, BasicTransfer calldata transferPayload) private {
        // Ensure that the expiration timestamp is still in the future.
        transferPayload.expires.later();

        // Derive domain separator and domain hash and validate allocator signature.
        messageHash.signedBy(allocator, transferPayload.allocatorSignature, _domainSeparator());

        // Emit Claim event.
        msg.sender.emitClaim(messageHash, allocator);
    }

    /**
     * @notice Private function that ensures all components in a batch transfer share the
     * same allocator and consumes the nonce. Reverts if any component has a different
     * allocator or if the batch is empty.
     * @param components Array of transfer components to check.
     * @param nonce      The nonce to consume.
     * @return allocator The validated allocator address.
     */
    function _deriveConsistentAllocatorAndConsumeNonce(TransferComponent[] calldata components, uint256 nonce) private returns (address allocator) {
        // Retrieve the total number of components.
        uint256 totalComponents = components.length;

        // Track errors, starting with whether total number of components is zero.
        uint256 errorBuffer = (totalComponents == 0).asUint256();

        // NOTE: bounds checks on these array accesses can be skipped as an optimization
        uint96 allocatorId = components[0].id.toAllocatorId();

        // Retrieve the allocator address and consume the nonce.
        allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(nonce);

        unchecked {
            // Iterate over each additional component in calldata.
            for (uint256 i = 1; i < totalComponents; ++i) {
                // Mark as an error if the allocatorId does not match the initial one.
                errorBuffer |= (components[i].id.toAllocatorId() != allocatorId).asUint256();
            }
        }

        // Revert if an error was encountered.
        assembly ("memory-safe") {
            if errorBuffer {
                // revert InvalidBatchAllocation()
                mstore(0, 0x3a03d3bb)
                revert(0x1c, 0x04)
            }
        }
    }

    /**
     * @notice Private function that ensures all components in a split batch transfer share
     * the same allocator and consumes the nonce. Reverts if any component has a different
     * allocator or if the batch is empty.
     * @param components Array of split transfer components to check.
     * @param nonce      The nonce to consume.
     * @return allocator The validated allocator address.
     */
    function _deriveConsistentAllocatorAndConsumeNonceWithSplit(SplitByIdComponent[] calldata components, uint256 nonce) private returns (address allocator) {
        // Retrieve the total number of components.
        uint256 totalComponents = components.length;

        // Track errors, starting with whether total number of components is zero.
        uint256 errorBuffer = (totalComponents == 0).asUint256();

        // NOTE: bounds checks on these array accesses can be skipped as an optimization
        uint96 allocatorId = components[0].id.toAllocatorId();

        // Retrieve the allocator address and consume the nonce.
        allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(nonce);

        unchecked {
            // Iterate over each additional component in calldata.
            for (uint256 i = 1; i < totalComponents; ++i) {
                // Mark as an error if the allocatorId does not match the initial one.
                errorBuffer |= (components[i].id.toAllocatorId() != allocatorId).asUint256();
            }
        }

        // Revert if an error was encountered.
        assembly ("memory-safe") {
            if errorBuffer {
                // revert InvalidBatchAllocation()
                mstore(0, 0x3a03d3bb)
                revert(0x1c, 0x04)
            }
        }
    }
}

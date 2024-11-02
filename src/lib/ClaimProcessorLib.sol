// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { COMPACT_TYPEHASH, BATCH_COMPACT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH } from "../types/EIP712Types.sol";
import { SplitComponent } from "../types/Components.sol";
import { Scope } from "../types/Scope.sol";

import { EfficiencyLib } from "./EfficiencyLib.sol";
import { IdLib } from "./IdLib.sol";

/**
 * @title ClaimProcessorLib
 * @notice Library contract implementing internal functions with helper logic for
 * processing claims against a signed or registered compact.
 */
library ClaimProcessorLib {
    using ClaimProcessorLib for uint256;
    using EfficiencyLib for bool;
    using IdLib for uint256;

    /**
     * @notice Internal function for verifying and processing split components. Ensures that the
     * sum of split amounts doesn't exceed the allocated amount, checks for arithmetic overflow,
     * and executes the specified operation for each split recipient. Reverts if the total
     * claimed amount exceeds the allocation or if arithmetic overflow occurs during summation.
     * @param claimants       Array of split components specifying recipients and their amounts.
     * @param sponsor         The address of the claim sponsor.
     * @param id              The ERC6909 token identifier of the resource lock.
     * @param allocatedAmount The total amount allocated for this claim.
     * @param operation       Function pointer to either _release or _withdraw for executing the claim.
     * @return                Whether all split components were successfully processed.
     */
    function verifyAndProcessSplitComponents(
        SplitComponent[] calldata claimants,
        address sponsor,
        uint256 id,
        uint256 allocatedAmount,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        // Initialize tracking variables.
        uint256 totalClaims = claimants.length;
        uint256 spentAmount = 0;
        uint256 errorBuffer = (totalClaims == 0).asUint256();

        unchecked {
            // Process each split component while tracking total amount and checking for overflow.
            for (uint256 i = 0; i < totalClaims; ++i) {
                SplitComponent calldata component = claimants[i];
                uint256 amount = component.amount;

                // Track total amount claimed, checking for overflow.
                uint256 updatedSpentAmount = amount + spentAmount;
                errorBuffer |= (updatedSpentAmount < spentAmount).asUint256();
                spentAmount = updatedSpentAmount;

                // Execute transfer or withdrawal for the split component.
                operation(sponsor, component.claimant, id, amount);
            }
        }

        // Revert if an overflow occurred or if total claimed amount exceeds allocation.
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

    /**
     * @notice Internal pure function for validating that a resource lock's scope is compatible
     * with the provided sponsor domain separator. Reverts if an exogenous claim (indicated by
     * a non-zero sponsor domain separator) attempts to claim against a chain-specific resource
     * lock (indicated by the most significant bit of the id).
     * @param sponsorDomainSeparator The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param id                     The ERC6909 token identifier of the resource lock.
     */
    function ensureValidScope(bytes32 sponsorDomainSeparator, uint256 id) internal pure {
        assembly ("memory-safe") {
            if iszero(or(iszero(sponsorDomainSeparator), iszero(shr(255, id)))) {
                // revert InvalidScope(id)
                mstore(0, 0xa06356f5)
                mstore(0x20, id)
                revert(0x1c, 0x24)
            }
        }
    }

    /**
     * @notice Internal pure function for retrieving EIP-712 typehashes where no witness data is
     * provided, returning the corresponding typehash based on the index provided. The available
     * typehashes are:
     *  - 0: COMPACT_TYPEHASH
     *  - 1: BATCH_COMPACT_TYPEHASH
     *  - 2: MULTICHAIN_COMPACT_TYPEHASH
     * @param i         The index of the EIP-712 typehash to retrieve.
     * @return typehash The corresponding EIP-712 typehash.
     */
    function typehashes(uint256 i) internal pure returns (bytes32 typehash) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(0, COMPACT_TYPEHASH)
            mstore(0x20, BATCH_COMPACT_TYPEHASH)
            mstore(0x40, MULTICHAIN_COMPACT_TYPEHASH)
            typehash := mload(shl(5, i))
            mstore(0x40, m)
        }
    }

    /**
     * @notice Internal function for determining if a resource lock has chain-specific scope
     * in the context of an exogenous claim. Returns true if the claim is exogenous (indicated
     * by non-zero sponsor domain separator) and the resource lock is chain-specific.
     * @param id                     The ERC6909 token identifier of the resource lock.
     * @param sponsorDomainSeparator The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @return                       Whether the resource lock's scope is incompatible with the claim context.
     */
    function scopeNotMultichain(uint256 id, bytes32 sponsorDomainSeparator) internal pure returns (bool) {
        return (sponsorDomainSeparator != bytes32(0)).and(id.toScope() == Scope.ChainSpecific);
    }

    /**
     * @notice Internal function that combines two claim validations: whether the amount exceeds
     * allocation and whether the resource lock's scope is compatible with the claim context.
     * Returns true if either the allocated amount is exceeded or if the claim is exogenous but
     * the resource lock is chain-specific.
     * @param allocatedAmount         The total amount allocated for the claim.
     * @param amount                  The amount being claimed.
     * @param id                      The ERC6909 token identifier of the resource lock.
     * @param sponsorDomainSeparator  The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @return                        Whether either validation fails.
     */
    function allocationExceededOrScopeNotMultichain(uint256 allocatedAmount, uint256 amount, uint256 id, bytes32 sponsorDomainSeparator) internal pure returns (bool) {
        return (allocatedAmount < amount).or(id.scopeNotMultichain(sponsorDomainSeparator));
    }
}

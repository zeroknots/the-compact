// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { COMPACT_TYPEHASH, BATCH_COMPACT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH } from "../types/EIP712Types.sol";
import { SplitComponent, BatchClaimComponent, SplitBatchClaimComponent } from "../types/Components.sol";
import { Scope } from "../types/Scope.sol";

import { EfficiencyLib } from "./EfficiencyLib.sol";
import { EventLib } from "./EventLib.sol";
import { IdLib } from "./IdLib.sol";
import { RegistrationLib } from "./RegistrationLib.sol";
import { ValidityLib } from "./ValidityLib.sol";

/**
 * @title ClaimProcessorLib
 * @notice Library contract implementing internal functions with helper logic for
 * processing claims against a signed or registered compact.
 */
library ClaimProcessorLib {
    using ClaimProcessorLib for uint256;
    using ClaimProcessorLib for bytes32;
    using ClaimProcessorLib for SplitComponent[];
    using EfficiencyLib for bool;
    using EfficiencyLib for uint256;
    using EfficiencyLib for bytes32;
    using EventLib for address;
    using IdLib for uint256;
    using ValidityLib for uint256;
    using ValidityLib for uint96;
    using ValidityLib for bytes32;
    using RegistrationLib for address;

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

    /**
     * @notice Internal function for validating claim execution parameters. Extracts and validates
     * signatures from calldata, checks expiration, verifies allocator registration, consumes the
     * nonce, derives the domain separator, and validates both the sponsor authorization (either
     * through direct registration or a provided signature or EIP-1271 call) and the (potentially
     * qualified) allocator authorization. Finally, emits a Claim event.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param allocatorId              The unique identifier for the allocator mediating the claim.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param domainSeparator          The local domain separator.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @return sponsor                 The extracted address of the claim sponsor.
     */
    function validate(bytes32 messageHash, uint96 allocatorId, bytes32 qualificationMessageHash, uint256 calldataPointer, bytes32 domainSeparator, bytes32 sponsorDomainSeparator, bytes32 typehash)
        internal
        returns (address sponsor)
    {
        // Declare variables for signatures and parameters that will be extracted from calldata.
        bytes calldata allocatorSignature;
        bytes calldata sponsorSignature;
        uint256 nonce;
        uint256 expires;

        assembly ("memory-safe") {
            // Extract allocator signature from calldata using offset stored at calldataPointer.
            let allocatorSignaturePtr := add(calldataPointer, calldataload(calldataPointer))
            allocatorSignature.offset := add(0x20, allocatorSignaturePtr)
            allocatorSignature.length := calldataload(allocatorSignaturePtr)

            // Extract sponsor signature from calldata using offset stored at calldataPointer + 0x20.
            let sponsorSignaturePtr := add(calldataPointer, calldataload(add(calldataPointer, 0x20)))
            sponsorSignature.offset := add(0x20, sponsorSignaturePtr)
            sponsorSignature.length := calldataload(sponsorSignaturePtr)

            // Extract sponsor address, sanitizing upper 96 bits.
            sponsor := shr(96, shl(96, calldataload(add(calldataPointer, 0x40))))

            // Extract nonce and expiration timestamp.
            nonce := calldataload(add(calldataPointer, 0x60))
            expires := calldataload(add(calldataPointer, 0x80))
        }

        // Ensure that the claim hasn't expired.
        expires.later();

        // Retrieve allocator address and consume nonce, ensuring it has not already been consumed.
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(nonce);

        assembly ("memory-safe") {
            // Swap domain separator for provided sponsorDomainSeparator if a nonzero value was supplied.
            sponsorDomainSeparator := add(sponsorDomainSeparator, mul(iszero(sponsorDomainSeparator), domainSeparator))
        }

        // Validate sponsor authorization through either ECDSA, EIP-1271, or direct registration.
        if ((sponsorDomainSeparator != domainSeparator).or(sponsorSignature.length != 0) || sponsor.hasNoActiveRegistration(messageHash, typehash)) {
            messageHash.signedBy(sponsor, sponsorSignature, sponsorDomainSeparator);
        }

        // Validate allocator authorization against qualification message.
        qualificationMessageHash.signedBy(allocator, allocatorSignature, domainSeparator);

        // Emit claim event.
        sponsor.emitClaim(messageHash, allocator);
    }

    /**
     * @notice Private function for processing qualified claims with potentially exogenous
     * sponsor signatures. Extracts claim parameters from calldata, validates the scope,
     * ensures the claimed amount is within the allocated amount, validates the claim,
     * and executes either a release of ERC6909 tokens or a withdrawal of underlying tokens.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param offsetToId               Offset to segment of calldata where relevant claim parameters begin.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @param domainSeparator          The local domain separator.
     * @param operation                Function pointer to either _release or _withdraw for executing the claim.
     * @return                         Whether the claim was successfully processed.
     */
    function processClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        // Declare variables for parameters that will be extracted from calldata.
        uint256 id;
        uint256 allocatedAmount;
        address claimant;
        uint256 amount;

        assembly ("memory-safe") {
            // Calculate pointer to claim parameters using provided offset.
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)

            // Extract resource lock id, allocated amount, claimant address, and claim amount.
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))
            claimant := shr(96, shl(96, calldataload(add(calldataPointerWithOffset, 0x40))))
            amount := calldataload(add(calldataPointerWithOffset, 0x60))
        }

        // Verify the resource lock scope is compatible with the provided domain separator.
        sponsorDomainSeparator.ensureValidScope(id);

        // Ensure the claimed amount does not exceed the allocated amount.
        amount.withinAllocated(allocatedAmount);

        // Validate the claim and execute the specified operation (either release or withdraw).
        return operation(validate(messageHash, id.toAllocatorId(), qualificationMessageHash, calldataPointer, domainSeparator, sponsorDomainSeparator, typehash), claimant, id, amount);
    }

    /**
     * @notice Private function for processing qualified split claims with potentially exogenous
     * sponsor signatures. Extracts claim parameters from calldata, validates the claim,
     * validates the scope, and executes either releases of ERC6909 tokens or withdrawals of
     * underlying tokens to multiple recipients.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param offsetToId               Offset to segment of calldata where relevant claim parameters begin.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @param domainSeparator          The local domain separator.
     * @param operation                Function pointer to either _release or _withdraw for executing the claim.
     * @return                         Whether the split claim was successfully processed.
     */
    function processSplitClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        // Declare variables for parameters that will be extracted from calldata.
        uint256 id;
        uint256 allocatedAmount;
        SplitComponent[] calldata components;

        assembly ("memory-safe") {
            // Calculate pointer to claim parameters using provided offset.
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)

            // Extract resource lock id and allocated amount.
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))

            // Extract array of split components containing claimant addresses and amounts.
            let componentsPtr := add(calldataPointer, calldataload(add(calldataPointerWithOffset, 0x40)))
            components.offset := add(0x20, componentsPtr)
            components.length := calldataload(componentsPtr)
        }

        // Validate the claim and extract the sponsor address.
        address sponsor = validate(messageHash, id.toAllocatorId(), qualificationMessageHash, calldataPointer, domainSeparator, sponsorDomainSeparator, typehash);

        // Verify the resource lock scope is compatible with the provided domain separator.
        sponsorDomainSeparator.ensureValidScope(id);

        // Process each split component, verifying total amount and executing operations.
        return components.verifyAndProcessSplitComponents(sponsor, id, allocatedAmount, operation);
    }

    /**
     * @notice Private function for processing qualified batch claims with potentially exogenous
     * sponsor signatures. Extracts batch claim parameters from calldata, validates the claim,
     * executes operations, and performs optimized validation of allocator consistency, amounts,
     * and scopes. If any validation fails, all operations are reverted after explicitly
     * identifying the specific validation failures.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param offsetToId               Offset to segment of calldata where relevant claim parameters begin.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @param domainSeparator          The local domain separator.
     * @param operation                Function pointer to either _release or _withdraw for executing the claim.
     * @return                         Whether the batch claim was successfully processed.
     */
    function processBatchClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        // Declare variables for parameters that will be extracted from calldata.
        BatchClaimComponent[] calldata claims;
        address claimant;

        assembly ("memory-safe") {
            // Calculate pointer to claim parameters using provided offset.
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)

            // Extract array of batch claim components and claimant address.
            let claimsPtr := add(calldataPointer, calldataload(calldataPointerWithOffset))
            claims.offset := add(0x20, claimsPtr)
            claims.length := calldataload(claimsPtr)
            claimant := calldataload(add(calldataPointerWithOffset, 0x20))
        }

        // Extract allocator id from first claim for validation.
        uint96 firstAllocatorId = claims[0].id.toAllocatorId();

        // Validate the claim and extract the sponsor address.
        address sponsor = validate(messageHash, firstAllocatorId, qualificationMessageHash, calldataPointer, domainSeparator, sponsorDomainSeparator, typehash);

        // Revert if the batch is empty.
        uint256 totalClaims = claims.length;
        assembly ("memory-safe") {
            if iszero(totalClaims) {
                // revert InvalidBatchAllocation()
                mstore(0, 0x3a03d3bb)
                revert(0x1c, 0x04)
            }
        }

        // Process first claim and initialize error tracking.
        // NOTE: many of the bounds checks on these array accesses can be skipped as an optimization
        BatchClaimComponent calldata component = claims[0];
        uint256 id = component.id;
        uint256 amount = component.amount;
        uint256 errorBuffer = component.allocatedAmount.allocationExceededOrScopeNotMultichain(amount, id, sponsorDomainSeparator).asUint256();

        // Execute transfer or withdrawal for first claim.
        operation(sponsor, claimant, id, amount);

        unchecked {
            // Process remaining claims while accumulating potential errors.
            for (uint256 i = 1; i < totalClaims; ++i) {
                component = claims[i];
                id = component.id;
                amount = component.amount;
                errorBuffer |= (id.toAllocatorId() != firstAllocatorId).or(component.allocatedAmount.allocationExceededOrScopeNotMultichain(amount, id, sponsorDomainSeparator)).asUint256();

                operation(sponsor, claimant, id, amount);
            }

            // If any errors occurred, identify specific failures and revert.
            if (errorBuffer.asBool()) {
                for (uint256 i = 0; i < totalClaims; ++i) {
                    component = claims[i];
                    component.amount.withinAllocated(component.allocatedAmount);
                    id = component.id;
                    sponsorDomainSeparator.ensureValidScope(component.id);
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

    /**
     * @notice Private function for processing qualified split batch claims with potentially
     * exogenous sponsor signatures. Extracts split batch claim parameters from calldata,
     * validates the claim, and executes split operations for each resource lock. Uses optimized
     * validation of allocator consistency and scopes, with explicit validation on failure to
     * identify specific issues. Each resource lock can be split among multiple recipients.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param offsetToId               Offset to segment of calldata where relevant claim parameters begin.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @param domainSeparator          The local domain separator.
     * @param operation                Function pointer to either _release or _withdraw for executing the claim.
     * @return                         Whether the split batch claim was successfully processed.
     */
    function processSplitBatchClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        // Declare variable for SplitBatchClaimComponent array that will be extracted from calldata.
        SplitBatchClaimComponent[] calldata claims;

        assembly ("memory-safe") {
            // Extract array of split batch claim components.
            let claimsPtr := add(calldataPointer, calldataload(add(calldataPointer, offsetToId)))
            claims.offset := add(0x20, claimsPtr)
            claims.length := calldataload(claimsPtr)
        }

        // Extract allocator id from first claim for validation.
        uint96 firstAllocatorId = claims[0].id.toAllocatorId();

        // Validate the claim and extract the sponsor address.
        address sponsor = validate(messageHash, firstAllocatorId, qualificationMessageHash, calldataPointer, domainSeparator, sponsorDomainSeparator, typehash);

        // Initialize tracking variables.
        uint256 totalClaims = claims.length;
        uint256 errorBuffer = (totalClaims == 0).asUint256();
        uint256 id;

        unchecked {
            // Process each claim component while accumulating potential errors.
            for (uint256 i = 0; i < totalClaims; ++i) {
                SplitBatchClaimComponent calldata claimComponent = claims[i];
                id = claimComponent.id;
                errorBuffer |= (id.toAllocatorId() != firstAllocatorId).or(id.scopeNotMultichain(sponsorDomainSeparator)).asUint256();

                // Process each split component, verifying total amount and executing operations.
                claimComponent.portions.verifyAndProcessSplitComponents(sponsor, id, claimComponent.allocatedAmount, operation);
            }

            // If any errors occurred, identify specific scope failures and revert.
            if (errorBuffer.asBool()) {
                for (uint256 i = 0; i < totalClaims; ++i) {
                    sponsorDomainSeparator.ensureValidScope(claims[i].id);
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

    function processSimpleClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, domainSeparator, operation);
    }

    function processSimpleSplitClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processSplitClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, domainSeparator, operation);
    }

    function processSimpleBatchClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, domainSeparator, operation);
    }

    function processBatchClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processBatchClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, domainSeparator, operation);
    }

    function processSimpleSplitBatchClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processSplitBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, domainSeparator, operation);
    }

    function processSplitBatchClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return
            processSplitBatchClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, domainSeparator, operation);
    }

    function processClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, domainSeparator, operation);
    }

    function processClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, domainSeparator, operation);
    }

    function processSplitClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processSplitClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, domainSeparator, operation);
    }

    function processSplitClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processSplitClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, domainSeparator, operation);
    }

    function processBatchClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, domainSeparator, operation);
    }

    function processSplitBatchClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        bytes32 domainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return processSplitBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, domainSeparator, operation);
    }
}

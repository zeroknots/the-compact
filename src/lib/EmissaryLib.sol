// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { IdLib } from "./IdLib.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { EmissaryConfig, EmissaryStatus } from "../types/EmissaryStatus.sol";
import { IEmissary } from "../interfaces/IEmissary.sol";

/**
 * @title EmissaryLib
 * @notice This library manages the assignment and verification of emissaries for sponsors
 * within the system. An emissary is an address that can verify claims on behalf of a sponsor.
 * The library enforces security constraints and scheduling rules to ensure proper delegation.
 *
 * @dev The library uses a storage-efficient design with a single storage slot for all emissary
 * configurations, using mappings to organize data by sponsor and allocator ID. This allows for
 * efficient storage and access while maintaining data isolation between different sponsors.
 *
 * Key Components:
 * - EmissarySlot: Storage structure that maps sponsors to their allocator ID configurations
 * - EmissaryConfig: Configuration data for each emissary assignment, including reset periods
 * - Assignment scheduling: Enforces cooldown periods between assignments to prevent abuse
 * - Verification: Delegates claim verification to the assigned emissary contract
 *
 * Security Features:
 * - Timelock mechanism for reassignment to prevent rapid succession of emissaries
 * - Clear state management with Disabled/Enabled/Scheduled statuses
 * - Storage cleanup when emissaries are removed
 */
library EmissaryLib {
    using IdLib for uint256;
    using IdLib for ResetPeriod;

    error EmissaryAssignmentUnavailable(uint256 assignAt);

    event EmissaryAssigned(address indexed sponsor, uint256 indexed id, address indexed emissary);
    event EmissaryAssignmentScheduled(address indexed sponsor, uint256 indexed id, uint256 indexed assignableAt);

    uint88 constant NOT_SCHEDULED = type(uint88).max;

    // Storage slot for emissary configurations
    // Maps: keccak256(_EMISSARY_SCOPE) => EmissarySlot
    uint256 private constant _EMISSARY_SCOPE = 0x2d5c707;

    /**
     * @dev Retrieves the configuration for a given emissary.
     * This ensures that emissary-specific settings (like reset period and assignment time)
     * are stored and retrieved in a consistent and isolated manner to prevent conflicts.
     */
    function _getEmissaryConfig(address sponsor, uint256 id) private pure returns (EmissaryConfig storage config) {
        assembly ("memory-safe") {
            // Retrieve the current free memory pointer.
            let m := mload(0x40)

            // Pack data for computing storage slot.
            mstore(0x14, sponsor) // Offset 0x14 (20 bytes): Store 20-byte sponsor address
            mstore(0, _EMISSARY_SCOPE) // Offset 0 (0 bytes): Store 4-byte scope value
            mstore(0x34, id) // Offset 0x34 (52 bytes): Store 32-byte allocator id

            // Compute storage slot from packed data.
            // Start at offset 0x1c (28 bytes), which includes:
            // - The 4 bytes of _EMISSARY_SCOPE (which is stored at position 0x00)
            // - The entire 20-byte sponsor address (which starts at position 0x14)
            // - The entire 32-byte allocator id (which starts at position 0x34)
            // Hash 0x38 (56 bytes) of data in total
            config.slot := keccak256(0x1c, 0x38)

            // Restore the free memory pointer.
            mstore(0x40, m)
        }
    }

    /**
     * @dev Assigns or removes an emissary for a specific sponsor and allocator ID.
     * The function ensures that the assignment process adheres to the scheduling rules
     * and prevents invalid or premature assignments. It also clears the configuration
     * when removing an emissary to keep storage clean and avoid stale data.
     */
    function assignEmissary(address sponsor, uint256 id, address newEmissary, ResetPeriod resetPeriod) internal {
        EmissaryConfig storage config = _getEmissaryConfig(sponsor, id);
        uint256 _assignableAt = config.assignableAt;
        address _emissary = config.emissary;

        // Ensures that the assignment has been scheduled properly.
        // Without this check, an emissary could be assigned without proper scheduling,
        // leading to uncontrolled state transitions.
        require(_assignableAt != NOT_SCHEDULED, EmissaryAssignmentUnavailable(NOT_SCHEDULED));

        // The second check ensures that either there is no current emissary,
        // or the reset period has elapsed before allowing a new assignment.
        // This enforces the cooldown period between assignments to prevent abuse.
        require(_emissary == address(0) || config.assignableAt <= block.timestamp, EmissaryAssignmentUnavailable(config.assignableAt));

        // if new Emissary is address(0), that means that the sponsor wants to remove the emissary feature.
        // we wipe all storage
        if (newEmissary == address(0)) {
            // If the new emissary is address(0), this means we are removing the emissary.
            // We clear all related storage fields to maintain a clean state and avoid stale data.
            delete config.emissary;
            delete config.assignableAt;
            delete config.resetPeriod;
        }
        // otherwise we set the provided resetPeriod
        else {
            config.emissary = newEmissary;
            config.assignableAt = NOT_SCHEDULED;
            config.resetPeriod = resetPeriod;
        }

        emit EmissaryAssigned(sponsor, id, newEmissary);
    }

    /**
     * @dev Schedules a future assignment for an emissary.
     * The scheduling mechanism ensures that emissaries cannot be reassigned arbitrarily,
     * enforcing a reset period that must elapse before a new assignment is possible.
     * This prevents abuse of the system by requiring a cooldown period between assignments.
     */
    function scheduleEmissaryAssignment(address sponsor, uint256 allocatorId) internal returns (uint256 assignableAt) {
        EmissaryConfig storage emissaryConfig = _getEmissaryConfig(sponsor, allocatorId);
        uint256 resetPeriod = emissaryConfig.resetPeriod.toSeconds();
        assignableAt = block.timestamp + resetPeriod;
        emissaryConfig.assignableAt = uint88(assignableAt);

        emit EmissaryAssignmentScheduled(sponsor, allocatorId, assignableAt);
        return assignableAt;
    }

    /**
     * @dev Verifies a claim using the assigned emissary.
     * This function delegates the verification logic to the emissary contract,
     * ensuring that the verification process is modular and can be updated independently.
     * If no emissary is assigned, the verification fails, enforcing the requirement
     * for an active emissary to validate claims.
     */
    function verifyWithEmissary(bytes32 claimHash, address sponsor, uint256 id, bytes calldata signature) internal view returns (bool) {
        EmissaryConfig storage emissaryConfig = _getEmissaryConfig(sponsor, id);
        address emissary = emissaryConfig.emissary;
        if (emissary == address(0)) return false;
        // Delegate the verification process to the assigned emissary contract.
        // This modular approach allows the verification logic to be updated independently,
        // ensuring flexibility and separation of concerns in the emissary system.
        return IEmissary(emissary).verifyClaim(sponsor, claimHash, signature, id) == IEmissary.verifyClaim.selector;
    }

    /**
     * @dev Retrieves the current status of an emissary for a given sponsor and allocator ID.
     * The status provides insight into whether the emissary is active, disabled, or scheduled for reassignment.
     * This helps external contracts and users understand the state of the emissary system
     * without needing to interpret raw configuration data.
     */
    function getEmissaryStatus(address sponsor, uint256 id) internal view returns (EmissaryStatus status, uint256 assignableAt, address currentEmissary) {
        EmissaryConfig storage emissaryConfig = _getEmissaryConfig(sponsor, id);
        assignableAt = emissaryConfig.assignableAt;
        currentEmissary = emissaryConfig.emissary;

        // Determine the emissary's status based on its current state:
        // - If there is no current emissary, the status is Disabled.
        // - If assignableAt is NOT_SCHEDULED, the emissary is Enabled and active.
        // - If assignableAt is set to a future timestamp, the emissary is Scheduled for reassignment.
        if (currentEmissary == address(0)) status = EmissaryStatus.Disabled;
        else if (assignableAt == NOT_SCHEDULED) status = EmissaryStatus.Enabled;
        else if (assignableAt != 0) status = EmissaryStatus.Scheduled;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

import { ConsumerLib } from "./ConsumerLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { IdLib } from "./IdLib.sol";
import { ValidityLib } from "./ValidityLib.sol";

/**
 * @title AllocatorLogic
 * @notice Inherited contract implementing internal functions with logic for registering
 * new allocators, allowing registered allocators to directly consume nonces within their
 * scope, and querying for information on nonce consumption and lock details.
 */
contract AllocatorLogic {
    using IdLib for uint96;
    using IdLib for uint256;
    using IdLib for address;
    using ConsumerLib for uint256;
    using EfficiencyLib for uint256;
    using ValidityLib for address;

    function _consume(uint256[] calldata nonces) internal returns (bool) {
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

    function _registerAllocator(address allocator, bytes calldata proof) internal returns (uint96 allocatorId) {
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

    function _hasConsumedAllocatorNonce(uint256 nonce, address allocator) internal view returns (bool) {
        return allocator.hasConsumedAllocatorNonce(nonce);
    }

    function _getLockDetails(uint256 id) internal view returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope) {
        token = id.toToken();
        allocator = id.toAllocatorId().toRegisteredAllocator();
        resetPeriod = id.toResetPeriod();
        scope = id.toScope();
    }
}

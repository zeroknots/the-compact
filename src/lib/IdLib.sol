// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Lock } from "../types/Lock.sol";
import { MetadataLib } from "./MetadataLib.sol";

library IdLib {
    using IdLib for address;
    using IdLib for uint256;
    using MetadataLib for Lock;

    event AllocatorRegistered(uint256 index, address allocator);

    error NoAllocatorRegistered(uint256 index);

    uint256 private constant _REGISTERED_ALLOCATORS_SLOT = 0xcf72006beff85889;
    uint256 private constant _ALLOCATOR_BY_INDEX_SLOT_SEED = 0x44036fc77deaed23;
    uint256 private constant _INDEX_BY_ALLOCATOR_SLOT_SEED = 0x19e4977afc3c0113;
    uint256 private constant _ALLOCATOR_REGISTERED_EVENT_SIGNATURE =
        0x5a1e65f3f7d7ee1f1ac7cc54c5c280d8d434555ebb06ca1544ddce8875188d32;
    uint256 private constant _NO_ALLOCATOR_REGISTERED_ERROR_SIGNATURE = 0x3e3fe688;

    function toToken(uint256 id) internal pure returns (address token) {
        return address(uint160(id));
    }

    function toResetPeriod(uint256 id) internal pure returns (uint256 resetPeriod) {
        return (id << 0x30) >> 0xd0;
    }

    function toAllocatorIndex(uint256 id) internal pure returns (uint256 index) {
        index = id >> 0xd0;
    }

    function toAllocator(uint256 id) internal view returns (address allocator) {
        allocator = id.toAllocatorIndex().toRegisteredAllocator();
    }

    function toLock(address token, address allocator, uint48 resetPeriod)
        internal
        pure
        returns (Lock memory)
    {
        return Lock({ token: token, allocator: allocator, resetPeriod: uint256(resetPeriod) });
    }

    function toLock(uint256 id) internal view returns (Lock memory lock) {
        lock.token = id.toToken();
        lock.resetPeriod = id.toResetPeriod();
        lock.allocator = id.toAllocator();
    }

    function toId(Lock memory lock) internal returns (uint256 id) {
        id = (
            uint256(uint160(lock.token)) | ((lock.resetPeriod << 0xd0) >> 0x30)
                | lock.allocator.toIndex() << 0xd0
        );
    }

    function toIdIfRegistered(Lock memory lock) internal view returns (uint256 id) {
        id = (
            uint256(uint160(lock.token)) | ((lock.resetPeriod << 0xd0) >> 0x30)
                | lock.allocator.toIndexIfRegistered() << 0xd0
        );
    }

    function registeredAllocators() internal view returns (uint256 total) {
        assembly {
            total := sload(_REGISTERED_ALLOCATORS_SLOT)
        }
    }

    function toRegisteredAllocator(uint256 index) internal view returns (address allocator) {
        assembly {
            allocator := sload(or(_ALLOCATOR_BY_INDEX_SLOT_SEED, index))

            if iszero(allocator) {
                mstore(0, _NO_ALLOCATOR_REGISTERED_ERROR_SIGNATURE)
                mstore(0x20, index)
                revert(0x1c, 0x24)
            }
        }
    }

    function toIndex(address allocator) internal returns (uint256 index) {
        assembly {
            let indexSlot := or(_INDEX_BY_ALLOCATOR_SLOT_SEED, allocator)
            let indexWithOffset := sload(indexSlot)
            index := sub(indexWithOffset, 1)

            if iszero(indexWithOffset) {
                if iszero(allocator) {
                    mstore(0, _NO_ALLOCATOR_REGISTERED_ERROR_SIGNATURE)
                    mstore(0x20, index)
                    revert(0x1c, 0x24)
                }

                index := sload(_REGISTERED_ALLOCATORS_SLOT)
                indexWithOffset := add(index, 1)

                sstore(indexSlot, indexWithOffset)
                sstore(_REGISTERED_ALLOCATORS_SLOT, indexWithOffset)
                sstore(or(_ALLOCATOR_BY_INDEX_SLOT_SEED, index), allocator)

                mstore(0x00, index)
                mstore(0x20, allocator)
                log1(0x00, 0x40, _ALLOCATOR_REGISTERED_EVENT_SIGNATURE)
            }
        }
    }

    function toIndexIfRegistered(address allocator) internal view returns (uint256 index) {
        assembly {
            let indexSlot := or(_INDEX_BY_ALLOCATOR_SLOT_SEED, allocator)
            let indexWithOffset := sload(indexSlot)
            index := sub(indexWithOffset, 1)

            if iszero(indexWithOffset) {
                mstore(0, _NO_ALLOCATOR_REGISTERED_ERROR_SIGNATURE)
                mstore(0x20, index)
                revert(0x1c, 0x24)
            }
        }
    }
}

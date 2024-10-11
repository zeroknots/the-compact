// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";
import { Lock } from "../types/Lock.sol";
import { MetadataLib } from "./MetadataLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { SignatureCheckerLib } from "solady/utils/SignatureCheckerLib.sol";

library IdLib {
    using IdLib for uint96;
    using IdLib for uint256;
    using IdLib for address;
    using MetadataLib for Lock;
    using EfficiencyLib for uint8;
    using EfficiencyLib for uint96;
    using EfficiencyLib for uint256;
    using EfficiencyLib for address;
    using EfficiencyLib for ResetPeriod;
    using EfficiencyLib for Scope;
    using SignatureCheckerLib for address;

    error NoAllocatorRegistered(uint96 allocatorId);
    error AllocatorAlreadyRegistered(uint96 allocatorId, address allocator);

    uint256 private constant _ALLOCATOR_BY_ALLOCATOR_ID_SLOT_SEED =
        0x000044036fc77deaed2300000000000000000000000;
    uint256 private constant _ALLOCATOR_REGISTERED_EVENT_SIGNATURE =
        0xc54dcaa67a8fd7b4a9aa6fd57351934c792613d5ec1acbd65274270e6de8f7e4;
    uint256 private constant _NO_ALLOCATOR_REGISTERED_ERROR_SIGNATURE = 0xcf90c3a8;
    uint256 private constant _ALLOCATOR_ALREADY_REGISTERED_ERROR_SIGNATURE = 0xc18b0e97;

    function toToken(uint256 id) internal pure returns (address) {
        return id.asSanitizedAddress();
    }

    function withReplacedToken(uint256 id, address token)
        internal
        pure
        returns (uint256 updatedId)
    {
        assembly {
            updatedId := or(shl(160, shr(160, id)), shr(96, shl(96, token)))
        }
    }

    function toScope(uint256 id) internal pure returns (Scope scope) {
        assembly {
            // extract uppermost bit
            scope := shr(255, id)
        }
    }

    function toResetPeriod(uint256 id) internal pure returns (ResetPeriod resetPeriod) {
        assembly {
            // extract 2nd, 3rd & 4th uppermost bits
            resetPeriod := and(shr(252, id), 7)
        }
    }

    function toCompactFlag(uint256 id) internal pure returns (uint8 compactFlag) {
        assembly {
            // extract 5th, 6th, 7th & 8th uppermost bits
            compactFlag := and(shr(248, id), 15)
        }
    }

    function toAllocatorId(uint256 id) internal pure returns (uint96 allocatorId) {
        assembly {
            // extract bits 5-96
            allocatorId := shr(164, shl(4, id))
        }
    }

    // TODO: add a bit of extra time to pad 1 hour and 1 day values
    function toSeconds(ResetPeriod resetPeriod) internal pure returns (uint256 duration) {
        // note: no bounds check performed; ensure that the enum is in range
        assembly {
            // 278d00  093a80  015180  000e10  000258  00003c  00000f  000001
            // 30 days 7 days  1 day   1 hour  10 min  1 min   15 sec  1 sec
            let bitpacked := 0x278d00093a80015180000e1000025800003c00000f000001

            // shift right by period * 24 bits & mask the least significant 24 bits
            duration := and(shr(mul(resetPeriod, 24), bitpacked), 0xFFFFFF)
        }
    }

    function toAllocator(uint256 id) internal view returns (address allocator) {
        allocator = id.toAllocatorId().toRegisteredAllocator();
    }

    // The "compact flag" is a 4-bit value that represents how "compact" the address of
    // an allocator is. A fully "compact" allocator address will have nine leading zero
    // bytes, or 18 leading zero nibbles. To be considered even partially compact, the
    // account must have at least two leading zero bytes, or four leading zero nibbles.
    // The scoring formula is as follows:
    //  * 0-3 leading zero nibbles: 0
    //  * 4 leading zero nibbles: 1
    //  * 5 leading zero nibbles: 2
    //  * ...
    //  * 17 leading zero nibbles: 14
    //  * 18+ leading zero nibbles: 15
    function toCompactFlag(address allocator) internal pure returns (uint8 compactFlag) {
        assembly {
            // extract the uppermost 72 bits of the address
            let x := shr(168, shl(96, allocator))

            // propagate the highest set bit
            x := or(x, shr(1, x))
            x := or(x, shr(2, x))
            x := or(x, shr(4, x))
            x := or(x, shr(8, x))
            x := or(x, shr(16, x))
            x := or(x, shr(32, x))

            // count set bits to derive MSB in the last byte
            let y := sub(x, and(shr(1, x), 0x5555555555555555))
            y := add(and(y, 0x3333333333333333), and(shr(2, y), 0x3333333333333333))
            y := and(add(y, shr(4, y)), 0x0f0f0f0f0f0f0f0f)
            y := add(y, shr(8, y))
            y := add(y, shr(16, y))
            y := add(y, shr(32, y))

            // look up final value in the sequence
            compactFlag := and(shr(and(sub(72, and(y, 127)), not(3)), 0xfedcba9876543210000), 15)
        }
    }

    // this value is actually a uint92; 4 bits for the compact flag and 88 bits from the end
    // of the allocator's address.
    function usingAllocatorId(address allocator) internal pure returns (uint96 allocatorId) {
        uint8 compactFlag = allocator.toCompactFlag();

        assembly {
            allocatorId := or(shl(88, compactFlag), shr(168, shl(168, allocator)))
        }
    }

    function toLock(address token, address allocator, ResetPeriod resetPeriod, Scope scope)
        internal
        pure
        returns (Lock memory)
    {
        return Lock({ token: token, allocator: allocator, resetPeriod: resetPeriod, scope: scope });
    }

    function toLock(uint256 id) internal view returns (Lock memory lock) {
        lock.token = id.toToken();
        lock.allocator = id.toAllocator();
        lock.resetPeriod = id.toResetPeriod();
        lock.scope = id.toScope();
    }

    // first bit: scope
    // bits 2-4: reset period
    // bits 5-96: allocator ID (first 4 bits are compact flag, next 88 from allocator address)
    // bits 97-256: token
    // note that this will return an ID even if the allocator is unregistered
    function toId(Lock memory lock) internal pure returns (uint256 id) {
        id = (
            (lock.scope.asUint256() << 255) | (lock.resetPeriod.asUint256() << 252)
                | (lock.allocator.usingAllocatorId().asUint256() << 160) | lock.token.asUint256()
        );
    }

    function toIdIfRegistered(
        address token,
        Scope scope,
        ResetPeriod resetPeriod,
        address allocator
    ) internal view returns (uint256 id) {
        uint96 allocatorId = allocator.usingAllocatorId();
        allocatorId.mustHaveARegisteredAllocator();
        id = (
            (scope.asUint256() << 255) | (resetPeriod.asUint256() << 252)
                | (allocatorId.asUint256() << 160) | token.asUint256()
        );
    }

    function toRegisteredAllocator(uint96 allocatorId) internal view returns (address allocator) {
        assembly {
            // NOTE: consider an SLOAD bypass for a fully compact allocator

            allocator := sload(or(_ALLOCATOR_BY_ALLOCATOR_ID_SLOT_SEED, allocatorId))

            if iszero(allocator) {
                mstore(0, _NO_ALLOCATOR_REGISTERED_ERROR_SIGNATURE)
                mstore(0x20, allocatorId)
                revert(0x1c, 0x24)
            }
        }
    }

    function toRegisteredAllocatorId(uint256 id) internal view returns (uint96 allocatorId) {
        allocatorId = id.toAllocatorId();
        allocatorId.mustHaveARegisteredAllocator();
    }

    function mustHaveARegisteredAllocator(uint96 allocatorId) internal view {
        assembly {
            // NOTE: consider an SLOAD bypass for a fully compact allocator
            if iszero(sload(or(_ALLOCATOR_BY_ALLOCATOR_ID_SLOT_SEED, allocatorId))) {
                mstore(0, _NO_ALLOCATOR_REGISTERED_ERROR_SIGNATURE)
                mstore(0x20, allocatorId)
                revert(0x1c, 0x24)
            }
        }
    }

    function canBeRegistered(address allocator, bytes calldata proof)
        internal
        view
        returns (bool)
    {
        // TODO: optimize
        return (msg.sender == allocator)
            || (
                proof.length == 86 && proof[0] == 0xff
                    && allocator == address(uint160(uint256(keccak256(proof))))
            )
            || (
                proof.length > 31
                    && allocator.isValidSignatureNow(abi.decode(proof[0:32], (bytes32)), proof[32:])
            );
    }

    function register(address allocator) internal returns (uint96 allocatorId) {
        allocatorId = allocator.usingAllocatorId();

        assembly {
            let allocatorSlot := or(_ALLOCATOR_BY_ALLOCATOR_ID_SLOT_SEED, allocatorId)

            let registeredAllocator := sload(allocatorSlot)

            if registeredAllocator {
                mstore(0, _ALLOCATOR_ALREADY_REGISTERED_ERROR_SIGNATURE)
                mstore(0x20, allocatorId)
                mstore(0x40, registeredAllocator)
                revert(0x1c, 0x44)
            }

            sstore(allocatorSlot, allocator)

            mstore(0x00, allocatorId)
            mstore(0x20, allocator)
            log1(0x00, 0x40, _ALLOCATOR_REGISTERED_EVENT_SIGNATURE)
        }
    }
}

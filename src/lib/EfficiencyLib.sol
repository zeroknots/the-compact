// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Scope } from "../types/Scope.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";

library EfficiencyLib {
    // NOTE: this function is only safe if the supplied booleans are known to not
    // have any dirty bits set (i.e. they are either 0 or 1). It is meant to get
    // around the fact that solidity only evaluates both expressions in an && if
    // the first expression evaluates to true, which requires a conditional jump.
    function and(bool a, bool b) internal pure returns (bool c) {
        assembly ("memory-safe") {
            c := and(a, b)
        }
    }

    // NOTE: this function is only safe if the supplied booleans are known to not
    // have any dirty bits set (i.e. they are either 0 or 1). It is meant to get
    // around the fact that solidity only evaluates both expressions in an || if
    // the first expression evaluates to false, which requires a conditional jump.
    function or(bool a, bool b) internal pure returns (bool c) {
        assembly ("memory-safe") {
            c := or(a, b)
        }
    }

    // NOTE: this function is only safe if the supplied uint256 is known to not
    // have any dirty bits set (i.e. it is either 0 or 1).
    function asBool(uint256 a) internal pure returns (bool b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    function asSanitizedAddress(uint256 accountValue) internal pure returns (address account) {
        // extract last 160 bits (can also just use a mask if contract size permits)
        assembly ("memory-safe") {
            account := shr(96, shl(96, accountValue))
        }
    }

    function isNullAddress(address account) internal pure returns (bool isNull) {
        assembly ("memory-safe") {
            isNull := iszero(shl(96, account))
        }
    }

    function asUint256(bool a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    function asUint256(uint8 a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    function asUint256(uint96 a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    function asUint256(Scope a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    function asUint256(address a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    function asUint256(ResetPeriod a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }
}

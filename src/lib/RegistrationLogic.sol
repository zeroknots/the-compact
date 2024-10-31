// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { EfficiencyLib } from "./EfficiencyLib.sol";

contract RegistrationLogic {
    using EfficiencyLib for uint256;

    /// @dev `keccak256(bytes("CompactRegistered(address,bytes32,bytes32,uint256)"))`.
    uint256 private constant _COMPACT_REGISTERED_SIGNATURE = 0xf78a2f33ff80ef4391f7449c748dc2d577a62cd645108f4f4069f4a7e0635b6a;

    // slot: keccak256(_ACTIVE_REGISTRATIONS_SCOPE ++ sponsor ++ claimHash ++ typehash) => expires
    uint256 private constant _ACTIVE_REGISTRATIONS_SCOPE = 0x68a30dd0;

    function _register(address sponsor, bytes32 claimHash, bytes32 typehash, uint256 duration) internal {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(add(m, 0x14), sponsor)
            mstore(m, _ACTIVE_REGISTRATIONS_SCOPE)
            mstore(add(m, 0x34), claimHash)
            mstore(add(m, 0x54), typehash)
            let cutoffSlot := keccak256(add(m, 0x1c), 0x58)

            let expires := add(timestamp(), duration)
            if or(lt(expires, sload(cutoffSlot)), gt(duration, 0x278d00)) {
                // revert InvalidRegistrationDuration(uint256 duration)
                mstore(0, 0x1f9a96f4)
                mstore(0x20, duration)
                revert(0x1c, 0x24)
            }

            sstore(cutoffSlot, expires)
            mstore(add(m, 0x74), expires)
            log2(add(m, 0x34), 0x60, _COMPACT_REGISTERED_SIGNATURE, shr(0x60, shl(0x60, sponsor)))
        }
    }

    function _registerWithDefaults(bytes32 claimHash, bytes32 typehash) internal {
        _register(msg.sender, claimHash, typehash, uint256(0x258).asStubborn());
    }

    function _registerBatch(bytes32[2][] calldata claimHashesAndTypehashes, uint256 duration) internal returns (bool) {
        unchecked {
            uint256 totalClaimHashes = claimHashesAndTypehashes.length;
            for (uint256 i = 0; i < totalClaimHashes; ++i) {
                bytes32[2] calldata claimHashAndTypehash = claimHashesAndTypehashes[i];
                _register(msg.sender, claimHashAndTypehash[0], claimHashAndTypehash[1], duration);
            }
        }

        return true;
    }

    function _getRegistrationStatus(address sponsor, bytes32 claimHash, bytes32 typehash) internal view returns (uint256 expires) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(add(m, 0x14), sponsor)
            mstore(m, _ACTIVE_REGISTRATIONS_SCOPE)
            mstore(add(m, 0x34), claimHash)
            mstore(add(m, 0x54), typehash)
            expires := sload(keccak256(add(m, 0x1c), 0x58))
        }
    }
}

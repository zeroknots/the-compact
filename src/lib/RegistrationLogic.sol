// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { RegistrationLib } from "./RegistrationLib.sol";

/**
 * @title RegistrationLogic
 * @notice Inherited contract implementing logic for registering compact claim hashes
 * and typehashes and querying for whether given claim hashes and typehashes have
 * been registered.
 */
contract RegistrationLogic {
    using RegistrationLib for address;
    using RegistrationLib for bytes32;
    using RegistrationLib for bytes32[2][];

    function _register(address sponsor, bytes32 claimHash, bytes32 typehash, uint256 duration) internal {
        sponsor.registerCompactWithSpecificDuration(claimHash, typehash, duration);
    }

    function _registerWithDefaults(bytes32 claimHash, bytes32 typehash) internal {
        claimHash.registerAsCallerWithDefaultDuration(typehash);
    }

    function _registerBatch(bytes32[2][] calldata claimHashesAndTypehashes, uint256 duration) internal returns (bool) {
        return claimHashesAndTypehashes.registerBatchAsCaller(duration);
    }

    function _getRegistrationStatus(address sponsor, bytes32 claimHash, bytes32 typehash) internal view returns (uint256 expires) {
        return sponsor.toRegistrationExpiration(claimHash, typehash);
    }
}

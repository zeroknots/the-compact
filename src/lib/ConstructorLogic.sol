// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Lock } from "../types/Lock.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

import { HashLib } from "./HashLib.sol";
import { IdLib } from "./IdLib.sol";
import { MetadataRenderer } from "./MetadataRenderer.sol";

import { Tstorish } from "tstorish/Tstorish.sol";

contract ConstructorLogic is Tstorish {
    using HashLib for bytes32;
    using HashLib for uint256;
    using IdLib for uint256;

    address private constant _PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    uint256 private constant _REENTRANCY_GUARD_SLOT = 0x929eee149b4bd21268;

    uint256 private immutable _INITIAL_CHAIN_ID;
    bytes32 private immutable _INITIAL_DOMAIN_SEPARATOR;
    MetadataRenderer private immutable _METADATA_RENDERER;
    bool private immutable _PERMIT2_INITIALLY_DEPLOYED;

    constructor() {
        _INITIAL_CHAIN_ID = block.chainid;
        _INITIAL_DOMAIN_SEPARATOR = block.chainid.toNotarizedDomainSeparator();
        _METADATA_RENDERER = new MetadataRenderer();
        _PERMIT2_INITIALLY_DEPLOYED = _checkPermit2Deployment();
    }

    function _setReentrancyGuard() internal {
        _setTstorish(_REENTRANCY_GUARD_SLOT, 1);
    }

    function _clearReentrancyGuard() internal {
        _clearTstorish(_REENTRANCY_GUARD_SLOT);
    }

    function _isPermit2Deployed() internal view returns (bool) {
        if (_PERMIT2_INITIALLY_DEPLOYED) {
            return true;
        }

        return _checkPermit2Deployment();
    }

    function _domainSeparator() internal view returns (bytes32) {
        return _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
    }

    /// @dev Returns the symbol for token `id`.
    function _name(uint256 id) internal view returns (string memory) {
        return _METADATA_RENDERER.name(id);
    }

    /// @dev Returns the symbol for token `id`.
    function _symbol(uint256 id) internal view returns (string memory) {
        return _METADATA_RENDERER.symbol(id);
    }

    /// @dev Returns the Uniform Resource Identifier (URI) for token `id`.
    function _tokenURI(uint256 id) internal view returns (string memory) {
        return _METADATA_RENDERER.uri(id.toLock(), id);
    }

    function _checkPermit2Deployment() private view returns (bool permit2Deployed) {
        assembly ("memory-safe") {
            permit2Deployed := iszero(iszero(extcodesize(_PERMIT2)))
        }
    }
}

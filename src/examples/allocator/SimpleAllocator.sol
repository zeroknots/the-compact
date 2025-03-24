// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { IAllocator } from "../../interfaces/IAllocator.sol";

contract SimpleAllocator is IAllocator {
    address public signer;

    constructor(address _signer) {
        signer = _signer;
        // TODO: set The Compact and verify it's the caller on other fns
    }

    function attest(address, address, address, uint256, uint256) external pure returns (bytes4) {
        revert("unimplemented");
    }

    function authorizeClaim(
        bytes32 claimHash, // The message hash representing the claim.
        address arbiter, // The account tasked with verifying and submitting the claim.
        address sponsor, // The account to source the tokens from.
        uint256 nonce, // A parameter to enforce replay protection, scoped to allocator.
        uint256 expires, // The time at which the claim expires.
        uint256[2][] calldata idsAndAmounts, // The allocated token IDs and amounts.
        bytes calldata allocatorData // Arbitrary data provided by the arbiter.
    ) external pure returns (bytes4) {
        claimHash;
        arbiter;
        sponsor;
        nonce;
        expires;
        idsAndAmounts;
        allocatorData;

        // TODO: use signer
        return this.authorizeClaim.selector;
    }
}

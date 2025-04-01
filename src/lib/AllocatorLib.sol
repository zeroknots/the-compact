// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { IAllocator } from "../interfaces/IAllocator.sol";

library AllocatorLib {
    error InvalidAllocation(address allocator);

    function callAuthorizeClaim(address allocator, bytes32 claimHash, address sponsor, uint256 nonce, uint256 expires, uint256[2][] memory idsAndAmounts, bytes calldata allocatorData) internal {
        // TODO: optimize this
        bytes4 magicValue = IAllocator(allocator).authorizeClaim(
            claimHash,
            msg.sender, // arbiter
            sponsor,
            nonce,
            expires,
            idsAndAmounts,
            allocatorData
        );

        if (magicValue != IAllocator.authorizeClaim.selector) {
            revert InvalidAllocation(allocator);
        }
    }
}

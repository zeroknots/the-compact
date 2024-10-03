// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IAllocator {
    // Called on standard transfers; must return this function selector.
    function attest(address from, address to, uint256 id, uint256 amount) external returns (bytes4);
}

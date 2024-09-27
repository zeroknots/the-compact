// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

struct Lock {
    address token;
    address allocator;
    uint256 resetPeriod;
}

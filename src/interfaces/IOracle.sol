// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IOracle {
    function attest(bytes32 allocationHash, bytes calldata fixedData, bytes calldata variableData)
        external
        returns (address claimant, uint256 claimAmount);
}

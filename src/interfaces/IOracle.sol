// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IOracle {
    // Called on claims referencing a single allocated token.
    function attest(bytes32 allocationHash, bytes calldata fixedData, bytes calldata variableData)
        external
        returns (address claimant, uint256 claimAmount);

    // Called on claims referencing an array of allocated tokens.
    function attestBatch(bytes32 allocationHash, bytes calldata fixedData, bytes calldata variableData)
        external
        returns (address claimant, uint256[] memory claimAmounts);
}

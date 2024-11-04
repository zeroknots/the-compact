// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BatchTransfer, SplitBatchTransfer } from "../types/BatchClaims.sol";
import { BasicTransfer, SplitTransfer } from "../types/Claims.sol";
import { TransferComponent, SplitByIdComponent } from "../types/Components.sol";

/**
 * @title TransferLogicFunctionCastLib
 * @notice Libray contract implementing function casts used in TransferLogic.
 * The input function operates on a function that takes some argument that differs
 * from what is currently available. The output function modifies one or more argument
 * types so that they match the arguments that are being used to call the function.
 * Note that from the perspective of the function being modified, the original type is
 * still in force; great care should be taken to preserve offsets and general structure
 * between the two structs.
 */
library TransferLogicFunctionCastLib {
    /**
     * @notice Function cast to provide a SplitTransfer calldata struct while
     * treating it as a BasicTransfer calldata struct.
     * @param fnIn   Function pointer to `_notExpiredAndSignedByAllocator`.
     * @return fnOut Modified function used in `_processSplitTransfer`.
     */
    function usingSplitTransfer(function (bytes32, address, BasicTransfer calldata) internal fnIn) internal pure returns (function (bytes32, address, SplitTransfer calldata) internal fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchTransfer calldata struct while
     * treating it as a BasicTransfer calldata struct.
     * @param fnIn   Function pointer to `_notExpiredAndSignedByAllocator`.
     * @return fnOut Modified function used in `_processBatchTransfer`.
     */
    function usingBatchTransfer(function (bytes32, address, BasicTransfer calldata) internal fnIn) internal pure returns (function (bytes32, address, BatchTransfer calldata) internal fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitBatchTransfer calldata struct while
     * treating it as a BasicTransfer calldata struct.
     * @param fnIn   Function pointer to `_notExpiredAndSignedByAllocator`.
     * @return fnOut Modified function used in `_processSplitBatchTransfer`.
     */
    function usingSplitBatchTransfer(function (bytes32, address, BasicTransfer calldata) internal fnIn)
        internal
        pure
        returns (function (bytes32, address, SplitBatchTransfer calldata) internal fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitByIdComponent array while treating it
     * as a TransferComponent array.
     * @param fnIn   Function pointer to `_deriveConsistentAllocatorAndConsumeNonce`.
     * @return fnOut Modified function used in `_processSplitBatchTransfer`.
     */
    function usingSplitByIdComponent(function(TransferComponent[] calldata, uint256, function (TransferComponent[] calldata, uint256) internal pure returns (uint96)) internal returns (address) fnIn)
        internal
        pure
        returns (function(SplitByIdComponent[] calldata, uint256, function (SplitByIdComponent[] calldata, uint256) internal pure returns (uint96)) internal returns (address) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }
}

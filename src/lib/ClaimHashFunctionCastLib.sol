// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BasicClaim, ClaimWithWitness, SplitClaim, SplitClaimWithWitness } from "../types/Claims.sol";

import {
    BatchClaim,
    BatchClaimWithWitness,
    SplitBatchClaim,
    SplitBatchClaimWithWitness
} from "../types/BatchClaims.sol";

import {
    MultichainClaim,
    MultichainClaimWithWitness,
    SplitMultichainClaim,
    SplitMultichainClaimWithWitness,
    ExogenousMultichainClaim,
    ExogenousMultichainClaimWithWitness,
    ExogenousSplitMultichainClaim,
    ExogenousSplitMultichainClaimWithWitness
} from "../types/MultichainClaims.sol";

import {
    BatchMultichainClaim,
    BatchMultichainClaimWithWitness,
    SplitBatchMultichainClaim,
    SplitBatchMultichainClaimWithWitness,
    ExogenousBatchMultichainClaim,
    ExogenousBatchMultichainClaimWithWitness,
    ExogenousSplitBatchMultichainClaim,
    ExogenousSplitBatchMultichainClaimWithWitness
} from "../types/BatchMultichainClaims.sol";

/**
 * @title ClaimHashFunctionCastLib
 * @notice Library contract implementing function casts used throughout the codebase,
 * particularly as part of processing claims. The input function operates on a
 * function that takes some argument that differs from what is currently available.
 * The output function modifies one or more argument types so that they match the
 * arguments that are being used to call the function. Note that from the perspective
 * of the function being modified, the original type is still in force; great care
 * should be taken to preserve offsets and general structure between the two structs.
 * @dev Note that some of these function casts may no longer be in use.
 */
library ClaimHashFunctionCastLib {
    /**
     * @notice Function cast to provide a BasicClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib._toBasicMessageHash`.
     */
    function usingBasicClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BasicClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitClaim calldata struct while
     * treating it as a BasicClaim calldata struct.
     * @param fnIn   Function pointer to `ClaimHashLib._toBasicMessageHash(BasicClaim calldata)`.
     * @return fnOut Modified function used in `ClaimHashLib.toClaimHash(SplitClaim calldata)`.
     */
    function usingSplitClaim(function (BasicClaim calldata) internal view returns (bytes32) fnIn) internal pure returns (function (SplitClaim calldata) internal view returns (bytes32) fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib._toBasicMessageHash(BatchClaim calldata)`.
     */
    function usingBatchClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitBatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toClaimHash(SplitBatchClaim calldata)`.
     */
    function usingSplitBatchClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib._toMultichainMessageHash(MultichainClaim calldata)`.
     */
    function usingMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (MultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitMultichainClaim calldata struct while
     * treating it as a MultichainClaim calldata struct.
     * @param fnIn   Function pointer to `ClaimHashLib._toMultichainMessageHash(MultichainClaim calldata)`.
     * @return fnOut Modified function used in `ClaimHashLib.toClaimHash(SplitMultichainClaim calldata)`.
     */
    function usingSplitMultichainClaim(function (MultichainClaim calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaim calldata) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toClaimHash(BatchMultichainClaim calldata)`.
     */
    function usingBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toClaimHash(SplitBatchMultichainClaim calldata)`.
     */
    function usingSplitBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toClaimHash(ExogenousMultichainClaim calldata)`.
     */
    function usingExogenousMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousSplitMultichainClaim calldata struct while
     * treating it as an ExogenousMultichainClaim calldata struct.
     * @param fnIn   Function pointer to `ClaimHashLib._toExogenousMultichainMessageHash(ExogenousMultichainClaim calldata)`.
     * @return fnOut Modified function used in `ClaimHashLib.toClaimHash(ExogenousSplitMultichainClaim calldata)`.
     */
    function usingExogenousSplitMultichainClaim(function (ExogenousMultichainClaim calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaim calldata) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toClaimHash(ExogenousBatchMultichainClaim calldata)`.
     */
    function usingExogenousBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousSplitBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toClaimHash(ExogenousSplitBatchMultichainClaim calldata)`.
     */
    function usingExogenousSplitBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(MultichainClaimWithWitness calldata)`.
     */
    function usingMultichainClaimWithWitness(function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (MultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitMultichainClaimWithWitness calldata struct while
     * treating it as a MultichainClaimWithWitness calldata struct.
     * @param fnIn   Function pointer to `ClaimHashLib._toMultichainClaimWithWitnessMessageHash(MultichainClaimWithWitness calldata)`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(MultichainClaimWithWitness calldata)`.
     */
    function usingSplitMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(BatchMultichainClaimWithWitness calldata)`.
     */
    function usingBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (BatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitBatchMultichainClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(SplitBatchMultichainClaimWithWitness calldata)`.
     */
    function usingSplitBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (SplitBatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousMultichainClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(ExogenousMultichainClaimWithWitness calldata)`.
     */
    function usingExogenousMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (ExogenousMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousSplitMultichainClaimWithWitness calldata
     * struct while treating it as an ExogenousMultichainClaimWithWitness calldata struct.
     * @param fnIn   Function pointer to `ClaimHashLib._toExogenousMultichainClaimWithWitnessMessageHash(ExogenousMultichainClaimWithWitness calldata)`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(ExogenousSplitMultichainClaimWithWitness calldata)`.
     */
    function usingExogenousSplitMultichainClaimWithWitness(function (ExogenousMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousBatchMultichainClaimWithWitness calldata
     * struct while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(ExogenousBatchMultichainClaimWithWitness calldata)`.
     */
    function usingExogenousBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (ExogenousBatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousSplitBatchMultichainClaimWithWitness calldata
     * struct while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(ExogenousSplitBatchMultichainClaimWithWitness calldata)`.
     */
    function usingExogenousSplitBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (ExogenousSplitBatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `HashLib.toMessageHashWithWitness(uint256, uint256)`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(ClaimWithWitness calldata)`.
     */
    function usingClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `HashLib.toMessageHashWithWitness(uint256, uint256)`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(SplitClaimWithWitness calldata)`.
     */
    function usingSplitClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `HashLib.toMessageHashWithWitness(uint256, uint256)`.
     * @return fnOut Modified function used in `ClaimHashLib.toMessageHashes(BatchClaimWithWitness calldata)`.
     */
    function usingBatchClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (BatchClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitBatchClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `HashLib.toMessageHashWithWitness(uint256, uint256)`.
     * @return fnOut Modified function used in `SplitBatchClaimWithWitness.toMessageHashes(BatchClaimWithWitness calldata)`.
     */
    function usingSplitBatchClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toMultichainMessageHash(MultichainClaim calldata)`.
     * @return fnOut Modified function used in `ClaimHashLib._toMultichainMessageHash(MultichainClaim calldata)`.
     */
    function usingMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn) internal pure returns (function (MultichainClaim calldata, uint256) internal pure returns (uint256) fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toMultichainClaimWithWitnessMessageHash(MultichainClaimWithWitness calldata)`.
     * @return fnOut Modified function used in `ClaimHashLib._toMultichainClaimWithWitnessMessageHash(MultichainClaimWithWitness calldata)`.
     */
    function usingMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (MultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toExogenousMultichainClaimWithWitnessMessageHash(ExogenousMultichainClaimWithWitness calldata)`.
     * @return fnOut Modified function used in `ClaimHashLib._toExogenousMultichainClaimWithWitnessMessageHash(ExogenousMultichainClaimWithWitness calldata)`.
     */
    function usingExogenousMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toExogenousMultichainMessageHash(ExogenousMultichainClaim calldata)`.
     * @return fnOut Modified function used in `ClaimHashLib._toExogenousMultichainMessageHash(ExogenousMultichainClaim calldata)`.
     */
    function usingExogenousMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }
}

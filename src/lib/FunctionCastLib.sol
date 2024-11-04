// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {
    BasicTransfer,
    SplitTransfer,
    BasicClaim,
    QualifiedClaim,
    ClaimWithWitness,
    QualifiedClaimWithWitness,
    SplitClaim,
    SplitClaimWithWitness,
    QualifiedSplitClaim,
    QualifiedSplitClaimWithWitness
} from "../types/Claims.sol";

import {
    BatchTransfer,
    SplitBatchTransfer,
    BatchClaim,
    QualifiedBatchClaim,
    BatchClaimWithWitness,
    QualifiedBatchClaimWithWitness,
    SplitBatchClaim,
    SplitBatchClaimWithWitness,
    QualifiedSplitBatchClaim,
    QualifiedSplitBatchClaimWithWitness
} from "../types/BatchClaims.sol";

import {
    MultichainClaim,
    QualifiedMultichainClaim,
    MultichainClaimWithWitness,
    QualifiedMultichainClaimWithWitness,
    SplitMultichainClaim,
    SplitMultichainClaimWithWitness,
    QualifiedSplitMultichainClaim,
    QualifiedSplitMultichainClaimWithWitness,
    ExogenousMultichainClaim,
    ExogenousQualifiedMultichainClaim,
    ExogenousMultichainClaimWithWitness,
    ExogenousQualifiedMultichainClaimWithWitness,
    ExogenousSplitMultichainClaim,
    ExogenousSplitMultichainClaimWithWitness,
    ExogenousQualifiedSplitMultichainClaim,
    ExogenousQualifiedSplitMultichainClaimWithWitness
} from "../types/MultichainClaims.sol";

import {
    BatchMultichainClaim,
    QualifiedBatchMultichainClaim,
    BatchMultichainClaimWithWitness,
    QualifiedBatchMultichainClaimWithWitness,
    SplitBatchMultichainClaim,
    SplitBatchMultichainClaimWithWitness,
    QualifiedSplitBatchMultichainClaim,
    QualifiedSplitBatchMultichainClaimWithWitness,
    ExogenousBatchMultichainClaim,
    ExogenousQualifiedBatchMultichainClaim,
    ExogenousBatchMultichainClaimWithWitness,
    ExogenousQualifiedBatchMultichainClaimWithWitness,
    ExogenousSplitBatchMultichainClaim,
    ExogenousSplitBatchMultichainClaimWithWitness,
    ExogenousQualifiedSplitBatchMultichainClaim,
    ExogenousQualifiedSplitBatchMultichainClaimWithWitness
} from "../types/BatchMultichainClaims.sol";

import { TransferComponent, SplitByIdComponent, BatchClaimComponent, SplitBatchClaimComponent } from "../types/Components.sol";

/**
 * @title FunctionCastLib
 * @notice Libray contract implementing function casts used throughout the codebase,
 * particularly as part of processing claims. The input function operates on a
 * function that takes some argument that differs from what is currently available.
 * The output function modifies one or more argument types so that they match the
 * arguments that are being used to call the function. Note that from the perspective
 * of the function being modified, the original type is still in force; great care
 * should be taken to preserve offsets and general structure between the two structs.
 * @dev Note that some of these function casts may no longer be in use.
 */
library FunctionCastLib {
    /**
     * @notice Function cast to provide a BasicClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHash
     * @return fnOut Modified function for ClaimHashLib._toBasicMessageHash
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
     * @param fnIn   Function pointer to ClaimHashLib._toBasicMessageHash(BasicClaim calldata)
     * @return fnOut Modified function for ClaimHashLib.toClaimHash(SplitClaim calldata)
     */
    function usingSplitClaim(function (BasicClaim calldata) internal view returns (bytes32) fnIn) internal pure returns (function (SplitClaim calldata) internal view returns (bytes32) fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHash
     * @return fnOut Modified function for ClaimHashLib._toBasicMessageHash(BatchClaim calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHash
     * @return fnOut Modified function for ClaimHashLib.toClaimHash(SplitBatchClaim calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHash
     * @return fnOut Modified function for ClaimHashLib._toMultichainMessageHash(MultichainClaim calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toMultichainMessageHash(MultichainClaim calldata)
     * @return fnOut Modified function for ClaimHashLib.toClaimHash(SplitMultichainClaim calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHash
     * @return fnOut Modified function for ClaimHashLib.toClaimHash(BatchMultichainClaim calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHash
     * @return fnOut Modified function for ClaimHashLib.toClaimHash(SplitBatchMultichainClaim calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHash
     * @return fnOut Modified function for ClaimHashLib.toClaimHash(ExogenousMultichainClaim calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toExogenousMultichainMessageHash(ExogenousMultichainClaim calldata)
     * @return fnOut Modified function for ClaimHashLib.toClaimHash(ExogenousSplitMultichainClaim calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHash
     * @return fnOut Modified function for ClaimHashLib.toClaimHash(ExogenousBatchMultichainClaim calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHash
     * @return fnOut Modified function for ClaimHashLib.toClaimHash(ExogenousSplitBatchMultichainClaim calldata)
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
     * @notice Function cast to provide a QualifiedClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHashWithQualificationHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedClaim calldata)
     */
    function usingQualifiedClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitClaim calldata struct while
     * treating it as a QualifiedClaim calldata struct.
     * @param fnIn   Function pointer to ClaimHashLib._toQualifiedMessageHash(QualifiedClaim calldata)
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedSplitClaim calldata)
     */
    function usingQualifiedSplitClaim(function (QualifiedClaim calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitClaim calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedBatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHashWithQualificationHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedBatchClaim calldata)
     */
    function usingQualifiedBatchClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitBatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHashWithQualificationHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedSplitBatchClaim calldata)
     */
    function usingQualifiedSplitBatchClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHashWithQualificationHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedMultichainClaim calldata)
     */
    function usingQualifiedMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitMultichainClaim calldata struct while
     * treating it as a QualifiedMultichainClaim calldata struct.
     * @param fnIn   Function pointer to ClaimHashLib._toQualifiedMultichainMessageHash(QualifiedMultichainClaim calldata)
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedSplitMultichainClaim calldata)
     */
    function usingQualifiedSplitMultichainClaim(function (QualifiedMultichainClaim calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaim calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHashWithQualificationHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedBatchMultichainClaim calldata)
     */
    function usingQualifiedBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHashWithQualificationHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedSplitBatchMultichainClaim calldata)
     */
    function usingQualifiedSplitBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousQualifiedMultichainClaim calldata struct
     * while treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHashWithQualificationHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousQualifiedMultichainClaim calldata)
     */
    function usingExogenousQualifiedMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousQualifiedSplitMultichainClaim calldata
     * struct while treating it as an ExogenousQualifiedMultichainClaim calldata struct.
     * @param fnIn   Function pointer to ClaimHashLib._toExogenousQualifiedMultichainMessageHash(ExogenousQualifiedMultichainClaim calldata)
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousQualifiedSplitMultichainClaim calldata)
     */
    function usingExogenousQualifiedSplitMultichainClaim(function (ExogenousQualifiedMultichainClaim calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaim calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousQualifiedBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHashWithQualificationHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousQualifiedBatchMultichainClaim calldata)
     */
    function usingExogenousQualifiedBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousQualifiedSplitBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMessageHashWithQualificationHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousQualifiedSplitBatchMultichainClaim calldata)
     */
    function usingExogenousQualifiedSplitBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(MultichainClaimWithWitness calldata)
     */
    function usingMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (MultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitMultichainClaimWithWitness calldata struct while
     * treating it as a MultichainClaimWithWitness calldata struct.
     * @param fnIn   Function pointer to ClaimHashLib._toMultichainClaimWithWitnessMessageHash(MultichainClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(MultichainClaimWithWitness calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(BatchMultichainClaimWithWitness calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(SplitBatchMultichainClaimWithWitness calldata)
     */
    function usingSplitBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (SplitBatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousMultichainClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousMultichainClaimWithWitness calldata)
     */
    function usingExogenousMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (ExogenousMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousSplitMultichainClaimWithWitness calldata
     * struct while treating it as an ExogenousMultichainClaimWithWitness calldata struct.
     * @param fnIn   Function pointer to ClaimHashLib._toExogenousMultichainClaimWithWitnessMessageHash(ExogenousMultichainClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousSplitMultichainClaimWithWitness calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousBatchMultichainClaimWithWitness calldata)
     */
    function usingExogenousBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (ExogenousBatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousSplitBatchMultichainClaimWithWitness calldata
     * struct while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousSplitBatchMultichainClaimWithWitness calldata)
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
     * @notice Function cast to provide a QualifiedClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericQualifiedClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedClaimWithWitness calldata)
     */
    function usingQualifiedClaimWithWitness(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32, bytes32)) internal view returns (bytes32, bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedClaimWithWitness calldata, uint256, function(uint256, uint256) internal view returns (bytes32, bytes32)) internal view returns (bytes32, bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitClaimWithWitness calldata struct while
     * treating it as a QualifiedClaimWithWitness calldata struct.
     * @param fnIn   Function pointer to ClaimHashLib._toQualifiedClaimWithWitnessMessageHash(QualifiedClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedSplitClaimWithWitness calldata)
     */
    function usingQualifiedSplitClaimWithWitness(function (QualifiedClaimWithWitness calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitClaimWithWitness calldata) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedBatchClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericQualifiedClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedBatchClaimWithWitness calldata)
     */
    function usingQualifiedBatchClaimWithWitness(
        function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32, bytes32)) internal view returns (bytes32, bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (QualifiedBatchClaimWithWitness calldata, uint256, function(uint256, uint256) internal view returns (bytes32, bytes32)) internal view returns (bytes32, bytes32, bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitBatchClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericQualifiedClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedSplitBatchClaimWithWitness calldata)
     */
    function usingQualifiedSplitBatchClaimWithWitness(
        function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32, bytes32)) internal view returns (bytes32, bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (QualifiedSplitBatchClaimWithWitness calldata, uint256, function(uint256, uint256) internal view returns (bytes32, bytes32)) internal view returns (bytes32, bytes32, bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedMultichainClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericQualifiedMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedMultichainClaimWithWitness calldata)
     */
    function usingQualifiedMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (QualifiedMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitMultichainClaimWithWitness calldata struct
     * while treating it as a QualifiedMultichainClaimWithWitness calldata struct.
     * @param fnIn   Function pointer to ClaimHashLib._toQualifiedMultichainClaimWithWitnessMessageHash(QualifiedMultichainClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedSplitMultichainClaimWithWitness calldata)
     */
    function usingQualifiedSplitMultichainClaimWithWitness(function (QualifiedMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedBatchMultichainClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericQualifiedMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedBatchMultichainClaimWithWitness calldata)
     */
    function usingQualifiedBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (QualifiedBatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitBatchMultichainClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericQualifiedMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedSplitBatchMultichainClaimWithWitness calldata)
     */
    function usingQualifiedSplitBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (QualifiedSplitBatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousQualifiedMultichainClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericQualifiedMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousQualifiedMultichainClaimWithWitness calldata)
     */
    function usingExogenousQualifiedMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (ExogenousQualifiedMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousQualifiedSplitMultichainClaimWithWitness calldata struct
     * while treating it as an ExogenousQualifiedMultichainClaimWithWitness calldata struct.
     * @param fnIn   Function pointer to ClaimHashLib._toExogenousQualifiedMultichainClaimWithWitnessMessageHash(ExogenousQualifiedMultichainClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousQualifiedSplitMultichainClaimWithWitness calldata)
     */
    function usingExogenousQualifiedSplitMultichainClaimWithWitness(function (ExogenousQualifiedMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousQualifiedBatchMultichainClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericQualifiedMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousQualifiedBatchMultichainClaimWithWitness calldata)
     */
    function usingExogenousQualifiedBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (ExogenousQualifiedBatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata struct
     * while treating it as a uint256 representing a calldata pointer location with witness data.
     * @param fnIn   Function pointer to ClaimHashLib._toGenericQualifiedMultichainClaimWithWitnessMessageHash
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata)
     */
    function usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BasicClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processSimpleClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processBasicClaim
     */
    function usingBasicClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            BasicClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedClaim
     */
    function usingQualifiedClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processClaimWithWitness
     */
    function usingClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            ClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedClaimWithWitness
     */
    function usingQualifiedClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processSplitClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processSplitClaim
     */
    function usingSplitClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            SplitClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedSplitClaim
     */
    function usingQualifiedSplitClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedSplitClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processSplitClaimWithWitness
     */
    function usingSplitClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            SplitClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedSplitClaimWithWitness
     */
    function usingQualifiedSplitClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedSplitClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processBatchClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processBatchClaim
     */
    function usingBatchClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            BatchClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedBatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedBatchClaim
     */
    function usingQualifiedBatchClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedBatchClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processBatchClaimWithWitness
     */
    function usingBatchClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            BatchClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedBatchClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedBatchClaimWithWitness
     */
    function usingQualifiedBatchClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedBatchClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitBatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processSplitBatchClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processSplitBatchClaim
     */
    function usingSplitBatchClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            SplitBatchClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitBatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedSplitBatchClaim
     */
    function usingQualifiedSplitBatchClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedSplitBatchClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitBatchClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processSplitBatchClaimWithWitness
     */
    function usingSplitBatchClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            SplitBatchClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitBatchClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedSplitBatchClaimWithWitness
     */
    function usingQualifiedSplitBatchClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedSplitBatchClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processMultichainClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processMultichainClaim
     */
    function usingMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            MultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedMultichainClaim
     */
    function usingQualifiedMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processMultichainClaimWithWitness
     */
    function usingMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            MultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedMultichainClaimWithWitness
     */
    function usingQualifiedMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processSplitMultichainClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processSplitMultichainClaim
     */
    function usingSplitMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            SplitMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedSplitMultichainClaim
     */
    function usingQualifiedSplitMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedSplitMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processSplitMultichainClaimWithWitness
     */
    function usingSplitMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            SplitMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedSplitMultichainClaimWithWitness
     */
    function usingQualifiedSplitMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedSplitMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processBatchMultichainClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processBatchMultichainClaim
     */
    function usingBatchMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            BatchMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedBatchMultichainClaim
     */
    function usingQualifiedBatchMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedBatchMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processBatchMultichainClaimWithWitness
     */
    function usingBatchMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            BatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedBatchMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedBatchMultichainClaimWithWitness
     */
    function usingQualifiedBatchMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedBatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processSplitBatchMultichainClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processSplitBatchMultichainClaim
     */
    function usingSplitBatchMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            SplitBatchMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedSplitBatchMultichainClaim
     */
    function usingQualifiedSplitBatchMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedSplitBatchMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitBatchMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processSplitBatchMultichainClaimWithWitness
     */
    function usingSplitBatchMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            SplitBatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitBatchMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processQualifiedSplitBatchMultichainClaimWithWitness
     */
    function usingQualifiedSplitBatchMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            QualifiedSplitBatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processExogenousMultichainClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousMultichainClaim
     */
    function usingExogenousMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            ExogenousMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousQualifiedMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousQualifiedMultichainClaim
     */
    function usingExogenousQualifiedMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            ExogenousQualifiedMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousMultichainClaimWithWitness
     */
    function usingExogenousMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            ExogenousMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousQualifiedMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousQualifiedMultichainClaimWithWitness
     */
    function usingExogenousQualifiedMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            ExogenousQualifiedMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousSplitMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processExogenousSplitMultichainClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousSplitMultichainClaim
     */
    function usingExogenousSplitMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            ExogenousSplitMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousQualifiedSplitMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousQualifiedSplitMultichainClaim
     */
    function usingExogenousQualifiedSplitMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            ExogenousQualifiedSplitMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousSplitMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousSplitMultichainClaimWithWitness
     */
    function usingExogenousSplitMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            ExogenousSplitMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousQualifiedSplitMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousQualifiedSplitMultichainClaimWithWitness
     */
    function usingExogenousQualifiedSplitMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            ExogenousQualifiedSplitMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processExogenousBatchMultichainClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousBatchMultichainClaim
     */
    function usingExogenousBatchMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            ExogenousBatchMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousQualifiedBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousQualifiedBatchMultichainClaim
     */
    function usingExogenousQualifiedBatchMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            ExogenousQualifiedBatchMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousBatchMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousBatchMultichainClaimWithWitness
     */
    function usingExogenousBatchMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            ExogenousBatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousQualifiedBatchMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousQualifiedBatchMultichainClaimWithWitness
     */
    function usingExogenousQualifiedBatchMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            ExogenousQualifiedBatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousSplitBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processSplitBatchMultichainClaim
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousSplitBatchMultichainClaim
     */
    function usingExogenousSplitBatchMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            ExogenousSplitBatchMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousQualifiedSplitBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousQualifiedSplitBatchMultichainClaim
     */
    function usingExogenousQualifiedSplitBatchMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            ExogenousQualifiedSplitBatchMultichainClaim calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousSplitBatchMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithWitness
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousSplitBatchMultichainClaimWithWitness
     */
    function usingExogenousSplitBatchMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            ExogenousSplitBatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimProcessorLib.processClaimWithQualification
     * @return fnOut Modified function for ClaimProcessorLogic._processExogenousQualifiedSplitBatchMultichainClaimWithWitness
     */
    function usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
        bytes32,
        bytes32,
        bytes32,
        function(address, address, uint256, uint256) internal returns (bool)
        ) internal returns (bool) fnIn
    )
        internal
        pure
        returns (
            function(
            bytes32,
            bytes32,
            ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            bytes32,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedSplitClaimWithWitness calldata struct while
     * treating it as a QualifiedClaimWithWitness calldata struct.
     * @param fnIn   Function pointer to ClaimHashLib._toQualifiedClaimWithWitnessMessageHash(QualifiedClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib.toMessageHashes(QualifiedSplitClaimWithWitness calldata)
     */
    function usingQualifiedSplitClaimWithWitness(function (QualifiedClaimWithWitness calldata) internal view returns (bytes32, bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitClaimWithWitness calldata) internal view returns (bytes32, bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a SplitClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to HashLib.toMessageHashWithWitness(uint256, uint256)
     * @return fnOut Modified function for HashLib.toMessageHashWithWitness(SplitClaimWithWitness calldata, uint256)
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
     * @notice Function cast to provide a ClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to HashLib.toMessageHashWithWitness(uint256, uint256)
     * @return fnOut Modified function for HashLib.toMessageHashWithWitness(ClaimWithWitness calldata, uint256)
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
     * @notice Function cast to provide a BatchClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to HashLib.toMessageHashWithWitness(uint256, uint256)
     * @return fnOut Modified function for HashLib.toMessageHashWithWitness(BatchClaimWithWitness calldata, uint256)
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
     * @param fnIn   Function pointer to HashLib.toMessageHashWithWitness(uint256, uint256)
     * @return fnOut Modified function for HashLib.toMessageHashWithWitness(SplitBatchClaimWithWitness calldata, uint256)
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
     * @notice Function cast to provide an ExogenousQualifiedMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toExogenousQualifiedMultichainMessageHash(ExogenousQualifiedMultichainClaim calldata)
     * @return fnOut Modified function for ClaimHashLib._toExogenousQualifiedMultichainMessageHash(ExogenousQualifiedMultichainClaim calldata)
     */
    function usingExogenousQualifiedMultichainClaim(function(uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toQualifiedMultichainMessageHash(QualifiedMultichainClaim calldata)
     * @return fnOut Modified function for ClaimHashLib._toQualifiedMultichainMessageHash(QualifiedMultichainClaim calldata)
     */
    function usingQualifiedMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a QualifiedMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toQualifiedMultichainClaimWithWitnessMessageHash(QualifiedMultichainClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib._toQualifiedMultichainClaimWithWitnessMessageHash(QualifiedMultichainClaimWithWitness calldata)
     */
    function usingQualifiedMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousQualifiedMultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toExogenousQualifiedMultichainClaimWithWitnessMessageHash(ExogenousQualifiedMultichainClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib._toExogenousQualifiedMultichainClaimWithWitnessMessageHash(ExogenousQualifiedMultichainClaimWithWitness calldata)
     */
    function usingExogenousQualifiedMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toMultichainMessageHash(MultichainClaim calldata)
     * @return fnOut Modified function for ClaimHashLib._toMultichainMessageHash(MultichainClaim calldata)
     */
    function usingMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (MultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaimWithWitness calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to ClaimHashLib._toMultichainClaimWithWitnessMessageHash(MultichainClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib._toMultichainClaimWithWitnessMessageHash(MultichainClaimWithWitness calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toExogenousMultichainClaimWithWitnessMessageHash(ExogenousMultichainClaimWithWitness calldata)
     * @return fnOut Modified function for ClaimHashLib._toExogenousMultichainClaimWithWitnessMessageHash(ExogenousMultichainClaimWithWitness calldata)
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
     * @param fnIn   Function pointer to ClaimHashLib._toExogenousMultichainMessageHash(ExogenousMultichainClaim calldata)
     * @return fnOut Modified function for ClaimHashLib._toExogenousMultichainMessageHash(ExogenousMultichainClaim calldata)
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

    /**
     * @notice Function cast to provide a SplitBatchTransfer calldata struct while
     * treating it as a BatchTransfer calldata struct.
     * @param fnIn   Function pointer to HashLib.toBatchTransferMessageHashUsingIdsAndAmountsHash(BatchTransfer calldata, uint256)
     * @return fnOut Modified function for HashLib.toBatchTransferMessageHashUsingIdsAndAmountsHash(SplitBatchTransfer calldata, uint256)
     */
    function usingSplitBatchTransfer(function(BatchTransfer calldata, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(SplitBatchTransfer calldata, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }
}

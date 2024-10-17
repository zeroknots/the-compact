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

import { MultichainClaim } from "../types/MultichainClaims.sol";

import {
    TransferComponent,
    SplitByIdComponent,
    BatchClaimComponent,
    SplitBatchClaimComponent
} from "../types/Components.sol";

library FunctionCastLib {
    function usingSplitTransfer(
        function (bytes32, address, BasicTransfer calldata) internal view fnIn
    )
        internal
        pure
        returns (function (bytes32, address, SplitTransfer calldata) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchTransfer(
        function (bytes32, address, BasicTransfer calldata) internal view fnIn
    )
        internal
        pure
        returns (function (bytes32, address, BatchTransfer calldata) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchTransfer(
        function (bytes32, address, BasicTransfer calldata) internal view fnIn
    )
        internal
        pure
        returns (function (bytes32, address, SplitBatchTransfer calldata) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchTransfer(
        function(BatchTransfer calldata, bytes32) internal view returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(SplitBatchTransfer calldata, bytes32) internal view returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaim(
        function(QualifiedClaim calldata) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedSplitClaim calldata) internal view returns (bytes32, bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(
        function(ClaimWithWitness calldata, uint256) internal view returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedClaimWithWitness calldata, uint256) internal view returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(
        function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedClaimWithWitness calldata, bytes32, uint256)
            internal
            pure
            returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(
        function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedBatchClaim calldata, bytes32, uint256)
            internal
            pure
            returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaimWithWitness(
        function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedBatchClaimWithWitness calldata, bytes32, uint256)
            internal
            pure
            returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaim(
        function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedSplitBatchClaim calldata, bytes32, uint256)
            internal
            pure
            returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaimWithWitness(
        function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedSplitBatchClaimWithWitness calldata, bytes32, uint256)
            internal
            pure
            returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaimWithWitness(
        function (QualifiedClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnIn
    )
        internal
        pure
        returns (
            function (QualifiedSplitClaimWithWitness calldata) internal view returns (bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaim(
        function (SplitBatchClaim calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32)
            fnIn
    )
        internal
        pure
        returns (
            function (QualifiedSplitBatchClaim calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaimWithWitness(
        function (SplitBatchClaimWithWitness calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32)
            fnIn
    )
        internal
        pure
        returns (
            function (QualifiedSplitBatchClaimWithWitness calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(
        function(BatchClaim calldata, BatchClaimComponent[] calldata) internal view returns (bytes32)
            fnIn
    )
        internal
        pure
        returns (
            function(QualifiedBatchClaim calldata, BatchClaimComponent[] calldata) internal view returns (bytes32)
            fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaimWithWitness(
        function(BatchClaimWithWitness calldata, BatchClaimComponent[] calldata) internal view returns (bytes32)
            fnIn
    )
        internal
        pure
        returns (
            function(QualifiedBatchClaimWithWitness calldata, BatchClaimComponent[] calldata) internal view returns (bytes32)
            fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaim(function (BasicClaim calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitClaim calldata) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaimWithWitness(
        function (ClaimWithWitness calldata, uint256) internal view returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function (SplitClaimWithWitness calldata, uint256) internal view returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    // NOTE: the id field needs to be at the exact same struct offset for this to work!
    function usingSplitByIdComponent(
        function (TransferComponent[] memory, uint256) internal returns (address) fnIn
    )
        internal
        pure
        returns (function (SplitByIdComponent[] memory, uint256) internal returns (address) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingClaimWithWitness(
        function (bytes32, BasicClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (function (bytes32, ClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaimWithWitness(
        function(bytes32, BasicClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (function(bytes32, SplitClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaim(function(bytes32, BasicClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, SplitClaim calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchClaim(function(bytes32, BasicClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, BatchClaim calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaim(
        function(bytes32, BasicClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (function(bytes32, SplitBatchClaim calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaimWithWitness(
        function(bytes32, BasicClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function(bytes32, SplitBatchClaimWithWitness calldata, address) internal view fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchClaimWithWitness(
        function(bytes32, BasicClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (function(bytes32, BatchClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaim(
        function(QualifiedClaim calldata) internal returns (bytes32, address) fnIn
    )
        internal
        pure
        returns (function(QualifiedSplitClaim calldata) internal returns (bytes32, address) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedClaimWithWitness calldata, address) internal view fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedBatchClaim calldata, address) internal view fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaim(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedSplitBatchClaim calldata, address) internal view fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaimWithWitness(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedBatchClaimWithWitness calldata, address) internal view
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaimWithWitness(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedSplitBatchClaimWithWitness calldata, address) internal view
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaimQualifiedWithWitness(
        function(QualifiedClaimWithWitness calldata) internal returns (bytes32, address) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedSplitClaimWithWitness calldata) internal returns (bytes32, address) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaim(
        function(bytes32, BasicClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (function(bytes32, MultichainClaim calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }
}

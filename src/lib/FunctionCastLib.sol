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

library FunctionCastLib {
    function usingBasicClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BasicClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaim(function (BasicClaim calldata) internal view returns (bytes32) fnIn) internal pure returns (function (SplitClaim calldata) internal view returns (bytes32) fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (MultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaim(function (MultichainClaim calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaim calldata) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaim(function (ExogenousMultichainClaim calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaim calldata) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaim(function (QualifiedClaim calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitClaim calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaim(function (QualifiedMultichainClaim calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaim calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaim(function (ExogenousQualifiedMultichainClaim calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaim calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaim(function (uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaim calldata, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

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

    function usingSplitMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

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

    function usingExogenousSplitMultichainClaimWithWitness(function (ExogenousMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

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

    function usingSplitTransfer(function (bytes32, address, BasicTransfer calldata) internal fnIn) internal pure returns (function (bytes32, address, SplitTransfer calldata) internal fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchTransfer(function (bytes32, address, BasicTransfer calldata) internal fnIn) internal pure returns (function (bytes32, address, BatchTransfer calldata) internal fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchTransfer(function (bytes32, address, BasicTransfer calldata) internal fnIn)
        internal
        pure
        returns (function (bytes32, address, SplitBatchTransfer calldata) internal fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchTransfer(function(BatchTransfer calldata, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(SplitBatchTransfer calldata, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBasicClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaim(
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
            ExogenousMultichainClaim calldata,
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

    function usingExogenousQualifiedMultichainClaim(
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
            ExogenousQualifiedMultichainClaim calldata,
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

    function usingExogenousMultichainClaimWithWitness(
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
            ExogenousMultichainClaimWithWitness calldata,
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

    function usingExogenousQualifiedMultichainClaimWithWitness(
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
            ExogenousQualifiedMultichainClaimWithWitness calldata,
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

    function usingExogenousSplitMultichainClaim(
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
            ExogenousSplitMultichainClaim calldata,
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

    function usingExogenousQualifiedSplitMultichainClaim(
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
            ExogenousQualifiedSplitMultichainClaim calldata,
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

    function usingExogenousSplitMultichainClaimWithWitness(
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
            ExogenousSplitMultichainClaimWithWitness calldata,
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

    function usingExogenousQualifiedSplitMultichainClaimWithWitness(
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
            ExogenousQualifiedSplitMultichainClaimWithWitness calldata,
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

    function usingExogenousBatchMultichainClaim(
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
            ExogenousBatchMultichainClaim calldata,
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

    function usingExogenousQualifiedBatchMultichainClaim(
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
            ExogenousQualifiedBatchMultichainClaim calldata,
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

    function usingExogenousBatchMultichainClaimWithWitness(
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
            ExogenousBatchMultichainClaimWithWitness calldata,
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

    function usingExogenousQualifiedBatchMultichainClaimWithWitness(
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
            ExogenousQualifiedBatchMultichainClaimWithWitness calldata,
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

    function usingExogenousSplitBatchMultichainClaim(
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
            ExogenousSplitBatchMultichainClaim calldata,
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

    function usingExogenousQualifiedSplitBatchMultichainClaim(
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
            ExogenousQualifiedSplitBatchMultichainClaim calldata,
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

    function usingExogenousSplitBatchMultichainClaimWithWitness(
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
            ExogenousSplitBatchMultichainClaimWithWitness calldata,
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

    function usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(
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
            ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata,
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

    function usingQualifiedSplitClaim(function(uint256, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedSplitClaim calldata, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaim(function(uint256, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedClaim calldata, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(function(uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaimWithWitness(function(uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedSplitClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedSplitClaimWithWitness(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (
            function(QualifiedSplitClaimWithWitness calldata, bytes32, uint256)
            internal
            pure
            returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaim(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (
            function(QualifiedSplitClaim calldata, bytes32, uint256)
            internal
            pure
            returns (bytes32) fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedBatchClaimWithWitness(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedSplitBatchClaim(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedSplitBatchClaimWithWitness(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedSplitClaimWithWitness(function (QualifiedClaimWithWitness calldata) internal view returns (bytes32, bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitClaimWithWitness calldata) internal view returns (bytes32, bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaim(function (SplitBatchClaim calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchClaim calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaimWithWitness(function (SplitBatchClaimWithWitness calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchClaimWithWitness calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(function(BatchClaim calldata, BatchClaimComponent[] calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedBatchClaim calldata, BatchClaimComponent[] calldata) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaimWithWitness(function(BatchClaimWithWitness calldata, bytes32) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedBatchClaimWithWitness calldata, bytes32) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaimWithWitness(function(BatchClaimWithWitness calldata, bytes32) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedSplitBatchClaimWithWitness calldata, bytes32) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaim(function (uint256, uint256) internal view returns (bytes32) fnIn) internal pure returns (function (SplitClaim calldata, uint256) internal view returns (bytes32) fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingClaimWithWitness(function (bytes32, BasicClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function (bytes32, ClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaimWithWitness(function(bytes32, BasicClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, SplitClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaim(function(bytes32, BasicClaim calldata, address) internal view fnIn) internal pure returns (function(bytes32, SplitClaim calldata, address) internal view fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchClaim(function(bytes32, BasicClaim calldata, address) internal view fnIn) internal pure returns (function(bytes32, BatchClaim calldata, address) internal view fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchClaim(function (uint256, uint256) internal view returns (bytes32) fnIn) internal pure returns (function (BatchClaim calldata, uint256) internal view returns (bytes32) fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (BatchClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(function (uint256, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchClaim calldata, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaim(function (uint256, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchClaim calldata, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaim(function (uint256, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchClaim calldata, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaimWithWitness(function (uint256, uint256) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchClaimWithWitness calldata, uint256) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaim(function(bytes32, BasicClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, SplitBatchClaim calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaimWithWitness(function(bytes32, BasicClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, SplitBatchClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchClaimWithWitness(function(bytes32, BasicClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, BatchClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaim(function(QualifiedClaim calldata) internal returns (bytes32, address) fnIn)
        internal
        pure
        returns (function(QualifiedSplitClaim calldata) internal returns (bytes32, address) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function (bytes32, bytes32, QualifiedClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function (bytes32, bytes32, QualifiedBatchClaim calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaim(function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function (bytes32, bytes32, QualifiedSplitBatchClaim calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaimWithWitness(function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function (bytes32, bytes32, QualifiedBatchClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaimWithWitness(function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function (bytes32, bytes32, QualifiedSplitBatchClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitClaimQualifiedWithWitness(function(QualifiedClaimWithWitness calldata) internal returns (bytes32, address) fnIn)
        internal
        pure
        returns (function(QualifiedSplitClaimWithWitness calldata) internal returns (bytes32, address) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaim(function(bytes32, BasicClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, MultichainClaim calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaimWithWitness(function(bytes32, BasicClaim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, MultichainClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedSplitMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaim(function(uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaim(function(ExogenousMultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaim(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaimWithWitness(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaimWithWitness(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedSplitMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaimWithWitness(function(uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitBatchMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaimWithWitness(function(BatchClaimWithWitness calldata, bytes32) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function( SplitBatchClaimWithWitness calldata, bytes32) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaim(function (uint256, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBasicClaim(function (uint256, uint256) internal view returns (bytes32) fnIn) internal pure returns (function (BasicClaim calldata, uint256) internal view returns (bytes32) fnOut) {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaim(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaimWithWitness(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaim(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaim(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaim(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (MultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitBatchMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (MultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaim(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaim(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaim(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaim(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitBatchMultichainClaim(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitBatchMultichainClaim calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaim(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaim calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaimWithWitness(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaimWithWitness(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaimWithWitness(function (uint256, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (MultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaimWithWitness(function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (MultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaimWithWitness(function (uint256) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaimWithWitness(function (uint256, uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaimWithWitness calldata, uint256) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

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

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

    function usingSplitBatchTransfer(function(BatchTransfer calldata, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(SplitBatchTransfer calldata, bytes32) internal view returns (bytes32) fnOut)
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingSplitClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingSplitClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingBatchClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingBatchClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingSplitBatchClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaim(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaim(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaimWithWitness(
        function(
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaimWithWitness(
        function(
        bytes32,
        bytes32,
        uint256,
        uint256,
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaim(
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
            ExogenousMultichainClaim calldata,
            uint256,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaimWithWitness(
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
            ExogenousMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaim(
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
            ExogenousSplitMultichainClaim calldata,
            uint256,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaimWithWitness(
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
            ExogenousSplitMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaim(
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
            ExogenousBatchMultichainClaim calldata,
            uint256,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaimWithWitness(
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
            ExogenousBatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitBatchMultichainClaim(
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
            ExogenousSplitBatchMultichainClaim calldata,
            uint256,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitBatchMultichainClaimWithWitness(
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
            ExogenousSplitBatchMultichainClaimWithWitness calldata,
            uint256,
            bytes32,
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
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
            function(address, address, uint256, uint256) internal returns (bool)
            ) internal returns (bool) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitClaim(function(QualifiedClaim calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedSplitClaim calldata) internal view returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(function(ClaimWithWitness calldata, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedClaimWithWitness calldata, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedBatchClaim(function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedBatchClaimWithWitness(function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedSplitBatchClaim(function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedSplitBatchClaimWithWitness(function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
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

    function usingQualifiedSplitClaimWithWitness(function (QualifiedClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitClaimWithWitness calldata) internal view returns (bytes32, bytes32) fnOut)
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

    function usingQualifiedSplitBatchClaimWithWitness(function (SplitBatchClaimWithWitness calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchClaimWithWitness calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32) fnOut)
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

    function usingQualifiedBatchClaimWithWitness(function(BatchClaimWithWitness calldata, BatchClaimComponent[] calldata) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(QualifiedBatchClaimWithWitness calldata, BatchClaimComponent[] calldata) internal view returns (bytes32) fnOut)
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

    function usingSplitClaimWithWitness(function (ClaimWithWitness calldata, uint256) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitClaimWithWitness calldata, uint256) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    // NOTE: the id field needs to be at the exact same struct offset for this to work!
    function usingSplitByIdComponent(function (TransferComponent[] memory, uint256) internal returns (address) fnIn)
        internal
        pure
        returns (function (SplitByIdComponent[] memory, uint256) internal returns (address) fnOut)
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
}

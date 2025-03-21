// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {
    BasicTransfer,
    SplitTransfer,
    BasicClaim,
    ClaimWithWitness,
    SplitClaim,
    SplitClaimWithWitness
} from "../types/Claims.sol";

import {
    BatchTransfer,
    SplitBatchTransfer,
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

import { BatchClaimComponent, SplitBatchClaimComponent } from "../types/Components.sol";

import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

import { EfficiencyLib } from "./EfficiencyLib.sol";
import { ClaimHashFunctionCastLib } from "./ClaimHashFunctionCastLib.sol";
import { HashLib } from "./HashLib.sol";

/**
 * @title ClaimHashLib
 * @notice Library contract implementing logic for deriving hashes as part of processing
 * claims, allocated transfers, and withdrawals.
 */
library ClaimHashLib {
    using ClaimHashFunctionCastLib for function(uint256, uint256) internal pure returns (uint256);
    using ClaimHashFunctionCastLib for function(uint256, uint256) internal view returns (bytes32, bytes32);
    using ClaimHashFunctionCastLib for function(uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32);
    using ClaimHashFunctionCastLib for function(uint256, uint256, function(uint256, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32);
    using ClaimHashFunctionCastLib for function(uint256, uint256, function(uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32);
    using ClaimHashFunctionCastLib for function(uint256, uint256, function(uint256, uint256) internal view returns (bytes32, bytes32)) internal view returns (bytes32, bytes32, bytes32);
    using ClaimHashFunctionCastLib for function(uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32, bytes32);
    using ClaimHashFunctionCastLib for function(BasicClaim calldata) internal view returns (bytes32);
    using ClaimHashFunctionCastLib for function(MultichainClaim calldata) internal view returns (bytes32);
    using ClaimHashFunctionCastLib for function(ExogenousMultichainClaim calldata) internal view returns (bytes32);
    using ClaimHashFunctionCastLib for function(MultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32);
    using ClaimHashFunctionCastLib for function(ExogenousMultichainClaimWithWitness calldata) internal view returns (bytes32, bytes32);
    using EfficiencyLib for uint256;
    using HashLib for uint256;
    using HashLib for BatchClaimComponent[];
    using HashLib for SplitBatchClaimComponent[];
    using HashLib for BasicTransfer;
    using HashLib for SplitTransfer;
    using HashLib for BatchTransfer;
    using HashLib for SplitBatchTransfer;

    ///// CATEGORY 1: Transfer claim hashes /////
    function toClaimHash(BasicTransfer calldata transfer) internal view returns (bytes32 claimHash) {
        return transfer.toBasicTransferMessageHash();
    }

    function toClaimHash(SplitTransfer calldata transfer) internal view returns (bytes32 claimHash) {
        return transfer.toSplitTransferMessageHash();
    }

    function toClaimHash(BatchTransfer calldata transfer) internal view returns (bytes32 claimHash) {
        return transfer.toBatchTransferMessageHash();
    }

    function toClaimHash(SplitBatchTransfer calldata transfer) internal view returns (bytes32 claimHash) {
        return transfer.toSplitBatchTransferMessageHash();
    }

    ///// CATEGORY 2: "Simple" Claim hashes /////
    function toClaimHash(BasicClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toBasicMessageHash(claim);
    }

    function toClaimHash(SplitClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toBasicMessageHash.usingSplitClaim()(claim);
    }

    function toClaimHash(BatchClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toGenericMessageHash.usingBatchClaim()(claim, claim.claims.toIdsAndAmountsHash(), HashLib.toBatchMessageHash);
    }

    function toClaimHash(SplitBatchClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toGenericMessageHash.usingSplitBatchClaim()(claim, claim.claims.toSplitIdsAndAmountsHash(), HashLib.toBatchMessageHash);
    }

    function toClaimHash(MultichainClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toMultichainMessageHash(claim);
    }

    function toClaimHash(SplitMultichainClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toMultichainMessageHash.usingSplitMultichainClaim()(claim);
    }

    function toClaimHash(BatchMultichainClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toGenericMessageHash.usingBatchMultichainClaim()(claim, claim.claims.toIdsAndAmountsHash(), HashLib.toSimpleMultichainClaimMessageHash);
    }

    function toClaimHash(SplitBatchMultichainClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toGenericMessageHash.usingSplitBatchMultichainClaim()(claim, claim.claims.toSplitIdsAndAmountsHash(), HashLib.toSimpleMultichainClaimMessageHash);
    }

    function toClaimHash(ExogenousMultichainClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toExogenousMultichainMessageHash(claim);
    }

    function toClaimHash(ExogenousSplitMultichainClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toExogenousMultichainMessageHash.usingExogenousSplitMultichainClaim()(claim);
    }

    function toClaimHash(ExogenousBatchMultichainClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toGenericMessageHash.usingExogenousBatchMultichainClaim()(claim, claim.claims.toIdsAndAmountsHash(), HashLib.toSimpleExogenousMultichainClaimMessageHash);
    }

    function toClaimHash(ExogenousSplitBatchMultichainClaim calldata claim) internal view returns (bytes32 claimHash) {
        return _toGenericMessageHash.usingExogenousSplitBatchMultichainClaim()(claim, claim.claims.toSplitIdsAndAmountsHash(), HashLib.toSimpleExogenousMultichainClaimMessageHash);
    }

    ///// CATEGORY 3: Claim with witness message & type hashes /////
    function toMessageHashes(ClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return HashLib.toMessageHashWithWitness.usingClaimWithWitness()(claim, 0);
    }

    function toMessageHashes(SplitClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return HashLib.toMessageHashWithWitness.usingSplitClaimWithWitness()(claim, 0);
    }

    function toMessageHashes(BatchClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return HashLib.toBatchClaimWithWitnessMessageHash.usingBatchClaimWithWitness()(claim, claim.claims.toIdsAndAmountsHash());
    }

    function toMessageHashes(SplitBatchClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return HashLib.toBatchClaimWithWitnessMessageHash.usingSplitBatchClaimWithWitness()(claim, claim.claims.toSplitIdsAndAmountsHash());
    }

    function toMessageHashes(MultichainClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return _toMultichainClaimWithWitnessMessageHash(claim);
    }

    function toMessageHashes(SplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return _toMultichainClaimWithWitnessMessageHash.usingSplitMultichainClaimWithWitness()(claim);
    }

    function toMessageHashes(BatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return _toGenericMultichainClaimWithWitnessMessageHash.usingBatchMultichainClaimWithWitness()(claim, claim.claims.toIdsAndAmountsHash(), HashLib.toMultichainClaimMessageHash);
    }

    function toMessageHashes(SplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return _toGenericMultichainClaimWithWitnessMessageHash.usingSplitBatchMultichainClaimWithWitness()(claim, claim.claims.toSplitIdsAndAmountsHash(), HashLib.toMultichainClaimMessageHash);
    }

    function toMessageHashes(ExogenousMultichainClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return _toExogenousMultichainClaimWithWitnessMessageHash(claim);
    }

    function toMessageHashes(ExogenousSplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return _toExogenousMultichainClaimWithWitnessMessageHash.usingExogenousSplitMultichainClaimWithWitness()(claim);
    }

    function toMessageHashes(ExogenousBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return _toGenericMultichainClaimWithWitnessMessageHash.usingExogenousBatchMultichainClaimWithWitness()(claim, claim.claims.toIdsAndAmountsHash(), HashLib.toExogenousMultichainClaimMessageHash);
    }

    function toMessageHashes(ExogenousSplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 claimHash, bytes32 typehash) {
        return _toGenericMultichainClaimWithWitnessMessageHash.usingExogenousSplitBatchMultichainClaimWithWitness()(claim, claim.claims.toSplitIdsAndAmountsHash(), HashLib.toExogenousMultichainClaimMessageHash);
    }

    ///// Private helper functions /////
    function _toGenericMessageHash(uint256 claim, uint256 additionalInput, function(uint256, uint256) internal view returns (bytes32) hashFn) private view returns (bytes32 claimHash) {
        return hashFn(claim, additionalInput);
    }

    function _toBasicMessageHash(BasicClaim calldata claim) private view returns (bytes32 claimHash) {
        return _toGenericMessageHash.usingBasicClaim()(claim, uint256(0).asStubborn(), HashLib.toClaimMessageHash);
    }

    function _toMultichainMessageHash(MultichainClaim calldata claim) private view returns (bytes32 claimHash) {
        return _toGenericMessageHash.usingMultichainClaim()(claim, HashLib.toSingleIdAndAmountHash.usingMultichainClaim()(claim, 0), HashLib.toSimpleMultichainClaimMessageHash);
    }

    function _toExogenousMultichainMessageHash(ExogenousMultichainClaim calldata claim) private view returns (bytes32 claimHash) {
        return _toGenericMessageHash.usingExogenousMultichainClaim()(
            claim, HashLib.toSingleIdAndAmountHash.usingExogenousMultichainClaim()(claim, uint256(0x40).asStubborn()), HashLib.toSimpleExogenousMultichainClaimMessageHash
        );
    }

    function _toGenericMultichainClaimWithWitnessMessageHash(uint256 claim, uint256 additionalInput, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32) hashFn)
        private
        view
        returns (bytes32 claimHash, bytes32 /* typehash */ )
    {
        (bytes32 allocationTypehash, bytes32 typehash) = claim.toMultichainTypehashes();
        return (hashFn(claim, uint256(0x40).asStubborn(), allocationTypehash, typehash, additionalInput), typehash);
    }

    function _toMultichainClaimWithWitnessMessageHash(MultichainClaimWithWitness calldata claim) private view returns (bytes32 claimHash, bytes32 typehash) {
        return _toGenericMultichainClaimWithWitnessMessageHash.usingMultichainClaimWithWitness()(
            claim, HashLib.toSingleIdAndAmountHash.usingMultichainClaimWithWitness()(claim, uint256(0x40).asStubborn()), HashLib.toMultichainClaimMessageHash
        );
    }

    function _toExogenousMultichainClaimWithWitnessMessageHash(ExogenousMultichainClaimWithWitness calldata claim) private view returns (bytes32 claimHash, bytes32 typehash) {
        return _toGenericMultichainClaimWithWitnessMessageHash.usingExogenousMultichainClaimWithWitness()(
            claim, HashLib.toSingleIdAndAmountHash.usingExogenousMultichainClaimWithWitness()(claim, uint256(0x80).asStubborn()), HashLib.toExogenousMultichainClaimMessageHash
        );
    }
}

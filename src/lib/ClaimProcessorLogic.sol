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

import { ClaimHashLib } from "./ClaimHashLib.sol";
import { ClaimProcessorLib } from "./ClaimProcessorLib.sol";
import { ClaimProcessorFunctionCastLib } from "./ClaimProcessorFunctionCastLib.sol";
import { DomainLib } from "./DomainLib.sol";
import { HashLib } from "./HashLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { SharedLogic } from "./SharedLogic.sol";
import { ValidityLib } from "./ValidityLib.sol";

/**
 * @title ClaimProcessorLogic
 * @notice Inherited contract implementing internal functions with logic for processing
 * claims against a signed or registered compact. Each function derives the respective
 * claim hash as well as a typehash if applicable, then processes the claim.
 * @dev IMPORTANT NOTE: this logic assumes that the utilized structs are formatted in a
 * very specific manner — if parameters are rearranged or new parameters are inserted,
 * much of this functionality will break. Proceed with caution when making any changes.
 */
contract ClaimProcessorLogic is SharedLogic {
    using ClaimHashLib for BasicClaim;
    using ClaimHashLib for ClaimWithWitness;
    using ClaimHashLib for SplitClaim;
    using ClaimHashLib for SplitClaimWithWitness;
    using ClaimHashLib for BatchClaim;
    using ClaimHashLib for BatchClaimWithWitness;
    using ClaimHashLib for SplitBatchClaim;
    using ClaimHashLib for SplitBatchClaimWithWitness;
    using ClaimHashLib for MultichainClaim;
    using ClaimHashLib for MultichainClaimWithWitness;
    using ClaimHashLib for SplitMultichainClaim;
    using ClaimHashLib for SplitMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousMultichainClaim;
    using ClaimHashLib for ExogenousMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousSplitMultichainClaim;
    using ClaimHashLib for ExogenousSplitMultichainClaimWithWitness;
    using ClaimHashLib for BatchMultichainClaim;
    using ClaimHashLib for BatchMultichainClaimWithWitness;
    using ClaimHashLib for SplitBatchMultichainClaim;
    using ClaimHashLib for SplitBatchMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousBatchMultichainClaim;
    using ClaimHashLib for ExogenousBatchMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousSplitBatchMultichainClaim;
    using ClaimHashLib for ExogenousSplitBatchMultichainClaimWithWitness;
    using ClaimProcessorLib for uint256;
    using ClaimProcessorFunctionCastLib for function(bytes32, uint256, uint256, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using ClaimProcessorFunctionCastLib for function(bytes32, uint256, uint256, bytes32, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using ClaimProcessorFunctionCastLib for function(bytes32, bytes32, uint256, uint256, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using ClaimProcessorFunctionCastLib for function(bytes32, bytes32, uint256, uint256, bytes32, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using DomainLib for uint256;
    using HashLib for uint256;
    using EfficiencyLib for uint256;
    using ValidityLib for uint96;
    using ValidityLib for uint256;
    using ValidityLib for bytes32;

    ///// 1. Claims /////
    function _processBasicClaim(BasicClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processSimpleClaim.usingBasicClaim()(claimPayload.toClaimHash(), claimPayload, uint256(0xa0).asStubborn(), uint256(0).asStubborn().typehashes(), _domainSeparator(), operation);
    }

    function _processClaimWithWitness(ClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSimpleClaim.usingClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, _domainSeparator(), operation);
    }

    function _processSplitClaim(SplitClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processSimpleSplitClaim.usingSplitClaim()(claimPayload.toClaimHash(), claimPayload, 0xa0, uint256(0).asStubborn().typehashes(), _domainSeparator(), operation);
    }

    function _processSplitClaimWithWitness(SplitClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSimpleSplitClaim.usingSplitClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, _domainSeparator(), operation);
    }

    ///// 2. Batch Claims /////
    function _processBatchClaim(BatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processSimpleBatchClaim.usingBatchClaim()(claimPayload.toClaimHash(), claimPayload, 0xa0, uint256(1).asStubborn().typehashes(), _domainSeparator(), operation);
    }

    function _processBatchClaimWithWitness(BatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSimpleBatchClaim.usingBatchClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, _domainSeparator(), operation);
    }

    function _processSplitBatchClaim(SplitBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processSimpleSplitBatchClaim.usingSplitBatchClaim()(claimPayload.toClaimHash(), claimPayload, 0xa0, uint256(1).asStubborn().typehashes(), _domainSeparator(), operation);
    }

    function _processSplitBatchClaimWithWitness(SplitBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSimpleSplitBatchClaim.usingSplitBatchClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, _domainSeparator(), operation);
    }

    ///// 3. Multichain Claims /////
    function _processMultichainClaim(MultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processSimpleClaim.usingMultichainClaim()(claimPayload.toClaimHash(), claimPayload, 0xc0, uint256(2).asStubborn().typehashes(), _domainSeparator(), operation);
    }

    function _processMultichainClaimWithWitness(MultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSimpleClaim.usingMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, _domainSeparator(), operation);
    }

    function _processSplitMultichainClaim(SplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processSimpleSplitClaim.usingSplitMultichainClaim()(claimPayload.toClaimHash(), claimPayload, 0xc0, uint256(2).asStubborn().typehashes(), _domainSeparator(), operation);
    }

    function _processSplitMultichainClaimWithWitness(SplitMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSimpleSplitClaim.usingSplitMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, _domainSeparator(), operation);
    }

    ///// 4. Batch Multichain Claims /////
    function _processBatchMultichainClaim(BatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processSimpleBatchClaim.usingBatchMultichainClaim()(claimPayload.toClaimHash(), claimPayload, 0xc0, uint256(2).asStubborn().typehashes(), _domainSeparator(), operation);
    }

    function _processBatchMultichainClaimWithWitness(BatchMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSimpleBatchClaim.usingBatchMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, _domainSeparator(), operation);
    }

    function _processSplitBatchMultichainClaim(SplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return
            ClaimProcessorLib.processSimpleSplitBatchClaim.usingSplitBatchMultichainClaim()(claimPayload.toClaimHash(), claimPayload, 0xc0, uint256(2).asStubborn().typehashes(), _domainSeparator(), operation);
    }

    function _processSplitBatchMultichainClaimWithWitness(SplitBatchMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSimpleSplitBatchClaim.usingSplitBatchMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, _domainSeparator(), operation);
    }

    ///// 5. Exogenous Multichain Claims /////
    function _processExogenousMultichainClaim(ExogenousMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processClaimWithSponsorDomain.usingExogenousMultichainClaim()(
            claimPayload.toClaimHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), _domainSeparator(), operation
        );
    }

    function _processExogenousMultichainClaimWithWitness(ExogenousMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processClaimWithSponsorDomain.usingExogenousMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, _domainSeparator(), operation
        );
    }

    function _processExogenousSplitMultichainClaim(ExogenousSplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processSplitClaimWithSponsorDomain.usingExogenousSplitMultichainClaim()(
            claimPayload.toClaimHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), _domainSeparator(), operation
        );
    }

    function _processExogenousSplitMultichainClaimWithWitness(ExogenousSplitMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSplitClaimWithSponsorDomain.usingExogenousSplitMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, _domainSeparator(), operation
        );
    }

    ///// 6. Exogenous Batch Multichain Claims /////
    function _processExogenousBatchMultichainClaim(ExogenousBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return ClaimProcessorLib.processBatchClaimWithSponsorDomain.usingExogenousBatchMultichainClaim()(
            claimPayload.toClaimHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), _domainSeparator(), operation
        );
    }

    function _processExogenousBatchMultichainClaimWithWitness(ExogenousBatchMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processBatchClaimWithSponsorDomain.usingExogenousBatchMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, _domainSeparator(), operation
        );
    }

    function _processExogenousSplitBatchMultichainClaim(ExogenousSplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return ClaimProcessorLib.processSplitBatchClaimWithSponsorDomain.usingExogenousSplitBatchMultichainClaim()(
            claimPayload.toClaimHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), _domainSeparator(), operation
        );
    }

    function _processExogenousSplitBatchMultichainClaimWithWitness(
        ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return ClaimProcessorLib.processSplitBatchClaimWithSponsorDomain.usingExogenousSplitBatchMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, _domainSeparator(), operation
        );
    }
}

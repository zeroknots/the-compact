// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BasicClaim, QualifiedClaim, ClaimWithWitness, QualifiedClaimWithWitness, SplitClaim, SplitClaimWithWitness, QualifiedSplitClaim, QualifiedSplitClaimWithWitness } from "../types/Claims.sol";
import {
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
import { SplitComponent, BatchClaimComponent, SplitBatchClaimComponent } from "../types/Components.sol";

import { ClaimHashLib } from "./ClaimHashLib.sol";
import { ClaimProcessorLib } from "./ClaimProcessorLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { FunctionCastLib } from "./FunctionCastLib.sol";
import { HashLib } from "./HashLib.sol";
import { IdLib } from "./IdLib.sol";
import { RegistrationLib } from "./RegistrationLib.sol";
import { ValidityLib } from "./ValidityLib.sol";
import { SharedLogic } from "./SharedLogic.sol";

/**
 * @title ClaimProcessorLogic
 * @notice Inherited contract implementing internal functions with logic for processing
 * claims against a signed or registered compact.
 * @dev IMPORTANT NOTE: this logic assumes that the utilized structs are formatted in a
 * very specific manner — if parameters are rearranged or new parameters are inserted,
 * much of this functionality will break. Proceed with caution when making any changes.
 */
contract ClaimProcessorLogic is SharedLogic {
    using ClaimProcessorLib for uint256;
    using ClaimProcessorLib for bytes32;
    using ClaimProcessorLib for SplitComponent[];
    using EfficiencyLib for bool;
    using EfficiencyLib for bytes32;
    using EfficiencyLib for uint256;
    using FunctionCastLib for function(bytes32, uint256, uint256, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using FunctionCastLib for function(bytes32, uint256, uint256, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using FunctionCastLib for function(bytes32, bytes32, uint256, uint256, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using FunctionCastLib for function(bytes32, bytes32, uint256, uint256, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using HashLib for address;
    using HashLib for bytes32;
    using HashLib for uint256;
    using ClaimHashLib for BasicClaim;
    using ClaimHashLib for QualifiedClaim;
    using ClaimHashLib for ClaimWithWitness;
    using ClaimHashLib for QualifiedClaimWithWitness;
    using ClaimHashLib for SplitClaim;
    using ClaimHashLib for SplitClaimWithWitness;
    using ClaimHashLib for QualifiedSplitClaim;
    using ClaimHashLib for QualifiedSplitClaimWithWitness;
    using ClaimHashLib for BatchClaim;
    using ClaimHashLib for QualifiedBatchClaim;
    using ClaimHashLib for BatchClaimWithWitness;
    using ClaimHashLib for QualifiedBatchClaimWithWitness;
    using ClaimHashLib for SplitBatchClaim;
    using ClaimHashLib for SplitBatchClaimWithWitness;
    using ClaimHashLib for QualifiedSplitBatchClaim;
    using ClaimHashLib for QualifiedSplitBatchClaimWithWitness;
    using ClaimHashLib for MultichainClaim;
    using ClaimHashLib for QualifiedMultichainClaim;
    using ClaimHashLib for MultichainClaimWithWitness;
    using ClaimHashLib for QualifiedMultichainClaimWithWitness;
    using ClaimHashLib for SplitMultichainClaim;
    using ClaimHashLib for SplitMultichainClaimWithWitness;
    using ClaimHashLib for QualifiedSplitMultichainClaim;
    using ClaimHashLib for QualifiedSplitMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousMultichainClaim;
    using ClaimHashLib for ExogenousQualifiedMultichainClaim;
    using ClaimHashLib for ExogenousMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousQualifiedMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousSplitMultichainClaim;
    using ClaimHashLib for ExogenousSplitMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousQualifiedSplitMultichainClaim;
    using ClaimHashLib for ExogenousQualifiedSplitMultichainClaimWithWitness;
    using ClaimHashLib for BatchMultichainClaim;
    using ClaimHashLib for QualifiedBatchMultichainClaim;
    using ClaimHashLib for BatchMultichainClaimWithWitness;
    using ClaimHashLib for QualifiedBatchMultichainClaimWithWitness;
    using ClaimHashLib for SplitBatchMultichainClaim;
    using ClaimHashLib for SplitBatchMultichainClaimWithWitness;
    using ClaimHashLib for QualifiedSplitBatchMultichainClaim;
    using ClaimHashLib for QualifiedSplitBatchMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousBatchMultichainClaim;
    using ClaimHashLib for ExogenousQualifiedBatchMultichainClaim;
    using ClaimHashLib for ExogenousBatchMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousQualifiedBatchMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousSplitBatchMultichainClaim;
    using ClaimHashLib for ExogenousSplitBatchMultichainClaimWithWitness;
    using ClaimHashLib for ExogenousQualifiedSplitBatchMultichainClaim;
    using ClaimHashLib for ExogenousQualifiedSplitBatchMultichainClaimWithWitness;
    using IdLib for uint256;
    using RegistrationLib for address;
    using ValidityLib for uint96;
    using ValidityLib for uint256;
    using ValidityLib for bytes32;

    ///// 1. Claims /////
    function _processBasicClaim(BasicClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleClaim.usingBasicClaim()(claimPayload.toClaimHash(), claimPayload, uint256(0xa0).asStubborn(), uint256(0).asStubborn().typehashes(), operation);
    }

    function _processQualifiedClaim(QualifiedClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processClaimWithQualification.usingQualifiedClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, uint256(0).asStubborn().typehashes(), operation);
    }

    function _processClaimWithWitness(ClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSimpleClaim.usingClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedClaimWithWitness(QualifiedClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processClaimWithQualification.usingQualifiedClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    function _processSplitClaim(SplitClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleSplitClaim.usingSplitClaim()(claimPayload.toClaimHash(), claimPayload, 0xa0, uint256(0).asStubborn().typehashes(), operation);
    }

    function _processQualifiedSplitClaim(QualifiedSplitClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processSplitClaimWithQualification.usingQualifiedSplitClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, uint256(0).asStubborn().typehashes(), operation);
    }

    function _processSplitClaimWithWitness(SplitClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSimpleSplitClaim.usingSplitClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedSplitClaimWithWitness(QualifiedSplitClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSplitClaimWithQualification.usingQualifiedSplitClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    ///// 2. Batch Claims /////
    function _processBatchClaim(BatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleBatchClaim.usingBatchClaim()(claimPayload.toClaimHash(), claimPayload, 0xa0, uint256(1).asStubborn().typehashes(), operation);
    }

    function _processQualifiedBatchClaim(QualifiedBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processBatchClaimWithQualification.usingQualifiedBatchClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, uint256(1).asStubborn().typehashes(), operation);
    }

    function _processBatchClaimWithWitness(BatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSimpleBatchClaim.usingBatchClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedBatchClaimWithWitness(QualifiedBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processBatchClaimWithQualification.usingQualifiedBatchClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    function _processSplitBatchClaim(SplitBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleSplitBatchClaim.usingSplitBatchClaim()(claimPayload.toClaimHash(), claimPayload, 0xa0, uint256(1).asStubborn().typehashes(), operation);
    }

    function _processQualifiedSplitBatchClaim(QualifiedSplitBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, uint256(1).asStubborn().typehashes(), operation);
    }

    function _processSplitBatchClaimWithWitness(SplitBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSimpleSplitBatchClaim.usingSplitBatchClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedSplitBatchClaimWithWitness(QualifiedSplitBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    ///// 3. Multichain Claims /////
    function _processMultichainClaim(MultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleClaim.usingMultichainClaim()(claimPayload.toClaimHash(), claimPayload, 0xc0, uint256(2).asStubborn().typehashes(), operation);
    }

    function _processQualifiedMultichainClaim(QualifiedMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processClaimWithQualification.usingQualifiedMultichainClaim()(messageHash, qualificationMessageHash, claimPayload, 0x100, uint256(2).asStubborn().typehashes(), operation);
    }

    function _processMultichainClaimWithWitness(MultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSimpleClaim.usingMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedMultichainClaimWithWitness(QualifiedMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processClaimWithQualification.usingQualifiedMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    function _processSplitMultichainClaim(SplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleSplitClaim.usingSplitMultichainClaim()(claimPayload.toClaimHash(), claimPayload, 0xc0, uint256(2).asStubborn().typehashes(), operation);
    }

    function _processQualifiedSplitMultichainClaim(QualifiedSplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processSplitClaimWithQualification.usingQualifiedSplitMultichainClaim()(messageHash, qualificationMessageHash, claimPayload, 0x100, uint256(2).asStubborn().typehashes(), operation);
    }

    function _processSplitMultichainClaimWithWitness(SplitMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSimpleSplitClaim.usingSplitMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedSplitMultichainClaimWithWitness(
        QualifiedSplitMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSplitClaimWithQualification.usingQualifiedSplitMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    ///// 4. Batch Multichain Claims /////
    function _processBatchMultichainClaim(BatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleBatchClaim.usingBatchMultichainClaim()(claimPayload.toClaimHash(), claimPayload, 0xc0, uint256(2).asStubborn().typehashes(), operation);
    }

    function _processQualifiedBatchMultichainClaim(QualifiedBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processBatchClaimWithQualification.usingQualifiedBatchMultichainClaim()(messageHash, qualificationMessageHash, claimPayload, 0x100, uint256(2).asStubborn().typehashes(), operation);
    }

    function _processBatchMultichainClaimWithWitness(BatchMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSimpleBatchClaim.usingBatchMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedBatchMultichainClaimWithWitness(
        QualifiedBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processBatchClaimWithQualification.usingQualifiedBatchMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    function _processSplitBatchMultichainClaim(SplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSimpleSplitBatchClaim.usingSplitBatchMultichainClaim()(claimPayload.toClaimHash(), claimPayload, 0xc0, uint256(2).asStubborn().typehashes(), operation);
    }

    function _processQualifiedSplitBatchMultichainClaim(QualifiedSplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x100, uint256(1).asStubborn().typehashes(), operation
        );
    }

    function _processSplitBatchMultichainClaimWithWitness(SplitBatchMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSimpleSplitBatchClaim.usingSplitBatchMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedSplitBatchMultichainClaimWithWitness(
        QualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    ///// 5. Exogenous Multichain Claims /////
    function _processExogenousMultichainClaim(ExogenousMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processClaimWithSponsorDomain.usingExogenousMultichainClaim()(
            claimPayload.toClaimHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), operation
        );
    }

    function _processExogenousQualifiedMultichainClaim(ExogenousQualifiedMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), operation
        );
    }

    function _processExogenousMultichainClaimWithWitness(ExogenousMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return
            _processClaimWithSponsorDomain.usingExogenousMultichainClaimWithWitness()(messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation);
    }

    function _processExogenousQualifiedMultichainClaimWithWitness(
        ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousSplitMultichainClaim(ExogenousSplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSplitClaimWithSponsorDomain.usingExogenousSplitMultichainClaim()(
            claimPayload.toClaimHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), operation
        );
    }

    function _processExogenousQualifiedSplitMultichainClaim(
        ExogenousQualifiedSplitMultichainClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processSplitClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), operation
        );
    }

    function _processExogenousSplitMultichainClaimWithWitness(
        ExogenousSplitMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSplitClaimWithSponsorDomain.usingExogenousSplitMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousQualifiedSplitMultichainClaimWithWitness(
        ExogenousQualifiedSplitMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSplitClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    ///// 6. Exogenous Batch Multichain Claims /////
    function _processExogenousBatchMultichainClaim(ExogenousBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processBatchClaimWithSponsorDomain.usingExogenousBatchMultichainClaim()(
            claimPayload.toClaimHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), operation
        );
    }

    function _processExogenousQualifiedBatchMultichainClaim(
        ExogenousQualifiedBatchMultichainClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedBatchMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), operation
        );
    }

    function _processExogenousBatchMultichainClaimWithWitness(
        ExogenousBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processBatchClaimWithSponsorDomain.usingExogenousBatchMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousQualifiedBatchMultichainClaimWithWitness(
        ExogenousQualifiedBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedBatchMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousSplitBatchMultichainClaim(ExogenousSplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSplitBatchClaimWithSponsorDomain.usingExogenousSplitBatchMultichainClaim()(
            claimPayload.toClaimHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), operation
        );
    }

    function _processExogenousQualifiedSplitBatchMultichainClaim(
        ExogenousQualifiedSplitBatchMultichainClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHashes();
        return _processSplitBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitBatchMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), uint256(2).asStubborn().typehashes(), operation
        );
    }

    function _processExogenousSplitBatchMultichainClaimWithWitness(
        ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSplitBatchClaimWithSponsorDomain.usingExogenousSplitBatchMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousQualifiedSplitBatchMultichainClaimWithWitness(
        ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHashes();
        return _processSplitBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitBatchMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    ///// 7. Private helper functions /////

    /**
     * @notice Internal function for validating claim execution parameters. Extracts and validates
     * signatures from calldata, checks expiration, verifies allocator registration, consumes the
     * nonce, derives the domain separator, and validates both the sponsor authorization (either
     * through direct registration or a provided signature or EIP-1271 call) and the (potentially
     * qualified) allocator authorization. Finally, emits a Claim event.
     * @param allocatorId              The unique identifier for the allocator mediating the claim.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @return sponsor                 The extracted address of the claim sponsor.
     */
    function _validate(uint96 allocatorId, bytes32 messageHash, bytes32 qualificationMessageHash, uint256 calldataPointer, bytes32 sponsorDomainSeparator, bytes32 typehash)
        private
        returns (address sponsor)
    {
        // Declare variables for signatures and parameters that will be extracted from calldata.
        bytes calldata allocatorSignature;
        bytes calldata sponsorSignature;
        uint256 nonce;
        uint256 expires;

        assembly ("memory-safe") {
            // Extract allocator signature from calldata using offset stored at calldataPointer.
            let allocatorSignaturePtr := add(calldataPointer, calldataload(calldataPointer))
            allocatorSignature.offset := add(0x20, allocatorSignaturePtr)
            allocatorSignature.length := calldataload(allocatorSignaturePtr)

            // Extract sponsor signature from calldata using offset stored at calldataPointer + 0x20.
            let sponsorSignaturePtr := add(calldataPointer, calldataload(add(calldataPointer, 0x20)))
            sponsorSignature.offset := add(0x20, sponsorSignaturePtr)
            sponsorSignature.length := calldataload(sponsorSignaturePtr)

            // Extract sponsor address, sanitizing upper 96 bits.
            sponsor := shr(96, shl(96, calldataload(add(calldataPointer, 0x40))))

            // Extract nonce and expiration timestamp.
            nonce := calldataload(add(calldataPointer, 0x60))
            expires := calldataload(add(calldataPointer, 0x80))
        }

        // Ensure that the claim hasn't expired.
        expires.later();

        // Retrieve allocator address and consume nonce, ensuring it has not already been consumed.
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(nonce);

        // Derive the default domain separator.
        bytes32 domainSeparator = _domainSeparator();
        assembly ("memory-safe") {
            // Substitue for provided sponsorDomainSeparator if a nonzero value was supplied.
            sponsorDomainSeparator := add(sponsorDomainSeparator, mul(iszero(sponsorDomainSeparator), domainSeparator))
        }

        // Validate sponsor authorization through either ECDSA, EIP-1271, or direct registration.
        if ((sponsorDomainSeparator != domainSeparator).or(sponsorSignature.length != 0) || sponsor.hasNoActiveRegistration(messageHash, typehash)) {
            messageHash.signedBy(sponsor, sponsorSignature, sponsorDomainSeparator);
        }

        // Validate allocator authorization against qualification message.
        qualificationMessageHash.signedBy(allocator, allocatorSignature, domainSeparator);

        // Emit claim event.
        _emitClaim(sponsor, messageHash, allocator);
    }

    /**
     * @notice Private function for processing qualified claims with potentially exogenous
     * sponsor signatures. Extracts claim parameters from calldata, validates the scope,
     * ensures the claimed amount is within the allocated amount, validates the claim,
     * and executes either a release of ERC6909 tokens or a withdrawal of underlying tokens.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param offsetToId               Offset to segment of calldata where relevant claim parameters begin.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @param operation                Function pointer to either _release or _withdraw for executing the claim.
     * @return                         Whether the claim was successfully processed.
     */
    function _processClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        // Declare variables for parameters that will be extracted from calldata.
        uint256 id;
        uint256 allocatedAmount;
        address claimant;
        uint256 amount;

        assembly ("memory-safe") {
            // Calculate pointer to claim parameters using provided offset.
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)

            // Extract resource lock id, allocated amount, claimant address, and claim amount.
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))
            claimant := shr(96, shl(96, calldataload(add(calldataPointerWithOffset, 0x40))))
            amount := calldataload(add(calldataPointerWithOffset, 0x60))
        }

        // Verify the resource lock scope is compatible with the provided domain separator.
        sponsorDomainSeparator.ensureValidScope(id);

        // Ensure the claimed amount does not exceed the allocated amount.
        amount.withinAllocated(allocatedAmount);

        // Validate the claim and execute the specified operation (either release or withdraw).
        return operation(_validate(id.toAllocatorId(), messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash), claimant, id, amount);
    }

    /**
     * @notice Private function for processing qualified split claims with potentially exogenous
     * sponsor signatures. Extracts claim parameters from calldata, validates the claim,
     * validates the scope, and executes either releases of ERC6909 tokens or withdrawals of
     * underlying tokens to multiple recipients.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param offsetToId               Offset to segment of calldata where relevant claim parameters begin.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @param operation                Function pointer to either _release or _withdraw for executing the claim.
     * @return                         Whether the split claim was successfully processed.
     */
    function _processSplitClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        // Declare variables for parameters that will be extracted from calldata.
        uint256 id;
        uint256 allocatedAmount;
        SplitComponent[] calldata components;

        assembly ("memory-safe") {
            // Calculate pointer to claim parameters using provided offset.
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)

            // Extract resource lock id and allocated amount.
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))

            // Extract array of split components containing claimant addresses and amounts.
            let componentsPtr := add(calldataPointer, calldataload(add(calldataPointerWithOffset, 0x40)))
            components.offset := add(0x20, componentsPtr)
            components.length := calldataload(componentsPtr)
        }

        // Validate the claim and extract the sponsor address.
        address sponsor = _validate(id.toAllocatorId(), messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash);

        // Verify the resource lock scope is compatible with the provided domain separator.
        sponsorDomainSeparator.ensureValidScope(id);

        // Process each split component, verifying total amount and executing operations.
        return components.verifyAndProcessSplitComponents(sponsor, id, allocatedAmount, operation);
    }

    /**
     * @notice Private function for processing qualified batch claims with potentially exogenous
     * sponsor signatures. Extracts batch claim parameters from calldata, validates the claim,
     * executes operations, and performs optimized validation of allocator consistency, amounts,
     * and scopes. If any validation fails, all operations are reverted after explicitly
     * identifying the specific validation failures.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param offsetToId               Offset to segment of calldata where relevant claim parameters begin.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @param operation                Function pointer to either _release or _withdraw for executing the claim.
     * @return                         Whether the batch claim was successfully processed.
     */
    function _processBatchClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        // Declare variables for parameters that will be extracted from calldata.
        BatchClaimComponent[] calldata claims;
        address claimant;

        assembly ("memory-safe") {
            // Calculate pointer to claim parameters using provided offset.
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)

            // Extract array of batch claim components and claimant address.
            let claimsPtr := add(calldataPointer, calldataload(calldataPointerWithOffset))
            claims.offset := add(0x20, claimsPtr)
            claims.length := calldataload(claimsPtr)
            claimant := calldataload(add(calldataPointerWithOffset, 0x20))
        }

        // Extract allocator id from first claim for validation.
        uint96 firstAllocatorId = claims[0].id.toAllocatorId();

        // Validate the claim and extract the sponsor address.
        address sponsor = _validate(firstAllocatorId, messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash);

        // Revert if the batch is empty.
        uint256 totalClaims = claims.length;
        assembly ("memory-safe") {
            if iszero(totalClaims) {
                // revert InvalidBatchAllocation()
                mstore(0, 0x3a03d3bb)
                revert(0x1c, 0x04)
            }
        }

        // Process first claim and initialize error tracking.
        // NOTE: many of the bounds checks on these array accesses can be skipped as an optimization
        BatchClaimComponent calldata component = claims[0];
        uint256 id = component.id;
        uint256 amount = component.amount;
        uint256 errorBuffer = component.allocatedAmount.allocationExceededOrScopeNotMultichain(amount, id, sponsorDomainSeparator).asUint256();

        // Execute transfer or withdrawal for first claim.
        operation(sponsor, claimant, id, amount);

        unchecked {
            // Process remaining claims while accumulating potential errors.
            for (uint256 i = 1; i < totalClaims; ++i) {
                component = claims[i];
                id = component.id;
                amount = component.amount;
                errorBuffer |= (id.toAllocatorId() != firstAllocatorId).or(component.allocatedAmount.allocationExceededOrScopeNotMultichain(amount, id, sponsorDomainSeparator)).asUint256();

                operation(sponsor, claimant, id, amount);
            }

            // If any errors occurred, identify specific failures and revert.
            if (errorBuffer.asBool()) {
                for (uint256 i = 0; i < totalClaims; ++i) {
                    component = claims[i];
                    component.amount.withinAllocated(component.allocatedAmount);
                    id = component.id;
                    sponsorDomainSeparator.ensureValidScope(component.id);
                }

                assembly ("memory-safe") {
                    // revert InvalidBatchAllocation()
                    mstore(0, 0x3a03d3bb)
                    revert(0x1c, 0x04)
                }
            }
        }

        return true;
    }

    /**
     * @notice Private function for processing qualified split batch claims with potentially
     * exogenous sponsor signatures. Extracts split batch claim parameters from calldata,
     * validates the claim, and executes split operations for each resource lock. Uses optimized
     * validation of allocator consistency and scopes, with explicit validation on failure to
     * identify specific issues. Each resource lock can be split among multiple recipients.
     * @param messageHash              The EIP-712 hash of the claim message.
     * @param qualificationMessageHash The EIP-712 hash of the allocator's qualification message.
     * @param calldataPointer          Pointer to the location of the associated struct in calldata.
     * @param offsetToId               Offset to segment of calldata where relevant claim parameters begin.
     * @param sponsorDomainSeparator   The domain separator for the sponsor's signature, or zero for non-exogenous claims.
     * @param typehash                 The EIP-712 typehash used for the claim message.
     * @param operation                Function pointer to either _release or _withdraw for executing the claim.
     * @return                         Whether the split batch claim was successfully processed.
     */
    function _processSplitBatchClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        // Declare variable for SplitBatchClaimComponent array that will be extracted from calldata.
        SplitBatchClaimComponent[] calldata claims;

        assembly ("memory-safe") {
            // Extract array of split batch claim components.
            let claimsPtr := add(calldataPointer, calldataload(add(calldataPointer, offsetToId)))
            claims.offset := add(0x20, claimsPtr)
            claims.length := calldataload(claimsPtr)
        }

        // Extract allocator id from first claim for validation.
        uint96 firstAllocatorId = claims[0].id.toAllocatorId();

        // Validate the claim and extract the sponsor address.
        address sponsor = _validate(firstAllocatorId, messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash);

        // Initialize tracking variables.
        uint256 totalClaims = claims.length;
        uint256 errorBuffer = (totalClaims == 0).asUint256();
        uint256 id;

        unchecked {
            // Process each claim component while accumulating potential errors.
            for (uint256 i = 0; i < totalClaims; ++i) {
                SplitBatchClaimComponent calldata claimComponent = claims[i];
                id = claimComponent.id;
                errorBuffer |= (id.toAllocatorId() != firstAllocatorId).or(id.scopeNotMultichain(sponsorDomainSeparator)).asUint256();

                // Process each split component, verifying total amount and executing operations.
                claimComponent.portions.verifyAndProcessSplitComponents(sponsor, id, claimComponent.allocatedAmount, operation);
            }

            // If any errors occurred, identify specific scope failures and revert.
            if (errorBuffer.asBool()) {
                for (uint256 i = 0; i < totalClaims; ++i) {
                    sponsorDomainSeparator.ensureValidScope(claims[i].id);
                }

                assembly ("memory-safe") {
                    // revert InvalidBatchAllocation()
                    mstore(0, 0x3a03d3bb)
                    revert(0x1c, 0x04)
                }
            }
        }

        return true;
    }

    function _processSimpleClaim(bytes32 messageHash, uint256 calldataPointer, uint256 offsetToId, bytes32 typehash, function(address, address, uint256, uint256) internal returns (bool) operation)
        private
        returns (bool)
    {
        return _processClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, operation);
    }

    function _processSimpleSplitClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processSplitClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, operation);
    }

    function _processSimpleBatchClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, operation);
    }

    function _processBatchClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processBatchClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, operation);
    }

    function _processSimpleSplitBatchClaim(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processSplitBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, operation);
    }

    function _processSplitBatchClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processSplitBatchClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, operation);
    }

    function _processClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, operation);
    }

    function _processClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, operation);
    }

    function _processSplitClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processSplitClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0).asStubborn(), typehash, operation);
    }

    function _processSplitClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processSplitClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, operation);
    }

    function _processBatchClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, operation);
    }

    function _processSplitBatchClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        return _processSplitBatchClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, typehash, operation);
    }
}

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
import { COMPACT_TYPEHASH, BATCH_COMPACT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH } from "../types/EIP712Types.sol";
import { SplitComponent, BatchClaimComponent, SplitBatchClaimComponent } from "../types/Components.sol";
import { Scope } from "../types/Scope.sol";

import { EfficiencyLib } from "./EfficiencyLib.sol";
import { FunctionCastLib } from "./FunctionCastLib.sol";
import { HashLib } from "./HashLib.sol";
import { IdLib } from "./IdLib.sol";
import { RegistrationLib } from "./RegistrationLib.sol";
import { ValidityLib } from "./ValidityLib.sol";
import { SharedLogic } from "./SharedLogic.sol";

contract ClaimProcessorLogic is SharedLogic {
    using HashLib for address;
    using HashLib for bytes32;
    using HashLib for uint256;
    using HashLib for BasicClaim;
    using HashLib for QualifiedClaim;
    using HashLib for ClaimWithWitness;
    using HashLib for QualifiedClaimWithWitness;
    using HashLib for SplitClaim;
    using HashLib for SplitClaimWithWitness;
    using HashLib for QualifiedSplitClaim;
    using HashLib for QualifiedSplitClaimWithWitness;
    using HashLib for BatchClaim;
    using HashLib for QualifiedBatchClaim;
    using HashLib for BatchClaimWithWitness;
    using HashLib for QualifiedBatchClaimWithWitness;
    using HashLib for SplitBatchClaim;
    using HashLib for SplitBatchClaimWithWitness;
    using HashLib for QualifiedSplitBatchClaim;
    using HashLib for QualifiedSplitBatchClaimWithWitness;
    using HashLib for MultichainClaim;
    using HashLib for QualifiedMultichainClaim;
    using HashLib for MultichainClaimWithWitness;
    using HashLib for QualifiedMultichainClaimWithWitness;
    using HashLib for SplitMultichainClaim;
    using HashLib for SplitMultichainClaimWithWitness;
    using HashLib for QualifiedSplitMultichainClaim;
    using HashLib for QualifiedSplitMultichainClaimWithWitness;
    using HashLib for ExogenousMultichainClaim;
    using HashLib for ExogenousQualifiedMultichainClaim;
    using HashLib for ExogenousMultichainClaimWithWitness;
    using HashLib for ExogenousQualifiedMultichainClaimWithWitness;
    using HashLib for ExogenousSplitMultichainClaim;
    using HashLib for ExogenousSplitMultichainClaimWithWitness;
    using HashLib for ExogenousQualifiedSplitMultichainClaim;
    using HashLib for ExogenousQualifiedSplitMultichainClaimWithWitness;
    using HashLib for BatchMultichainClaim;
    using HashLib for QualifiedBatchMultichainClaim;
    using HashLib for BatchMultichainClaimWithWitness;
    using HashLib for QualifiedBatchMultichainClaimWithWitness;
    using HashLib for SplitBatchMultichainClaim;
    using HashLib for SplitBatchMultichainClaimWithWitness;
    using HashLib for QualifiedSplitBatchMultichainClaim;
    using HashLib for QualifiedSplitBatchMultichainClaimWithWitness;
    using HashLib for ExogenousBatchMultichainClaim;
    using HashLib for ExogenousQualifiedBatchMultichainClaim;
    using HashLib for ExogenousBatchMultichainClaimWithWitness;
    using HashLib for ExogenousQualifiedBatchMultichainClaimWithWitness;
    using HashLib for ExogenousSplitBatchMultichainClaim;
    using HashLib for ExogenousSplitBatchMultichainClaimWithWitness;
    using HashLib for ExogenousQualifiedSplitBatchMultichainClaim;
    using HashLib for ExogenousQualifiedSplitBatchMultichainClaimWithWitness;
    using IdLib for uint256;
    using EfficiencyLib for bool;
    using EfficiencyLib for bytes32;
    using EfficiencyLib for uint256;
    using RegistrationLib for address;
    using ValidityLib for uint96;
    using ValidityLib for uint256;
    using ValidityLib for bytes32;
    using FunctionCastLib for function(bytes32, BasicClaim calldata, address) internal view;
    using FunctionCastLib for function(bytes32, bytes32, QualifiedClaim calldata, address) internal view;
    using FunctionCastLib for function(QualifiedClaim calldata) internal returns (bytes32, address);
    using FunctionCastLib for function(QualifiedClaimWithWitness calldata) internal returns (bytes32, address);
    using FunctionCastLib for function(bytes32, uint256, uint256, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using FunctionCastLib for function(bytes32, uint256, uint256, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using FunctionCastLib for function(bytes32, bytes32, uint256, uint256, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);
    using FunctionCastLib for function(bytes32, bytes32, uint256, uint256, bytes32, bytes32, function(address, address, uint256, uint256) internal returns (bool)) internal returns (bool);

    /// @dev `keccak256(bytes("Claim(address,address,address,bytes32)"))`.
    uint256 private constant _CLAIM_EVENT_SIGNATURE = 0x770c32a2314b700d6239ee35ba23a9690f2fceb93a55d8c753e953059b3b18d4;

    ///// 1. Claims /////
    function _processBasicClaim(BasicClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleClaim.usingBasicClaim()(claimPayload.toMessageHash(), claimPayload, uint256(0xa0).asStubborn(), _typehashes(uint256(0).asStubborn()), operation);
    }

    function _processQualifiedClaim(QualifiedClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processClaimWithQualification.usingQualifiedClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, _typehashes(uint256(0).asStubborn()), operation);
    }

    function _processClaimWithWitness(ClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleClaim.usingClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedClaimWithWitness(QualifiedClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processClaimWithQualification.usingQualifiedClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    function _processSplitClaim(SplitClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleSplitClaim.usingSplitClaim()(claimPayload.toMessageHash(), claimPayload, 0xa0, _typehashes(uint256(0).asStubborn()), operation);
    }

    function _processQualifiedSplitClaim(QualifiedSplitClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualification.usingQualifiedSplitClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, _typehashes(uint256(0).asStubborn()), operation);
    }

    function _processSplitClaimWithWitness(SplitClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleSplitClaim.usingSplitClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedSplitClaimWithWitness(QualifiedSplitClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualification.usingQualifiedSplitClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    ///// 2. Batch Claims /////
    function _processBatchClaim(BatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleBatchClaim.usingBatchClaim()(claimPayload.toMessageHash(), claimPayload, 0xa0, _typehashes(uint256(1).asStubborn()), operation);
    }

    function _processQualifiedBatchClaim(QualifiedBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualification.usingQualifiedBatchClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, _typehashes(uint256(1).asStubborn()), operation);
    }

    function _processBatchClaimWithWitness(BatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleBatchClaim.usingBatchClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedBatchClaimWithWitness(QualifiedBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualification.usingQualifiedBatchClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    function _processSplitBatchClaim(SplitBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleSplitBatchClaim.usingSplitBatchClaim()(claimPayload.toMessageHash(), claimPayload, 0xa0, _typehashes(uint256(1).asStubborn()), operation);
    }

    function _processQualifiedSplitBatchClaim(QualifiedSplitBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchClaim()(messageHash, qualificationMessageHash, claimPayload, 0xe0, _typehashes(uint256(1).asStubborn()), operation);
    }

    function _processSplitBatchClaimWithWitness(SplitBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleSplitBatchClaim.usingSplitBatchClaimWithWitness()(messageHash, claimPayload, 0xe0, typehash, operation);
    }

    function _processQualifiedSplitBatchClaimWithWitness(QualifiedSplitBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x120, typehash, operation);
    }

    ///// 3. Multichain Claims /////
    function _processMultichainClaim(MultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleClaim.usingMultichainClaim()(claimPayload.toMessageHash(), claimPayload, 0xc0, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processQualifiedMultichainClaim(QualifiedMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processClaimWithQualification.usingQualifiedMultichainClaim()(messageHash, qualificationMessageHash, claimPayload, 0x100, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processMultichainClaimWithWitness(MultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleClaim.usingMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedMultichainClaimWithWitness(QualifiedMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processClaimWithQualification.usingQualifiedMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    function _processSplitMultichainClaim(SplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleSplitClaim.usingSplitMultichainClaim()(claimPayload.toMessageHash(), claimPayload, 0xc0, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processQualifiedSplitMultichainClaim(QualifiedSplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualification.usingQualifiedSplitMultichainClaim()(messageHash, qualificationMessageHash, claimPayload, 0x100, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processSplitMultichainClaimWithWitness(SplitMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleSplitClaim.usingSplitMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedSplitMultichainClaimWithWitness(
        QualifiedSplitMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualification.usingQualifiedSplitMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    ///// 4. Batch Multichain Claims /////
    function _processBatchMultichainClaim(BatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processSimpleBatchClaim.usingBatchMultichainClaim()(claimPayload.toMessageHash(), claimPayload, 0xc0, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processQualifiedBatchMultichainClaim(QualifiedBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualification.usingQualifiedBatchMultichainClaim()(messageHash, qualificationMessageHash, claimPayload, 0x100, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processBatchMultichainClaimWithWitness(BatchMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleBatchClaim.usingBatchMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedBatchMultichainClaimWithWitness(
        QualifiedBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualification.usingQualifiedBatchMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    function _processSplitBatchMultichainClaim(SplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSimpleSplitBatchClaim.usingSplitBatchMultichainClaim()(claimPayload.toMessageHash(), claimPayload, 0xc0, _typehashes(uint256(2).asStubborn()), operation);
    }

    function _processQualifiedSplitBatchMultichainClaim(QualifiedSplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x100, _typehashes(uint256(1).asStubborn()), operation
        );
    }

    function _processSplitBatchMultichainClaimWithWitness(SplitBatchMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSimpleSplitBatchClaim.usingSplitBatchMultichainClaimWithWitness()(messageHash, claimPayload, 0x100, typehash, operation);
    }

    function _processQualifiedSplitBatchMultichainClaimWithWitness(
        QualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualification.usingQualifiedSplitBatchMultichainClaimWithWitness()(messageHash, qualificationMessageHash, claimPayload, 0x140, typehash, operation);
    }

    ///// 5. Exogenous Multichain Claims /////
    function _processExogenousMultichainClaim(ExogenousMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return _processClaimWithSponsorDomain.usingExogenousMultichainClaim()(
            claimPayload.toMessageHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousQualifiedMultichainClaim(ExogenousQualifiedMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousMultichainClaimWithWitness(ExogenousMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return
            _processClaimWithSponsorDomain.usingExogenousMultichainClaimWithWitness()(messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation);
    }

    function _processExogenousQualifiedMultichainClaimWithWitness(
        ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousSplitMultichainClaim(ExogenousSplitMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSplitClaimWithSponsorDomain.usingExogenousSplitMultichainClaim()(
            claimPayload.toMessageHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousQualifiedSplitMultichainClaim(
        ExogenousQualifiedSplitMultichainClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousSplitMultichainClaimWithWitness(
        ExogenousSplitMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitClaimWithSponsorDomain.usingExogenousSplitMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousQualifiedSplitMultichainClaimWithWitness(
        ExogenousQualifiedSplitMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
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
            claimPayload.toMessageHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousQualifiedBatchMultichainClaim(
        ExogenousQualifiedBatchMultichainClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedBatchMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousBatchMultichainClaimWithWitness(
        ExogenousBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processBatchClaimWithSponsorDomain.usingExogenousBatchMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousQualifiedBatchMultichainClaimWithWitness(
        ExogenousQualifiedBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedBatchMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousSplitBatchMultichainClaim(ExogenousSplitBatchMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSplitBatchClaimWithSponsorDomain.usingExogenousSplitBatchMultichainClaim()(
            claimPayload.toMessageHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousQualifiedSplitBatchMultichainClaim(
        ExogenousQualifiedSplitBatchMultichainClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitBatchMultichainClaim()(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), _typehashes(uint256(2).asStubborn()), operation
        );
    }

    function _processExogenousSplitBatchMultichainClaimWithWitness(
        ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithSponsorDomain.usingExogenousSplitBatchMultichainClaimWithWitness()(
            messageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    function _processExogenousQualifiedSplitBatchMultichainClaimWithWitness(
        ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) = claimPayload.toMessageHash();
        return _processSplitBatchClaimWithQualificationAndSponsorDomain.usingExogenousQualifiedSplitBatchMultichainClaimWithWitness()(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), typehash, operation
        );
    }

    ///// 7. Private Helpers /////
    function _validate(uint96 allocatorId, bytes32 messageHash, bytes32 qualificationMessageHash, uint256 calldataPointer, bytes32 sponsorDomainSeparator, bytes32 typehash)
        private
        returns (address sponsor)
    {
        bytes calldata allocatorSignature;
        bytes calldata sponsorSignature;
        uint256 nonce;
        uint256 expires;

        assembly ("memory-safe") {
            let allocatorSignaturePtr := add(calldataPointer, calldataload(calldataPointer))
            allocatorSignature.offset := add(0x20, allocatorSignaturePtr)
            allocatorSignature.length := calldataload(allocatorSignaturePtr)

            let sponsorSignaturePtr := add(calldataPointer, calldataload(add(calldataPointer, 0x20)))
            sponsorSignature.offset := add(0x20, sponsorSignaturePtr)
            sponsorSignature.length := calldataload(sponsorSignaturePtr)

            sponsor := shr(96, shl(96, calldataload(add(calldataPointer, 0x40))))
            nonce := calldataload(add(calldataPointer, 0x60))
            expires := calldataload(add(calldataPointer, 0x80))
        }

        expires.later();

        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(nonce);

        bytes32 domainSeparator = _domainSeparator();
        assembly ("memory-safe") {
            sponsorDomainSeparator := add(sponsorDomainSeparator, mul(iszero(sponsorDomainSeparator), domainSeparator))
        }

        if ((sponsorDomainSeparator != domainSeparator).or(sponsorSignature.length != 0) || sponsor.hasNoActiveRegistration(messageHash, typehash)) {
            messageHash.signedBy(sponsor, sponsorSignature, sponsorDomainSeparator);
        }
        qualificationMessageHash.signedBy(allocator, allocatorSignature, domainSeparator);

        _emitClaim(sponsor, messageHash, allocator);
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

    function _processClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        uint256 id;
        uint256 allocatedAmount;
        address claimant;
        uint256 amount;

        assembly ("memory-safe") {
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))
            claimant := shr(96, shl(96, calldataload(add(calldataPointerWithOffset, 0x40))))
            amount := calldataload(add(calldataPointerWithOffset, 0x60))
        }

        _ensureValidScope(sponsorDomainSeparator, id);

        amount.withinAllocated(allocatedAmount);

        return operation(_validate(id.toAllocatorId(), messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash), claimant, id, amount);
    }

    function _processSplitClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        uint256 id;
        uint256 allocatedAmount;
        SplitComponent[] calldata claimants;

        assembly ("memory-safe") {
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))

            let claimantsPtr := add(calldataPointer, calldataload(add(calldataPointerWithOffset, 0x40)))
            claimants.offset := add(0x20, claimantsPtr)
            claimants.length := calldataload(claimantsPtr)
        }

        address sponsor = _validate(id.toAllocatorId(), messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash);

        _ensureValidScope(sponsorDomainSeparator, id);

        return _verifyAndProcessSplitComponents(sponsor, id, allocatedAmount, claimants, operation);
    }

    function _processBatchClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        BatchClaimComponent[] calldata claims;
        address claimant;
        assembly ("memory-safe") {
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)
            let claimsPtr := add(calldataPointer, calldataload(calldataPointerWithOffset))
            claims.offset := add(0x20, claimsPtr)
            claims.length := calldataload(claimsPtr)

            claimant := calldataload(add(calldataPointerWithOffset, 0x20))
        }

        uint96 firstAllocatorId = claims[0].id.toAllocatorId();

        address sponsor = _validate(firstAllocatorId, messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash);

        uint256 totalClaims = claims.length;

        assembly ("memory-safe") {
            if iszero(totalClaims) {
                // revert InvalidBatchAllocation()
                mstore(0, 0x3a03d3bb)
                revert(0x1c, 0x04)
            }
        }

        // NOTE: many of the bounds checks on these array accesses can be skipped as an optimization
        BatchClaimComponent calldata component = claims[0];
        uint256 id = component.id;
        uint256 amount = component.amount;
        uint256 errorBuffer = (component.allocatedAmount < amount).or((sponsorDomainSeparator != bytes32(0)).and(id.toScope() == Scope.ChainSpecific)).asUint256();

        operation(sponsor, claimant, id, amount);

        unchecked {
            for (uint256 i = 1; i < totalClaims; ++i) {
                component = claims[i];
                id = component.id;
                amount = component.amount;
                errorBuffer |=
                    (id.toAllocatorId() != firstAllocatorId).or(component.allocatedAmount < amount).or((sponsorDomainSeparator != bytes32(0)).and(id.toScope() == Scope.ChainSpecific)).asUint256();

                operation(sponsor, claimant, id, amount);
            }

            if (errorBuffer.asBool()) {
                for (uint256 i = 0; i < totalClaims; ++i) {
                    component = claims[i];
                    component.amount.withinAllocated(component.allocatedAmount);
                    id = component.id;
                    _ensureValidScope(sponsorDomainSeparator, component.id);
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

    function _processSplitBatchClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        bytes32 typehash,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        SplitBatchClaimComponent[] calldata claims;
        assembly ("memory-safe") {
            let claimsPtr := add(calldataPointer, calldataload(add(calldataPointer, offsetToId)))
            claims.offset := add(0x20, claimsPtr)
            claims.length := calldataload(claimsPtr)
        }

        uint96 firstAllocatorId = claims[0].id.toAllocatorId();

        address sponsor = _validate(firstAllocatorId, messageHash, qualificationMessageHash, calldataPointer, sponsorDomainSeparator, typehash);

        uint256 totalClaims = claims.length;
        uint256 errorBuffer = (totalClaims == 0).asUint256();
        uint256 id;

        unchecked {
            for (uint256 i = 0; i < totalClaims; ++i) {
                SplitBatchClaimComponent calldata claimComponent = claims[i];
                id = claimComponent.id;
                errorBuffer |= (id.toAllocatorId() != firstAllocatorId).or((sponsorDomainSeparator != bytes32(0)).and(id.toScope() == Scope.ChainSpecific)).asUint256();

                _verifyAndProcessSplitComponents(sponsor, id, claimComponent.allocatedAmount, claimComponent.portions, operation);
            }

            if (errorBuffer.asBool()) {
                for (uint256 i = 0; i < totalClaims; ++i) {
                    _ensureValidScope(sponsorDomainSeparator, claims[i].id);
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

    function _verifyAndProcessSplitComponents(
        address sponsor,
        uint256 id,
        uint256 allocatedAmount,
        SplitComponent[] calldata claimants,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) private returns (bool) {
        uint256 totalClaims = claimants.length;
        uint256 spentAmount = 0;
        uint256 errorBuffer = (totalClaims == 0).asUint256();

        unchecked {
            for (uint256 i = 0; i < totalClaims; ++i) {
                SplitComponent calldata component = claimants[i];
                uint256 amount = component.amount;

                uint256 updatedSpentAmount = amount + spentAmount;
                errorBuffer |= (updatedSpentAmount < spentAmount).asUint256();
                spentAmount = updatedSpentAmount;

                operation(sponsor, component.claimant, id, amount);
            }
        }

        errorBuffer |= (allocatedAmount < spentAmount).asUint256();
        assembly ("memory-safe") {
            if errorBuffer {
                // revert AllocatedAmountExceeded(allocatedAmount, amount);
                mstore(0, 0x3078b2f6)
                mstore(0x20, allocatedAmount)
                mstore(0x40, spentAmount)
                revert(0x1c, 0x44)
            }
        }

        return true;
    }

    function _ensureValidScope(bytes32 sponsorDomainSeparator, uint256 id) private pure {
        assembly ("memory-safe") {
            if iszero(or(iszero(sponsorDomainSeparator), iszero(shr(255, id)))) {
                // revert InvalidScope(id)
                mstore(0, 0xa06356f5)
                mstore(0x20, id)
                revert(0x1c, 0x24)
            }
        }
    }

    function _typehashes(uint256 i) private pure returns (bytes32 typehash) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(0, COMPACT_TYPEHASH)
            mstore(0x20, BATCH_COMPACT_TYPEHASH)
            mstore(0x40, MULTICHAIN_COMPACT_TYPEHASH)
            typehash := mload(shl(5, i))
            mstore(0x40, m)
        }
    }
}

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

/**
 * @title The Compact Claims Interface
 * @custom:version 0 (early-stage proof-of-concept)
 * @author 0age (0age.eth)
 * @notice Claim endpoints can only be called by the arbiter indicated on the associated
 *         compact, and are used to settle the compact in question.
 */
interface ITheCompactClaims {
    function claim(BasicClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(BasicClaim calldata claimPayload) external returns (bool);

    function claim(QualifiedClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedClaim calldata claimPayload) external returns (bool);

    function claim(ClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(QualifiedClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(SplitClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(SplitClaim calldata claimPayload) external returns (bool);

    function claim(QualifiedSplitClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedSplitClaim calldata claimPayload) external returns (bool);

    function claim(SplitClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(SplitClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(QualifiedSplitClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedSplitClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(BatchClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(BatchClaim calldata claimPayload) external returns (bool);

    function claim(QualifiedBatchClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedBatchClaim calldata claimPayload) external returns (bool);

    function claim(BatchClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(BatchClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(QualifiedBatchClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedBatchClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(SplitBatchClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(SplitBatchClaim calldata claimPayload) external returns (bool);

    function claim(QualifiedSplitBatchClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedSplitBatchClaim calldata claimPayload) external returns (bool);

    function claim(SplitBatchClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(SplitBatchClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(QualifiedSplitBatchClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedSplitBatchClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(MultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(MultichainClaim calldata claimPayload) external returns (bool);

    function claim(ExogenousMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousMultichainClaim calldata claimPayload) external returns (bool);

    function claim(QualifiedMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedMultichainClaim calldata claimPayload) external returns (bool);

    function claim(ExogenousQualifiedMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousQualifiedMultichainClaim calldata claimPayload) external returns (bool);

    function claim(MultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(MultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(ExogenousMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(QualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(SplitMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(SplitMultichainClaim calldata claimPayload) external returns (bool);

    function claim(ExogenousSplitMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousSplitMultichainClaim calldata claimPayload) external returns (bool);

    function claim(QualifiedSplitMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedSplitMultichainClaim calldata claimPayload) external returns (bool);

    function claim(ExogenousQualifiedSplitMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousQualifiedSplitMultichainClaim calldata claimPayload) external returns (bool);

    function claim(SplitMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(SplitMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(ExogenousSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(QualifiedSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(ExogenousQualifiedSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousQualifiedSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(BatchMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(BatchMultichainClaim calldata claimPayload) external returns (bool);

    function claim(ExogenousBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claim(QualifiedBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claim(ExogenousQualifiedBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousQualifiedBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claim(BatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(BatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(ExogenousBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(QualifiedBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(ExogenousQualifiedBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousQualifiedBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(SplitBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(SplitBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claim(ExogenousSplitBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousSplitBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claim(QualifiedSplitBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedSplitBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claim(ExogenousQualifiedSplitBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousQualifiedSplitBatchMultichainClaim calldata claimPayload) external returns (bool);

    function claim(SplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(SplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(QualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(QualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claim(ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);

    function claimAndWithdraw(ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool);
}

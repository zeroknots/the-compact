// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ITheCompactClaims } from "../interfaces/ITheCompactClaims.sol";
import { ClaimProcessorLogic } from "./ClaimProcessorLogic.sol";

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
 * @title ClaimProcessor
 * @notice Inherited contract implementing external functions for processing claims against
 * a signed or registered compact. Each of these functions is only callable by the arbiter
 * indicated by the respective compact.
 */
contract ClaimProcessor is ITheCompactClaims, ClaimProcessorLogic {
    function claim(BasicClaim calldata claimPayload) external returns (bool) {
        return _processBasicClaim(claimPayload, _release);
    }

    function claimAndWithdraw(BasicClaim calldata claimPayload) external returns (bool) {
        return _processBasicClaim(claimPayload, _withdraw);
    }

    function claim(ClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(SplitClaim calldata claimPayload) external returns (bool) {
        return _processSplitClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitClaim calldata claimPayload) external returns (bool) {
        return _processSplitClaim(claimPayload, _withdraw);
    }

    function claim(SplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(BatchClaim calldata claimPayload) external returns (bool) {
        return _processBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(BatchClaim calldata claimPayload) external returns (bool) {
        return _processBatchClaim(claimPayload, _withdraw);
    }

    function claim(BatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(BatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(SplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaim(claimPayload, _withdraw);
    }

    function claim(SplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(MultichainClaim calldata claimPayload) external returns (bool) {
        return _processMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(MultichainClaim calldata claimPayload) external returns (bool) {
        return _processMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaim(claimPayload, _withdraw);
    }

    function claim(MultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(MultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(SplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processSplitMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processSplitMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousSplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousSplitMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousSplitMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousSplitMultichainClaim(claimPayload, _withdraw);
    }

    function claim(SplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousSplitMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousSplitMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousSplitMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(BatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(BatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(BatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(BatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(SplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(ExogenousSplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousSplitBatchMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousSplitBatchMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousSplitBatchMultichainClaim(claimPayload, _withdraw);
    }

    function claim(SplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousSplitBatchMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousSplitBatchMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousSplitBatchMultichainClaimWithWitness(claimPayload, _withdraw);
    }
}

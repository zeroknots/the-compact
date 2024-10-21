// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ForcedWithdrawalStatus } from "../types/ForcedWithdrawalStatus.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";
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

/**
 * @title The Compact
 * @custom:version 0 (early-stage proof-of-concept)
 * @author 0age (0age.eth)
 * @notice The Compact is an ownerless ERC6909 contract that facilitates the voluntary
 *         formation (and, if necessary, involuntary dissolution) of "resource locks."
 *         This contract has not yet been properly tested, audited, or reviewed.
 */
interface ITheCompact {
    event Deposit(address indexed depositor, address indexed recipient, uint256 indexed id, uint256 depositedAmount);
    event Claim(address indexed sponsor, address indexed allocator, address indexed arbiter, bytes32 claimHash);
    event Withdrawal(address indexed account, address indexed recipient, uint256 indexed id, uint256 withdrawnAmount);
    event ForcedWithdrawalEnabled(address indexed account, uint256 indexed id, uint256 withdrawableAt);
    event ForcedWithdrawalDisabled(address indexed account, uint256 indexed id);
    event AllocatorRegistered(uint96 allocatorId, address allocator);

    error InvalidToken(address token);
    error Expired(uint256 expiration);
    error InvalidSignature();
    error PrematureWithdrawal(uint256 id);
    error ForcedWithdrawalAlreadyDisabled(address account, uint256 id);
    error UnallocatedTransfer(address operator, address from, address to, uint256 id, uint256 amount);
    error InvalidBatchAllocation();
    error InvalidRegistrationProof(address allocator);
    error InvalidBatchDepositStructure();
    error AllocatedAmountExceeded(uint256 allocatedAmount, uint256 providedAmount);
    error InvalidScope(uint256 id);
    error InvalidDepositTokenOrdering();
    error InvalidDepositBalanceChange();

    function deposit(address allocator) external payable returns (uint256 id);

    function deposit(address token, address allocator, uint256 amount) external returns (uint256 id);

    function deposit(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient) external payable returns (uint256 id);

    function deposit(address token, address allocator, ResetPeriod resetPeriod, Scope scope, uint256 amount, address recipient) external returns (uint256 id);

    function deposit(uint256[2][] calldata idsAndAmounts, address recipient) external payable returns (bool);

    function deposit(
        address token,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        address depositor,
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        address recipient,
        bytes calldata signature
    ) external returns (uint256 id);

    function deposit(
        address depositor,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        address recipient,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external payable returns (uint256[] memory ids);

    function allocatedTransfer(BasicTransfer calldata transfer) external returns (bool);

    function allocatedWithdrawal(BasicTransfer calldata withdrawal) external returns (bool);

    function allocatedTransfer(SplitTransfer calldata transfer) external returns (bool);

    function allocatedWithdrawal(SplitTransfer calldata withdrawal) external returns (bool);

    function allocatedTransfer(BatchTransfer calldata transfer) external returns (bool);

    function allocatedWithdrawal(BatchTransfer calldata withdrawal) external returns (bool);

    function allocatedTransfer(SplitBatchTransfer calldata transfer) external returns (bool);

    function allocatedWithdrawal(SplitBatchTransfer calldata withdrawal) external returns (bool);

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

    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt);

    function disableForcedWithdrawal(uint256 id) external returns (bool);

    function forcedWithdrawal(uint256 id, address recipient, uint256 amount) external returns (bool);

    function __register(address allocator, bytes calldata proof) external returns (uint96 allocatorId);

    function getForcedWithdrawalStatus(address account, uint256 id) external view returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt);

    function getLockDetails(uint256 id) external view returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope);

    function check(uint256 nonce, address allocator) external view returns (bool consumed);

    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator);

    /// @dev Returns the name for the contract.
    function name() external pure returns (string memory);
}

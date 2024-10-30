// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ForcedWithdrawalStatus } from "../types/ForcedWithdrawalStatus.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";
import { CompactCategory } from "../types/CompactCategory.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";
import { BasicTransfer, SplitTransfer } from "../types/Claims.sol";

import { BatchTransfer, SplitBatchTransfer } from "../types/BatchClaims.sol";

/**
 * @title The Compact
 * @custom:version 0 (early-stage proof-of-concept)
 * @author 0age (0age.eth)
 * @notice The Compact is an ownerless ERC6909 contract that facilitates the voluntary
 *         formation (and, if necessary, involuntary dissolution) of "resource locks."
 *         This contract has not yet been properly tested, audited, or reviewed.
 */
interface ITheCompact {
    event Claim(address indexed sponsor, address indexed allocator, address indexed arbiter, bytes32 claimHash);
    event ForcedWithdrawalEnabled(address indexed account, uint256 indexed id, uint256 withdrawableAt);
    event ForcedWithdrawalDisabled(address indexed account, uint256 indexed id);
    event CompactRegistered(address indexed sponsor, bytes32 claimHash, bytes32 typehash, uint256 expires);
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
    error Permit2CallFailed();
    error InvalidRegistrationDuration(uint256 duration);

    function deposit(address allocator) external payable returns (uint256 id);

    function depositAndRegister(address allocator, bytes32 claimHash, bytes32 typehash) external payable returns (uint256 id);

    function deposit(address token, address allocator, uint256 amount) external returns (uint256 id);

    function depositAndRegister(address token, address allocator, uint256 amount, bytes32 claimHash, bytes32 typehash) external returns (uint256 id);

    function deposit(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient) external payable returns (uint256 id);

    function deposit(address token, address allocator, ResetPeriod resetPeriod, Scope scope, uint256 amount, address recipient) external returns (uint256 id);

    function deposit(uint256[2][] calldata idsAndAmounts, address recipient) external payable returns (bool);

    function depositAndRegister(uint256[2][] calldata idsAndAmounts, bytes32[2][] calldata claimHashesAndTypehashes, uint256 duration) external payable returns (bool);

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

    function depositAndRegister(
        address token,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        address depositor,
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        bytes32 claimHash,
        CompactCategory compactCategory,
        string calldata witness,
        bytes calldata signature
    ) external returns (uint256 id);

    function allocatedTransfer(BasicTransfer calldata transfer) external returns (bool);

    function allocatedWithdrawal(BasicTransfer calldata withdrawal) external returns (bool);

    /*
    function allocatedTransfer(SplitTransfer calldata transfer) external returns (bool);

    function allocatedWithdrawal(SplitTransfer calldata withdrawal) external returns (bool);

    function allocatedTransfer(BatchTransfer calldata transfer) external returns (bool);

    function allocatedWithdrawal(BatchTransfer calldata withdrawal) external returns (bool);
    */

    function allocatedTransfer(SplitBatchTransfer calldata transfer) external returns (bool);

    function allocatedWithdrawal(SplitBatchTransfer calldata withdrawal) external returns (bool);

    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt);

    function disableForcedWithdrawal(uint256 id) external returns (bool);

    function forcedWithdrawal(uint256 id, address recipient, uint256 amount) external returns (bool);

    function register(bytes32 claimHash, bytes32 typehash, uint256 duration) external returns (bool);

    function register(bytes32[2][] calldata claimHashesAndTypehashes, uint256 duration) external returns (bool);

    function consume(uint256[] calldata nonces) external returns (bool);

    function __registerAllocator(address allocator, bytes calldata proof) external returns (uint96 allocatorId);

    function getForcedWithdrawalStatus(address account, uint256 id) external view returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt);

    function getRegistrationStatus(address sponsor, bytes32 claimHash, bytes32 typehash) external view returns (bool isActive, uint256 expires);

    function getLockDetails(uint256 id) external view returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope);

    function hasConsumedAllocatorNonce(uint256 nonce, address allocator) external view returns (bool consumed);

    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator);

    /// @dev Returns the name for the contract.
    function name() external pure returns (string memory);
}

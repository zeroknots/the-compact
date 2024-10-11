// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ForcedWithdrawalStatus } from "../types/ForcedWithdrawalStatus.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";
import { Claim, BasicTransfer } from "../types/Claims.sol";
import { BatchClaim } from "../types/BatchClaims.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";

/**
 * @title The Compact
 * @custom:version 1 (early-stage proof-of-concept)
 * @author 0age (0age.eth)
 * @notice The Compact is an ownerless ERC6909 contract that facilitates the voluntary
 *         formation (and, if necessary, involuntary dissolution) of "resource locks."
 *         This contract has not yet been properly tested, audited, or reviewed.
 */
interface ITheCompact {
    event Deposit(
        address indexed depositor,
        address indexed recipient,
        uint256 indexed id,
        uint256 depositedAmount
    );
    event Claimed(
        address indexed sponsor,
        address indexed claimant,
        uint256 indexed id,
        bytes32 claimHash,
        uint256 claimAmount
    );
    event Withdrawal(
        address indexed account,
        address indexed recipient,
        uint256 indexed id,
        uint256 withdrawnAmount
    );
    event ForcedWithdrawalEnabled(
        address indexed account, uint256 indexed id, uint256 withdrawableAt
    );
    event ForcedWithdrawalDisabled(address indexed account, uint256 indexed id);
    event AllocatorRegistered(uint96 allocatorId, address allocator);

    error InvalidToken(address token);
    error Expired(uint256 expiration);
    error InvalidSignature();
    error PrematureWithdrawal(uint256 id);
    error ForcedWithdrawalAlreadyDisabled(address account, uint256 id);
    error UnallocatedTransfer(
        address operator, address from, address to, uint256 id, uint256 amount
    );
    error InvalidBatchAllocation();
    error InvalidRegistrationProof(address allocator);
    error InvalidBatchDepositStructure();
    error AllocatedAmountExceeded(uint256 allocatedAmount, uint256 providedAmount);

    function deposit(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient)
        external
        payable
        returns (uint256 id);

    function deposit(
        address token,
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        uint256 amount,
        address recipient
    ) external returns (uint256 id);

    function deposit(
        address depositor,
        address token,
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        uint256 amount,
        address recipient,
        uint256 nonce,
        uint256 deadline,
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

    function allocatedTransfer(BasicTransfer memory transfer) external returns (bool);

    function allocatedWithdrawal(BasicTransfer memory transfer) external returns (bool);

    function claim(Claim memory claim) external returns (bool);

    function claim(BatchClaim memory claim) external returns (bool);

    function claimAndWithdraw(Claim memory claim) external returns (bool);

    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt);

    function disableForcedWithdrawal(uint256 id) external returns (bool);

    function forcedWithdrawal(uint256 id, address recipient)
        external
        returns (uint256 withdrawnAmount);

    function __register(address allocator, bytes calldata proof)
        external
        returns (uint96 allocatorId);

    function getForcedWithdrawalStatus(address account, uint256 id)
        external
        view
        returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt);

    function getLockDetails(uint256 id)
        external
        view
        returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope);

    function check(uint256 nonce, address allocator) external view returns (bool consumed);

    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator);

    function extsload(bytes32 slot) external view returns (bytes32);

    function extsload(bytes32 startSlot, uint256 nSlots) external view returns (bytes32[] memory);

    function extsload(bytes32[] calldata slots) external view returns (bytes32[] memory);

    /// @dev Returns the name for the contract.
    function name() external pure returns (string memory);
}

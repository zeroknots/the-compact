// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ITheCompact } from "./interfaces/ITheCompact.sol";
import { Lock } from "./types/Lock.sol";
import { Scope } from "./types/Scope.sol";
import { ResetPeriod } from "./types/ResetPeriod.sol";
import { ForcedWithdrawalStatus } from "./types/ForcedWithdrawalStatus.sol";
import { IdLib } from "./lib/IdLib.sol";
import { EfficiencyLib } from "./lib/EfficiencyLib.sol";
import { FunctionCastLib } from "./lib/FunctionCastLib.sol";
import { HashLib } from "./lib/HashLib.sol";
import { MetadataLib } from "./lib/MetadataLib.sol";
import { ValidityLib } from "./lib/ValidityLib.sol";
import { Extsload } from "./lib/Extsload.sol";
import { ERC6909 } from "solady/tokens/ERC6909.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { IPermit2 } from "permit2/src/interfaces/IPermit2.sol";
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
} from "./types/Claims.sol";

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
} from "./types/BatchClaims.sol";

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
} from "./types/MultichainClaims.sol";

import { SplitComponent, TransferComponent, SplitByIdComponent, BatchClaimComponent, SplitBatchClaimComponent } from "./types/Components.sol";

import { IAllocator } from "./interfaces/IAllocator.sol";
import { MetadataRenderer } from "./lib/MetadataRenderer.sol";

/**
 * @title The Compact
 * @custom:version 1 (early-stage proof-of-concept)
 * @author 0age (0age.eth)
 * @notice The Compact is an ownerless ERC6909 contract that facilitates the voluntary
 *         formation (and, if necessary, involuntary dissolution) of "resource locks."
 *         This contract has not yet been properly tested, audited, or reviewed.
 */
contract TheCompact is ITheCompact, ERC6909, Extsload {
    using HashLib for address;
    using HashLib for bytes32;
    using HashLib for uint256;
    using HashLib for BasicTransfer;
    using HashLib for SplitTransfer;
    using HashLib for BasicClaim;
    using HashLib for QualifiedClaim;
    using HashLib for ClaimWithWitness;
    using HashLib for QualifiedClaimWithWitness;
    using HashLib for SplitClaim;
    using HashLib for SplitClaimWithWitness;
    using HashLib for QualifiedSplitClaim;
    using HashLib for QualifiedSplitClaimWithWitness;
    using HashLib for BatchTransfer;
    using HashLib for SplitBatchTransfer;
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
    using IdLib for uint96;
    using IdLib for uint256;
    using IdLib for address;
    using IdLib for Lock;
    using IdLib for ResetPeriod;
    using MetadataLib for address;
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    using EfficiencyLib for bool;
    using EfficiencyLib for uint256;
    using ValidityLib for address;
    using ValidityLib for uint96;
    using ValidityLib for uint256;
    using ValidityLib for bytes32;
    using FunctionCastLib for function(bytes32, address, BasicTransfer calldata) internal view;
    using FunctionCastLib for function(TransferComponent[] memory, uint256) internal returns (address);
    using FunctionCastLib for function(bytes32, BasicClaim calldata, address) internal view;
    using FunctionCastLib for function(bytes32, bytes32, QualifiedClaim calldata, address) internal view;
    using FunctionCastLib for function(QualifiedClaim calldata) internal returns (bytes32, address);
    using FunctionCastLib for function(QualifiedClaimWithWitness calldata) internal returns (bytes32, address);

    IPermit2 private constant _PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    /// @dev `keccak256(bytes("Transfer(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE = 0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    /// @dev `keccak256(bytes("Claim(address,address,address,bytes32)"))`.
    uint256 private constant _CLAIM_EVENT_SIGNATURE = 0x770c32a2314b700d6239ee35ba23a9690f2fceb93a55d8c753e953059b3b18d4;

    /// @dev `keccak256(bytes("Deposit(address,address,uint256,uint256)"))`.
    uint256 private constant _DEPOSIT_EVENT_SIGNATURE = 0xdcbc1c05240f31ff3ad067ef1ee35ce4997762752e3a095284754544f4c709d7;

    /// @dev `keccak256(bytes("Withdrawal(address,address,uint256,uint256)"))`.
    uint256 private constant _WITHDRAWAL_EVENT_SIGNATURE = 0xc2b4a290c20fb28939d29f102514fbffd2b73c059ffba8b78250c94161d5fcc6;

    // Rage-quit functionality (TODO: optimize storage layout)
    mapping(address => mapping(uint256 => uint256)) private _cutoffTime;

    uint256 private immutable _INITIAL_CHAIN_ID;
    bytes32 private immutable _INITIAL_DOMAIN_SEPARATOR;
    MetadataRenderer private immutable _METADATA_RENDERER;

    constructor() {
        _INITIAL_CHAIN_ID = block.chainid;
        _INITIAL_DOMAIN_SEPARATOR = keccak256(abi.encode(HashLib._DOMAIN_TYPEHASH, HashLib._NAME_HASH, HashLib._VERSION_HASH, block.chainid, address(this)));
        _METADATA_RENDERER = new MetadataRenderer();
    }

    function deposit(address allocator) external payable returns (uint256 id) {
        id = address(0).toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        _deposit(msg.sender, msg.sender, id, msg.value);
    }

    function deposit(address token, address allocator, uint256 amount) external returns (uint256 id) {
        id = token.excludingNative().toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        token.safeTransferFrom(msg.sender, address(this), amount);

        _deposit(msg.sender, msg.sender, id, amount);
    }

    function deposit(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient) external payable returns (uint256 id) {
        id = address(0).toIdIfRegistered(scope, resetPeriod, allocator);

        _deposit(msg.sender, recipient, id, msg.value);
    }

    function deposit(address token, address allocator, ResetPeriod resetPeriod, Scope scope, uint256 amount, address recipient) external returns (uint256 id) {
        id = token.excludingNative().toIdIfRegistered(scope, resetPeriod, allocator);

        token.safeTransferFrom(msg.sender, address(this), amount);

        _deposit(msg.sender, recipient, id, amount);
    }

    function deposit(uint256[2][] calldata idsAndAmounts, address recipient) external payable returns (bool) {
        uint256 totalIds = idsAndAmounts.length;
        bool firstUnderlyingTokenIsNative;
        uint256 id;

        assembly ("memory-safe") {
            let idsAndAmountsOffset := idsAndAmounts.offset
            id := calldataload(idsAndAmountsOffset)
            firstUnderlyingTokenIsNative := iszero(shr(96, shl(96, id)))
            // Revert if:
            //  * the array is empty
            //  * the callvalue is zero but the first token is native
            //  * the callvalue is nonzero but the first token is non-native
            //  * the first token is non-native and the callvalue doesn't equal the first amount
            if or(iszero(totalIds), or(eq(firstUnderlyingTokenIsNative, iszero(callvalue())), and(firstUnderlyingTokenIsNative, iszero(eq(callvalue(), calldataload(add(idsAndAmountsOffset, 0x20)))))))
            {
                // revert InvalidBatchDepositStructure()
                mstore(0, 0xca0fc08e)
                revert(0x1c, 0x04)
            }
        }

        uint96 currentAllocatorId = id.toRegisteredAllocatorId();

        if (firstUnderlyingTokenIsNative) {
            _deposit(msg.sender, recipient, id, msg.value);
        }

        unchecked {
            for (uint256 i = firstUnderlyingTokenIsNative.asUint256(); i < totalIds; ++i) {
                uint256[2] calldata idAndAmount = idsAndAmounts[i];
                id = idAndAmount[0];
                uint256 amount = idAndAmount[1];

                uint96 newAllocatorId = id.toAllocatorId();
                if (newAllocatorId != currentAllocatorId) {
                    newAllocatorId.mustHaveARegisteredAllocator();
                    currentAllocatorId = newAllocatorId;
                }

                id.toToken().safeTransferFrom(msg.sender, address(this), amount);

                _deposit(msg.sender, recipient, id, amount);
            }
        }

        return true;
    }

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
    ) external returns (uint256 id) {
        id = token.excludingNative().toIdIfRegistered(scope, resetPeriod, allocator);

        ISignatureTransfer.SignatureTransferDetails memory signatureTransferDetails = ISignatureTransfer.SignatureTransferDetails({ to: address(this), requestedAmount: amount });

        ISignatureTransfer.TokenPermissions memory tokenPermissions = ISignatureTransfer.TokenPermissions({ token: token, amount: amount });

        ISignatureTransfer.PermitTransferFrom memory permitTransferFrom = ISignatureTransfer.PermitTransferFrom({ permitted: tokenPermissions, nonce: nonce, deadline: deadline });

        _PERMIT2.permitWitnessTransferFrom(
            permitTransferFrom,
            signatureTransferDetails,
            depositor,
            allocator.toPermit2WitnessHash(depositor, resetPeriod, scope, recipient),
            "CompactDeposit witness)CompactDeposit(address depositor,address allocator,uint8 resetPeriod,uint8 scope,address recipient)TokenPermissions(address token,uint256 amount)",
            signature
        );

        _deposit(depositor, recipient, id, amount);
    }

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
    ) external payable returns (uint256[] memory) {
        uint256 totalTokens = permitted.length;
        bool firstUnderlyingTokenIsNative;
        assembly ("memory-safe") {
            let permittedOffset := permitted.offset
            firstUnderlyingTokenIsNative := iszero(shr(96, shl(96, add(permittedOffset, 0x20))))

            // Revert if:
            //  * the array is empty
            //  * the callvalue is zero but the first token is native
            //  * the callvalue is nonzero but the first token is non-native
            //  * the first token is non-native and the callvalue doesn't equal the first amount
            if or(iszero(totalTokens), or(eq(firstUnderlyingTokenIsNative, iszero(callvalue())), and(firstUnderlyingTokenIsNative, iszero(eq(callvalue(), calldataload(add(permittedOffset, 0x40)))))))
            {
                // revert InvalidBatchDepositStructure()
                mstore(0, 0xca0fc08e)
                revert(0x1c, 0x04)
            }
        }

        uint256 initialId = address(0).toIdIfRegistered(scope, resetPeriod, allocator);

        return _processBatchPermit2Deposits(
            firstUnderlyingTokenIsNative, recipient, initialId, totalTokens, permitted, depositor, nonce, deadline, allocator.toPermit2WitnessHash(depositor, resetPeriod, scope, recipient), signature
        );
    }

    function allocatedTransfer(BasicTransfer calldata transfer) external returns (bool) {
        return _processBasicTransfer(transfer, _release);
    }

    function allocatedWithdrawal(BasicTransfer calldata withdrawal) external returns (bool) {
        return _processBasicTransfer(withdrawal, _withdraw);
    }

    function allocatedTransfer(SplitTransfer calldata transfer) external returns (bool) {
        return _processSplitTransfer(transfer, _release);
    }

    function allocatedWithdrawal(SplitTransfer calldata withdrawal) external returns (bool) {
        return _processSplitTransfer(withdrawal, _withdraw);
    }

    function allocatedTransfer(BatchTransfer calldata transfer) external returns (bool) {
        return _processBatchTransfer(transfer, _release);
    }

    function allocatedWithdrawal(BatchTransfer calldata withdrawal) external returns (bool) {
        return _processBatchTransfer(withdrawal, _withdraw);
    }

    function allocatedTransfer(SplitBatchTransfer calldata transfer) external returns (bool) {
        return _processSplitBatchTransfer(transfer, _release);
    }

    function allocatedWithdrawal(SplitBatchTransfer calldata withdrawal) external returns (bool) {
        return _processSplitBatchTransfer(withdrawal, _withdraw);
    }

    function claim(BasicClaim calldata claimPayload) external returns (bool) {
        return _processBasicClaim(claimPayload, _release);
    }

    function claimAndWithdraw(BasicClaim calldata claimPayload) external returns (bool) {
        return _processBasicClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedClaim(claimPayload, _withdraw);
    }

    function claim(ClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(SplitClaim calldata claimPayload) external returns (bool) {
        return _processSplitClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitClaim calldata claimPayload) external returns (bool) {
        return _processSplitClaim(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitClaim(claimPayload, _withdraw);
    }

    function claim(SplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(BatchClaim calldata claimPayload) external returns (bool) {
        return _processBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(BatchClaim calldata claimPayload) external returns (bool) {
        return _processBatchClaim(claimPayload, _release);
    }

    function claim(QualifiedBatchClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedBatchClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchClaim(claimPayload, _release);
    }

    function claim(BatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(BatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processBatchClaimWithWitness(claimPayload, _release);
    }

    function claim(QualifiedBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchClaimWithWitness(claimPayload, _release);
    }

    function claim(SplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaim(claimPayload, _release);
    }

    function claim(QualifiedSplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitBatchClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchClaim(claimPayload, _release);
    }

    function claim(SplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claim(QualifiedSplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claim(MultichainClaim calldata claimPayload) external returns (bool) {
        return _processMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(MultichainClaim calldata claimPayload) external returns (bool) {
        return _processMultichainClaim(claimPayload, _release);
    }

    function claim(ExogenousMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaim(claimPayload, _release);
    }

    function claim(QualifiedMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedMultichainClaim calldata claimPayload) external returns (bool) {
        return _processQualifiedMultichainClaim(claimPayload, _release);
    }

    function claim(ExogenousQualifiedMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedMultichainClaim(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedMultichainClaim calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedMultichainClaim(claimPayload, _release);
    }

    function claim(MultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(MultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processMultichainClaimWithWitness(claimPayload, _release);
    }

    function claim(ExogenousMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousMultichainClaimWithWitness(claimPayload, _release);
    }

    function claim(QualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedMultichainClaimWithWitness(claimPayload, _release);
    }

    function claim(ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedMultichainClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processExogenousQualifiedMultichainClaimWithWitness(claimPayload, _release);
    }

    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt) {
        // overflow check not necessary as reset period is capped
        unchecked {
            withdrawableAt = block.timestamp + id.toResetPeriod().toSeconds();
        }

        _cutoffTime[msg.sender][id] = withdrawableAt;

        emit ForcedWithdrawalEnabled(msg.sender, id, withdrawableAt);
    }

    function disableForcedWithdrawal(uint256 id) external returns (bool) {
        if (_cutoffTime[msg.sender][id] == 0) {
            assembly ("memory-safe") {
                // revert ForcedWithdrawalAlreadyDisabled(msg.sender, id)
                mstore(0, 0xe632dbad)
                mstore(0x20, caller())
                mstore(0x40, id)
                revert(0x1c, 0x44)
            }
        }

        delete _cutoffTime[msg.sender][id];

        emit ForcedWithdrawalDisabled(msg.sender, id);

        return true;
    }

    function forcedWithdrawal(uint256 id, address recipient) external returns (uint256 withdrawnAmount) {
        uint256 withdrawableAt = _cutoffTime[msg.sender][id];

        if ((withdrawableAt == 0).or(withdrawableAt > block.timestamp)) {
            assembly ("memory-safe") {
                // revert PrematureWithdrawal(id)
                mstore(0, 0x9287bcb0)
                mstore(0x20, id)
                revert(0x1c, 0x24)
            }
        }

        withdrawnAmount = balanceOf(msg.sender, id);

        _withdraw(msg.sender, recipient, id, withdrawnAmount);
    }

    function __register(address allocator, bytes calldata proof) external returns (uint96 allocatorId) {
        allocator = uint256(uint160(allocator)).asSanitizedAddress();
        if (!allocator.canBeRegistered(proof)) {
            assembly ("memory-safe") {
                // revert InvalidRegistrationProof(allocator)
                mstore(0, 0x4e7f492b)
                mstore(0x20, allocator)
                revert(0x1c, 0x24)
            }
        }

        allocatorId = allocator.register();
    }

    function getForcedWithdrawalStatus(address account, uint256 id) external view returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt) {
        forcedWithdrawalAvailableAt = _cutoffTime[account][id];

        assembly ("memory-safe") {
            status := mul(iszero(iszero(forcedWithdrawalAvailableAt)), sub(2, gt(forcedWithdrawalAvailableAt, timestamp())))
        }
    }

    function getLockDetails(uint256 id) external view returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope) {
        token = id.toToken();
        allocator = id.toAllocatorId().toRegisteredAllocator();
        resetPeriod = id.toResetPeriod();
        scope = id.toScope();
    }

    function check(uint256 nonce, address allocator) external view returns (bool consumed) {
        consumed = allocator.hasConsumed(nonce);
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator) {
        return _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
    }

    /// @dev Returns the symbol for token `id`.
    function name(uint256 id) public view virtual override returns (string memory) {
        return string.concat("Compact ", id.toToken().readNameWithDefaultValue());
    }

    /// @dev Returns the symbol for token `id`.
    function symbol(uint256 id) public view virtual override returns (string memory) {
        return string.concat(unicode"🤝-", id.toToken().readSymbolWithDefaultValue());
    }

    /// @dev Returns the Uniform Resource Identifier (URI) for token `id`.
    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return _METADATA_RENDERER.uri(id.toLock(), id);
    }

    /// @dev Returns the name for the contract.
    function name() external pure returns (string memory) {
        // Return the name of the contract.
        assembly ("memory-safe") {
            mstore(0x20, 0x20)
            mstore(0x4b, 0x0b54686520436f6d70616374)
            return(0x20, 0x60)
        }
    }

    function _notExpiredAndSignedByAllocator(bytes32 messageHash, address allocator, BasicTransfer calldata transferPayload) internal view {
        transferPayload.expires.later();

        messageHash.signedBy(allocator, transferPayload.allocatorSignature, _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID));
    }

    function _notExpiredAndSignedByBoth(
        uint256 expires,
        bytes32 messageHash,
        address sponsor,
        bytes calldata sponsorSignature,
        bytes32 qualificationMessageHash,
        address allocator,
        bytes calldata allocatorSignature
    ) internal view {
        expires.later();

        bytes32 domainSeparator = _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);

        messageHash.signedBy(sponsor, sponsorSignature, domainSeparator);
        qualificationMessageHash.signedBy(allocator, allocatorSignature, domainSeparator);
    }

    function _processBasicTransfer(BasicTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        _notExpiredAndSignedByAllocator(transfer.toMessageHash(), transfer.id.toRegisteredAllocatorWithConsumed(transfer.nonce), transfer);

        return operation(msg.sender, transfer.recipient, transfer.id, transfer.amount);
    }

    function _processSplitTransfer(SplitTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        _notExpiredAndSignedByAllocator.usingSplitTransfer()(transfer.toMessageHash(), transfer.id.toRegisteredAllocatorWithConsumed(transfer.nonce), transfer);

        uint256 totalSplits = transfer.recipients.length;
        unchecked {
            for (uint256 i = 0; i < totalSplits; ++i) {
                SplitComponent calldata component = transfer.recipients[i];
                operation(msg.sender, component.claimant, transfer.id, component.amount);
            }
        }

        return true;
    }

    function _processBatchTransfer(BatchTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        _notExpiredAndSignedByAllocator.usingBatchTransfer()(transfer.toMessageHash(), _deriveConsistentAllocatorAndConsumeNonce(transfer.transfers, transfer.nonce), transfer);

        unchecked {
            uint256 totalTransfers = transfer.transfers.length;
            for (uint256 i = 0; i < totalTransfers; ++i) {
                TransferComponent calldata component = transfer.transfers[i];
                operation(msg.sender, transfer.recipient, component.id, component.amount);
            }
        }

        return true;
    }

    function _processSplitBatchTransfer(SplitBatchTransfer calldata transfer, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        _notExpiredAndSignedByAllocator.usingSplitBatchTransfer()(
            transfer.toMessageHash(), _deriveConsistentAllocatorAndConsumeNonce.usingSplitByIdComponent()(transfer.transfers, transfer.nonce), transfer
        );

        unchecked {
            uint256 totalIds = transfer.transfers.length;
            for (uint256 i = 0; i < totalIds; ++i) {
                SplitByIdComponent calldata component = transfer.transfers[i];
                SplitComponent[] calldata portions = component.portions;
                uint256 totalPortions = portions.length;
                for (uint256 j = 0; j < totalPortions; ++j) {
                    SplitComponent calldata portion = portions[j];
                    operation(msg.sender, portion.claimant, component.id, portion.amount);
                }
            }
        }

        return true;
    }

    function _processSimpleClaim(bytes32 messageHash, uint256 calldataPointer, uint256 offsetToId, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0), operation);
    }

    function _processSimpleSplitClaim(bytes32 messageHash, uint256 calldataPointer, uint256 offsetToId, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return _processSplitClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, bytes32(0), operation);
    }

    function _processClaimWithSponsorDomain(
        bytes32 messageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomain,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processClaimWithQualificationAndSponsorDomain(messageHash, messageHash, calldataPointer, offsetToId, sponsorDomain, operation);
    }

    function _processClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0), operation);
    }

    function _processSplitClaimWithQualification(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _processSplitClaimWithQualificationAndSponsorDomain(messageHash, qualificationMessageHash, calldataPointer, offsetToId, bytes32(0), operation);
    }

    function _validate(bytes32 messageHash, bytes32 qualificationMessageHash, uint256 calldataPointer, uint256 offsetToId, bytes32 sponsorDomainSeparator) internal returns (address sponsor) {
        bytes calldata allocatorSignature;
        bytes calldata sponsorSignature;
        uint256 nonce;
        uint256 expires;

        uint256 id;
        uint256 allocatedAmount;

        assembly {
            let allocatorSignaturePtr := add(calldataPointer, calldataload(calldataPointer))
            allocatorSignature.offset := add(0x20, allocatorSignaturePtr)
            allocatorSignature.length := calldataload(allocatorSignaturePtr)

            let sponsorSignaturePtr := add(calldataPointer, calldataload(add(calldataPointer, 0x20)))
            sponsorSignature.offset := add(0x20, sponsorSignaturePtr)
            sponsorSignature.length := calldataload(sponsorSignaturePtr)

            sponsor := calldataload(add(calldataPointer, 0x40)) // TODO: sanitize
            nonce := calldataload(add(calldataPointer, 0x60))
            expires := calldataload(add(calldataPointer, 0x80))

            let calldataPointerWithOffset := add(calldataPointer, offsetToId)
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))
        }

        expires.later();

        uint96 allocatorId = id.toAllocatorId();
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(nonce);

        if ((sponsorDomainSeparator != bytes32(0)).and(id.toScope() != Scope.Multichain)) {
            revert InvalidScope(id);
        }

        bytes32 domainSeparator = _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
        assembly {
            sponsorDomainSeparator := add(sponsorDomainSeparator, mul(iszero(sponsorDomainSeparator), domainSeparator))
        }

        messageHash.signedBy(sponsor, sponsorSignature, sponsorDomainSeparator);
        qualificationMessageHash.signedBy(allocator, allocatorSignature, domainSeparator);

        _emitClaim(sponsor, messageHash, allocator);

        return sponsor;
    }

    function _processClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        address sponsor = _validate(messageHash, qualificationMessageHash, calldataPointer, offsetToId, sponsorDomainSeparator);

        uint256 id;
        uint256 allocatedAmount;
        address claimant;
        uint256 amount;

        assembly {
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))
            claimant := calldataload(add(calldataPointerWithOffset, 0x40)) // TODO: sanitize
            amount := calldataload(add(calldataPointerWithOffset, 0x60))
        }

        amount.withinAllocated(allocatedAmount);

        return operation(sponsor, claimant, id, amount);
    }

    function _processSplitClaimWithQualificationAndSponsorDomain(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        uint256 calldataPointer,
        uint256 offsetToId,
        bytes32 sponsorDomainSeparator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        address sponsor = _validate(messageHash, qualificationMessageHash, calldataPointer, offsetToId, sponsorDomainSeparator);

        uint256 id;
        uint256 allocatedAmount;
        SplitComponent[] calldata claimants;

        assembly {
            let calldataPointerWithOffset := add(calldataPointer, offsetToId)
            id := calldataload(calldataPointerWithOffset)
            allocatedAmount := calldataload(add(calldataPointerWithOffset, 0x20))

            let claimantsPtr := add(calldataPointer, calldataload(add(calldataPointerWithOffset, 0x40)))
            claimants.offset := add(0x20, claimantsPtr)
            claimants.length := calldataload(claimantsPtr)
        }

        return _verifyAndProcessSplitComponents(sponsor, id, allocatedAmount, claimants, operation);
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

    function _processBasicClaim(BasicClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return usingBasicClaim(_processSimpleClaim)(claimPayload.toMessageHash(), claimPayload, 0xa0, operation);
    }

    function _processQualifiedClaim(QualifiedClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return usingQualifiedClaim(_processClaimWithQualification)(messageHash, qualificationMessageHash, claimPayload, 0xe0, operation);
    }

    function _processClaimWithWitness(ClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return usingClaimWithWitness(_processSimpleClaim)(claimPayload.toMessageHash(), claimPayload, 0xe0, operation);
    }

    function _processQualifiedClaimWithWitness(QualifiedClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return usingQualifiedClaimWithWitness(_processClaimWithQualification)(messageHash, qualificationMessageHash, claimPayload, 0x120, operation);
    }

    function _processMultichainClaim(MultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return usingMultichainClaim(_processSimpleClaim)(claimPayload.toMessageHash(), claimPayload, 0xc0, operation);
    }

    function _processQualifiedMultichainClaim(QualifiedMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return usingQualifiedMultichainClaim(_processClaimWithQualification)(messageHash, qualificationMessageHash, claimPayload, 0x100, operation);
    }

    function _processMultichainClaimWithWitness(MultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return usingMultichainClaimWithWitness(_processSimpleClaim)(claimPayload.toMessageHash(), claimPayload, 0x100, operation);
    }

    function _processQualifiedMultichainClaimWithWitness(QualifiedMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return usingQualifiedMultichainClaimWithWitness(_processClaimWithQualification)(messageHash, qualificationMessageHash, claimPayload, 0x140, operation);
    }

    function _processExogenousMultichainClaim(ExogenousMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return usingExogenousMultichainClaim(_processClaimWithSponsorDomain)(claimPayload.toMessageHash(), claimPayload, 0x100, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), operation);
    }

    function _processExogenousMultichainClaimWithWitness(ExogenousMultichainClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        return usingExogenousMultichainClaimWithWitness(_processClaimWithSponsorDomain)(
            claimPayload.toMessageHash(), claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), operation
        );
    }

    function _processExogenousQualifiedMultichainClaim(ExogenousQualifiedMultichainClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return usingExogenousQualifiedMultichainClaim(_processClaimWithQualificationAndSponsorDomain)(
            messageHash, qualificationMessageHash, claimPayload, 0x140, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), operation
        );
    }

    function _processExogenousQualifiedMultichainClaimWithWitness(
        ExogenousQualifiedMultichainClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return usingExogenousQualifiedMultichainClaimWithWitness(_processClaimWithQualificationAndSponsorDomain)(
            messageHash, qualificationMessageHash, claimPayload, 0x180, claimPayload.notarizedChainId.toNotarizedDomainSeparator(), operation
        );
    }

    function _processSplitClaim(SplitClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return usingSplitClaim(_processSimpleSplitClaim)(claimPayload.toMessageHash(), claimPayload, 0xa0, operation);
    }

    function _processQualifiedSplitClaim(QualifiedSplitClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return usingQualifiedSplitClaim(_processSplitClaimWithQualification)(messageHash, qualificationMessageHash, claimPayload, 0xe0, operation);
    }

    function _processSplitClaimWithWitness(SplitClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        return usingSplitClaimWithWitness(_processSimpleSplitClaim)(claimPayload.toMessageHash(), claimPayload, 0xe0, operation);
    }

    function _processQualifiedSplitClaimWithWitness(QualifiedSplitClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        return usingQualifiedSplitClaimWithWitness(_processSplitClaimWithQualification)(messageHash, qualificationMessageHash, claimPayload, 0x120, operation);
    }

    function _processBatchClaim(BatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        bytes32 messageHash = claimPayload.toMessageHash();
        uint96 allocatorId = claimPayload.claims[0].id.toAllocatorId();
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce);
        _notExpiredAndSignedByBoth(claimPayload.expires, messageHash, claimPayload.sponsor, claimPayload.sponsorSignature, messageHash, allocator, claimPayload.allocatorSignature);

        return _verifyAndProcessBatchComponents(allocatorId, claimPayload.sponsor, claimPayload.claimant, messageHash, claimPayload.claims, allocator, operation);
    }

    function _processSplitBatchClaim(SplitBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        bytes32 messageHash = claimPayload.toMessageHash();
        uint96 allocatorId = claimPayload.claims[0].id.toAllocatorId();
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce);

        _notExpiredAndSignedByBoth(claimPayload.expires, messageHash, claimPayload.sponsor, claimPayload.sponsorSignature, messageHash, allocator, claimPayload.allocatorSignature);

        return _verifyAndProcessSplitBatchComponents(allocatorId, claimPayload.sponsor, messageHash, claimPayload.claims, allocator, operation);
    }

    function _processQualifiedSplitBatchClaim(QualifiedSplitBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        uint96 allocatorId = claimPayload.claims[0].id.toAllocatorId();
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce);

        _notExpiredAndSignedByBoth(claimPayload.expires, messageHash, claimPayload.sponsor, claimPayload.sponsorSignature, qualificationMessageHash, allocator, claimPayload.allocatorSignature);

        return _verifyAndProcessSplitBatchComponents(allocatorId, claimPayload.sponsor, messageHash, claimPayload.claims, allocator, operation);
    }

    function _processQualifiedSplitBatchClaimWithWitness(QualifiedSplitBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        uint96 allocatorId = claimPayload.claims[0].id.toAllocatorId();
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce);

        _notExpiredAndSignedByBoth(claimPayload.expires, messageHash, claimPayload.sponsor, claimPayload.sponsorSignature, qualificationMessageHash, allocator, claimPayload.allocatorSignature);

        return _verifyAndProcessSplitBatchComponents(allocatorId, claimPayload.sponsor, messageHash, claimPayload.claims, allocator, operation);
    }

    function _processSplitBatchClaimWithWitness(SplitBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        bytes32 messageHash = claimPayload.toMessageHash();
        uint96 allocatorId = claimPayload.claims[0].id.toAllocatorId();
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce);

        _notExpiredAndSignedByBoth(claimPayload.expires, messageHash, claimPayload.sponsor, claimPayload.sponsorSignature, messageHash, allocator, claimPayload.allocatorSignature);

        return _verifyAndProcessSplitBatchComponents(allocatorId, claimPayload.sponsor, messageHash, claimPayload.claims, allocator, operation);
    }

    function _processQualifiedBatchClaim(QualifiedBatchClaim calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();
        uint96 allocatorId = claimPayload.claims[0].id.toAllocatorId();
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce);

        _notExpiredAndSignedByBoth(claimPayload.expires, messageHash, claimPayload.sponsor, claimPayload.sponsorSignature, qualificationMessageHash, allocator, claimPayload.allocatorSignature);

        return _verifyAndProcessBatchComponents(allocatorId, claimPayload.sponsor, claimPayload.claimant, messageHash, claimPayload.claims, allocator, operation);
    }

    function _processBatchClaimWithWitness(BatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation) internal returns (bool) {
        bytes32 messageHash = claimPayload.toMessageHash();
        uint96 allocatorId = claimPayload.claims[0].id.toAllocatorId();
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce);

        _notExpiredAndSignedByBoth(claimPayload.expires, messageHash, claimPayload.sponsor, claimPayload.sponsorSignature, messageHash, allocator, claimPayload.allocatorSignature);

        return _verifyAndProcessBatchComponents(allocatorId, claimPayload.sponsor, claimPayload.claimant, messageHash, claimPayload.claims, allocator, operation);
    }

    function _processQualifiedBatchClaimWithWitness(QualifiedBatchClaimWithWitness calldata claimPayload, function(address, address, uint256, uint256) internal returns (bool) operation)
        internal
        returns (bool)
    {
        uint96 allocatorId = claimPayload.claims[0].id.toAllocatorId();
        address allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce);
        (bytes32 messageHash, bytes32 qualificationMessageHash) = claimPayload.toMessageHash();

        _notExpiredAndSignedByBoth(claimPayload.expires, messageHash, claimPayload.sponsor, claimPayload.sponsorSignature, qualificationMessageHash, allocator, claimPayload.allocatorSignature);

        return _verifyAndProcessBatchComponents(allocatorId, claimPayload.sponsor, claimPayload.claimant, messageHash, claimPayload.claims, allocator, operation);
    }

    function _processBatchPermit2Deposits(
        bool firstUnderlyingTokenIsNative,
        address recipient,
        uint256 initialId,
        uint256 totalTokens,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        address depositor,
        uint256 nonce,
        uint256 deadline,
        bytes32 witness,
        bytes calldata signature
    ) internal returns (uint256[] memory ids) {
        ids = new uint256[](totalTokens);

        uint256 totalTokensLessInitialNative;
        unchecked {
            totalTokensLessInitialNative = totalTokens - firstUnderlyingTokenIsNative.asUint256();
        }

        if (firstUnderlyingTokenIsNative) {
            _deposit(msg.sender, recipient, initialId, msg.value);
            ids[0] = initialId;
        }

        (ISignatureTransfer.SignatureTransferDetails[] memory details, ISignatureTransfer.TokenPermissions[] memory permittedTokens) =
            _preparePermit2ArraysAndPerformDeposits(ids, totalTokensLessInitialNative, firstUnderlyingTokenIsNative, permitted, initialId, recipient, depositor);

        ISignatureTransfer.PermitBatchTransferFrom memory permitTransferFrom = ISignatureTransfer.PermitBatchTransferFrom({ permitted: permittedTokens, nonce: nonce, deadline: deadline });

        _PERMIT2.permitWitnessTransferFrom(
            permitTransferFrom,
            details,
            depositor,
            witness,
            "CompactDeposit witness)CompactDeposit(address depositor,address allocator,uint8 resetPeriod,uint8 scope,address recipient)TokenPermissions(address token,uint256 amount)",
            signature
        );
    }

    function _verifyAndProcessBatchComponents(
        uint96 allocatorId,
        address sponsor,
        address claimant,
        bytes32 messageHash,
        BatchClaimComponent[] calldata claims,
        address allocator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        uint256 totalClaims = claims.length;
        if (totalClaims == 0) {
            revert InvalidBatchAllocation();
        }

        // TODO: many of the bounds checks on these array accesses can be skipped as an optimization
        BatchClaimComponent calldata component = claims[0];
        uint256 errorBuffer = (component.allocatedAmount < component.amount).asUint256();

        _emitClaim(sponsor, messageHash, allocator);

        operation(sponsor, claimant, component.id, component.amount);

        unchecked {
            for (uint256 i = 1; i < totalClaims; ++i) {
                component = claims[i];
                errorBuffer |= (component.id.toAllocatorId() != allocatorId).or(component.allocatedAmount < component.amount).asUint256();

                operation(sponsor, claimant, component.id, component.amount);
            }

            if (errorBuffer.asBool()) {
                for (uint256 i = 0; i < totalClaims; ++i) {
                    component = claims[i];
                    component.amount.withinAllocated(component.allocatedAmount);
                }

                // TODO: extract more informative error by deriving the reason for the failure
                revert InvalidBatchAllocation();
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
    ) internal returns (bool) {
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

    function _verifyAndProcessSplitBatchComponents(
        uint96 allocatorId,
        address sponsor,
        bytes32 messageHash,
        SplitBatchClaimComponent[] calldata claims,
        address allocator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        uint256 totalClaims = claims.length;
        uint256 errorBuffer = (totalClaims == 0).asUint256();

        _emitClaim(sponsor, messageHash, allocator);

        unchecked {
            for (uint256 i = 0; i < totalClaims; ++i) {
                SplitBatchClaimComponent calldata claimComponent = claims[i];
                errorBuffer |= (claimComponent.id.toAllocatorId() != allocatorId).asUint256();

                _verifyAndProcessSplitComponents(sponsor, claimComponent.id, claimComponent.allocatedAmount, claimComponent.portions, operation);
            }
        }

        if (errorBuffer.asBool()) {
            revert InvalidBatchAllocation();
        }

        return true;
    }

    function _preparePermit2ArraysAndPerformDeposits(
        uint256[] memory ids,
        uint256 totalTokensLessInitialNative,
        bool firstUnderlyingTokenIsNative,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        uint256 initialId,
        address recipient,
        address depositor
    ) internal returns (ISignatureTransfer.SignatureTransferDetails[] memory details, ISignatureTransfer.TokenPermissions[] memory permittedTokens) {
        unchecked {
            details = new ISignatureTransfer.SignatureTransferDetails[](totalTokensLessInitialNative);

            permittedTokens = new ISignatureTransfer.TokenPermissions[](totalTokensLessInitialNative);

            for (uint256 i = 0; i < totalTokensLessInitialNative; ++i) {
                ISignatureTransfer.TokenPermissions calldata permittedToken = permitted[i + firstUnderlyingTokenIsNative.asUint256()];

                permittedTokens[i] = permittedToken;
                details[i] = ISignatureTransfer.SignatureTransferDetails({ to: address(this), requestedAmount: permittedToken.amount });

                uint256 id = initialId.withReplacedToken(permittedToken.token);
                ids[i + firstUnderlyingTokenIsNative.asUint256()] = id;

                _deposit(depositor, recipient, id, permittedToken.amount);
            }
        }
    }

    function _deriveConsistentAllocatorAndConsumeNonce(TransferComponent[] memory components, uint256 nonce) internal returns (address allocator) {
        uint256 totalComponents = components.length;

        uint256 errorBuffer = (components.length == 0).asUint256();

        // TODO: bounds checks on these array accesses can be skipped as an optimization
        uint96 allocatorId = components[0].id.toAllocatorId();

        allocator = allocatorId.fromRegisteredAllocatorIdWithConsumed(nonce);

        unchecked {
            for (uint256 i = 1; i < totalComponents; ++i) {
                errorBuffer |= (components[i].id.toAllocatorId() != allocatorId).asUint256();
            }
        }
        if (errorBuffer.asBool()) {
            revert InvalidBatchAllocation();
        }
    }

    function _emitClaim(address sponsor, bytes32 messageHash, address allocator) internal {
        assembly ("memory-safe") {
            mstore(0, messageHash)
            log4(0, 0x20, _CLAIM_EVENT_SIGNATURE, shr(0x60, shl(0x60, sponsor)), shr(0x60, shl(0x60, allocator)), caller())
        }
    }

    function _emitAndOperate(
        address sponsor,
        address claimant,
        uint256 id,
        bytes32 messageHash,
        uint256 amount,
        uint256 allocatedAmount,
        address allocator,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        amount.withinAllocated(allocatedAmount);

        _emitClaim(sponsor, messageHash, allocator);

        return operation(sponsor, claimant, id, amount);
    }

    /// @dev Moves token `id` from `from` to `to` without checking
    //  allowances or _beforeTokenTransfer / _afterTokenTransfer hooks.
    function _release(address from, address to, uint256 id, uint256 amount) internal returns (bool) {
        assembly ("memory-safe") {
            /// Compute the balance slot and load its value.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, from)
            mstore(0x00, id)
            let fromBalanceSlot := keccak256(0x00, 0x40)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if insufficient or zero balance.
            if or(iszero(amount), gt(amount, fromBalance)) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))
            // Compute the balance slot of `to`.
            mstore(0x14, to)
            mstore(0x00, id)
            let toBalanceSlot := keccak256(0x00, 0x40)
            let toBalanceBefore := sload(toBalanceSlot)
            let toBalanceAfter := add(toBalanceBefore, amount)
            // Revert if the balance overflows.
            if lt(toBalanceAfter, toBalanceBefore) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            // Store the updated balance of `to`.
            sstore(toBalanceSlot, toBalanceAfter)
            // Emit the {Transfer} event.
            mstore(0x00, caller())
            mstore(0x20, amount)
            // forgefmt: disable-next-line
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, shr(0x60, shl(0x60, from)), shr(0x60, shl(0x60, to)), id)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x34, 0x00)
        }

        return true;
    }

    /// @dev Mints `amount` of token `id` to `to` without checking transfer hooks.
    /// Emits {Transfer} and {Deposit} events.
    function _deposit(address from, address to, uint256 id, uint256 amount) internal {
        assembly ("memory-safe") {
            // Compute the balance slot.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, to)
            mstore(0x00, id)
            let toBalanceSlot := keccak256(0x00, 0x40)
            // Add and store the updated balance
            let toBalanceBefore := sload(toBalanceSlot)
            let toBalanceAfter := add(toBalanceBefore, amount)
            // Revert if the balance overflows.
            if lt(toBalanceAfter, toBalanceBefore) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, toBalanceAfter)

            let recipient := shr(0x60, shl(0x60, to))

            // Emit the {Transfer} and {Deposit} events.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0, 0x40, _TRANSFER_EVENT_SIGNATURE, 0, recipient, id)
            log4(0x20, 0x20, _DEPOSIT_EVENT_SIGNATURE, shr(0x60, shl(0x60, from)), recipient, id)
        }
    }

    /// @dev Burns `amount` token `id` from `from` without checking transfer hooks and sends
    /// the corresponding underlying tokens to `to`. Emits {Transfer} & {Withdrawal} events.
    function _withdraw(address from, address to, uint256 id, uint256 amount) internal returns (bool) {
        assembly ("memory-safe") {
            // Compute the balance slot.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, from)
            mstore(0x00, id)
            let fromBalanceSlot := keccak256(0x00, 0x40)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))

            let account := shr(0x60, shl(0x60, from))

            // Emit the {Transfer} and {Withdrawal} events.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, account, 0, id)
            log4(0x20, 0x20, _WITHDRAWAL_EVENT_SIGNATURE, account, shr(0x60, shl(0x60, to)), id)
        }

        address token = id.toToken();
        if (token == address(0)) {
            to.safeTransferETH(amount);
        } else {
            token.safeTransfer(to, amount);
        }

        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 id, uint256 amount) internal virtual override {
        address allocator = id.toAllocator();

        if (IAllocator(allocator).attest(msg.sender, from, to, id, amount) != IAllocator.attest.selector) {
            assembly ("memory-safe") {
                // revert UnallocatedTransfer(msg.sender, from, to, id, amount)
                mstore(0, 0x014c9310)
                mstore(0x20, caller())
                mstore(0x40, shr(0x60, shl(0x60, from)))
                mstore(0x60, shr(0x60, shl(0x60, to)))
                mstore(0x80, id)
                mstore(0xa0, amount)
                revert(0x1c, 0xa4)
            }
        }
    }
}

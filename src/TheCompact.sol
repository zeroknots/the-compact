// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ITheCompact } from "./interfaces/ITheCompact.sol";
import { Lock } from "./types/Lock.sol";
import { Scope } from "./types/Scope.sol";
import { ResetPeriod } from "./types/ResetPeriod.sol";
import { ForcedWithdrawalStatus } from "./types/ForcedWithdrawalStatus.sol";
import { IdLib } from "./lib/IdLib.sol";
import { EfficiencyLib } from "./lib/EfficiencyLib.sol";
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
    Claim,
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

import {
    SplitComponent,
    TransferComponent,
    SplitByIdComponent,
    BatchClaimComponent,
    SplitBatchClaimComponent
} from "./types/Components.sol";

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
    using HashLib for BasicTransfer;
    using HashLib for SplitTransfer;
    using HashLib for Claim;
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

    IPermit2 private constant _PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    /// @dev `keccak256(bytes("Transfer(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE =
        0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    // Rage-quit functionality (TODO: optimize storage layout)
    mapping(address => mapping(uint256 => uint256)) private _cutoffTime;

    uint256 private immutable _INITIAL_CHAIN_ID;
    bytes32 private immutable _INITIAL_DOMAIN_SEPARATOR;
    MetadataRenderer private immutable _METADATA_RENDERER;

    constructor() {
        _INITIAL_CHAIN_ID = block.chainid;
        _INITIAL_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                HashLib._DOMAIN_TYPEHASH,
                HashLib._NAME_HASH,
                HashLib._VERSION_HASH,
                block.chainid,
                address(this)
            )
        );
        _METADATA_RENDERER = new MetadataRenderer();
    }

    function deposit(address allocator) external payable returns (uint256 id) {
        id = address(0).toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        _deposit(msg.sender, msg.sender, id, msg.value);
    }

    function deposit(address token, address allocator, uint256 amount)
        external
        returns (uint256 id)
    {
        id = token.excludingNative().toIdIfRegistered(
            Scope.Multichain, ResetPeriod.TenMinutes, allocator
        );

        token.safeTransferFrom(msg.sender, address(this), amount);

        _deposit(msg.sender, msg.sender, id, amount);
    }

    function deposit(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient)
        external
        payable
        returns (uint256 id)
    {
        id = address(0).toIdIfRegistered(scope, resetPeriod, allocator);

        _deposit(msg.sender, recipient, id, msg.value);
    }

    function deposit(
        address token,
        address allocator,
        ResetPeriod resetPeriod,
        Scope scope,
        uint256 amount,
        address recipient
    ) external returns (uint256 id) {
        id = token.excludingNative().toIdIfRegistered(scope, resetPeriod, allocator);

        token.safeTransferFrom(msg.sender, address(this), amount);

        _deposit(msg.sender, recipient, id, amount);
    }

    function deposit(uint256[2][] calldata idsAndAmounts, address recipient)
        external
        payable
        returns (bool)
    {
        uint256 totalIds = idsAndAmounts.length;
        bool firstUnderlyingTokenIsNative;
        uint256 id;

        assembly {
            let idsAndAmountsOffset := idsAndAmounts.offset
            id := calldataload(idsAndAmountsOffset)
            firstUnderlyingTokenIsNative := iszero(shr(96, shl(96, id)))
            // Revert if:
            //  * the array is empty
            //  * the callvalue is zero but the first token is native
            //  * the callvalue is nonzero but the first token is non-native
            //  * the first token is non-native and the callvalue doesn't equal the first amount
            if or(
                iszero(totalIds),
                or(
                    eq(firstUnderlyingTokenIsNative, iszero(callvalue())),
                    and(
                        firstUnderlyingTokenIsNative,
                        iszero(eq(callvalue(), calldataload(add(idsAndAmountsOffset, 0x20))))
                    )
                )
            ) {
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

        ISignatureTransfer.SignatureTransferDetails memory signatureTransferDetails =
        ISignatureTransfer.SignatureTransferDetails({ to: address(this), requestedAmount: amount });

        ISignatureTransfer.TokenPermissions memory tokenPermissions =
            ISignatureTransfer.TokenPermissions({ token: token, amount: amount });

        ISignatureTransfer.PermitTransferFrom memory permitTransferFrom = ISignatureTransfer
            .PermitTransferFrom({ permitted: tokenPermissions, nonce: nonce, deadline: deadline });

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
        assembly {
            let permittedOffset := permitted.offset
            firstUnderlyingTokenIsNative := iszero(shr(96, shl(96, add(permittedOffset, 0x20))))

            // Revert if:
            //  * the array is empty
            //  * the callvalue is zero but the first token is native
            //  * the callvalue is nonzero but the first token is non-native
            //  * the first token is non-native and the callvalue doesn't equal the first amount
            if or(
                iszero(totalTokens),
                or(
                    eq(firstUnderlyingTokenIsNative, iszero(callvalue())),
                    and(
                        firstUnderlyingTokenIsNative,
                        iszero(eq(callvalue(), calldataload(add(permittedOffset, 0x40))))
                    )
                )
            ) {
                // revert InvalidBatchDepositStructure()
                mstore(0, 0xca0fc08e)
                revert(0x1c, 0x04)
            }
        }

        uint256 initialId = address(0).toIdIfRegistered(scope, resetPeriod, allocator);

        return _processBatchPermit2Deposits(
            firstUnderlyingTokenIsNative,
            recipient,
            initialId,
            totalTokens,
            permitted,
            depositor,
            nonce,
            deadline,
            allocator.toPermit2WitnessHash(depositor, resetPeriod, scope, recipient),
            signature
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

    function claim(Claim calldata claimPayload) external returns (bool) {
        return _processClaim(claimPayload, _release);
    }

    function claimAndWithdraw(Claim calldata claimPayload) external returns (bool) {
        return _processClaim(claimPayload, _withdraw);
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

    function claimAndWithdraw(QualifiedClaimWithWitness calldata claimPayload)
        external
        returns (bool)
    {
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

    function claimAndWithdraw(SplitClaimWithWitness calldata claimPayload)
        external
        returns (bool)
    {
        return _processSplitClaimWithWitness(claimPayload, _withdraw);
    }

    function claim(QualifiedSplitClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedSplitClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitClaimWithWitness calldata claimPayload)
        external
        returns (bool)
    {
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

    function claimAndWithdraw(BatchClaimWithWitness calldata claimPayload)
        external
        returns (bool)
    {
        return _processBatchClaimWithWitness(claimPayload, _release);
    }

    function claim(QualifiedBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processQualifiedBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedBatchClaimWithWitness calldata claimPayload)
        external
        returns (bool)
    {
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

    function claimAndWithdraw(QualifiedSplitBatchClaim calldata claimPayload)
        external
        returns (bool)
    {
        return _processQualifiedSplitBatchClaim(claimPayload, _release);
    }

    function claim(SplitBatchClaimWithWitness calldata claimPayload) external returns (bool) {
        return _processSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(SplitBatchClaimWithWitness calldata claimPayload)
        external
        returns (bool)
    {
        return _processSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claim(QualifiedSplitBatchClaimWithWitness calldata claimPayload)
        external
        returns (bool)
    {
        return _processQualifiedSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function claimAndWithdraw(QualifiedSplitBatchClaimWithWitness calldata claimPayload)
        external
        returns (bool)
    {
        return _processQualifiedSplitBatchClaimWithWitness(claimPayload, _release);
    }

    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt) {
        withdrawableAt = block.timestamp + id.toResetPeriod().toSeconds();

        _cutoffTime[msg.sender][id] = withdrawableAt;

        emit ForcedWithdrawalEnabled(msg.sender, id, withdrawableAt);
    }

    function disableForcedWithdrawal(uint256 id) external returns (bool) {
        if (_cutoffTime[msg.sender][id] == 0) {
            revert ForcedWithdrawalAlreadyDisabled(msg.sender, id);
        }

        delete _cutoffTime[msg.sender][id];

        emit ForcedWithdrawalDisabled(msg.sender, id);

        return true;
    }

    function forcedWithdrawal(uint256 id, address recipient)
        external
        returns (uint256 withdrawnAmount)
    {
        uint256 withdrawableAt = _cutoffTime[msg.sender][id];

        if ((withdrawableAt == 0).or(withdrawableAt > block.timestamp)) {
            revert PrematureWithdrawal(id);
        }

        withdrawnAmount = balanceOf(msg.sender, id);

        _withdraw(msg.sender, recipient, id, withdrawnAmount);
    }

    function __register(address allocator, bytes calldata proof)
        external
        returns (uint96 allocatorId)
    {
        if (!allocator.canBeRegistered(proof)) {
            revert InvalidRegistrationProof(allocator);
        }

        allocatorId = allocator.register();
    }

    function getForcedWithdrawalStatus(address account, uint256 id)
        external
        view
        returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt)
    {
        forcedWithdrawalAvailableAt = _cutoffTime[account][id];

        if (forcedWithdrawalAvailableAt == 0) {
            status = ForcedWithdrawalStatus.Disabled;
        } else if (forcedWithdrawalAvailableAt > block.timestamp) {
            status = ForcedWithdrawalStatus.Pending;
        } else {
            status = ForcedWithdrawalStatus.Enabled;
        }
    }

    function getLockDetails(uint256 id)
        external
        view
        returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope)
    {
        Lock memory lock = id.toLock();
        token = lock.token;
        allocator = lock.allocator;
        resetPeriod = lock.resetPeriod;
        scope = lock.scope;
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

    function _usingSplitTransfer(
        function (bytes32, address, BasicTransfer calldata) internal view fnIn
    )
        internal
        pure
        returns (function (bytes32, address, SplitTransfer calldata) internal view fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingBatchTransfer(
        function (bytes32, address, BasicTransfer calldata) internal view fnIn
    )
        internal
        pure
        returns (function (bytes32, address, BatchTransfer calldata) internal view fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingSplitBatchTransfer(
        function (bytes32, address, BasicTransfer calldata) internal view fnIn
    )
        internal
        pure
        returns (function (bytes32, address, SplitBatchTransfer calldata) internal view fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _notExpiredAndWithValidSignatures(
        bytes32 messageHash,
        Claim calldata claimPayload,
        address allocator
    ) internal view {
        claimPayload.expires.later();

        bytes32 domainSeparator = _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
        messageHash.signedBy(claimPayload.sponsor, claimPayload.sponsorSignature, domainSeparator);
        messageHash.signedBy(allocator, claimPayload.allocatorSignature, domainSeparator);
    }

    function _usingQualifiedClaimWithWitness(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedClaimWithWitness calldata, address) internal view fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingQualifiedBatchClaim(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedBatchClaim calldata, address) internal view fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingQualifiedSplitBatchClaim(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedSplitBatchClaim calldata, address) internal view fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingQualifiedBatchClaimWithWitness(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedBatchClaimWithWitness calldata, address) internal view
                fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingQualifiedSplitBatchClaimWithWitness(
        function (bytes32, bytes32, QualifiedClaim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function (bytes32, bytes32, QualifiedSplitBatchClaimWithWitness calldata, address) internal view
                fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _notExpiredAndWithValidQualifiedSignatures(
        bytes32 messageHash,
        bytes32 qualificationMessageHash,
        QualifiedClaim calldata claimPayload,
        address allocator
    ) internal view {
        claimPayload.expires.later();
        bytes32 domainSeparator = _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
        messageHash.signedBy(claimPayload.sponsor, claimPayload.sponsorSignature, domainSeparator);
        qualificationMessageHash.signedBy(
            allocator, claimPayload.allocatorSignature, domainSeparator
        );
    }

    // NOTE: this function expects that there's at least one array element
    function _notExpiredAndWithValidSignaturesBatch(BatchClaim calldata claimPayload)
        internal
        returns (bytes32 messageHash, uint96 allocatorId)
    {
        messageHash = claimPayload.toMessageHash();
        allocatorId = claimPayload.claims[0].id.toAllocatorId();

        _usingBatchClaim(_notExpiredAndWithValidSignatures)(
            messageHash,
            claimPayload,
            allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce)
        );
    }

    function _notExpiredAndWithValidSignaturesBatchWithWitness(
        BatchClaimWithWitness calldata claimPayload
    ) internal returns (bytes32 messageHash, uint96 allocatorId) {
        messageHash = claimPayload.toMessageHash();
        allocatorId = claimPayload.claims[0].id.toAllocatorId();

        _usingBatchClaimWithWitness(_notExpiredAndWithValidSignatures)(
            messageHash,
            claimPayload,
            allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce)
        );
    }

    // NOTE: this function expects that there's at least one array element
    function _notExpiredAndWithValidSignaturesQualifiedBatch(
        QualifiedBatchClaim calldata claimPayload
    ) internal returns (bytes32 messageHash, uint96 allocatorId) {
        bytes32 qualificationMessageHash;
        allocatorId = claimPayload.claims[0].id.toAllocatorId();
        (messageHash, qualificationMessageHash) = claimPayload.toMessageHash();

        _usingQualifiedBatchClaim(_notExpiredAndWithValidQualifiedSignatures)(
            messageHash,
            qualificationMessageHash,
            claimPayload,
            allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce)
        );
    }

    function _notExpiredAndWithValidSignaturesQualifiedBatchWithWitness(
        QualifiedBatchClaimWithWitness calldata claimPayload
    ) internal returns (bytes32 messageHash, uint96 allocatorId) {
        bytes32 qualificationMessageHash;
        allocatorId = claimPayload.claims[0].id.toAllocatorId();
        (messageHash, qualificationMessageHash) = claimPayload.toMessageHash();

        _usingQualifiedBatchClaimWithWitness(_notExpiredAndWithValidQualifiedSignatures)(
            messageHash,
            qualificationMessageHash,
            claimPayload,
            allocatorId.fromRegisteredAllocatorIdWithConsumed(claimPayload.nonce)
        );
    }

    function _notExpiredAndWithValidSignaturesQualified(QualifiedClaim calldata claimPayload)
        internal
        returns (bytes32 messageHash)
    {
        bytes32 qualificationMessageHash;
        (messageHash, qualificationMessageHash) = claimPayload.toMessageHash();

        _notExpiredAndWithValidQualifiedSignatures(
            messageHash,
            qualificationMessageHash,
            claimPayload,
            claimPayload.id.toRegisteredAllocatorWithConsumed(claimPayload.nonce)
        );
    }

    function _usingClaimWithWitness(function (bytes32, Claim calldata, address) internal view fnIn)
        internal
        pure
        returns (function (bytes32, ClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _notExpiredAndWithValidSignaturesWithWitness(
        bytes32 messageHash,
        ClaimWithWitness calldata claimPayload,
        address allocator
    ) internal view {
        claimPayload.expires.later();
        bytes32 domainSeparator = _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
        messageHash.signedBy(claimPayload.sponsor, claimPayload.sponsorSignature, domainSeparator);
        messageHash.signedBy(allocator, claimPayload.allocatorSignature, domainSeparator);
    }

    function _notExpiredAndWithValidSignaturesQualifiedWithWitness(
        QualifiedClaimWithWitness calldata claimPayload
    ) internal returns (bytes32 messageHash) {
        bytes32 qualificationMessageHash;
        (messageHash, qualificationMessageHash) = claimPayload.toMessageHash();

        _usingQualifiedClaimWithWitness(_notExpiredAndWithValidQualifiedSignatures)(
            messageHash,
            qualificationMessageHash,
            claimPayload,
            claimPayload.id.toRegisteredAllocatorWithConsumed(claimPayload.nonce)
        );
    }

    function _usingSplitClaimQualifiedWithWitness(
        function(QualifiedClaimWithWitness calldata) internal returns (bytes32) fnIn
    )
        internal
        pure
        returns (function(QualifiedSplitClaimWithWitness calldata) internal returns (bytes32) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingSplitClaimWithWitness(
        function(bytes32, Claim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (function(bytes32, SplitClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingSplitClaim(function(bytes32, Claim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, SplitClaim calldata, address) internal view fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingBatchClaim(function(bytes32, Claim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, BatchClaim calldata, address) internal view fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingSplitBatchClaim(function(bytes32, Claim calldata, address) internal view fnIn)
        internal
        pure
        returns (function(bytes32, SplitBatchClaim calldata, address) internal view fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingSplitBatchClaimWithWitness(
        function(bytes32, Claim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (
            function(bytes32, SplitBatchClaimWithWitness calldata, address) internal view fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingBatchClaimWithWitness(
        function(bytes32, Claim calldata, address) internal view fnIn
    )
        internal
        pure
        returns (function(bytes32, BatchClaimWithWitness calldata, address) internal view fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _usingQualifiedSplitClaim(
        function(QualifiedClaim calldata) internal returns (bytes32) fnIn
    )
        internal
        pure
        returns (function(QualifiedSplitClaim calldata) internal returns (bytes32) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _notExpiredAndSignedByAllocator(
        bytes32 messageHash,
        address allocator,
        BasicTransfer calldata transferPayload
    ) internal view {
        transferPayload.expires.later();

        messageHash.signedBy(
            allocator,
            transferPayload.allocatorSignature,
            _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID)
        );
    }

    function _processBasicTransfer(
        BasicTransfer calldata transfer,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        _notExpiredAndSignedByAllocator(
            transfer.toMessageHash(),
            transfer.id.toRegisteredAllocatorWithConsumed(transfer.nonce),
            transfer
        );

        return operation(msg.sender, transfer.recipient, transfer.id, transfer.amount);
    }

    function _processSplitTransfer(
        SplitTransfer calldata transfer,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        _usingSplitTransfer(_notExpiredAndSignedByAllocator)(
            transfer.toMessageHash(),
            transfer.id.toRegisteredAllocatorWithConsumed(transfer.nonce),
            transfer
        );

        uint256 totalSplits = transfer.recipients.length;
        unchecked {
            for (uint256 i = 0; i < totalSplits; ++i) {
                SplitComponent calldata component = transfer.recipients[i];
                operation(msg.sender, component.claimant, transfer.id, component.amount);
            }
        }

        return true;
    }

    function _processBatchTransfer(
        BatchTransfer calldata transfer,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        _usingBatchTransfer(_notExpiredAndSignedByAllocator)(
            transfer.toMessageHash(),
            _deriveConsistentAllocatorAndConsumeNonce(transfer.transfers, transfer.nonce),
            transfer
        );

        unchecked {
            uint256 totalTransfers = transfer.transfers.length;
            for (uint256 i = 0; i < totalTransfers; ++i) {
                TransferComponent calldata component = transfer.transfers[i];
                operation(msg.sender, transfer.recipient, component.id, component.amount);
            }
        }

        return true;
    }

    function _processSplitBatchTransfer(
        SplitBatchTransfer calldata transfer,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        _usingSplitBatchTransfer(_notExpiredAndSignedByAllocator)(
            transfer.toMessageHash(),
            _usingSplitByIdComponent(_deriveConsistentAllocatorAndConsumeNonce)(
                transfer.transfers, transfer.nonce
            ),
            transfer
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

    function _processClaim(
        Claim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        bytes32 messageHash = claimPayload.toMessageHash();
        _notExpiredAndWithValidSignatures(
            messageHash,
            claimPayload,
            claimPayload.id.toRegisteredAllocatorWithConsumed(claimPayload.nonce)
        );

        claimPayload.amount.withinAllocated(claimPayload.allocatedAmount);

        return _emitAndOperate(
            claimPayload.sponsor,
            claimPayload.claimant,
            claimPayload.id,
            messageHash,
            claimPayload.amount,
            operation
        );
    }

    function _verifyAndProcessSplitComponents(
        address sponsor,
        bytes32 messageHash,
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

                _emitAndOperate(sponsor, component.claimant, id, messageHash, amount, operation);
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

    function _processSplitClaim(
        SplitClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        bytes32 messageHash = claimPayload.toMessageHash();
        _usingSplitClaim(_notExpiredAndWithValidSignatures)(
            messageHash,
            claimPayload,
            claimPayload.id.toRegisteredAllocatorWithConsumed(claimPayload.nonce)
        );

        return _verifyAndProcessSplitComponents(
            claimPayload.sponsor,
            messageHash,
            claimPayload.id,
            claimPayload.allocatedAmount,
            claimPayload.claimants,
            operation
        );
    }

    function _processQualifiedClaim(
        QualifiedClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        claimPayload.amount.withinAllocated(claimPayload.allocatedAmount);

        return _emitAndOperate(
            claimPayload.sponsor,
            claimPayload.claimant,
            claimPayload.id,
            _notExpiredAndWithValidSignaturesQualified(claimPayload),
            claimPayload.amount,
            operation
        );
    }

    function _processQualifiedSplitClaim(
        QualifiedSplitClaim calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _verifyAndProcessSplitComponents(
            claimPayload.sponsor,
            _usingQualifiedSplitClaim(_notExpiredAndWithValidSignaturesQualified)(claimPayload),
            claimPayload.id,
            claimPayload.allocatedAmount,
            claimPayload.claimants,
            operation
        );
    }

    function _processClaimWithWitness(
        ClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        bytes32 messageHash = claimPayload.toMessageHash();
        _usingClaimWithWitness(_notExpiredAndWithValidSignatures)(
            messageHash,
            claimPayload,
            claimPayload.id.toRegisteredAllocatorWithConsumed(claimPayload.nonce)
        );

        claimPayload.amount.withinAllocated(claimPayload.allocatedAmount);

        return _emitAndOperate(
            claimPayload.sponsor,
            claimPayload.claimant,
            claimPayload.id,
            messageHash,
            claimPayload.amount,
            operation
        );
    }

    function _processSplitClaimWithWitness(
        SplitClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        bytes32 messageHash = claimPayload.toMessageHash();
        _usingSplitClaimWithWitness(_notExpiredAndWithValidSignatures)(
            messageHash,
            claimPayload,
            claimPayload.id.toRegisteredAllocatorWithConsumed(claimPayload.nonce)
        );

        return _verifyAndProcessSplitComponents(
            claimPayload.sponsor,
            messageHash,
            claimPayload.id,
            claimPayload.allocatedAmount,
            claimPayload.claimants,
            operation
        );
    }

    function _emitAndOperate(
        address sponsor,
        address claimant,
        uint256 id,
        bytes32 messageHash,
        uint256 amount,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        emit Claimed(sponsor, claimant, id, messageHash, amount);

        return operation(sponsor, claimant, id, amount);
    }

    function _processQualifiedClaimWithWitness(
        QualifiedClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        claimPayload.amount.withinAllocated(claimPayload.allocatedAmount);

        return _emitAndOperate(
            claimPayload.sponsor,
            claimPayload.claimant,
            claimPayload.id,
            _notExpiredAndWithValidSignaturesQualifiedWithWitness(claimPayload),
            claimPayload.amount,
            operation
        );
    }

    function _processQualifiedSplitClaimWithWitness(
        QualifiedSplitClaimWithWitness calldata claimPayload,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        return _verifyAndProcessSplitComponents(
            claimPayload.sponsor,
            _usingSplitClaimQualifiedWithWitness(
                _notExpiredAndWithValidSignaturesQualifiedWithWitness
            )(claimPayload),
            claimPayload.id,
            claimPayload.allocatedAmount,
            claimPayload.claimants,
            operation
        );
    }

    function _verifyAndProcessBatchComponents(
        uint96 allocatorId,
        address sponsor,
        address claimant,
        bytes32 messageHash,
        BatchClaimComponent[] calldata claims,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        uint256 totalClaims = claims.length;
        if (totalClaims == 0) {
            revert InvalidBatchAllocation();
        }

        // TODO: many of the bounds checks on these array accesses can be skipped as an optimization
        BatchClaimComponent calldata component = claims[0];
        uint256 errorBuffer = (component.allocatedAmount < component.amount).asUint256();

        _emitAndOperate(sponsor, claimant, component.id, messageHash, component.amount, operation);

        unchecked {
            for (uint256 i = 1; i < totalClaims; ++i) {
                component = claims[i];
                errorBuffer |= (component.id.toAllocatorId() != allocatorId).or(
                    component.allocatedAmount < component.amount
                ).asUint256();

                _emitAndOperate(
                    sponsor, claimant, component.id, messageHash, component.amount, operation
                );
            }
        }
        if (errorBuffer.asBool()) {
            for (uint256 i = 0; i < totalClaims; ++i) {
                component = claims[i];
                component.amount.withinAllocated(component.allocatedAmount);
            }

            // TODO: extract more informative error by deriving the reason for the failure
            revert InvalidBatchAllocation();
        }

        return true;
    }

    function _verifyAndProcessSplitBatchComponents(
        uint96 allocatorId,
        address sponsor,
        bytes32 messageHash,
        SplitBatchClaimComponent[] calldata claims,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        uint256 totalClaims = claims.length;
        uint256 errorBuffer = (totalClaims == 0).asUint256();

        unchecked {
            for (uint256 i = 0; i < totalClaims; ++i) {
                SplitBatchClaimComponent calldata claim = claims[i];
                errorBuffer |= (claim.id.toAllocatorId() != allocatorId).asUint256();

                _verifyAndProcessSplitComponents(
                    sponsor, messageHash, claim.id, claim.allocatedAmount, claim.portions, operation
                );
            }
        }

        if (errorBuffer.asBool()) {
            revert InvalidBatchAllocation();
        }

        return true;
    }

    function _processBatchClaim(
        BatchClaim calldata batchClaim,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        bytes32 messageHash = batchClaim.toMessageHash();
        uint96 allocatorId = batchClaim.claims[0].id.toAllocatorId();

        _usingBatchClaim(_notExpiredAndWithValidSignatures)(
            messageHash,
            batchClaim,
            allocatorId.fromRegisteredAllocatorIdWithConsumed(batchClaim.nonce)
        );

        return _verifyAndProcessBatchComponents(
            allocatorId,
            batchClaim.sponsor,
            batchClaim.claimant,
            messageHash,
            batchClaim.claims,
            operation
        );
    }

    function _processSplitBatchClaim(
        SplitBatchClaim calldata batchClaim,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        bytes32 messageHash = batchClaim.toMessageHash();
        uint96 allocatorId = batchClaim.claims[0].id.toAllocatorId();

        _usingSplitBatchClaim(_notExpiredAndWithValidSignatures)(
            messageHash,
            batchClaim,
            allocatorId.fromRegisteredAllocatorIdWithConsumed(batchClaim.nonce)
        );

        return _verifyAndProcessSplitBatchComponents(
            allocatorId, batchClaim.sponsor, messageHash, batchClaim.claims, operation
        );
    }

    function _processQualifiedSplitBatchClaim(
        QualifiedSplitBatchClaim calldata batchClaim,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualifiedMessageHash) = batchClaim.toMessageHash();
        uint96 allocatorId = batchClaim.claims[0].id.toAllocatorId();

        _usingQualifiedSplitBatchClaim(_notExpiredAndWithValidQualifiedSignatures)(
            messageHash,
            qualifiedMessageHash,
            batchClaim,
            allocatorId.fromRegisteredAllocatorIdWithConsumed(batchClaim.nonce)
        );

        return _verifyAndProcessSplitBatchComponents(
            allocatorId, batchClaim.sponsor, messageHash, batchClaim.claims, operation
        );
    }

    function _processQualifiedSplitBatchClaimWithWitness(
        QualifiedSplitBatchClaimWithWitness calldata batchClaim,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, bytes32 qualifiedMessageHash) = batchClaim.toMessageHash();
        uint96 allocatorId = batchClaim.claims[0].id.toAllocatorId();

        _usingQualifiedSplitBatchClaimWithWitness(_notExpiredAndWithValidQualifiedSignatures)(
            messageHash,
            qualifiedMessageHash,
            batchClaim,
            allocatorId.fromRegisteredAllocatorIdWithConsumed(batchClaim.nonce)
        );

        return _verifyAndProcessSplitBatchComponents(
            allocatorId, batchClaim.sponsor, messageHash, batchClaim.claims, operation
        );
    }

    function _processSplitBatchClaimWithWitness(
        SplitBatchClaimWithWitness calldata batchClaim,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        bytes32 messageHash = batchClaim.toMessageHash();
        uint96 allocatorId = batchClaim.claims[0].id.toAllocatorId();

        _usingSplitBatchClaimWithWitness(_notExpiredAndWithValidSignatures)(
            messageHash,
            batchClaim,
            allocatorId.fromRegisteredAllocatorIdWithConsumed(batchClaim.nonce)
        );

        return _verifyAndProcessSplitBatchComponents(
            allocatorId, batchClaim.sponsor, messageHash, batchClaim.claims, operation
        );
    }

    function _processQualifiedBatchClaim(
        QualifiedBatchClaim calldata batchClaim,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, uint96 allocatorId) =
            _notExpiredAndWithValidSignaturesQualifiedBatch(batchClaim);

        return _verifyAndProcessBatchComponents(
            allocatorId,
            batchClaim.sponsor,
            batchClaim.claimant,
            messageHash,
            batchClaim.claims,
            operation
        );
    }

    function _processBatchClaimWithWitness(
        BatchClaimWithWitness calldata batchClaim,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, uint96 allocatorId) =
            _notExpiredAndWithValidSignaturesBatchWithWitness(batchClaim);

        return _verifyAndProcessBatchComponents(
            allocatorId,
            batchClaim.sponsor,
            batchClaim.claimant,
            messageHash,
            batchClaim.claims,
            operation
        );
    }

    function _processQualifiedBatchClaimWithWitness(
        QualifiedBatchClaimWithWitness calldata batchClaim,
        function(address, address, uint256, uint256) internal returns (bool) operation
    ) internal returns (bool) {
        (bytes32 messageHash, uint96 allocatorId) =
            _notExpiredAndWithValidSignaturesQualifiedBatchWithWitness(batchClaim);

        return _verifyAndProcessBatchComponents(
            allocatorId,
            batchClaim.sponsor,
            batchClaim.claimant,
            messageHash,
            batchClaim.claims,
            operation
        );
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

        (
            ISignatureTransfer.SignatureTransferDetails[] memory details,
            ISignatureTransfer.TokenPermissions[] memory permittedTokens
        ) = _preparePermit2ArraysAndPerformDeposits(
            ids,
            totalTokensLessInitialNative,
            firstUnderlyingTokenIsNative,
            permitted,
            initialId,
            recipient,
            depositor
        );

        ISignatureTransfer.PermitBatchTransferFrom memory permitTransferFrom = ISignatureTransfer
            .PermitBatchTransferFrom({ permitted: permittedTokens, nonce: nonce, deadline: deadline });

        _PERMIT2.permitWitnessTransferFrom(
            permitTransferFrom,
            details,
            depositor,
            witness,
            "CompactDeposit witness)CompactDeposit(address depositor,address allocator,uint8 resetPeriod,uint8 scope,address recipient)TokenPermissions(address token,uint256 amount)",
            signature
        );
    }

    function _preparePermit2ArraysAndPerformDeposits(
        uint256[] memory ids,
        uint256 totalTokensLessInitialNative,
        bool firstUnderlyingTokenIsNative,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        uint256 initialId,
        address recipient,
        address depositor
    )
        internal
        returns (
            ISignatureTransfer.SignatureTransferDetails[] memory details,
            ISignatureTransfer.TokenPermissions[] memory permittedTokens
        )
    {
        unchecked {
            details =
                new ISignatureTransfer.SignatureTransferDetails[](totalTokensLessInitialNative);

            permittedTokens =
                new ISignatureTransfer.TokenPermissions[](totalTokensLessInitialNative);

            for (uint256 i = 0; i < totalTokensLessInitialNative; ++i) {
                ISignatureTransfer.TokenPermissions calldata permittedToken =
                    permitted[i + firstUnderlyingTokenIsNative.asUint256()];

                permittedTokens[i] = permittedToken;
                details[i] = ISignatureTransfer.SignatureTransferDetails({
                    to: address(this),
                    requestedAmount: permittedToken.amount
                });

                uint256 id = initialId.withReplacedToken(permittedToken.token);
                ids[i + firstUnderlyingTokenIsNative.asUint256()] = id;

                _deposit(depositor, recipient, id, permittedToken.amount);
            }
        }
    }

    // NOTE: the id field needs to be at the exact same struct offset for this to work!
    function _usingSplitByIdComponent(
        function (TransferComponent[] memory, uint256) internal returns (address) fnIn
    )
        internal
        pure
        returns (function (SplitByIdComponent[] memory, uint256) internal returns (address) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _deriveConsistentAllocatorAndConsumeNonce(
        TransferComponent[] memory components,
        uint256 nonce
    ) internal returns (address allocator) {
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

    /// @dev Moves token `id` from `from` to `to` without checking
    //  allowances or _beforeTokenTransfer / _afterTokenTransfer hooks.
    function _release(address from, address to, uint256 id, uint256 amount)
        internal
        returns (bool)
    {
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
            // Emit the {Transfer} event.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, 0, shr(0x60, shl(0x60, to)), id)
        }

        emit Deposit(from, to, id, amount);
    }

    /// @dev Burns `amount` token `id` from `from` without checking transfer hooks and sends
    /// the corresponding underlying tokens to `to`. Emits {Transfer} & {Withdrawal} events.
    function _withdraw(address from, address to, uint256 id, uint256 amount)
        internal
        returns (bool)
    {
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
            // Emit the {Transfer} event.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, shr(0x60, shl(0x60, from)), 0, id)
        }

        address token = id.toToken();
        if (token == address(0)) {
            to.safeTransferETH(amount);
        } else {
            token.safeTransfer(to, amount);
        }

        emit Withdrawal(from, to, id, amount);

        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 id, uint256 amount)
        internal
        virtual
        override
    {
        if (
            IAllocator(id.toAllocator()).attest(msg.sender, from, to, id, amount)
                != IAllocator.attest.selector
        ) {
            revert UnallocatedTransfer(msg.sender, from, to, id, amount);
        }
    }
}

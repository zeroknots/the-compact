// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ITheCompact } from "./interfaces/ITheCompact.sol";
import { Lock } from "./types/Lock.sol";
import { Scope } from "./types/Scope.sol";
import { ResetPeriod } from "./types/ResetPeriod.sol";
import { ForcedWithdrawalStatus } from "./types/ForcedWithdrawalStatus.sol";
import { IdLib } from "./lib/IdLib.sol";
import { ConsumerLib } from "./lib/ConsumerLib.sol";
import { EfficiencyLib } from "./lib/EfficiencyLib.sol";
import { HashLib } from "./lib/HashLib.sol";
import { MetadataLib } from "./lib/MetadataLib.sol";
import { ERC6909 } from "solady/tokens/ERC6909.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { SignatureCheckerLib } from "solady/utils/SignatureCheckerLib.sol";
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

import { BatchClaimComponent } from "./types/Components.sol";

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
contract TheCompact is ITheCompact, ERC6909 {
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
    using ConsumerLib for uint256;
    using SafeTransferLib for address;
    using SignatureCheckerLib for address;
    using FixedPointMathLib for uint256;
    using EfficiencyLib for bool;
    using EfficiencyLib for uint256;

    IPermit2 private constant _PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    /// @dev `keccak256(bytes("CompactDeposit(address depositor,address allocator,uint8 resetPeriod,uint8 scope,address recipient)"))`.
    bytes32 private constant _PERMIT2_WITNESS_FRAGMENT_HASH =
        0x0091bfc8f1539e204529602051ae82f3e6c6f0f86d0227c9ea890616cedbe646;

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
        if (token == address(0)) {
            revert InvalidToken(token);
        }

        id = token.toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

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
        if (token == address(0)) {
            revert InvalidToken(token);
        }

        id = token.toIdIfRegistered(scope, resetPeriod, allocator);

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

        uint96 currentAllocatorId = id.toAllocatorId();
        currentAllocatorId.mustHaveARegisteredAllocator();

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
        if (token == address(0)) {
            revert InvalidToken(token);
        }

        id = token.toIdIfRegistered(scope, resetPeriod, allocator);

        ISignatureTransfer.SignatureTransferDetails memory signatureTransferDetails =
        ISignatureTransfer.SignatureTransferDetails({ to: address(this), requestedAmount: amount });

        ISignatureTransfer.TokenPermissions memory tokenPermissions =
            ISignatureTransfer.TokenPermissions({ token: token, amount: amount });

        ISignatureTransfer.PermitTransferFrom memory permitTransferFrom = ISignatureTransfer
            .PermitTransferFrom({ permitted: tokenPermissions, nonce: nonce, deadline: deadline });

        bytes32 witness = keccak256(
            abi.encode(
                _PERMIT2_WITNESS_FRAGMENT_HASH, depositor, allocator, resetPeriod, scope, recipient
            )
        );

        _PERMIT2.permitWitnessTransferFrom(
            permitTransferFrom,
            signatureTransferDetails,
            depositor,
            witness,
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

        bytes32 witness = keccak256(
            abi.encode(
                _PERMIT2_WITNESS_FRAGMENT_HASH, depositor, allocator, resetPeriod, scope, recipient
            )
        );

        return _processBatchPermit2Deposits(
            firstUnderlyingTokenIsNative,
            recipient,
            initialId,
            totalTokens,
            permitted,
            depositor,
            nonce,
            deadline,
            witness,
            signature
        );
    }

    function allocatedTransfer(BasicTransfer memory transfer) external returns (bool) {
        _assertValidTime(transfer.expires);

        address allocator = transfer.id.toAllocator();
        transfer.nonce.consumeNonce(allocator);

        _assertValidSignature(transfer.toMessageHash(), transfer.allocatorSignature, allocator);

        return _release(msg.sender, transfer.recipient, transfer.id, transfer.amount);
    }

    function allocatedWithdrawal(BasicTransfer memory transfer) external returns (bool) {
        _assertValidTime(transfer.expires);

        address allocator = transfer.id.toAllocator();
        transfer.nonce.consumeNonce(allocator);

        _assertValidSignature(transfer.toMessageHash(), transfer.allocatorSignature, allocator);

        _withdraw(msg.sender, transfer.recipient, transfer.id, transfer.amount);

        return true;
    }

    function claim(Claim memory claimPayload) external returns (bool) {
        _processClaim(claimPayload);

        return _release(
            claimPayload.sponsor, claimPayload.claimant, claimPayload.id, claimPayload.amount
        );
    }

    function claim(BatchClaim memory claimPayload) external returns (bool) {
        return _processBatchClaim(claimPayload);
    }

    function claimAndWithdraw(Claim memory claimPayload) external returns (bool) {
        _processClaim(claimPayload);

        _withdraw(claimPayload.sponsor, claimPayload.claimant, claimPayload.id, claimPayload.amount);

        return true;
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
        return nonce.isConsumedBy(allocator);
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator) {
        return _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);
    }

    function extsload(bytes32 slot) external view returns (bytes32) {
        assembly ("memory-safe") {
            mstore(0, sload(slot))
            return(0, 0x20)
        }
    }

    function extsload(bytes32 startSlot, uint256 nSlots) external view returns (bytes32[] memory) {
        assembly ("memory-safe") {
            let memptr := mload(0x40)
            let start := memptr
            // A left bit-shift of 5 is equivalent to multiplying by 32 but costs less gas.
            let length := shl(5, nSlots)
            // The abi offset of dynamic array in the returndata is 32.
            mstore(memptr, 0x20)
            // Store the length of the array returned
            mstore(add(memptr, 0x20), nSlots)
            // update memptr to the first location to hold a result
            memptr := add(memptr, 0x40)
            let end := add(memptr, length)
            for { } 1 { } {
                mstore(memptr, sload(startSlot))
                memptr := add(memptr, 0x20)
                startSlot := add(startSlot, 1)
                if iszero(lt(memptr, end)) { break }
            }
            return(start, sub(end, start))
        }
    }

    function extsload(bytes32[] calldata slots) external view returns (bytes32[] memory) {
        assembly ("memory-safe") {
            let memptr := mload(0x40)
            let start := memptr
            // for abi encoding the response - the array will be found at 0x20
            mstore(memptr, 0x20)
            // next we store the length of the return array
            mstore(add(memptr, 0x20), slots.length)
            // update memptr to the first location to hold an array entry
            memptr := add(memptr, 0x40)
            // A left bit-shift of 5 is equivalent to multiplying by 32 but costs less gas.
            let end := add(memptr, shl(5, slots.length))
            let calldataptr := slots.offset
            for { } 1 { } {
                mstore(memptr, sload(calldataload(calldataptr)))
                memptr := add(memptr, 0x20)
                calldataptr := add(calldataptr, 0x20)
                if iszero(lt(memptr, end)) { break }
            }
            return(start, sub(end, start))
        }
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

    function _processClaim(Claim memory claimPayload) internal {
        _assertValidTime(claimPayload.expires);
        if (claimPayload.allocatedAmount < claimPayload.amount) {
            revert AllocatedAmountExceeded(claimPayload.allocatedAmount, claimPayload.amount);
        }

        address allocator = claimPayload.id.toAllocator();
        claimPayload.nonce.consumeNonce(allocator);

        bytes32 messageHash = claimPayload.toMessageHash();
        _assertValidSignature(messageHash, claimPayload.sponsorSignature, claimPayload.sponsor);
        _assertValidSignature(messageHash, claimPayload.allocatorSignature, allocator);

        emit Claimed(
            claimPayload.sponsor,
            claimPayload.claimant,
            claimPayload.id,
            messageHash,
            claimPayload.amount
        );
    }

    function _processBatchClaim(BatchClaim memory batchClaim) internal returns (bool) {
        _assertValidTime(batchClaim.expires);

        uint256 totalClaims = batchClaim.claims.length;
        if (totalClaims == 0) {
            revert InvalidBatchAllocation();
        }

        // TODO: skip the bounds check on this array access
        uint96 allocatorId = batchClaim.claims[0].id.toAllocatorId();
        address allocator = allocatorId.toRegisteredAllocator();
        batchClaim.nonce.consumeNonce(allocator);
        bytes32 messageHash = batchClaim.toMessageHash();
        _assertValidSignature(messageHash, batchClaim.sponsorSignature, batchClaim.sponsor);
        _assertValidSignature(messageHash, batchClaim.allocatorSignature, allocator);

        // TODO: many of the bounds checks on these array accesses can be skipped as an optimization
        BatchClaimComponent memory component = batchClaim.claims[0];
        uint256 errorBuffer = (component.allocatedAmount < component.amount).asUint256();
        uint256 id = component.id;
        emit Claimed(batchClaim.sponsor, component.claimant, id, messageHash, component.amount);
        _release(batchClaim.sponsor, component.claimant, component.id, component.amount);

        unchecked {
            for (uint256 i = 1; i < totalClaims; ++i) {
                component = batchClaim.claims[i];
                id = component.id;
                errorBuffer |= (id.toAllocatorId() != allocatorId).or(
                    component.allocatedAmount < component.amount
                ).asUint256();
                emit Claimed(
                    batchClaim.sponsor,
                    component.claimant,
                    component.id,
                    messageHash,
                    component.amount
                );
                _release(batchClaim.sponsor, component.claimant, component.id, component.amount);
            }
        }
        if (errorBuffer.asBool()) {
            for (uint256 i = 0; i < totalClaims; ++i) {
                component = batchClaim.claims[i];
                if (component.allocatedAmount < component.amount) {
                    revert AllocatedAmountExceeded(component.allocatedAmount, component.amount);
                }
            }

            // TODO: extract more informative error by deriving the reason for the failure
            revert InvalidBatchAllocation();
        }

        return true;
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

        unchecked {
            ISignatureTransfer.SignatureTransferDetails[] memory details =
                new ISignatureTransfer.SignatureTransferDetails[](totalTokensLessInitialNative);

            ISignatureTransfer.TokenPermissions[] memory permittedTokens =
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

            ISignatureTransfer.PermitBatchTransferFrom memory permitTransferFrom =
            ISignatureTransfer.PermitBatchTransferFrom({
                permitted: permittedTokens,
                nonce: nonce,
                deadline: deadline
            });

            _PERMIT2.permitWitnessTransferFrom(
                permitTransferFrom,
                details,
                depositor,
                witness,
                "CompactDeposit witness)CompactDeposit(address depositor,address allocator,uint8 resetPeriod,uint8 scope,address recipient)TokenPermissions(address token,uint256 amount)",
                signature
            );
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
    function _deposit(address from, address to, uint256 id, uint256 amount) internal virtual {
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
    function _withdraw(address from, address to, uint256 id, uint256 amount) internal virtual {
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
    }

    function _assertValidTime(uint256 startTime, uint256 endTime) internal view {
        assembly ("memory-safe") {
            if or(gt(startTime, timestamp()), iszero(gt(endTime, timestamp()))) {
                // revert InvalidTime(startTime, endTime);
                mstore(0, 0x21ccfeb7)
                mstore(0x20, startTime)
                mstore(0x40, endTime)
                revert(0x1c, 0x44)
            }
        }
    }

    function _assertValidTime(uint256 expiration) internal view {
        assembly ("memory-safe") {
            if iszero(gt(expiration, timestamp())) {
                // revert Expired(expiration);
                mstore(0, 0xf80dbaea)
                mstore(0x20, expiration)
                revert(0x1c, 0x24)
            }
        }
    }

    function _assertValidSignature(
        bytes32 messageHash,
        bytes memory signature,
        address expectedSigner
    ) internal view {
        // NOTE: analyze whether the signature check can safely be skipped in all
        // cases where the caller is the expected signer.
        if (msg.sender != expectedSigner) {
            if (!expectedSigner.isValidSignatureNow(_getDomainHash(messageHash), signature)) {
                revert InvalidSignature();
            }
        }
    }

    function _deriveClaimant(
        address allocationClaimant,
        address allocationAuthorizationClaimant,
        address oracleClaimant
    ) internal pure returns (address claimant) {
        assembly ("memory-safe") {
            // clean upper dirty bits just in case
            let a := shr(0x60, shl(0x60, allocationClaimant))
            let b := shr(0x60, shl(0x60, allocationAuthorizationClaimant))
            let c := shr(0x60, shl(0x60, oracleClaimant))

            // all these things need to be true:
            // 1) a != 0 || b != 0 || c != 0
            // 2) a == b || a == 0 || b == 0
            // 3) a == c || a == 0 || c == 0
            // 4) b == c || b == 0 || c == 0
            let valid :=
                and(
                    and(iszero(iszero(or(or(a, b), c))), or(eq(a, b), or(iszero(a), iszero(b)))),
                    and(or(eq(a, c), or(iszero(a), iszero(c))), or(eq(b, c), or(iszero(b), iszero(c))))
                )

            if iszero(valid) {
                // `InvalidClaimant(address providerClaimant, address allocatorClaimant, address oracleClaimant)`
                mstore(0, 0xeeaed345)
                mstore(0x20, a)
                mstore(0x40, b)
                mstore(0x60, c)
                revert(0x1c, 0x64)
            }

            // a + (iszero(a) * b) + (iszero(a) * iszero(b) * c)
            // this gives the first non-zero address among a, b, or c
            claimant := add(add(a, mul(iszero(a), b)), mul(and(iszero(a), iszero(b)), c))
        }
    }

    function _getDomainHash(bytes32 messageHash) internal view returns (bytes32 domainHash) {
        bytes32 domainSeparator = _INITIAL_DOMAIN_SEPARATOR.toLatest(_INITIAL_CHAIN_ID);

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer.

            // Prepare the 712 prefix.
            mstore(0, 0x1901)

            mstore(0x20, domainSeparator)

            // Prepare the message hash and compute the domain hash.
            mstore(0x40, messageHash)
            domainHash := keccak256(0x1e, 0x42)

            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 id, uint256 amount)
        internal
        virtual
        override
    {
        if (IAllocator(id.toAllocator()).attest(from, to, id, amount) != IAllocator.attest.selector)
        {
            revert UnallocatedTransfer(from, to, id, amount);
        }
    }
}

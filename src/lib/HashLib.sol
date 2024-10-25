// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {
    Compact,
    COMPACT_TYPEHASH,
    COMPACT_TYPESTRING_FRAGMENT_ONE,
    COMPACT_TYPESTRING_FRAGMENT_TWO,
    COMPACT_TYPESTRING_FRAGMENT_THREE,
    BatchCompact,
    BATCH_COMPACT_TYPEHASH,
    BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE,
    BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO,
    BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE,
    BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR,
    Segment,
    SEGMENT_TYPEHASH,
    MultichainCompact,
    MULTICHAIN_COMPACT_TYPEHASH,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FOUR,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FIVE,
    PERMIT2_DEPOSIT_WITNESS_FRAGMENT_HASH
} from "../types/EIP712Types.sol";

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

import { TransferComponent, SplitComponent, SplitByIdComponent, BatchClaimComponent, SplitBatchClaimComponent } from "../types/Components.sol";

import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

import { FunctionCastLib } from "./FunctionCastLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";

library HashLib {
    using EfficiencyLib for bool;
    using FunctionCastLib for function(BatchTransfer calldata, bytes32) internal view returns (bytes32);
    using FunctionCastLib for function(QualifiedClaim calldata) internal view returns (bytes32, bytes32);
    using FunctionCastLib for function(uint256, uint256) internal view returns (bytes32, bytes32);
    using FunctionCastLib for function(uint256, bytes32, uint256) internal pure returns (bytes32);
    using FunctionCastLib for function(QualifiedClaimWithWitness calldata) internal view returns (bytes32, bytes32, bytes32);
    using FunctionCastLib for function(SplitBatchClaim calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32);
    using FunctionCastLib for function(SplitBatchClaimWithWitness calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32, bytes32);
    using FunctionCastLib for function(uint256, bytes32) internal view returns (bytes32);
    using FunctionCastLib for function(uint256, bytes32) internal view returns (bytes32, bytes32);
    using FunctionCastLib for function(uint256, uint256) internal view returns (bytes32);
    using FunctionCastLib for function(uint256, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32);
    using FunctionCastLib for function(ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32);
    using FunctionCastLib for function(BatchClaimWithWitness calldata, bytes32) internal view returns (bytes32, bytes32);
    using FunctionCastLib for function(MultichainClaimWithWitness calldata) pure returns (bytes32, bytes32);
    using FunctionCastLib for function(uint256, uint256) pure returns (bytes32);

    /// @dev `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`.
    bytes32 internal constant _DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev `keccak256(bytes("The Compact"))`.
    bytes32 internal constant _NAME_HASH = 0x5e6f7b4e1ac3d625bac418bc955510b3e054cb6cc23cc27885107f080180b292;

    /// @dev `keccak256("0")`.
    bytes32 internal constant _VERSION_HASH = 0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d;

    function toMessageHash(BasicTransfer calldata transfer) internal view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            mstore(add(m, 0x40), caller()) // sponsor: msg.sender
            calldatacopy(add(m, 0x60), add(transfer, 0x20), 0x80) // nonce, expires, id, amount
            messageHash := keccak256(m, 0xe0)
        }
    }

    function toMessageHash(SplitTransfer calldata transfer) internal view returns (bytes32 messageHash) {
        uint256 amount = 0;
        uint256 currentAmount;

        SplitComponent[] calldata recipients = transfer.recipients;
        uint256 totalRecipients = recipients.length;
        uint256 errorBuffer;

        unchecked {
            for (uint256 i = 0; i < totalRecipients; ++i) {
                currentAmount = recipients[i].amount;
                amount += currentAmount;
                errorBuffer |= (amount < currentAmount).asUint256();
            }
        }

        assembly ("memory-safe") {
            if errorBuffer {
                // Revert Panic(0x11) (arithmetic overflow)
                mstore(0, 0x4e487b71)
                mstore(0x20, 0x11)
                revert(0x1c, 0x24)
            }

            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            mstore(add(m, 0x40), caller()) // sponsor: msg.sender
            calldatacopy(add(m, 0x60), add(transfer, 0x20), 0x60) // nonce, expires, id
            mstore(add(m, 0xc0), amount)
            messageHash := keccak256(m, 0xe0)
        }
    }

    function toMessageHash(BatchTransfer calldata transfer) internal view returns (bytes32 messageHash) {
        TransferComponent[] calldata transfers = transfer.transfers;
        bytes32 idsAndAmountsHash;
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            let totalTransferData := mul(transfers.length, 0x40)
            calldatacopy(m, transfers.offset, totalTransferData)
            idsAndAmountsHash := keccak256(m, totalTransferData)
        }

        messageHash = _deriveBatchCompactMessageHash(transfer, idsAndAmountsHash);
    }

    function toMessageHash(SplitBatchTransfer calldata transfer) internal view returns (bytes32 messageHash) {
        SplitByIdComponent[] calldata transfers = transfer.transfers;
        uint256 totalIds = transfers.length;

        bytes memory idsAndAmounts = new bytes(totalIds * 0x40);
        uint256 errorBuffer;

        unchecked {
            for (uint256 i = 0; i < totalIds; ++i) {
                SplitByIdComponent calldata transferComponent = transfers[i];
                uint256 id = transferComponent.id;
                uint256 amount = 0;
                uint256 singleAmount;

                SplitComponent[] calldata portions = transferComponent.portions;
                uint256 portionsLength = portions.length;
                for (uint256 j = 0; j < portionsLength; ++j) {
                    singleAmount = portions[j].amount;
                    amount += singleAmount;
                    errorBuffer |= (amount < singleAmount).asUint256();
                }

                assembly ("memory-safe") {
                    let extraOffset := add(add(idsAndAmounts, 0x20), mul(i, 0x40))
                    mstore(extraOffset, id)
                    mstore(add(extraOffset, 0x20), amount)
                }
            }
        }

        bytes32 idsAndAmountsHash;
        assembly ("memory-safe") {
            if errorBuffer {
                // Revert Panic(0x11) (arithmetic overflow)
                mstore(0, 0x4e487b71)
                mstore(0x20, 0x11)
                revert(0x1c, 0x24)
            }
            idsAndAmountsHash := keccak256(add(idsAndAmounts, 0x20), mload(idsAndAmounts))
        }

        messageHash = _deriveBatchCompactMessageHash.usingSplitBatchTransfer()(transfer, idsAndAmountsHash);
    }

    function toMessageHash(BasicClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _toClaimMessageHash.usingBasicClaim()(claim, 0);
    }

    function toMessageHash(QualifiedClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toClaimMessageHash.usingQualifiedClaim()(claim, 0x40);

        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedClaim()(claim, messageHash, 0);
    }

    function toMessageHash(QualifiedSplitClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toClaimMessageHash.usingQualifiedSplitClaim()(claim, 0x40);

        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedSplitClaim()(claim, messageHash, 0);
    }

    function toMessageHash(ClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        return _toMessageHashWithWitness.usingClaimWithWitness()(claim, 0);
    }

    function toMessageHash(QualifiedClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        (messageHash, typehash) = _toMessageHashWithWitness.usingQualifiedClaimWithWitness()(claim, 0x40);
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(QualifiedSplitClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        (messageHash, typehash) = _toMessageHashWithWitness.usingQualifiedSplitClaimWithWitness()(claim, 0x40);
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedSplitClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(BatchClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _toBatchMessageHash.usingBatchClaim()(claim, _toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(SplitBatchClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _toBatchMessageHash.usingSplitBatchClaim()(claim, _toSplitIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(SplitBatchClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        return _toBatchClaimWithWitnessMessageHash.usingSplitBatchClaimWithWitness()(claim, _toSplitIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedBatchClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toBatchMessageHash.usingQualifiedBatchClaim()(claim, _toIdsAndAmountsHash(claim.claims));

        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedBatchClaim()(claim, messageHash, 0);
    }

    function toMessageHash(BatchClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        return _toBatchClaimWithWitnessMessageHash.usingBatchClaimWithWitness()(claim, _toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedBatchClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        (messageHash, typehash) = _toBatchClaimWithWitnessMessageHash.usingQualifiedBatchClaimWithWitness()(claim, _toIdsAndAmountsHash(claim.claims));

        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedBatchClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(SplitClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _toClaimMessageHash.usingSplitClaim()(claim, 0);
    }

    function toMessageHash(SplitClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        return _toMessageHashWithWitness.usingSplitClaimWithWitness()(claim, 0);
    }

    function toMessageHash(QualifiedSplitBatchClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toBatchMessageHash.usingQualifiedSplitBatchClaim()(claim, _toSplitIdsAndAmountsHash(claim.claims));

        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedSplitBatchClaim()(claim, messageHash, 0);
    }

    function toMessageHash(QualifiedSplitBatchClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        (messageHash, typehash) = _toBatchClaimWithWitnessMessageHash.usingQualifiedSplitBatchClaimWithWitness()(claim, _toSplitIdsAndAmountsHash(claim.claims));

        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedSplitBatchClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(MultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        messageHash = _toMultichainClaimMessageHash.usingMultichainClaim()(claim, 0, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _deriveIdsAndAmountsHash.usingMultichainClaim()(claim, 0));
    }

    function toMessageHash(BatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        messageHash = _toMultichainClaimMessageHash.usingBatchMultichainClaim()(claim, 0, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toMultichainClaimMessageHash.usingQualifiedBatchMultichainClaim()(claim, 0x40, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _toIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedBatchMultichainClaim()(claim, messageHash, 0);
    }

    function toMessageHash(BatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingBatchMultichainClaimWithWitness()(claim);
        messageHash = _toMultichainClaimMessageHash.usingBatchMultichainClaimWithWitness()(claim, 0x40, allocationTypehash, typehash, _toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingQualifiedBatchMultichainClaimWithWitness()(claim);

        messageHash = _toMultichainClaimMessageHash.usingQualifiedBatchMultichainClaimWithWitness()(claim, 0x80, allocationTypehash, typehash, _toIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedBatchMultichainClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(SplitBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        messageHash = _toMultichainClaimMessageHash.usingSplitBatchMultichainClaim()(claim, 0, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _toSplitIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedSplitBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toMultichainClaimMessageHash.usingQualifiedSplitBatchMultichainClaim()(claim, 0x40, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _toSplitIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedSplitBatchMultichainClaim()(claim, messageHash, 0);
    }

    function toMessageHash(SplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingSplitBatchMultichainClaimWithWitness()(claim);

        messageHash = _toMultichainClaimMessageHash.usingSplitBatchMultichainClaimWithWitness()(claim, 0x40, allocationTypehash, typehash, _toSplitIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedSplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingQualifiedSplitBatchMultichainClaimWithWitness()(claim);

        messageHash = _toMultichainClaimMessageHash.usingQualifiedSplitBatchMultichainClaimWithWitness()(claim, 0x80, allocationTypehash, typehash, _toSplitIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedSplitBatchMultichainClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(MultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes(claim);
        messageHash =
            _toMultichainClaimMessageHash.usingMultichainClaimWithWitness()(claim, 0x40, allocationTypehash, typehash, _deriveIdsAndAmountsHash.usingMultichainClaimWithWitness()(claim, 0x40));
    }

    function toMessageHash(ExogenousMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingExogenousMultichainClaimWithWitness()(claim);
        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousMultichainClaimWithWitness()(
            claim, 0x40, allocationTypehash, typehash, _deriveIdsAndAmountsHash.usingExogenousMultichainClaimWithWitness()(claim, 0x80)
        );
    }

    function toMessageHash(ExogenousSplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingExogenousSplitMultichainClaimWithWitness()(claim);
        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousSplitMultichainClaimWithWitness()(
            claim, 0x40, allocationTypehash, typehash, _deriveIdsAndAmountsHash.usingExogenousSplitMultichainClaimWithWitness()(claim, 0x80)
        );
    }

    function toMessageHash(QualifiedMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingQualifiedMultichainClaimWithWitness()(claim);

        messageHash = _toMultichainClaimMessageHash.usingQualifiedMultichainClaimWithWitness()(
            claim, 0x80, allocationTypehash, typehash, _deriveIdsAndAmountsHash.usingQualifiedMultichainClaimWithWitness()(claim, 0x80)
        );
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedMultichainClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(QualifiedSplitMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toMultichainClaimMessageHash.usingQualifiedSplitMultichainClaim()(
            claim, 0x40, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _deriveIdsAndAmountsHash.usingQualifiedSplitMultichainClaim()(claim, 0x40)
        );
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedSplitMultichainClaim()(claim, messageHash, 0);
    }

    function toMessageHash(SplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingSplitMultichainClaimWithWitness()(claim);
        messageHash = _toMultichainClaimMessageHash.usingSplitMultichainClaimWithWitness()(
            claim, 0x40, allocationTypehash, typehash, _deriveIdsAndAmountsHash.usingSplitMultichainClaimWithWitness()(claim, 0x40)
        );
    }

    function toMessageHash(QualifiedSplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingQualifiedSplitMultichainClaimWithWitness()(claim);

        messageHash = _toMultichainClaimMessageHash.usingQualifiedSplitMultichainClaimWithWitness()(
            claim, 0x80, allocationTypehash, typehash, _deriveIdsAndAmountsHash.usingQualifiedSplitMultichainClaimWithWitness()(claim, 0x80)
        );
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedSplitMultichainClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(QualifiedMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toMultichainClaimMessageHash.usingQualifiedMultichainClaim()(
            claim, 0x40, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _deriveIdsAndAmountsHash.usingQualifiedMultichainClaim()(claim, 0x40)
        );
        qualificationMessageHash = _toQualificationMessageHash.usingQualifiedMultichainClaim()(claim, messageHash, 0);
    }

    function getMultichainTypehashes(MultichainClaimWithWitness calldata claim) internal pure returns (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // prepare full typestring
            let witnessTypestringPtr := add(claim, calldataload(add(claim, 0xc0)))
            let witnessTypestringLength := calldataload(witnessTypestringPtr)

            mstore(m, MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE)
            mstore(add(m, 0x20), MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO)
            mstore(add(m, 0x40), MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE)
            mstore(add(m, 0x76), MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FIVE)
            mstore(add(m, 0x60), MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FOUR)

            calldatacopy(add(m, 0x96), add(0x20, witnessTypestringPtr), witnessTypestringLength)
            allocationTypehash := keccak256(add(m, 0x53), add(0x43, witnessTypestringLength))
            multichainCompactTypehash := keccak256(m, add(0x96, witnessTypestringLength))
        }
    }

    function _toExogenousMultichainClaimMessageHash(
        ExogenousMultichainClaim calldata claim,
        uint256 additionalOffset,
        bytes32 allocationTypehash,
        bytes32 multichainCompactTypehash,
        bytes32 idsAndAmountsHash
    ) internal view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(add(m, 0x60), idsAndAmountsHash)
            mstore(m, allocationTypehash)
            mstore(add(m, 0x20), caller()) // arbiter
            mstore(add(m, 0x40), chainid())

            let hasWitness := iszero(eq(allocationTypehash, SEGMENT_TYPEHASH))
            if hasWitness { mstore(add(m, 0x80), calldataload(add(claim, 0xa0))) } // witness

            let allocationHash := keccak256(m, add(0x80, mul(0x20, hasWitness))) // allocation hash

            // additional allocation hashes
            let claimWithAdditionalOffset := add(claim, additionalOffset)
            let additionalChainsPtr := add(claim, calldataload(add(claimWithAdditionalOffset, 0xa0)))
            let additionalChainsLength := shl(5, calldataload(additionalChainsPtr))
            let additionalChainsData := add(0x20, additionalChainsPtr)
            let chainIndex := shl(5, calldataload(add(claimWithAdditionalOffset, 0xc0)))

            // NOTE: rather than using extraOffset, consider breaking into two distinct
            // loops or potentially even two calldatacopy operations based on chainIndex
            let extraOffset := 0
            for { let i := 0 } lt(i, additionalChainsLength) { i := add(i, 0x20) } {
                mstore(add(m, i), calldataload(add(additionalChainsData, add(i, extraOffset))))
                if eq(i, chainIndex) {
                    extraOffset := 0x20
                    mstore(add(m, add(i, extraOffset)), allocationHash)
                }
            }

            // hash of allocation hashes
            mstore(add(m, 0x80), keccak256(m, add(0x20, additionalChainsLength)))

            mstore(m, multichainCompactTypehash)
            calldatacopy(add(m, 0x20), add(claim, 0x40), 0x60) // sponsor, nonce, expires

            messageHash := keccak256(m, 0xa0)
        }
    }

    function toMessageHash(ExogenousMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _toExogenousMultichainClaimMessageHash(claim, 0, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _deriveIdsAndAmountsHash.usingExogenousMultichainClaim()(claim, 0x40));
    }

    function toMessageHash(ExogenousSplitMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _toExogenousMultichainClaimMessageHash.usingExogenousSplitMultichainClaim()(
            claim, 0, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _deriveIdsAndAmountsHash.usingExogenousSplitMultichainClaim()(claim, 0x40)
        );
    }

    function toMessageHash(ExogenousBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _toExogenousMultichainClaimMessageHash.usingExogenousBatchMultichainClaim()(claim, 0, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(ExogenousSplitBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _toExogenousMultichainClaimMessageHash.usingExogenousSplitBatchMultichainClaim()(claim, 0, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _toSplitIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(ExogenousQualifiedMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousQualifiedMultichainClaim()(
            claim, 0x40, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _deriveIdsAndAmountsHash.usingExogenousQualifiedMultichainClaim()(claim, 0x80)
        );
        qualificationMessageHash = _toQualificationMessageHash.usingExogenousQualifiedMultichainClaim()(claim, messageHash, 0);
    }

    function toMessageHash(ExogenousQualifiedMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingExogenousQualifiedMultichainClaimWithWitness()(claim);

        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousQualifiedMultichainClaimWithWitness()(
            claim, 0x80, allocationTypehash, typehash, _deriveIdsAndAmountsHash.usingExogenousQualifiedMultichainClaimWithWitness()(claim, 0xc0)
        );
        qualificationMessageHash = _toQualificationMessageHash.usingExogenousQualifiedMultichainClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(ExogenousQualifiedSplitMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousQualifiedSplitMultichainClaim()(
            claim, 0x40, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _deriveIdsAndAmountsHash.usingExogenousQualifiedSplitMultichainClaim()(claim, 0x80)
        );
        qualificationMessageHash = _toQualificationMessageHash.usingExogenousQualifiedSplitMultichainClaim()(claim, messageHash, 0);
    }

    function toMessageHash(ExogenousQualifiedSplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingExogenousQualifiedSplitMultichainClaimWithWitness()(claim);

        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousQualifiedSplitMultichainClaimWithWitness()(
            claim, 0x80, allocationTypehash, typehash, _deriveIdsAndAmountsHash.usingExogenousQualifiedSplitMultichainClaimWithWitness()(claim, 0xc0)
        );
        qualificationMessageHash = _toQualificationMessageHash.usingExogenousQualifiedSplitMultichainClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(ExogenousQualifiedBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash =
            _toExogenousMultichainClaimMessageHash.usingExogenousQualifiedBatchMultichainClaim()(claim, 0x40, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _toIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = _toQualificationMessageHash.usingExogenousQualifiedBatchMultichainClaim()(claim, messageHash, 0);
    }

    function toMessageHash(ExogenousBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingExogenousBatchMultichainClaimWithWitness()(claim);
        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousBatchMultichainClaimWithWitness()(claim, 0x40, allocationTypehash, typehash, _toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(ExogenousQualifiedBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingExogenousQualifiedBatchMultichainClaimWithWitness()(claim);

        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousQualifiedBatchMultichainClaimWithWitness()(claim, 0x80, allocationTypehash, typehash, _toIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = _toQualificationMessageHash.usingExogenousQualifiedBatchMultichainClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(ExogenousQualifiedSplitBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousQualifiedSplitBatchMultichainClaim()(
            claim, 0x40, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _toSplitIdsAndAmountsHash(claim.claims)
        );
        qualificationMessageHash = _toQualificationMessageHash.usingExogenousQualifiedSplitBatchMultichainClaim()(claim, messageHash, 0);
    }

    function toMessageHash(ExogenousSplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingExogenousSplitBatchMultichainClaimWithWitness()(claim);

        messageHash = _toExogenousMultichainClaimMessageHash.usingExogenousSplitBatchMultichainClaimWithWitness()(claim, 0x40, allocationTypehash, typehash, _toSplitIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash, bytes32 typehash) {
        bytes32 allocationTypehash;
        (allocationTypehash, typehash) = getMultichainTypehashes.usingExogenousQualifiedSplitBatchMultichainClaimWithWitness()(claim);

        messageHash =
            _toExogenousMultichainClaimMessageHash.usingExogenousQualifiedSplitBatchMultichainClaimWithWitness()(claim, 0x80, allocationTypehash, typehash, _toSplitIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = _toQualificationMessageHash.usingExogenousQualifiedSplitBatchMultichainClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(SplitMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        messageHash = _toMultichainClaimMessageHash.usingSplitMultichainClaim()(claim, 0, SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, _deriveIdsAndAmountsHash.usingSplitMultichainClaim()(claim, 0));
    }

    function toPermit2DepositWitnessHash(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient) internal pure returns (bytes32 witnessHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, PERMIT2_DEPOSIT_WITNESS_FRAGMENT_HASH)
            mstore(add(m, 0x20), allocator)
            mstore(add(m, 0x40), resetPeriod)
            mstore(add(m, 0x60), scope)
            mstore(add(m, 0x80), recipient)
            witnessHash := keccak256(m, 0xa0)
        }
    }

    function toLatest(bytes32 initialDomainSeparator, uint256 initialChainId) external view returns (bytes32 domainSeparator) {
        domainSeparator = initialDomainSeparator;

        assembly ("memory-safe") {
            // Prepare the domain separator, rederiving it if necessary.
            if xor(chainid(), initialChainId) {
                let m := mload(0x40) // Grab the free memory pointer.
                mstore(m, _DOMAIN_TYPEHASH)
                mstore(add(m, 0x20), _NAME_HASH)
                mstore(add(m, 0x40), _VERSION_HASH)
                mstore(add(m, 0x60), chainid())
                mstore(add(m, 0x80), address())
                domainSeparator := keccak256(m, 0xa0)
            }
        }
    }

    function toNotarizedDomainSeparator(uint256 notarizedChainId) internal view returns (bytes32 notarizedDomainSeparator) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer.
            mstore(m, _DOMAIN_TYPEHASH)
            mstore(add(m, 0x20), _NAME_HASH)
            mstore(add(m, 0x40), _VERSION_HASH)
            mstore(add(m, 0x60), notarizedChainId)
            mstore(add(m, 0x80), address())
            notarizedDomainSeparator := keccak256(m, 0xa0)
        }
    }

    function withDomain(bytes32 messageHash, bytes32 domainSeparator) internal pure returns (bytes32 domainHash) {
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

    function _toClaimMessageHash(uint256 claim, uint256 additionalOffset) private view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            let claimWithAdditionalOffset := add(claim, additionalOffset)

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), calldataload(add(claimWithAdditionalOffset, 0xa0))) // id
            mstore(add(m, 0xc0), calldataload(add(claimWithAdditionalOffset, 0xc0))) // amount
            messageHash := keccak256(m, 0xe0)
        }
    }

    function _toQualificationMessageHash(uint256 claim, bytes32 messageHash, uint256 witnessOffset) private pure returns (bytes32 qualificationMessageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            let qualificationPayloadPtr := add(claim, calldataload(add(claim, add(0xc0, witnessOffset))))
            let qualificationPayloadLength := calldataload(qualificationPayloadPtr)

            mstore(m, calldataload(add(claim, add(0xa0, witnessOffset)))) // qualificationTypehash
            mstore(add(m, 0x20), messageHash)
            calldatacopy(add(m, 0x40), add(0x20, qualificationPayloadPtr), qualificationPayloadLength)

            qualificationMessageHash := keccak256(m, add(0x40, qualificationPayloadLength))
        }
    }

    function _toMessageHashWithWitness(uint256 claim, uint256 qualificationOffset) private view returns (bytes32 messageHash, bytes32 typehash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // prepare full typestring
            let witnessTypestringPtr := add(claim, calldataload(add(claim, 0xc0)))
            let witnessTypestringLength := calldataload(witnessTypestringPtr)
            mstore(m, COMPACT_TYPESTRING_FRAGMENT_ONE)
            mstore(add(m, 0x20), COMPACT_TYPESTRING_FRAGMENT_TWO)
            mstore(add(m, 0x40), COMPACT_TYPESTRING_FRAGMENT_THREE)
            calldatacopy(add(m, 0x60), add(0x20, witnessTypestringPtr), witnessTypestringLength)

            typehash := keccak256(m, add(0x60, witnessTypestringLength))

            mstore(m, typehash)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), calldataload(add(claim, add(0xe0, qualificationOffset)))) // id
            mstore(add(m, 0xc0), calldataload(add(claim, add(0x100, qualificationOffset)))) // amount
            mstore(add(m, 0xe0), calldataload(add(claim, 0xa0))) // witness
            messageHash := keccak256(m, 0x100)
        }
    }

    function _deriveBatchCompactMessageHash(BatchTransfer calldata transfer, bytes32 idsAndAmountsHash) private view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, BATCH_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            mstore(add(m, 0x40), caller()) // sponsor: msg.sender
            mstore(add(m, 0x60), calldataload(add(transfer, 0x20))) // nonce
            mstore(add(m, 0x80), calldataload(add(transfer, 0x40))) // expires
            mstore(add(m, 0xa0), idsAndAmountsHash)
            messageHash := keccak256(m, 0xc0)
        }
    }

    function _toIdsAndAmountsHash(BatchClaimComponent[] calldata claims) private pure returns (bytes32 idsAndAmountsHash) {
        uint256 totalIds = claims.length;
        bytes memory idsAndAmounts = new bytes(totalIds * 0x40);

        unchecked {
            for (uint256 i = 0; i < totalIds; ++i) {
                BatchClaimComponent calldata claimComponent = claims[i];
                assembly ("memory-safe") {
                    let extraOffset := add(add(idsAndAmounts, 0x20), mul(i, 0x40))
                    mstore(extraOffset, calldataload(claimComponent)) // id
                    mstore(add(extraOffset, 0x20), calldataload(add(claimComponent, 0x20))) // amount
                }
            }
        }

        assembly ("memory-safe") {
            idsAndAmountsHash := keccak256(add(idsAndAmounts, 0x20), mload(idsAndAmounts))
        }
    }

    function _toSplitIdsAndAmountsHash(SplitBatchClaimComponent[] calldata claims) private pure returns (bytes32 idsAndAmountsHash) {
        uint256 totalIds = claims.length;
        bytes memory idsAndAmounts = new bytes(totalIds * 0x40);

        unchecked {
            for (uint256 i = 0; i < totalIds; ++i) {
                SplitBatchClaimComponent calldata claimComponent = claims[i];
                assembly ("memory-safe") {
                    let extraOffset := add(add(idsAndAmounts, 0x20), mul(i, 0x40))
                    mstore(extraOffset, calldataload(claimComponent)) // id
                    mstore(add(extraOffset, 0x20), calldataload(add(claimComponent, 0x20))) // amount
                }
            }
        }

        assembly ("memory-safe") {
            idsAndAmountsHash := keccak256(add(idsAndAmounts, 0x20), mload(idsAndAmounts))
        }
    }

    function _toBatchMessageHash(uint256 claim, bytes32 idsAndAmountsHash) private view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, BATCH_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), idsAndAmountsHash)
            messageHash := keccak256(m, 0xc0)
        }
    }

    function _toBatchClaimWithWitnessMessageHash(uint256 claim, bytes32 idsAndAmountsHash) private view returns (bytes32 messageHash, bytes32 typehash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // prepare full typestring
            let witnessTypestringPtr := add(claim, calldataload(add(claim, 0xc0)))
            let witnessTypestringLength := calldataload(witnessTypestringPtr)
            mstore(m, BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE)
            mstore(add(m, 0x20), BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO)
            mstore(add(m, 0x46), BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR)
            mstore(add(m, 0x40), BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE)
            calldatacopy(add(m, 0x66), add(0x20, witnessTypestringPtr), witnessTypestringLength)

            typehash := keccak256(m, add(0x66, witnessTypestringLength))

            mstore(m, typehash)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), idsAndAmountsHash)
            mstore(add(m, 0xc0), calldataload(add(claim, 0xa0))) // witness
            messageHash := keccak256(m, 0xe0)
        }
    }

    function _deriveIdsAndAmountsHash(uint256 claim, uint256 additionalOffset) private pure returns (bytes32 idsAndAmountsHash) {
        assembly ("memory-safe") {
            let claimWithAdditionalOffset := add(claim, additionalOffset)

            mstore(0, calldataload(add(claimWithAdditionalOffset, 0xc0))) // id
            mstore(0x20, calldataload(add(claimWithAdditionalOffset, 0xe0))) // amount

            idsAndAmountsHash := keccak256(0, 0x40)
        }
    }

    function _toMultichainClaimMessageHash(uint256 claim, uint256 additionalOffset, bytes32 allocationTypehash, bytes32 multichainCompactTypehash, bytes32 idsAndAmountsHash)
        private
        view
        returns (bytes32 messageHash)
    {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(add(m, 0x60), idsAndAmountsHash)
            mstore(m, allocationTypehash)
            mstore(add(m, 0x20), caller()) // arbiter
            mstore(add(m, 0x40), chainid())

            let hasWitness := iszero(eq(allocationTypehash, SEGMENT_TYPEHASH))
            if hasWitness { mstore(add(m, 0x80), calldataload(add(claim, 0xa0))) } // witness

            mstore(m, keccak256(m, add(0x80, mul(0x20, hasWitness)))) // first allocation hash

            // subsequent allocation hashes
            let additionalChainsPtr := add(claim, calldataload(add(add(claim, additionalOffset), 0xa0)))
            let additionalChainsLength := shl(5, calldataload(additionalChainsPtr))
            calldatacopy(add(m, 0x20), add(0x20, additionalChainsPtr), additionalChainsLength)

            // hash of allocation hashes
            mstore(add(m, 0x80), keccak256(m, add(0x20, additionalChainsLength)))

            mstore(m, multichainCompactTypehash)
            calldatacopy(add(m, 0x20), add(claim, 0x40), 0x60) // sponsor, nonce, expires

            messageHash := keccak256(m, 0xa0)
        }
    }
}

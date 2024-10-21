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
    Allocation,
    ALLOCATION_TYPEHASH,
    ALLOCATION_TYPESTRING_FRAGMENT_ONE,
    ALLOCATION_TYPESTRING_FRAGMENT_TWO,
    ALLOCATION_TYPESTRING_FRAGMENT_THREE,
    MultichainCompact,
    MULTICHAIN_COMPACT_TYPEHASH,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
    PERMIT2_WITNESS_FRAGMENT_HASH
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
    using FunctionCastLib for function(ClaimWithWitness calldata, uint256) internal view returns (bytes32);
    using FunctionCastLib for function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32);
    using FunctionCastLib for function(QualifiedClaimWithWitness calldata) internal view returns (bytes32, bytes32);
    using FunctionCastLib for function(SplitBatchClaim calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32);
    using FunctionCastLib for function(SplitBatchClaimWithWitness calldata, SplitBatchClaimComponent[] calldata) internal view returns (bytes32);
    using FunctionCastLib for function(BatchClaim calldata, BatchClaimComponent[] calldata) internal view returns (bytes32);
    using FunctionCastLib for function(BatchClaimWithWitness calldata, BatchClaimComponent[] calldata) internal view returns (bytes32);
    using FunctionCastLib for function(BasicClaim calldata) internal view returns (bytes32);
    using FunctionCastLib for function(ClaimWithWitness calldata, uint256) internal view returns (bytes32);

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

    function toClaimMessageHash(BasicClaim calldata claim) internal view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0xa0) // sponsor, nonce, expires, id, amount
            messageHash := keccak256(m, 0xe0)
        }
    }

    function toMessageHash(BasicClaim calldata claim) internal view returns (bytes32 messageHash) {
        return toClaimMessageHash(claim);
    }

    function toQualifiedClaimMessageHash(QualifiedClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), calldataload(add(claim, 0xe0))) // id
            mstore(add(m, 0xc0), calldataload(add(claim, 0x100))) // amount
            messageHash := keccak256(m, 0xe0)
        }

        qualificationMessageHash = toQualificationMessageHash(claim, messageHash, 0);
    }

    function toMessageHash(QualifiedClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        return toQualifiedClaimMessageHash(claim);
    }

    function toMessageHash(QualifiedSplitClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        return toQualifiedClaimMessageHash.usingQualifiedSplitClaim()(claim);
    }

    function toQualificationMessageHash(QualifiedClaim calldata claim, bytes32 messageHash, uint256 witnessOffset) internal pure returns (bytes32 qualificationMessageHash) {
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

    function toMessageHash(ClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        messageHash = toMessageHashWithWitness(claim, 0);
    }

    function toMessageHashWithWitness(ClaimWithWitness calldata claim, uint256 qualificationOffset) internal view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // prepare full typestring
            let witnessTypestringPtr := add(claim, calldataload(add(claim, 0xc0)))
            let witnessTypestringLength := calldataload(witnessTypestringPtr)
            mstore(m, COMPACT_TYPESTRING_FRAGMENT_ONE)
            mstore(add(m, 0x20), COMPACT_TYPESTRING_FRAGMENT_TWO)
            mstore(add(m, 0x40), COMPACT_TYPESTRING_FRAGMENT_THREE)
            calldatacopy(add(m, 0x60), add(0x20, witnessTypestringPtr), witnessTypestringLength)

            mstore(m, keccak256(m, add(0x60, witnessTypestringLength))) // typehash
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), calldataload(add(claim, add(0xe0, qualificationOffset)))) // id
            mstore(add(m, 0xc0), calldataload(add(claim, add(0x100, qualificationOffset)))) // amount
            mstore(add(m, 0xe0), calldataload(add(claim, 0xa0))) // witness
            messageHash := keccak256(m, 0x100)
        }
    }

    function toQualifiedClaimWithWitnessMessageHash(QualifiedClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = toMessageHashWithWitness.usingQualifiedClaimWithWitness()(claim, 0x40);
        qualificationMessageHash = toQualificationMessageHash.usingQualifiedClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(QualifiedClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        return toQualifiedClaimWithWitnessMessageHash(claim);
    }

    function toMessageHash(QualifiedSplitClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        return toQualifiedClaimWithWitnessMessageHash.usingQualifiedSplitClaimWithWitness()(claim);
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

    function _deriveBatchCompactMessageHash(BatchTransfer calldata transfer, bytes32 idsAndAmountsHash) internal view returns (bytes32 messageHash) {
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

    function toIdsAndAmountsHash(BatchClaimComponent[] calldata claims) internal pure returns (bytes32 idsAndAmountsHash) {
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

    function toSplitIdsAndAmountsHash(SplitBatchClaimComponent[] calldata claims) internal pure returns (bytes32 idsAndAmountsHash) {
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

    function toMessageHash(BatchClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _deriveBatchMessageHash(claim, claim.claims);
    }

    function _deriveBatchMessageHash(BatchClaim calldata claim, BatchClaimComponent[] calldata claims) internal view returns (bytes32 messageHash) {
        bytes32 idsAndAmountsHash = toIdsAndAmountsHash(claims);

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, BATCH_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), idsAndAmountsHash)
            messageHash := keccak256(m, 0xc0)
        }
    }

    function toMessageHash(SplitBatchClaim calldata claim) internal view returns (bytes32 messageHash) {
        return _toSplitBatchMessageHash(claim, claim.claims);
    }

    function toMessageHash(SplitBatchClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        return _toSplitBatchMessageHashWithWitness(claim, claim.claims);
    }

    function _toSplitBatchMessageHash(SplitBatchClaim calldata claim, SplitBatchClaimComponent[] calldata claims) internal view returns (bytes32 messageHash) {
        bytes32 idsAndAmountsHash = toSplitIdsAndAmountsHash(claims);

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, BATCH_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), idsAndAmountsHash)
            messageHash := keccak256(m, 0xc0)
        }
    }

    function usingSplitBatchClaimWithWitness(function(BatchClaimWithWitness calldata, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function( SplitBatchClaimWithWitness calldata, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function _toBatchClaimWithWitnessMessageHash(BatchClaimWithWitness calldata claim, bytes32 idsAndAmountsHash) internal view returns (bytes32 messageHash) {
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
            mstore(m, keccak256(m, add(0x66, witnessTypestringLength))) // typehash
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), idsAndAmountsHash)
            mstore(add(m, 0xc0), calldataload(add(claim, 0xa0))) // witness
            messageHash := keccak256(m, 0xe0)
        }
    }

    function _toBatchMessageHashWithWitness(BatchClaimWithWitness calldata claim, BatchClaimComponent[] calldata claims) internal view returns (bytes32 messageHash) {
        return _toBatchClaimWithWitnessMessageHash(claim, toIdsAndAmountsHash(claims));
    }

    function _toSplitBatchMessageHashWithWitness(SplitBatchClaimWithWitness calldata claim, SplitBatchClaimComponent[] calldata claims) internal view returns (bytes32 messageHash) {
        return usingSplitBatchClaimWithWitness(_toBatchClaimWithWitnessMessageHash)(claim, toSplitIdsAndAmountsHash(claims));
    }

    function toMessageHash(QualifiedBatchClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _deriveBatchMessageHash.usingQualifiedBatchClaim()(claim, claim.claims);

        qualificationMessageHash = toQualificationMessageHash.usingQualifiedBatchClaim()(claim, messageHash, 0);
    }

    function toMessageHash(BatchClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        return _toBatchMessageHashWithWitness(claim, claim.claims);
    }

    function toMessageHash(QualifiedBatchClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toBatchMessageHashWithWitness.usingQualifiedBatchClaimWithWitness()(claim, claim.claims);

        qualificationMessageHash = toQualificationMessageHash.usingQualifiedBatchClaimWithWitness()(claim, messageHash, 0x40);
    }

    function toMessageHash(SplitClaim calldata claim) internal view returns (bytes32 messageHash) {
        return toClaimMessageHash.usingSplitClaim()(claim);
    }

    function toMessageHash(SplitClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        return toMessageHashWithWitness.usingSplitClaimWithWitness()(claim, 0);
    }

    function toMessageHash(QualifiedSplitBatchClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toSplitBatchMessageHash.usingQualifiedSplitBatchClaim()(claim, claim.claims);

        qualificationMessageHash = toQualificationMessageHash.usingQualifiedSplitBatchClaim()(claim, messageHash, 0);
    }

    function toMessageHash(QualifiedSplitBatchClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = _toSplitBatchMessageHashWithWitness.usingQualifiedSplitBatchClaimWithWitness()(claim, claim.claims);

        qualificationMessageHash = toQualificationMessageHash.usingQualifiedSplitBatchClaimWithWitness()(claim, messageHash, 0x40);
    }

    function deriveIdsAndAmountsHash(MultichainClaim calldata claim, uint256 additionalOffset) internal pure returns (bytes32 idsAndAmountsHash) {
        assembly ("memory-safe") {
            let claimWithAdditionalOffset := add(claim, additionalOffset)

            mstore(0, calldataload(add(claimWithAdditionalOffset, 0xc0))) // id
            mstore(0x20, calldataload(add(claimWithAdditionalOffset, 0xe0))) // amount

            idsAndAmountsHash := keccak256(0, 0x40)
        }
    }

    function toMultichainClaimMessageHash(MultichainClaim calldata claim, uint256 additionalOffset, bytes32 allocationTypehash, bytes32 multichainCompactTypehash, bytes32 idsAndAmountsHash)
        internal
        view
        returns (bytes32 messageHash)
    {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(add(m, 0x60), idsAndAmountsHash)
            mstore(m, allocationTypehash)
            mstore(add(m, 0x20), caller()) // arbiter
            mstore(add(m, 0x40), chainid())

            let hasWitness := iszero(eq(allocationTypehash, ALLOCATION_TYPEHASH))
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

    function toMessageHash(MultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        messageHash = toMultichainClaimMessageHash(claim, 0, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, deriveIdsAndAmountsHash(claim, 0));
    }

    function toMessageHash(BatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        messageHash = usingBatchMultichainClaim(toMultichainClaimMessageHash)(claim, 0, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = usingQualifiedBatchMultichainClaim(toMultichainClaimMessageHash)(claim, 0x40, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, toIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = usingQualifiedBatchMultichainClaim(toQualificationMessageHash)(claim, messageHash, 0);
    }

    function toMessageHash(BatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingBatchMultichainClaimWithWitness(getMultichainTypehashes)(claim);
        messageHash = usingBatchMultichainClaimWithWitness(toMultichainClaimMessageHash)(claim, 0x40, allocationTypehash, multichainCompactTypehash, toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingQualifiedBatchMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash = usingQualifiedBatchMultichainClaimWithWitness(toMultichainClaimMessageHash)(claim, 0x80, allocationTypehash, multichainCompactTypehash, toIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = usingQualifiedBatchMultichainClaimWithWitness(toQualificationMessageHash)(claim, messageHash, 0x40);
    }

    function toMessageHash(SplitBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        messageHash = usingSplitBatchMultichainClaim(toMultichainClaimMessageHash)(claim, 0, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, toSplitIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedSplitBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = usingQualifiedSplitBatchMultichainClaim(toMultichainClaimMessageHash)(claim, 0x40, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, toSplitIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = usingQualifiedSplitBatchMultichainClaim(toQualificationMessageHash)(claim, messageHash, 0);
    }

    function toMessageHash(SplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingSplitBatchMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash = usingSplitBatchMultichainClaimWithWitness(toMultichainClaimMessageHash)(claim, 0x40, allocationTypehash, multichainCompactTypehash, toSplitIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(QualifiedSplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingQualifiedSplitBatchMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash =
            usingQualifiedSplitBatchMultichainClaimWithWitness(toMultichainClaimMessageHash)(claim, 0x80, allocationTypehash, multichainCompactTypehash, toSplitIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = usingQualifiedSplitBatchMultichainClaimWithWitness(toQualificationMessageHash)(claim, messageHash, 0x40);
    }

    function usingQualifiedMultichainClaim(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaim(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaim(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaim(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaim(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaim(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaim(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaimWithWitness(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaim(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaim(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaim(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaim(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaim(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaim(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaim(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaim(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaim(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaim(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaimWithWitness(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaim(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaimWithWitness(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaim(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitBatchMultichainClaimWithWitness(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaim(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaim(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaim(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaim(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaim(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function toMessageHash(SplitMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        messageHash = usingSplitMultichainClaim(toMultichainClaimMessageHash)(claim, 0, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, usingSplitMultichainClaim(deriveIdsAndAmountsHash)(claim, 0));
    }

    function usingExogenousMultichainClaimWithWitness(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaimWithWitness(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaimWithWitness(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaimWithWitness(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaimWithWitness(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaimWithWitness(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaim(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaim(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitBatchMultichainClaim(function (ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitBatchMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaim(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaimWithWitness(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaimWithWitness(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaimWithWitness(function (QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaimWithWitness(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (MultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaimWithWitness(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaimWithWitness(function (MultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaimWithWitness calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (MultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingBatchMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (BatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaimWithWitness(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaimWithWitness calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaim(function (MultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function toMessageHash(MultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = getMultichainTypehashes(claim);
        messageHash = usingMultichainClaimWithWitness(toMultichainClaimMessageHash)(
            claim, 0x40, allocationTypehash, multichainCompactTypehash, usingMultichainClaimWithWitness(deriveIdsAndAmountsHash)(claim, 0x40)
        );
    }

    function toMessageHash(ExogenousMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingExogenousMultichainClaimWithWitness(getMultichainTypehashes)(claim);
        messageHash = usingExogenousMultichainClaimWithWitness(toExogenousMultichainClaimMessageHash)(
            claim, 0x40, allocationTypehash, multichainCompactTypehash, usingExogenousMultichainClaimWithWitness(deriveIdsAndAmountsHash)(claim, 0x80)
        );
    }

    function toMessageHash(ExogenousSplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingExogenousSplitMultichainClaimWithWitness(getMultichainTypehashes)(claim);
        messageHash = usingExogenousSplitMultichainClaimWithWitness(toExogenousMultichainClaimMessageHash)(
            claim, 0x40, allocationTypehash, multichainCompactTypehash, usingExogenousSplitMultichainClaimWithWitness(deriveIdsAndAmountsHash)(claim, 0x80)
        );
    }

    function toMessageHash(QualifiedMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingQualifiedMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash = usingQualifiedMultichainClaimWithWitness(toMultichainClaimMessageHash)(
            claim, 0x80, allocationTypehash, multichainCompactTypehash, usingQualifiedMultichainClaimWithWitness(deriveIdsAndAmountsHash)(claim, 0x80)
        );
        qualificationMessageHash = usingQualifiedMultichainClaimWithWitness(toQualificationMessageHash)(claim, messageHash, 0x40);
    }

    function toMessageHash(QualifiedSplitMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = usingQualifiedSplitMultichainClaim(toMultichainClaimMessageHash)(
            claim, 0x40, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, usingQualifiedSplitMultichainClaim(deriveIdsAndAmountsHash)(claim, 0x40)
        );
        qualificationMessageHash = usingQualifiedSplitMultichainClaim(toQualificationMessageHash)(claim, messageHash, 0);
    }

    function toMessageHash(SplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingSplitMultichainClaimWithWitness(getMultichainTypehashes)(claim);
        messageHash = usingSplitMultichainClaimWithWitness(toMultichainClaimMessageHash)(
            claim, 0x40, allocationTypehash, multichainCompactTypehash, usingSplitMultichainClaimWithWitness(deriveIdsAndAmountsHash)(claim, 0x40)
        );
    }

    function toMessageHash(QualifiedSplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingQualifiedSplitMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash = usingQualifiedSplitMultichainClaimWithWitness(toMultichainClaimMessageHash)(
            claim, 0x80, allocationTypehash, multichainCompactTypehash, usingQualifiedSplitMultichainClaimWithWitness(deriveIdsAndAmountsHash)(claim, 0x80)
        );
        qualificationMessageHash = usingQualifiedSplitMultichainClaimWithWitness(toQualificationMessageHash)(claim, messageHash, 0x40);
    }

    function toMessageHash(QualifiedMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = usingQualifiedMultichainClaim(toMultichainClaimMessageHash)(
            claim, 0x40, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, usingQualifiedMultichainClaim(deriveIdsAndAmountsHash)(claim, 0x40)
        );
        qualificationMessageHash = usingQualifiedMultichainClaim(toQualificationMessageHash)(claim, messageHash, 0);
    }

    function usingExogenousQualifiedMultichainClaim(function(ExogenousMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaim calldata, uint256, bytes32, bytes32, bytes32) internal view returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaim(function(ExogenousMultichainClaim calldata, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaim calldata, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaim(function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaimWithWitness(function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaimWithWitness(function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedSplitMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaimWithWitness(function(QualifiedClaim calldata, bytes32, uint256) internal pure returns (bytes32) fnIn)
        internal
        pure
        returns (function(ExogenousQualifiedBatchMultichainClaimWithWitness calldata, bytes32, uint256) internal pure returns (bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousBatchMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedBatchMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedBatchMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingQualifiedSplitBatchMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (QualifiedSplitBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingSplitBatchMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (SplitBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function usingExogenousSplitBatchMultichainClaimWithWitness(function (MultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnIn)
        internal
        pure
        returns (function (ExogenousSplitBatchMultichainClaimWithWitness calldata) internal pure returns (bytes32, bytes32) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    function getMultichainTypehashes(MultichainClaimWithWitness calldata claim) internal pure returns (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            let allocationTypestringOffset := add(m, 0x59)

            // prepare full typestring
            let witnessTypestringPtr := add(claim, calldataload(add(claim, 0xc0)))
            let witnessTypestringLength := calldataload(witnessTypestringPtr)

            mstore(m, MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE)
            mstore(add(m, 0x39), MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE)
            mstore(add(m, 0x20), MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO)

            mstore(allocationTypestringOffset, ALLOCATION_TYPESTRING_FRAGMENT_ONE)
            mstore(add(allocationTypestringOffset, 0x26), ALLOCATION_TYPESTRING_FRAGMENT_THREE)
            mstore(add(allocationTypestringOffset, 0x20), ALLOCATION_TYPESTRING_FRAGMENT_TWO)
            calldatacopy(add(allocationTypestringOffset, 0x46), add(0x20, witnessTypestringPtr), witnessTypestringLength)
            allocationTypehash := keccak256(allocationTypestringOffset, add(0x46, witnessTypestringLength))
            multichainCompactTypehash := keccak256(m, add(0x9f, witnessTypestringLength))
        }
    }

    function toExogenousMultichainClaimMessageHash(
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

            let hasWitness := iszero(eq(allocationTypehash, ALLOCATION_TYPEHASH))
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
        return toExogenousMultichainClaimMessageHash(claim, 0, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, usingExogenousMultichainClaim(deriveIdsAndAmountsHash)(claim, 0x40));
    }

    function toMessageHash(ExogenousSplitMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        return usingExogenousSplitMultichainClaim(toExogenousMultichainClaimMessageHash)(
            claim, 0, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, usingExogenousSplitMultichainClaim(deriveIdsAndAmountsHash)(claim, 0x40)
        );
    }

    function toMessageHash(ExogenousBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        return usingExogenousBatchMultichainClaim(toExogenousMultichainClaimMessageHash)(claim, 0, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(ExogenousSplitBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash) {
        return usingExogenousSplitBatchMultichainClaim(toExogenousMultichainClaimMessageHash)(claim, 0, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, toSplitIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(ExogenousQualifiedMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = usingExogenousQualifiedMultichainClaim(toExogenousMultichainClaimMessageHash)(
            claim, 0x40, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, usingExogenousQualifiedMultichainClaim(deriveIdsAndAmountsHash)(claim, 0x80)
        );
        qualificationMessageHash = usingExogenousQualifiedMultichainClaim(toQualificationMessageHash)(claim, messageHash, 0);
    }

    function toMessageHash(ExogenousQualifiedMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingExogenousQualifiedMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash = usingExogenousQualifiedMultichainClaimWithWitness(toExogenousMultichainClaimMessageHash)(
            claim, 0x80, allocationTypehash, multichainCompactTypehash, usingExogenousQualifiedMultichainClaimWithWitness(deriveIdsAndAmountsHash)(claim, 0xc0)
        );
        qualificationMessageHash = usingExogenousQualifiedMultichainClaimWithWitness(toQualificationMessageHash)(claim, messageHash, 0x40);
    }

    function toMessageHash(ExogenousQualifiedSplitMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = usingExogenousQualifiedSplitMultichainClaim(toExogenousMultichainClaimMessageHash)(
            claim, 0x40, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, usingExogenousQualifiedSplitMultichainClaim(deriveIdsAndAmountsHash)(claim, 0x80)
        );
        qualificationMessageHash = usingExogenousQualifiedSplitMultichainClaim(toQualificationMessageHash)(claim, messageHash, 0);
    }

    function toMessageHash(ExogenousQualifiedSplitMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingExogenousQualifiedSplitMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash = usingExogenousQualifiedSplitMultichainClaimWithWitness(toExogenousMultichainClaimMessageHash)(
            claim, 0x80, allocationTypehash, multichainCompactTypehash, usingExogenousQualifiedSplitMultichainClaimWithWitness(deriveIdsAndAmountsHash)(claim, 0xc0)
        );
        qualificationMessageHash = usingExogenousQualifiedSplitMultichainClaimWithWitness(toQualificationMessageHash)(claim, messageHash, 0x40);
    }

    function toMessageHash(ExogenousQualifiedBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash =
            usingExogenousQualifiedBatchMultichainClaim(toExogenousMultichainClaimMessageHash)(claim, 0x40, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, toIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = usingExogenousQualifiedBatchMultichainClaim(toQualificationMessageHash)(claim, messageHash, 0);
    }

    function toMessageHash(ExogenousBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingExogenousBatchMultichainClaimWithWitness(getMultichainTypehashes)(claim);
        messageHash =
            usingExogenousBatchMultichainClaimWithWitness(toExogenousMultichainClaimMessageHash)(claim, 0x40, allocationTypehash, multichainCompactTypehash, toIdsAndAmountsHash(claim.claims));
    }

    function toMessageHash(ExogenousQualifiedBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingExogenousQualifiedBatchMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash =
            usingExogenousQualifiedBatchMultichainClaimWithWitness(toExogenousMultichainClaimMessageHash)(claim, 0x80, allocationTypehash, multichainCompactTypehash, toIdsAndAmountsHash(claim.claims));
        qualificationMessageHash = usingExogenousQualifiedBatchMultichainClaimWithWitness(toQualificationMessageHash)(claim, messageHash, 0x40);
    }

    function toMessageHash(ExogenousQualifiedSplitBatchMultichainClaim calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        messageHash = usingExogenousQualifiedSplitBatchMultichainClaim(toExogenousMultichainClaimMessageHash)(
            claim, 0x40, ALLOCATION_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, toSplitIdsAndAmountsHash(claim.claims)
        );
        qualificationMessageHash = usingExogenousQualifiedSplitBatchMultichainClaim(toQualificationMessageHash)(claim, messageHash, 0);
    }

    function toMessageHash(ExogenousSplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingExogenousSplitBatchMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash = usingExogenousSplitBatchMultichainClaimWithWitness(toExogenousMultichainClaimMessageHash)(
            claim, 0x40, allocationTypehash, multichainCompactTypehash, toSplitIdsAndAmountsHash(claim.claims)
        );
    }

    function toMessageHash(ExogenousQualifiedSplitBatchMultichainClaimWithWitness calldata claim) internal view returns (bytes32 messageHash, bytes32 qualificationMessageHash) {
        (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) = usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(getMultichainTypehashes)(claim);

        messageHash = usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(toExogenousMultichainClaimMessageHash)(
            claim, 0x80, allocationTypehash, multichainCompactTypehash, toSplitIdsAndAmountsHash(claim.claims)
        );
        qualificationMessageHash = usingExogenousQualifiedSplitBatchMultichainClaimWithWitness(toQualificationMessageHash)(claim, messageHash, 0x40);
    }

    function toPermit2WitnessHash(address allocator, address depositor, ResetPeriod resetPeriod, Scope scope, address recipient) internal pure returns (bytes32 witnessHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, PERMIT2_WITNESS_FRAGMENT_HASH)
            mstore(add(m, 0x20), depositor)
            mstore(add(m, 0x40), allocator)
            mstore(add(m, 0x60), resetPeriod)
            mstore(add(m, 0x80), scope)
            mstore(add(m, 0xa0), recipient)
            witnessHash := keccak256(m, 0xc0)
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
}

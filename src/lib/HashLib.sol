// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {
    COMPACT_TYPEHASH,
    COMPACT_TYPESTRING_FRAGMENT_ONE,
    COMPACT_TYPESTRING_FRAGMENT_TWO,
    COMPACT_TYPESTRING_FRAGMENT_THREE,
    BATCH_COMPACT_TYPEHASH,
    BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE,
    BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO,
    BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE,
    BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR,
    SEGMENT_TYPEHASH,
    MULTICHAIN_COMPACT_TYPEHASH,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FOUR,
    MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_FIVE,
    TOKEN_PERMISSIONS_TYPESTRING_FRAGMENT_ONE,
    TOKEN_PERMISSIONS_TYPESTRING_FRAGMENT_TWO,
    PERMIT2_DEPOSIT_WITNESS_FRAGMENT_HASH
} from "../types/EIP712Types.sol";

import { BasicTransfer, SplitTransfer } from "../types/Claims.sol";

import { BatchTransfer, SplitBatchTransfer } from "../types/BatchClaims.sol";

import { TransferComponent, SplitComponent, SplitByIdComponent, BatchClaimComponent, SplitBatchClaimComponent } from "../types/Components.sol";

import { EfficiencyLib } from "./EfficiencyLib.sol";
import { FunctionCastLib } from "./FunctionCastLib.sol";

/**
 * @title HashLib
 * @notice Libray contract implementing logic for deriving hashes as part of processing
 * claims, allocated transfers, and withdrawals, as well as for deriving typehashes and
 * validating signatures more generally.
 */
library HashLib {
    using EfficiencyLib for bool;
    using EfficiencyLib for uint256;
    using FunctionCastLib for function (BatchTransfer calldata, uint256) internal view returns (bytes32);
    using HashLib for uint256;
    using HashLib for BatchTransfer;

    function toBasicTransferMessageHash(BasicTransfer calldata transfer) internal view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            mstore(add(m, 0x40), caller()) // sponsor: msg.sender
            calldatacopy(add(m, 0x60), add(transfer, 0x20), 0x80) // nonce, expires, id, amount
            messageHash := keccak256(m, 0xe0)
        }
    }

    function toSplitTransferMessageHash(SplitTransfer calldata transfer) internal view returns (bytes32 messageHash) {
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

    function toBatchTransferMessageHash(BatchTransfer calldata transfer) internal view returns (bytes32) {
        TransferComponent[] calldata transfers = transfer.transfers;
        uint256 idsAndAmountsHash;
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            let totalTransferData := mul(transfers.length, 0x40)
            calldatacopy(m, transfers.offset, totalTransferData)
            idsAndAmountsHash := keccak256(m, totalTransferData)
        }

        return transfer.deriveBatchCompactMessageHash(idsAndAmountsHash);
    }

    function toSplitBatchTransferMessageHash(SplitBatchTransfer calldata transfer) internal view returns (bytes32) {
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

        uint256 idsAndAmountsHash;
        assembly ("memory-safe") {
            if errorBuffer {
                // Revert Panic(0x11) (arithmetic overflow)
                mstore(0, 0x4e487b71)
                mstore(0x20, 0x11)
                revert(0x1c, 0x24)
            }
            idsAndAmountsHash := keccak256(add(idsAndAmounts, 0x20), mload(idsAndAmounts))
        }

        return deriveBatchCompactMessageHash.usingSplitBatchTransfer()(transfer, idsAndAmountsHash);
    }

    function toClaimMessageHash(uint256 claim, uint256 additionalOffset) internal view returns (bytes32 messageHash) {
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

    function toMessageHashWithWitness(uint256 claim, uint256 qualificationOffset) internal view returns (bytes32 messageHash, bytes32 typehash) {
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

    function deriveBatchCompactMessageHash(BatchTransfer calldata transfer, uint256 idsAndAmountsHash) internal view returns (bytes32 messageHash) {
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

    function toBatchMessageHash(uint256 claim, uint256 idsAndAmountsHash) internal view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, BATCH_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), idsAndAmountsHash)
            messageHash := keccak256(m, 0xc0)
        }
    }

    function toBatchClaimWithWitnessMessageHash(uint256 claim, uint256 idsAndAmountsHash) internal view returns (bytes32 messageHash, bytes32 typehash) {
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

    function toSingleIdAndAmountHash(uint256 claim, uint256 additionalOffset) internal pure returns (uint256 idsAndAmountsHash) {
        assembly ("memory-safe") {
            let claimWithAdditionalOffset := add(claim, additionalOffset)

            mstore(0, calldataload(add(claimWithAdditionalOffset, 0xc0))) // id
            mstore(0x20, calldataload(add(claimWithAdditionalOffset, 0xe0))) // amount

            idsAndAmountsHash := keccak256(0, 0x40)
        }
    }

    function toSimpleMultichainClaimMessageHash(uint256 claim, uint256 idsAndAmountsHash) internal view returns (bytes32 messageHash) {
        return claim.toMultichainClaimMessageHash(uint256(0).asStubborn(), SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, idsAndAmountsHash);
    }

    function toQualifiedMultichainClaimMessageHash(uint256 claim, uint256 idsAndAmountsHash) internal view returns (bytes32 messageHash) {
        return claim.toMultichainClaimMessageHash(uint256(0x40).asStubborn(), SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, idsAndAmountsHash);
    }

    function toMultichainClaimMessageHash(uint256 claim, uint256 additionalOffset, bytes32 allocationTypehash, bytes32 multichainCompactTypehash, uint256 idsAndAmountsHash)
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

    function toSimpleExogenousMultichainClaimMessageHash(uint256 claim, uint256 idsAndAmountsHash) internal view returns (bytes32 messageHash) {
        return claim.toExogenousMultichainClaimMessageHash(uint256(0).asStubborn(), SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, idsAndAmountsHash);
    }

    function toExogenousQualifiedMultichainClaimMessageHash(uint256 claim, uint256 idsAndAmountsHash) internal view returns (bytes32 messageHash) {
        return claim.toExogenousMultichainClaimMessageHash(uint256(0x40).asStubborn(), SEGMENT_TYPEHASH, MULTICHAIN_COMPACT_TYPEHASH, idsAndAmountsHash);
    }

    function toExogenousMultichainClaimMessageHash(uint256 claim, uint256 additionalOffset, bytes32 allocationTypehash, bytes32 multichainCompactTypehash, uint256 idsAndAmountsHash)
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

    function toIdsAndAmountsHash(BatchClaimComponent[] calldata claims) internal pure returns (uint256 idsAndAmountsHash) {
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

    function toSplitIdsAndAmountsHash(SplitBatchClaimComponent[] calldata claims) internal pure returns (uint256 idsAndAmountsHash) {
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

    function toMultichainTypehashes(uint256 claim) internal pure returns (bytes32 allocationTypehash, bytes32 multichainCompactTypehash) {
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

    function toQualificationMessageHash(uint256 claim, bytes32 messageHash, uint256 witnessOffset) internal pure returns (bytes32 qualificationMessageHash) {
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

    /**
     * @notice Internal pure function for retrieving EIP-712 typehashes where no witness data is
     * provided, returning the corresponding typehash based on the index provided. The available
     * typehashes are:
     *  - 0: COMPACT_TYPEHASH
     *  - 1: BATCH_COMPACT_TYPEHASH
     *  - 2: MULTICHAIN_COMPACT_TYPEHASH
     * @param i         The index of the EIP-712 typehash to retrieve.
     * @return typehash The corresponding EIP-712 typehash.
     */
    function typehashes(uint256 i) internal pure returns (bytes32 typehash) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(0, COMPACT_TYPEHASH)
            mstore(0x20, BATCH_COMPACT_TYPEHASH)
            mstore(0x40, MULTICHAIN_COMPACT_TYPEHASH)
            typehash := mload(shl(5, i))
            mstore(0x40, m)
        }
    }
}

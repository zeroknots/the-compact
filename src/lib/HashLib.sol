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
    Claim,
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

import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

// TODO: make calldata versions of these where useful
library HashLib {
    error Debug(bytes data);

    /// @dev `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`.
    bytes32 internal constant _DOMAIN_TYPEHASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev `keccak256(bytes("The Compact"))`.
    bytes32 internal constant _NAME_HASH =
        0x5e6f7b4e1ac3d625bac418bc955510b3e054cb6cc23cc27885107f080180b292;

    /// @dev `keccak256("1")`.
    bytes32 internal constant _VERSION_HASH =
        0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    function toMessageHash(BasicTransfer calldata transfer)
        internal
        view
        returns (bytes32 messageHash)
    {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            mstore(add(m, 0x40), caller()) // sponsor: msg.sender
            calldatacopy(add(m, 0x60), add(transfer, 0x20), 0x80) // nonce, expires, id, amount
            messageHash := keccak256(m, 0xe0)
        }
    }

    function toMessageHash(SplitTransfer calldata transfer)
        internal
        view
        returns (bytes32 messageHash)
    {
        // TODO: optimize this part (but remember to watch out for an amount overflow)
        uint256 amount = 0;
        for (uint256 i = 0; i < transfer.recipients.length; ++i) {
            amount += transfer.recipients[i].amount;
        }

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            mstore(add(m, 0x40), caller()) // sponsor: msg.sender
            calldatacopy(add(m, 0x60), add(transfer, 0x20), 0x60) // nonce, expires, id
            mstore(add(m, 0xc0), amount)
            messageHash := keccak256(m, 0xe0)
        }
    }

    function toMessageHash(Claim calldata claim) internal view returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0xa0) // sponsor, nonce, expires, id, amount
            messageHash := keccak256(m, 0xe0)
        }
    }

    function toMessageHash(QualifiedClaim calldata claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
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

    function usingQualifiedSplitClaim(
        function (
        QualifiedClaim calldata,
        bytes32,
        uint256
        ) internal pure returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(
            QualifiedSplitClaim calldata,
            bytes32,
            uint256
            ) internal pure returns (bytes32) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function toQualificationMessageHash(
        QualifiedClaim calldata claim,
        bytes32 messageHash,
        uint256 witnessOffset
    ) internal pure returns (bytes32 qualificationMessageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            let qualificationPayloadPtr :=
                add(claim, calldataload(add(claim, add(0xc0, witnessOffset))))
            let qualificationPayloadLength := calldataload(qualificationPayloadPtr)

            mstore(m, calldataload(add(claim, add(0xa0, witnessOffset)))) // qualificationTypehash
            mstore(add(m, 0x20), messageHash)
            calldatacopy(
                add(m, 0x40), add(0x20, qualificationPayloadPtr), qualificationPayloadLength
            )

            qualificationMessageHash := keccak256(m, add(0x40, qualificationPayloadLength))
        }
    }

    function toMessageHash(ClaimWithWitness calldata claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        messageHash = toMessageHashWithWitness(claim, 0);
    }

    function toMessageHashWithWitness(ClaimWithWitness calldata claim, uint256 qualificationOffset)
        internal
        view
        returns (bytes32 messageHash)
    {
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

    function usingQualifiedClaimWithWitness(
        function(ClaimWithWitness calldata, uint256) internal view returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedClaimWithWitness calldata, uint256) internal view returns (bytes32) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function usingQualifiedClaimWithWitness(
        function(QualifiedClaim calldata, bytes32, uint256)
        internal
        pure
        returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(QualifiedClaimWithWitness calldata, bytes32, uint256)
            internal
            pure
            returns (bytes32) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function toMessageHash(QualifiedClaimWithWitness calldata claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        messageHash = usingQualifiedClaimWithWitness(toMessageHashWithWitness)(claim, 0x40);
        qualificationMessageHash =
            usingQualifiedClaimWithWitness(toQualificationMessageHash)(claim, messageHash, 0x40);
    }

    function toMessageHash(BatchTransfer calldata transfer)
        internal
        view
        returns (bytes32 messageHash)
    {
        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](transfer.transfers.length);
        for (uint256 i = 0; i < transfer.transfers.length; ++i) {
            idsAndAmounts[i] = [transfer.transfers[i].id, transfer.transfers[i].amount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        messageHash = _deriveBatchCompactMessageHash(transfer, idsAndAmountsHash);
    }

    function _deriveBatchCompactMessageHash(
        BatchTransfer calldata transfer,
        bytes32 idsAndAmountsHash
    ) internal view returns (bytes32 messageHash) {
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

    function _usingSplitBatchTransfer(
        function(BatchTransfer calldata, bytes32) internal view returns (bytes32) fnIn
    )
        internal
        pure
        returns (
            function(SplitBatchTransfer calldata, bytes32) internal view returns (bytes32) fnOut
        )
    {
        assembly {
            fnOut := fnIn
        }
    }

    function toMessageHash(SplitBatchTransfer calldata transfer)
        internal
        view
        returns (bytes32 messageHash)
    {
        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](transfer.transfers.length);
        for (uint256 i = 0; i < transfer.transfers.length; ++i) {
            uint256 amount = 0;
            for (uint256 j = 0; j < transfer.transfers[i].portions.length; ++j) {
                amount += transfer.transfers[i].portions[j].amount;
            }
            idsAndAmounts[i] = [transfer.transfers[i].id, amount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        messageHash =
            _usingSplitBatchTransfer(_deriveBatchCompactMessageHash)(transfer, idsAndAmountsHash);
    }

    function toMessageHash(BatchClaim calldata claim) internal view returns (bytes32 messageHash) {
        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            mstore(m, BATCH_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), caller()) // arbiter: msg.sender
            calldatacopy(add(m, 0x40), add(claim, 0x40), 0x60) // sponsor, nonce, expires
            mstore(add(m, 0xa0), idsAndAmountsHash)
            messageHash := keccak256(m, 0xc0)
        }
    }

    function toMessageHash(QualifiedBatchClaim memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            let id := mload(add(claim, 0x60))
            let amount := mload(add(claim, 0x80))

            mstore(m, BATCH_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), caller()) // arbiter: msg.sender
            mstore(add(m, 0xa0), idsAndAmountsHash)
            messageHash := keccak256(m, 0xc0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(BatchClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // derive the typehash (TODO: make this more efficient especially once using calldata)
        bytes32 typehash = keccak256(
            abi.encodePacked(
                BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR,
                claim.witnessTypestring
            )
        );
        bytes32 witness = claim.witness;

        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            let id := mload(add(claim, 0x60))
            let amount := mload(add(claim, 0x80))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), caller()) // arbiter: msg.sender
            mstore(add(m, 0xa0), idsAndAmountsHash)
            mstore(add(m, 0xc0), witness)
            messageHash := keccak256(m, 0xe0)
        }
    }

    function toMessageHash(QualifiedBatchClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // derive the typehash (TODO: make this more efficient especially once using calldata)
        bytes32 typehash = keccak256(
            abi.encodePacked(
                BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR,
                claim.witnessTypestring
            )
        );
        bytes32 witness = claim.witness;

        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            let id := mload(add(claim, 0x60))
            let amount := mload(add(claim, 0x80))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), caller()) // arbiter: msg.sender
            mstore(add(m, 0xa0), idsAndAmountsHash)
            mstore(add(m, 0xc0), witness)
            messageHash := keccak256(m, 0xe0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    // TODO: all these SplitBatch can just use a function cast to leverage
    // BatchClaim.toMessageHash logic as the structs have the exact same offsets
    function toMessageHash(SplitBatchClaim memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            let id := mload(add(claim, 0x60))
            let amount := mload(add(claim, 0x80))

            mstore(m, BATCH_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), caller()) // arbiter: msg.sender
            mstore(add(m, 0xa0), idsAndAmountsHash)
            messageHash := keccak256(m, 0xc0)
        }
    }

    function toMessageHash(SplitBatchClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // derive the typehash (TODO: make this more efficient especially once using calldata)
        bytes32 typehash = keccak256(
            abi.encodePacked(
                BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR,
                claim.witnessTypestring
            )
        );
        bytes32 witness = claim.witness;

        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            let id := mload(add(claim, 0x60))
            let amount := mload(add(claim, 0x80))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), caller()) // arbiter: msg.sender
            mstore(add(m, 0xa0), idsAndAmountsHash)
            mstore(add(m, 0xc0), witness)
            messageHash := keccak256(m, 0xe0)
        }
    }

    function toMessageHash(QualifiedSplitBatchClaim memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            let id := mload(add(claim, 0x60))
            let amount := mload(add(claim, 0x80))

            mstore(m, BATCH_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), caller()) // arbiter: msg.sender
            mstore(add(m, 0xa0), idsAndAmountsHash)
            messageHash := keccak256(m, 0xc0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(QualifiedSplitBatchClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // derive the typehash (TODO: make this more efficient especially once using calldata)
        bytes32 typehash = keccak256(
            abi.encodePacked(
                BATCH_COMPACT_TYPESTRING_FRAGMENT_ONE,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_TWO,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_THREE,
                BATCH_COMPACT_TYPESTRING_FRAGMENT_FOUR,
                claim.witnessTypestring
            )
        );
        bytes32 witness = claim.witness;

        // TODO: make this more efficient especially once using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }
        bytes32 idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            let id := mload(add(claim, 0x60))
            let amount := mload(add(claim, 0x80))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), caller()) // arbiter: msg.sender
            mstore(add(m, 0xa0), idsAndAmountsHash)
            mstore(add(m, 0xc0), witness)
            messageHash := keccak256(m, 0xe0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(MultichainClaim memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // TODO: optimize this once we're using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                ALLOCATION_TYPEHASH,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts))
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, MULTICHAIN_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }
    }

    function toMessageHash(QualifiedMultichainClaim memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // TODO: optimize this once we're using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                ALLOCATION_TYPEHASH,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts))
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, MULTICHAIN_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(MultichainClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // derive the typehashes (TODO: make this more efficient especially once using calldata)
        bytes memory allocationTypestring = abi.encodePacked(
            ALLOCATION_TYPESTRING_FRAGMENT_ONE,
            ALLOCATION_TYPESTRING_FRAGMENT_TWO,
            ALLOCATION_TYPESTRING_FRAGMENT_THREE,
            claim.witnessTypestring
        );

        bytes32 allocationTypehash = keccak256(allocationTypestring);

        bytes32 typehash = keccak256(
            abi.encodePacked(
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
                allocationTypestring
            )
        );
        bytes32 witness = claim.witness;

        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                allocationTypehash,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts)),
                witness
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }
    }

    function toMessageHash(QualifiedMultichainClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // derive the typehashes (TODO: make this more efficient especially once using calldata)
        bytes memory allocationTypestring = abi.encodePacked(
            ALLOCATION_TYPESTRING_FRAGMENT_ONE,
            ALLOCATION_TYPESTRING_FRAGMENT_TWO,
            ALLOCATION_TYPESTRING_FRAGMENT_THREE,
            claim.witnessTypestring
        );

        bytes32 allocationTypehash = keccak256(allocationTypestring);

        bytes32 typehash = keccak256(
            abi.encodePacked(
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
                allocationTypestring
            )
        );
        bytes32 witness = claim.witness;

        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                allocationTypehash,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts)),
                witness
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(SplitMultichainClaim memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // TODO: optimize this once we're using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                ALLOCATION_TYPEHASH,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts))
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, MULTICHAIN_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }
    }

    function toMessageHash(QualifiedSplitMultichainClaim memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // TODO: optimize this once we're using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                ALLOCATION_TYPEHASH,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts))
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, MULTICHAIN_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(SplitMultichainClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // derive the typehashes (TODO: make this more efficient especially once using calldata)
        bytes memory allocationTypestring = abi.encodePacked(
            ALLOCATION_TYPESTRING_FRAGMENT_ONE,
            ALLOCATION_TYPESTRING_FRAGMENT_TWO,
            ALLOCATION_TYPESTRING_FRAGMENT_THREE,
            claim.witnessTypestring
        );

        bytes32 allocationTypehash = keccak256(allocationTypestring);

        bytes32 typehash = keccak256(
            abi.encodePacked(
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
                allocationTypestring
            )
        );
        bytes32 witness = claim.witness;

        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                allocationTypehash,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts)),
                witness
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }
    }

    function toMessageHash(QualifiedSplitMultichainClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // derive the typehashes (TODO: make this more efficient especially once using calldata)
        bytes memory allocationTypestring = abi.encodePacked(
            ALLOCATION_TYPESTRING_FRAGMENT_ONE,
            ALLOCATION_TYPESTRING_FRAGMENT_TWO,
            ALLOCATION_TYPESTRING_FRAGMENT_THREE,
            claim.witnessTypestring
        );

        bytes32 allocationTypehash = keccak256(allocationTypestring);

        bytes32 typehash = keccak256(
            abi.encodePacked(
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
                allocationTypestring
            )
        );
        bytes32 witness = claim.witness;

        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                allocationTypehash,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts)),
                witness
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(ExogenousMultichainClaim memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // TODO: optimize this once we're using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                ALLOCATION_TYPEHASH,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts))
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, MULTICHAIN_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }
    }

    function toMessageHash(ExogenousQualifiedMultichainClaim memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // TODO: optimize this once we're using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                ALLOCATION_TYPEHASH,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts))
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, MULTICHAIN_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(ExogenousMultichainClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // derive the typehashes (TODO: make this more efficient especially once using calldata)
        bytes memory allocationTypestring = abi.encodePacked(
            ALLOCATION_TYPESTRING_FRAGMENT_ONE,
            ALLOCATION_TYPESTRING_FRAGMENT_TWO,
            ALLOCATION_TYPESTRING_FRAGMENT_THREE,
            claim.witnessTypestring
        );

        bytes32 allocationTypehash = keccak256(allocationTypestring);

        bytes32 typehash = keccak256(
            abi.encodePacked(
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
                allocationTypestring
            )
        );
        bytes32 witness = claim.witness;

        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                allocationTypehash,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts)),
                witness
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }
    }

    function toMessageHash(ExogenousQualifiedMultichainClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // derive the typehashes (TODO: make this more efficient especially once using calldata)
        bytes memory allocationTypestring = abi.encodePacked(
            ALLOCATION_TYPESTRING_FRAGMENT_ONE,
            ALLOCATION_TYPESTRING_FRAGMENT_TWO,
            ALLOCATION_TYPESTRING_FRAGMENT_THREE,
            claim.witnessTypestring
        );

        bytes32 allocationTypehash = keccak256(allocationTypestring);

        bytes32 typehash = keccak256(
            abi.encodePacked(
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
                allocationTypestring
            )
        );
        bytes32 witness = claim.witness;

        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                allocationTypehash,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts)),
                witness
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(ExogenousSplitMultichainClaim memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // TODO: optimize this once we're using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                ALLOCATION_TYPEHASH,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts))
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, MULTICHAIN_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }
    }

    function toMessageHash(ExogenousQualifiedSplitMultichainClaim memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // TODO: optimize this once we're using calldata
        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                ALLOCATION_TYPEHASH,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts))
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, MULTICHAIN_COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toMessageHash(ExogenousSplitMultichainClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash)
    {
        // derive the typehashes (TODO: make this more efficient especially once using calldata)
        bytes memory allocationTypestring = abi.encodePacked(
            ALLOCATION_TYPESTRING_FRAGMENT_ONE,
            ALLOCATION_TYPESTRING_FRAGMENT_TWO,
            ALLOCATION_TYPESTRING_FRAGMENT_THREE,
            claim.witnessTypestring
        );

        bytes32 allocationTypehash = keccak256(allocationTypestring);

        bytes32 typehash = keccak256(
            abi.encodePacked(
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
                allocationTypestring
            )
        );
        bytes32 witness = claim.witness;

        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                allocationTypehash,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts)),
                witness
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }
    }

    function toMessageHash(ExogenousQualifiedSplitMultichainClaimWithWitness memory claim)
        internal
        view
        returns (bytes32 messageHash, bytes32 qualificationMessageHash)
    {
        // derive the typehashes (TODO: make this more efficient especially once using calldata)
        bytes memory allocationTypestring = abi.encodePacked(
            ALLOCATION_TYPESTRING_FRAGMENT_ONE,
            ALLOCATION_TYPESTRING_FRAGMENT_TWO,
            ALLOCATION_TYPESTRING_FRAGMENT_THREE,
            claim.witnessTypestring
        );

        bytes32 allocationTypehash = keccak256(allocationTypestring);

        bytes32 typehash = keccak256(
            abi.encodePacked(
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_ONE,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_TWO,
                MULTICHAIN_COMPACT_TYPESTRING_FRAGMENT_THREE,
                allocationTypestring
            )
        );
        bytes32 witness = claim.witness;

        uint256[2][] memory idsAndAmounts = new uint256[2][](claim.claims.length);
        for (uint256 i = 0; i < claim.claims.length; ++i) {
            idsAndAmounts[i] = [claim.claims[i].id, claim.claims[i].allocatedAmount];
        }

        bytes32 allocationHash = keccak256(
            abi.encodePacked(
                allocationTypehash,
                block.chainid,
                msg.sender, // arbiter
                keccak256(abi.encodePacked(idsAndAmounts)),
                witness
            )
        );

        bytes32[] memory allocationHashes = new bytes32[](claim.otherChains.length + 1);
        uint256 otherChainsIndex = 0;
        bytes32 hashToInsert;
        for (uint256 i = 0; i < allocationHashes.length; ++i) {
            if (i == claim.chainIndex) {
                hashToInsert = allocationHash;
            } else {
                hashToInsert = claim.otherChains[otherChainsIndex++];
            }
            allocationHashes[i] = hashToInsert;
        }

        bytes32 allocationsHash = keccak256(abi.encodePacked(allocationHashes));

        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            // TODO: calldatacopy this whole chunk at once as part of calldata implementation
            let sponsor := mload(claim)
            let expires := mload(add(claim, 0x20))
            let nonce := mload(add(claim, 0x40))

            mstore(m, typehash)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), allocationsHash)
            messageHash := keccak256(m, 0xa0)
        }

        // TODO: optimize once we're using calldata
        qualificationMessageHash = keccak256(
            abi.encodePacked(claim.qualificationTypehash, messageHash, claim.qualificationPayload)
        );
    }

    function toPermit2WitnessHash(
        address allocator,
        address depositor,
        ResetPeriod resetPeriod,
        Scope scope,
        address recipient
    ) internal pure returns (bytes32 witnessHash) {
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

    function toMessageHash(Compact memory compact) internal pure returns (bytes32 messageHash) {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer; memory will be left dirtied.

            let sponsor := shr(0x60, shl(0x60, mload(compact)))
            let expires := mload(add(compact, 0x20))
            let nonce := mload(add(compact, 0x40))
            let arbiter := shr(0x60, shl(0x60, mload(add(compact, 0x60))))
            let id := mload(add(compact, 0x80))
            let amount := mload(add(compact, 0xa0))

            mstore(m, COMPACT_TYPEHASH)
            mstore(add(m, 0x20), sponsor)
            mstore(add(m, 0x40), expires)
            mstore(add(m, 0x60), nonce)
            mstore(add(m, 0x80), arbiter)
            mstore(add(m, 0xa0), id)
            mstore(add(m, 0xc0), amount)
            messageHash := keccak256(m, 0xe0)
        }
    }

    // TODO: optimize if this ends up getting used
    function toMessageHash(BatchCompact memory compact)
        internal
        pure
        returns (bytes32 messageHash)
    {
        messageHash = keccak256(
            abi.encode(
                BATCH_COMPACT_TYPEHASH,
                compact.sponsor,
                compact.expires,
                compact.nonce,
                compact.arbiter,
                keccak256(abi.encodePacked(compact.idsAndAmounts))
            )
        );
    }

    // TODO: optimize if this ends up getting used
    function toMessageHash(MultichainCompact memory compact)
        internal
        pure
        returns (bytes32 messageHash)
    {
        bytes32[] memory allocationHashes = new bytes32[](compact.allocations.length);
        for (uint256 i = 0; i < compact.allocations.length; ++i) {
            Allocation memory allocation = compact.allocations[i];
            allocationHashes[i] = keccak256(
                abi.encode(
                    ALLOCATION_TYPEHASH,
                    allocation.chainId,
                    allocation.arbiter,
                    keccak256(abi.encodePacked(allocation.idsAndAmounts))
                )
            );
        }

        messageHash = keccak256(
            abi.encode(
                MULTICHAIN_COMPACT_TYPEHASH,
                compact.sponsor,
                compact.expires,
                compact.nonce,
                keccak256(abi.encodePacked(allocationHashes))
            )
        );
    }

    function toLatest(bytes32 initialDomainSeparator, uint256 initialChainId)
        external
        view
        returns (bytes32 domainSeparator)
    {
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

    function toNotarizedDomainHash(bytes32 messageHash, uint256 notarizedChainId)
        internal
        view
        returns (bytes32 domainHash)
    {
        assembly ("memory-safe") {
            let m := mload(0x40) // Grab the free memory pointer.

            // Prepare the 712 prefix.
            mstore(0, 0x1901)

            // Prepare the domain separator.
            mstore(m, _DOMAIN_TYPEHASH)
            mstore(add(m, 0x20), _NAME_HASH)
            mstore(add(m, 0x40), _VERSION_HASH)
            mstore(add(m, 0x60), notarizedChainId)
            mstore(add(m, 0x80), address())
            mstore(0x20, keccak256(m, 0xa0))

            // Prepare the message hash and compute the domain hash.
            mstore(0x40, messageHash)
            domainHash := keccak256(0x1e, 0x42)

            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    function withDomain(bytes32 messageHash, bytes32 domainSeparator)
        internal
        pure
        returns (bytes32 domainHash)
    {
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

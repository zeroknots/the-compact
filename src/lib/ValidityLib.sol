// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { IdLib } from "./IdLib.sol";
import { ConsumerLib } from "./ConsumerLib.sol";
import { HashLib } from "./HashLib.sol";
import { SignatureCheckerLib } from "solady/utils/SignatureCheckerLib.sol";

library ValidityLib {
    using IdLib for uint96;
    using IdLib for uint256;
    using ConsumerLib for uint256;
    using HashLib for bytes32;
    using SignatureCheckerLib for address;

    function later(uint256 expires) internal view {
        assembly ("memory-safe") {
            if iszero(gt(expires, timestamp())) {
                // revert Expired(expiration);
                mstore(0, 0xf80dbaea)
                mstore(0x20, expires)
                revert(0x1c, 0x24)
            }
        }
    }

    function signedBy(
        bytes32 messageHash,
        address expectedSigner,
        bytes memory signature,
        bytes32 domainSeparator
    ) internal view {
        bool hasValidSigner =
            expectedSigner.isValidSignatureNow(messageHash.withDomain(domainSeparator), signature);

        assembly ("memory-safe") {
            // NOTE: analyze whether the signature check can safely be skipped in all
            // cases where the caller is the expected signer.
            if iszero(or(hasValidSigner, eq(expectedSigner, caller()))) {
                // revert InvalidSignature();
                mstore(0, 0x8baa579f)
                revert(0x1c, 0x04)
            }
        }
    }

    function fromRegisteredAllocatorIdWithConsumed(uint96 allocatorId, uint256 nonce)
        internal
        returns (address allocator)
    {
        allocator = allocatorId.toRegisteredAllocator();
        nonce.consumeNonce(allocator);
    }

    function toRegisteredAllocatorWithConsumed(uint256 id, uint256 nonce)
        internal
        returns (address allocator)
    {
        allocator = id.toAllocator();
        nonce.consumeNonce(allocator);
    }

    function hasConsumed(address allocator, uint256 nonce) internal view returns (bool) {
        return nonce.isConsumedBy(allocator);
    }

    function excludingNative(address token) internal pure returns (address) {
        assembly {
            if iszero(shl(96, token)) {
                // revert InvalidToken(0);
                mstore(0x40, 0x961c9a4f)
                revert(0x5c, 0x24)
            }
        }

        return token;
    }

    function withinAllocated(uint256 amount, uint256 allocatedAmount) internal pure {
        assembly ("memory-safe") {
            if lt(allocatedAmount, amount) {
                // revert AllocatedAmountExceeded(allocatedAmount, amount);
                mstore(0, 0x3078b2f6)
                mstore(0x20, allocatedAmount)
                mstore(0x40, amount)
                revert(0x1c, 0x44)
            }
        }
    }
}

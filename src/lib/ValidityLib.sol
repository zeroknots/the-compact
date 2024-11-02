// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { IdLib } from "./IdLib.sol";
import { ConsumerLib } from "./ConsumerLib.sol";
import { HashLib } from "./HashLib.sol";
import { SignatureCheckerLib } from "solady/utils/SignatureCheckerLib.sol";

/**
 * @title ValidityLib
 * @notice Libray contract implementing logic for validating expirations,
 * signatures, nonces (including consuming unused nonces), and token addresses.
 */
library ValidityLib {
    using IdLib for uint96;
    using IdLib for uint256;
    using ConsumerLib for uint256;
    using HashLib for bytes32;
    using SignatureCheckerLib for address;

    /**
     * @notice Internal function that retrieves an allocator's address from their ID and
     * consumes a nonce in their scope. Reverts if the allocator is not registered.
     * @param allocatorId The unique identifier for a registered allocator.
     * @param nonce       The nonce to consume in the allocator's scope.
     * @return allocator  The address of the registered allocator.
     */
    function fromRegisteredAllocatorIdWithConsumed(uint96 allocatorId, uint256 nonce) internal returns (address allocator) {
        allocator = allocatorId.toRegisteredAllocator();
        nonce.consumeNonceAsAllocator(allocator);
    }

    /**
     * @notice Internal function that retrieves an allocator's address from a resource lock ID
     * and consumes a nonce in their scope. Reverts if the allocator is not registered.
     * @param id         The ERC6909 token identifier containing the allocator ID.
     * @param nonce      The nonce to consume in the allocator's scope.
     * @return allocator The address of the registered allocator.
     */
    function toRegisteredAllocatorWithConsumed(uint256 id, uint256 nonce) internal returns (address allocator) {
        allocator = id.toAllocator();
        nonce.consumeNonceAsAllocator(allocator);
    }

    /**
     * @notice Internal view function that ensures that a timestamp has not yet passed.
     * Reverts if the provided timestamp is not in the future.
     * @param expires The timestamp to check.
     */
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

    /**
     * @notice Internal view function that validates a signature against an expected signer.
     * Returns if the signature is valid or if the caller is the expected signer, otherwise
     * reverts. The message hash is combined with the domain separator before verification.
     * If ECDSA recovery fails, an EIP-1271 isValidSignature check is performed.
     * @param messageHash     The EIP-712 hash of the message to verify.
     * @param expectedSigner  The address that should have signed the message.
     * @param signature       The signature to verify.
     * @param domainSeparator The domain separator to combine with the message hash.
     */
    function signedBy(bytes32 messageHash, address expectedSigner, bytes calldata signature, bytes32 domainSeparator) internal view {
        // Apply domain separator to message hash and verify it was signed correctly.
        bool hasValidSigner = expectedSigner.isValidSignatureNowCalldata(messageHash.withDomain(domainSeparator), signature);

        assembly ("memory-safe") {
            // Allow signature check to be bypassed if caller is the expected signer.
            if iszero(or(hasValidSigner, eq(expectedSigner, caller()))) {
                // revert InvalidSignature();
                mstore(0, 0x8baa579f)
                revert(0x1c, 0x04)
            }
        }
    }

    /**
     * @notice Internal view function to check if a nonce has been consumed in an
     * allocator's scope.
     * @param allocator The allocator whose scope to check.
     * @param nonce     The nonce to check.
     * @return          Whether the nonce has been consumed.
     */
    function hasConsumedAllocatorNonce(address allocator, uint256 nonce) internal view returns (bool) {
        return nonce.isConsumedByAllocator(allocator);
    }

    /**
     * @notice Internal pure function that validates a token address is not the zero
     * address (which represents native tokens). Reverts if the address is zero.
     * @param token The token address to validate.
     * @return      The validated token address.
     */
    function excludingNative(address token) internal pure returns (address) {
        assembly ("memory-safe") {
            if iszero(shl(96, token)) {
                // revert InvalidToken(0);
                mstore(0x40, 0x961c9a4f)
                revert(0x5c, 0x24)
            }
        }

        return token;
    }

    /**
     * @notice Internal pure function that checks if an amount is within an allocated
     * amount. Reverts if the amount exceeds the allocation.
     * @param amount          The amount to validate.
     * @param allocatedAmount The maximum allowed amount.
     */
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

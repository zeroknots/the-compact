// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library ConsumerLib {
    bytes4 private constant _CONSUMER_HASH_SCOPE = 0xd4b1f245;
    bytes4 private constant _CONSUMER_NONCE_SCOPE = 0x153dc4d7;

    error InvalidHash(bytes32);
    error InvalidNonce(address account, uint256 nonce);

    function consumeHash(bytes32 hashToConsume) internal {
        assembly {
            // slot: keccak256(_CONSUMER_HASH_SCOPE ++ hashToConsume)
            mstore(0, _CONSUMER_HASH_SCOPE)
            mstore(0x20, hashToConsume)
            let bucketSlot := keccak256(0x1c, 0x24)

            if sload(bucketSlot) {
                mstore(0x00, 0x44d659bf) // `InvalidHash(bytes32)`.
                revert(0x1c, 0x24)
            }

            sstore(bucketSlot, 1) // Invalidate the hash.
        }
    }

    function consumeNonce(uint256 nonce, address account) internal {
        // The last byte of the nonce is used to assign a bit in a 256-bit bucket;
        // specific nonces are consumed for each account and can only be used once.
        // NOTE: this function temporarily overwrites the free memory pointer, but
        // restores it before returning.
        assembly {
            let freeMemoryPointer := mload(0x40)

            // slot: keccak256(_CONSUMER_NONCE_SCOPE ++ account ++ nonce[0:31])
            mstore(0x20, account)
            mstore(0x0c, _CONSUMER_NONCE_SCOPE)
            mstore(0x40, nonce)
            let bucketSlot := keccak256(0x28, 0x37)

            let bucketValue := sload(bucketSlot)
            let bit := shl(and(0xff, nonce), 1)
            if and(bit, bucketValue) {
                // `InvalidNonce(address,uint256)` with padding for `account`.
                mstore(0x0c, 0x8baa579f000000000000000000000000)
                revert(0x1c, 0x44)
            }

            sstore(bucketSlot, or(bucketValue, bit)) // Invalidate the nonce.

            mstore(0x40, freeMemoryPointer)
        }
    }

    function isConsumed(bytes32 hashToCheck) internal view returns (bool consumed) {
        assembly {
            // slot: keccak256(_CONSUMER_HASH_SCOPE ++ hashToCheck)
            mstore(0, _CONSUMER_HASH_SCOPE)
            mstore(0x20, hashToCheck)
            consumed := sload(keccak256(0x1c, 0x24))
        }
    }

    function isConsumedBy(uint256 nonceToCheck, address account)
        internal
        view
        returns (bool consumed)
    {
        assembly {
            let freeMemoryPointer := mload(0x40)

            // slot: keccak256(_CONSUMER_NONCE_SCOPE ++ account ++ nonce[0:31])
            mstore(0x20, account)
            mstore(0x0c, _CONSUMER_NONCE_SCOPE)
            mstore(0x40, nonceToCheck)
            consumed := and(shl(and(0xff, nonceToCheck), 1), sload(keccak256(0x28, 0x37)))

            mstore(0x40, freeMemoryPointer)
        }
    }
}

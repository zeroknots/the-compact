// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library ConsumerLib {
    bytes4 private constant _CONSUMER_NONCE_SCOPE = 0x153dc4d7;

    error InvalidNonce(address account, uint256 nonce);

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

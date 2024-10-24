// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library ConsumerLib {
    bytes4 private constant _ALLOCATOR_NONCE_SCOPE = 0x03f37b1a;
    bytes4 private constant _SPONSOR_NONCE_SCOPE = 0x8ccd9613;

    error InvalidNonce(address account, uint256 nonce);

    function consumeNonceAsAllocator(uint256 nonce, address allocator) internal {
        _consumeNonce(nonce, allocator, _ALLOCATOR_NONCE_SCOPE);
    }

    function isConsumedByAllocator(uint256 nonceToCheck, address allocator) internal view returns (bool consumed) {
        return _isConsumedBy(nonceToCheck, allocator, _ALLOCATOR_NONCE_SCOPE);
    }

    function consumeNonceAsSponsor(uint256 nonce, address sponsor) internal {
        _consumeNonce(nonce, sponsor, _SPONSOR_NONCE_SCOPE);
    }

    function isConsumedBySponsor(uint256 nonceToCheck, address sponsor) internal view returns (bool consumed) {
        return _isConsumedBy(nonceToCheck, sponsor, _SPONSOR_NONCE_SCOPE);
    }

    function _consumeNonce(uint256 nonce, address account, bytes4 scope) internal {
        // The last byte of the nonce is used to assign a bit in a 256-bit bucket;
        // specific nonces are consumed for each account and can only be used once.
        // NOTE: this function temporarily overwrites the free memory pointer, but
        // restores it before returning.
        assembly ("memory-safe") {
            let freeMemoryPointer := mload(0x40)

            // slot: keccak256(_CONSUMER_NONCE_SCOPE ++ account ++ nonce[0:31])
            mstore(0x20, account)
            mstore(0x0c, scope)
            mstore(0x40, nonce)
            let bucketSlot := keccak256(0x28, 0x37)

            let bucketValue := sload(bucketSlot)
            let bit := shl(and(0xff, nonce), 1)
            if and(bit, bucketValue) {
                // `InvalidNonce(address,uint256)` with padding for `account`.
                mstore(0x0c, 0xdbc205b1000000000000000000000000)
                revert(0x1c, 0x44)
            }

            sstore(bucketSlot, or(bucketValue, bit)) // Invalidate the nonce.

            mstore(0x40, freeMemoryPointer)
        }
    }

    function _isConsumedBy(uint256 nonceToCheck, address account, bytes4 scope) internal view returns (bool consumed) {
        assembly ("memory-safe") {
            let freeMemoryPointer := mload(0x40)

            // slot: keccak256(_CONSUMER_NONCE_SCOPE ++ account ++ nonce[0:31])
            mstore(0x20, account)
            mstore(0x0c, scope)
            mstore(0x40, nonceToCheck)
            consumed := and(shl(and(0xff, nonceToCheck), 1), sload(keccak256(0x28, 0x37)))

            mstore(0x40, freeMemoryPointer)
        }
    }
}

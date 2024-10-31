// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ConstructorLogic } from "./ConstructorLogic.sol";

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";

contract DepositLogic is ConstructorLogic {
    using SafeTransferLib for address;

    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    /// @dev `keccak256(bytes("Transfer(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE = 0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    /// @dev Retrieves a token balance, compares against `initialBalance`, and mints the resulting balance
    /// change of `id` to `to`. Emits a {Transfer} event.
    function _checkBalanceAndDeposit(address token, address to, uint256 id, uint256 initialBalance) internal {
        uint256 tokenBalance = token.balanceOf(address(this));

        assembly ("memory-safe") {
            if iszero(lt(initialBalance, tokenBalance)) {
                // revert InvalidDepositBalanceChange()
                mstore(0, 0x426d8dcf)
                revert(0x1c, 0x04)
            }
        }

        unchecked {
            _deposit(to, id, tokenBalance - initialBalance);
        }
    }

    /// @dev Mints `amount` of token `id` to `to` without checking transfer hooks.
    /// Emits a {Transfer} event.
    function _deposit(address to, uint256 id, uint256 amount) internal {
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

            let recipient := shr(0x60, shl(0x60, to))

            // Emit the {Transfer} and {Deposit} events.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0, 0x40, _TRANSFER_EVENT_SIGNATURE, 0, recipient, id)
        }
    }
}

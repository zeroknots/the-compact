// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ForcedWithdrawalStatus } from "../types/ForcedWithdrawalStatus.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";

import { DepositViaPermit2Logic } from "./DepositViaPermit2Logic.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { IdLib } from "./IdLib.sol";
import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";

contract WithdrawalLogic is DepositViaPermit2Logic {
    using IdLib for uint256;
    using IdLib for ResetPeriod;
    using SafeTransferLib for address;
    using EfficiencyLib for uint256;

    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    /// @dev `keccak256(bytes("Transfer(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE = 0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    /// @dev `keccak256(bytes("ForcedWithdrawalStatusUpdated(address,uint256,bool,uint256)"))`.
    uint256 private constant _FORCED_WITHDRAWAL_STATUS_UPDATED_SIGNATURE = 0xe27f5e0382cf5347965fc81d5c81cd141897fe9ce402d22c496b7c2ddc84e5fd;

    // slot: keccak256(_FORCED_WITHDRAWAL_ACTIVATIONS_SCOPE ++ account ++ id) => activates
    uint256 private constant _FORCED_WITHDRAWAL_ACTIVATIONS_SCOPE = 0x41d0e04b;

    function _enableForcedWithdrawal(uint256 id) internal returns (uint256 withdrawableAt) {
        // overflow check not necessary as reset period is capped
        unchecked {
            withdrawableAt = block.timestamp + id.toResetPeriod().toSeconds();
        }

        uint256 cutoffTimeSlotLocation = _getCutoffTimeSlot(msg.sender, id);
        assembly ("memory-safe") {
            sstore(cutoffTimeSlotLocation, withdrawableAt)
        }

        _emitForcedWithdrawalStatusUpdatedEvent(id, withdrawableAt);
    }

    function _disableForcedWithdrawal(uint256 id) internal returns (bool) {
        uint256 cutoffTimeSlotLocation = _getCutoffTimeSlot(msg.sender, id);

        assembly ("memory-safe") {
            if iszero(sload(cutoffTimeSlotLocation)) {
                // revert ForcedWithdrawalAlreadyDisabled(msg.sender, id)
                mstore(0, 0xe632dbad)
                mstore(0x20, caller())
                mstore(0x40, id)
                revert(0x1c, 0x44)
            }

            sstore(cutoffTimeSlotLocation, 0)
        }

        _emitForcedWithdrawalStatusUpdatedEvent(id, uint256(0).asStubborn());

        return true;
    }

    function _processForcedWithdrawal(uint256 id, address recipient, uint256 amount) internal returns (bool) {
        uint256 cutoffTimeSlotLocation = _getCutoffTimeSlot(msg.sender, id);

        assembly ("memory-safe") {
            let withdrawableAt := sload(cutoffTimeSlotLocation)
            if or(iszero(withdrawableAt), gt(withdrawableAt, timestamp())) {
                // revert PrematureWithdrawal(id)
                mstore(0, 0x9287bcb0)
                mstore(0x20, id)
                revert(0x1c, 0x24)
            }
        }

        return _withdraw(msg.sender, recipient, id, amount);
    }

    /// @dev Burns `amount` token `id` from `from` without checking transfer hooks and sends
    /// the corresponding underlying tokens to `to`. Emits a {Transfer} event.
    function _withdraw(address from, address to, uint256 id, uint256 amount) internal returns (bool) {
        _setReentrancyGuard();
        address token = id.toToken();

        if (token == address(0)) {
            to.safeTransferETH(amount);
        } else {
            uint256 initialBalance = token.balanceOf(address(this));
            token.safeTransfer(to, amount);
            // NOTE: if the balance increased, this will underflow to a massive number causing
            // the burn to fail; furthermore, this scenario would indicate a very broken token
            unchecked {
                amount = initialBalance - token.balanceOf(address(this));
            }
        }

        assembly ("memory-safe") {
            // Compute the balance slot.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, from)
            mstore(0x00, id)
            let fromBalanceSlot := keccak256(0x00, 0x40)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))

            let account := shr(0x60, shl(0x60, from))

            // Emit the {Transfer} and {Withdrawal} events.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, account, 0, id)
        }

        _clearReentrancyGuard();

        return true;
    }

    function _getForcedWithdrawalStatus(address account, uint256 id) internal view returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt) {
        uint256 cutoffTimeSlotLocation = _getCutoffTimeSlot(account, id);
        assembly ("memory-safe") {
            forcedWithdrawalAvailableAt := sload(cutoffTimeSlotLocation)
            status := mul(iszero(iszero(forcedWithdrawalAvailableAt)), sub(2, gt(forcedWithdrawalAvailableAt, timestamp())))
        }
    }

    function _emitForcedWithdrawalStatusUpdatedEvent(uint256 id, uint256 withdrawableAt) private {
        assembly ("memory-safe") {
            mstore(0, iszero(iszero(withdrawableAt)))
            mstore(0x20, withdrawableAt)
            log3(0, 0x40, _FORCED_WITHDRAWAL_STATUS_UPDATED_SIGNATURE, caller(), id)
        }
    }

    function _getCutoffTimeSlot(address account, uint256 id) private pure returns (uint256 cutoffTimeSlotLocation) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(0x14, account)
            mstore(0, _FORCED_WITHDRAWAL_ACTIVATIONS_SCOPE)
            mstore(0x34, id)
            cutoffTimeSlotLocation := keccak256(0x1c, 0x38)
            mstore(0x40, m)
        }
    }
}

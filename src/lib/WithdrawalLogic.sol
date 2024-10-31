// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ForcedWithdrawalStatus } from "../types/ForcedWithdrawalStatus.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";

import { SharedLogic } from "./SharedLogic.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { IdLib } from "./IdLib.sol";

contract WithdrawalLogic is SharedLogic {
    using IdLib for uint256;
    using IdLib for ResetPeriod;
    using EfficiencyLib for uint256;

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

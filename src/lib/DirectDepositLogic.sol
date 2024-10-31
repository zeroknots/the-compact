// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

import { EfficiencyLib } from "./EfficiencyLib.sol";
import { IdLib } from "./IdLib.sol";
import { DepositLogic } from "./DepositLogic.sol";
import { ValidityLib } from "./ValidityLib.sol";

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";

contract DirectDepositLogic is DepositLogic {
    using IdLib for uint96;
    using IdLib for uint256;
    using IdLib for address;
    using EfficiencyLib for bool;
    using ValidityLib for address;
    using SafeTransferLib for address;

    function _performBasicNativeTokenDeposit(address allocator) internal returns (uint256 id) {
        id = address(0).toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        _deposit(msg.sender, id, msg.value);
    }

    function _processBatchDeposit(uint256[2][] calldata idsAndAmounts, address recipient) internal {
        _setReentrancyGuard();
        uint256 totalIds = idsAndAmounts.length;
        bool firstUnderlyingTokenIsNative;
        uint256 id;

        assembly ("memory-safe") {
            let idsAndAmountsOffset := idsAndAmounts.offset
            id := calldataload(idsAndAmountsOffset)
            firstUnderlyingTokenIsNative := iszero(shr(96, shl(96, id)))
            // Revert if:
            //  * the array is empty
            //  * the callvalue is zero but the first token is native
            //  * the callvalue is nonzero but the first token is non-native
            //  * the first token is non-native and the callvalue doesn't equal the first amount
            if or(iszero(totalIds), or(eq(firstUnderlyingTokenIsNative, iszero(callvalue())), and(firstUnderlyingTokenIsNative, iszero(eq(callvalue(), calldataload(add(idsAndAmountsOffset, 0x20)))))))
            {
                // revert InvalidBatchDepositStructure()
                mstore(0, 0xca0fc08e)
                revert(0x1c, 0x04)
            }
        }

        uint96 currentAllocatorId = id.toRegisteredAllocatorId();

        if (firstUnderlyingTokenIsNative) {
            _deposit(recipient, id, msg.value);
        }

        unchecked {
            for (uint256 i = firstUnderlyingTokenIsNative.asUint256(); i < totalIds; ++i) {
                uint256[2] calldata idAndAmount = idsAndAmounts[i];
                id = idAndAmount[0];
                uint256 amount = idAndAmount[1];

                uint96 newAllocatorId = id.toAllocatorId();
                if (newAllocatorId != currentAllocatorId) {
                    newAllocatorId.mustHaveARegisteredAllocator();
                    currentAllocatorId = newAllocatorId;
                }

                _transferAndDeposit(id.toToken(), recipient, id, amount);
            }
        }

        _clearReentrancyGuard();
    }

    function _performBasicERC20Deposit(address token, address allocator, uint256 amount) internal returns (uint256 id) {
        id = token.excludingNative().toIdIfRegistered(Scope.Multichain, ResetPeriod.TenMinutes, allocator);

        _transferAndDepositWithReentrancyGuard(token, msg.sender, id, amount);
    }

    function _performCustomNativeTokenDeposit(address allocator, ResetPeriod resetPeriod, Scope scope, address recipient) internal returns (uint256 id) {
        id = address(0).toIdIfRegistered(scope, resetPeriod, allocator);

        _deposit(recipient, id, msg.value);
    }

    function _performCustomERC20Deposit(address token, address allocator, ResetPeriod resetPeriod, Scope scope, uint256 amount, address recipient) internal returns (uint256 id) {
        id = token.excludingNative().toIdIfRegistered(scope, resetPeriod, allocator);

        _transferAndDepositWithReentrancyGuard(token, recipient, id, amount);
    }

    /// @dev Transfers `amount` of `token` and mints the resulting balance change of `id` to `to`.
    /// Emits a {Transfer} event.
    function _transferAndDeposit(address token, address to, uint256 id, uint256 amount) private {
        uint256 initialBalance = token.balanceOf(address(this));

        token.safeTransferFrom(msg.sender, address(this), amount);

        _checkBalanceAndDeposit(token, to, id, initialBalance);
    }

    /// @dev Transfers `amount` of `token` and mints the resulting balance change of `id` to `to`.
    /// Emits a {Transfer} event.
    function _transferAndDepositWithReentrancyGuard(address token, address to, uint256 id, uint256 amount) private {
        _setReentrancyGuard();

        _transferAndDeposit(token, to, id, amount);

        _clearReentrancyGuard();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BatchTransfer, SplitBatchTransfer } from "../types/BatchClaims.sol";
import { BasicTransfer, SplitTransfer } from "../types/Claims.sol";
import { CompactCategory } from "../types/CompactCategory.sol";
import { SplitComponent, TransferComponent, SplitByIdComponent } from "../types/Components.sol";
import { ForcedWithdrawalStatus } from "../types/ForcedWithdrawalStatus.sol";
import { Lock } from "../types/Lock.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";

import { ConsumerLib } from "./ConsumerLib.sol";
import { EfficiencyLib } from "./EfficiencyLib.sol";
import { FunctionCastLib } from "./FunctionCastLib.sol";
import { HashLib } from "./HashLib.sol";
import { IdLib } from "./IdLib.sol";
import { MetadataRenderer } from "./MetadataRenderer.sol";
import { ValidityLib } from "./ValidityLib.sol";

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { Tstorish } from "tstorish/Tstorish.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";

contract AllocatorLogic {
    using HashLib for address;
    using HashLib for bytes32;
    using HashLib for uint256;
    using HashLib for BasicTransfer;
    using HashLib for SplitTransfer;
    using HashLib for BatchTransfer;
    using HashLib for SplitBatchTransfer;
    using IdLib for uint96;
    using IdLib for uint256;
    using IdLib for address;
    using IdLib for Lock;
    using IdLib for ResetPeriod;
    using SafeTransferLib for address;
    using ConsumerLib for uint256;
    using EfficiencyLib for bool;
    using EfficiencyLib for bytes32;
    using EfficiencyLib for uint256;
    using ValidityLib for address;
    using ValidityLib for uint96;
    using ValidityLib for uint256;
    using ValidityLib for bytes32;
    using FunctionCastLib for function(bytes32, address, BasicTransfer calldata) internal;

    function _consume(uint256[] calldata nonces) internal returns (bool) {
        // NOTE: this may not be necessary, consider removing
        msg.sender.usingAllocatorId().mustHaveARegisteredAllocator();

        unchecked {
            uint256 i;

            assembly ("memory-safe") {
                i := nonces.offset
            }

            uint256 end = i + (nonces.length << 5);
            uint256 nonce;
            for (; i < end; i += 0x20) {
                assembly ("memory-safe") {
                    nonce := calldataload(i)
                }
                nonce.consumeNonceAsAllocator(msg.sender);
            }
        }

        return true;
    }

    function _registerAllocator(address allocator, bytes calldata proof) internal returns (uint96 allocatorId) {
        allocator = uint256(uint160(allocator)).asSanitizedAddress();
        if (!allocator.canBeRegistered(proof)) {
            assembly ("memory-safe") {
                // revert InvalidRegistrationProof(allocator)
                mstore(0, 0x4e7f492b)
                mstore(0x20, allocator)
                revert(0x1c, 0x24)
            }
        }

        allocatorId = allocator.register();
    }

    function _hasConsumedAllocatorNonce(uint256 nonce, address allocator) internal view returns (bool) {
        return allocator.hasConsumedAllocatorNonce(nonce);
    }

    function _getLockDetails(uint256 id) internal view returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope) {
        token = id.toToken();
        allocator = id.toAllocatorId().toRegisteredAllocator();
        resetPeriod = id.toResetPeriod();
        scope = id.toScope();
    }
}

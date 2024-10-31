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

import { InternalLogic } from "./InternalLogic.sol";

contract RegistrationLogic is InternalLogic {
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

    address private constant _PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    uint256 private constant _REENTRANCY_GUARD_SLOT = 0x929eee149b4bd21268;

    /// @dev `keccak256(bytes("Transfer(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE = 0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    /// @dev `keccak256(bytes("Claim(address,address,address,bytes32)"))`.
    uint256 private constant _CLAIM_EVENT_SIGNATURE = 0x770c32a2314b700d6239ee35ba23a9690f2fceb93a55d8c753e953059b3b18d4;

    /// @dev `keccak256(bytes("CompactRegistered(address,bytes32,bytes32,uint256)"))`.
    uint256 private constant _COMPACT_REGISTERED_SIGNATURE = 0xf78a2f33ff80ef4391f7449c748dc2d577a62cd645108f4f4069f4a7e0635b6a;

    /// @dev `keccak256(bytes("ForcedWithdrawalStatusUpdated(address,uint256,bool,uint256)"))`.
    uint256 private constant _FORCED_WITHDRAWAL_STATUS_UPDATED_SIGNATURE = 0xe27f5e0382cf5347965fc81d5c81cd141897fe9ce402d22c496b7c2ddc84e5fd;

    uint32 private constant _ATTEST_SELECTOR = 0x1a808f91;

    // slot: keccak256(_FORCED_WITHDRAWAL_ACTIVATIONS_SCOPE ++ account ++ id) => activates
    uint256 private constant _FORCED_WITHDRAWAL_ACTIVATIONS_SCOPE = 0x41d0e04b;

    // slot: keccak256(_ACTIVE_REGISTRATIONS_SCOPE ++ sponsor ++ claimHash ++ typehash) => expires
    uint256 private constant _ACTIVE_REGISTRATIONS_SCOPE = 0x68a30dd0;

    function _register(address sponsor, bytes32 claimHash, bytes32 typehash, uint256 duration) internal {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(add(m, 0x14), sponsor)
            mstore(m, _ACTIVE_REGISTRATIONS_SCOPE)
            mstore(add(m, 0x34), claimHash)
            mstore(add(m, 0x54), typehash)
            let cutoffSlot := keccak256(add(m, 0x1c), 0x58)

            let expires := add(timestamp(), duration)
            if or(lt(expires, sload(cutoffSlot)), gt(duration, 0x278d00)) {
                // revert InvalidRegistrationDuration(uint256 duration)
                mstore(0, 0x1f9a96f4)
                mstore(0x20, duration)
                revert(0x1c, 0x24)
            }

            sstore(cutoffSlot, expires)
            mstore(add(m, 0x74), expires)
            log2(add(m, 0x34), 0x60, _COMPACT_REGISTERED_SIGNATURE, shr(0x60, shl(0x60, sponsor)))
        }
    }

    function _registerWithDefaults(bytes32 claimHash, bytes32 typehash) internal {
        _register(msg.sender, claimHash, typehash, uint256(0x258).asStubborn());
    }

    function _registerBatch(bytes32[2][] calldata claimHashesAndTypehashes, uint256 duration) internal returns (bool) {
        unchecked {
            uint256 totalClaimHashes = claimHashesAndTypehashes.length;
            for (uint256 i = 0; i < totalClaimHashes; ++i) {
                bytes32[2] calldata claimHashAndTypehash = claimHashesAndTypehashes[i];
                _register(msg.sender, claimHashAndTypehash[0], claimHashAndTypehash[1], duration);
            }
        }

        return true;
    }

    function _getRegistrationStatus(address sponsor, bytes32 claimHash, bytes32 typehash) internal view returns (uint256 expires) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(add(m, 0x14), sponsor)
            mstore(m, _ACTIVE_REGISTRATIONS_SCOPE)
            mstore(add(m, 0x34), claimHash)
            mstore(add(m, 0x54), typehash)
            expires := sload(keccak256(add(m, 0x1c), 0x58))
        }
    }
}

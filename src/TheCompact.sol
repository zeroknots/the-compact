// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Lock} from "./types/Lock.sol";
import {IdLib} from "./lib/IdLib.sol";
import {ConsumerLib} from "./lib/ConsumerLib.sol";
import {ERC6909} from "solady/tokens/ERC6909.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {SignatureCheckerLib} from "solady/utils/SignatureCheckerLib.sol";
import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";
import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";

contract TheCompact is ERC6909 {
    using IdLib for uint256;
    using IdLib for address;
    using IdLib for Lock;
    using ConsumerLib for bytes32;
    using SafeTransferLib for address;
    using SignatureCheckerLib for address;

    error InvalidToken(address token);
    error InvalidTime(uint256 startTime, uint256 endTime);
    error InvalidSignature();
    error PrematureWithdrawal(uint256 id);
    error ForcedWithdrawalAlreadyDisabled(address account, uint256 id);

    IPermit2 private constant _PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    /// @dev `keccak256(bytes("Transfer(address,address,address,uint256,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE =
        0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    /// @dev `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`.
    bytes32 private constant _DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev `keccak256("1")`.
    bytes32 private constant _VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    // Rage-quit functionality
    mapping(address => mapping(uint256 => uint256)) public cutoffTime;

    event ForcedWithdrawalEnabled(address indexed account, uint256 indexed id, uint256 withdrawableAt);
    event ForcedWithdrawalDisabled(address indexed account, uint256 indexed id);
    event Withdrawal(address indexed account, address indexed recipient, uint256 indexed id, uint256 withdrawnAmount);

    /// @dev Returns the name for the contract.
    function name() public pure returns (string memory) {
        return "The Compact";
    }

    /// @dev Returns the symbol for token `id`.
    function name(uint256 id) public view virtual override returns (string memory) {
        return string.concat("Compact ", id.toToken().readNameWithDefaultValue());
    }

    /// @dev Returns the symbol for token `id`.
    function symbol(uint256 id) public view virtual override returns (string memory) {
        return string.concat(unicode"🤝-", id.toToken().readSymbolWithDefaultValue());
    }

    /// @dev Returns the Uniform Resource Identifier (URI) for token `id`.
    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return id.toURI();
    }

    function deposit(address allocator, uint48 resetPeriod, address recipient) external payable returns (uint256 id) {
        Lock memory lock = address(0).toLock(allocator, resetPeriod);
        id = lock.toId();

        _deposit(recipient, id, msg.value);
    }

    function deposit(address token, address allocator, uint48 resetPeriod, uint256 amount, address recipient)
        external
        returns (uint256 id)
    {
        if (token == address(0)) {
            revert InvalidToken(token);
        }

        Lock memory lock = token.toLock(allocator, resetPeriod);
        id = lock.toId();

        token.safeTransferFrom(msg.sender, address(this), amount);

        _deposit(recipient, id, amount);
    }

    function deposit(
        address depositor,
        address token,
        address allocator,
        uint48 resetPeriod,
        uint256 amount,
        address recipient,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external returns (uint256 id) {
        if (token == address(0)) {
            revert InvalidToken(token);
        }

        Lock memory lock = token.toLock(allocator, resetPeriod);
        id = lock.toId();

        ISignatureTransfer.SignatureTransferDetails memory signatureTransferDetails =
            ISignatureTransfer.SignatureTransferDetails({to: address(this), requestedAmount: amount});

        ISignatureTransfer.TokenPermissions memory tokenPermissions =
            ISignatureTransfer.TokenPermissions({token: token, amount: amount});

        ISignatureTransfer.PermitTransferFrom memory permitTransferFrom =
            ISignatureTransfer.PermitTransferFrom({permitted: tokenPermissions, nonce: nonce, deadline: deadline});

        bytes32 witness = keccak256(
            abi.encode(
                keccak256("CompactDeposit(address depositor,address allocator,uint48 resetPeriod,address recipient)"),
                depositor,
                allocator,
                resetPeriod,
                recipient
            )
        );

        _PERMIT2.permitWitnessTransferFrom(
            permitTransferFrom,
            signatureTransferDetails,
            depositor,
            witness,
            "CompactDeposit witness)CompactDeposit(address depositor,address allocator,uint48 resetPeriod,address recipient)TokenPermissions(address token,uint256 amount)",
            signature
        );

        _deposit(recipient, id, amount);
    }

    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt) {
        withdrawableAt = block.timestamp + id.toResetPeriod();
        cutoffTime[msg.sender][id] = withdrawableAt;
        emit ForcedWithdrawalEnabled(msg.sender, id, withdrawableAt);
    }

    function disableForcedWithdrawal(uint256 id) external {
        if (cutoffTime[msg.sender][id] == 0) {
            revert ForcedWithdrawalAlreadyDisabled(msg.sender, id);
        }
        delete cutoffTime[msg.sender][id];
        emit ForcedWithdrawalDisabled(msg.sender, id);
    }

    function forcedWithdrawal(uint256 id, address recipient) external returns (uint256 withdrawnAmount) {
        uint256 withdrawableAt = cutoffTime[msg.sender][id];
        if (withdrawableAt == 0 || withdrawableAt > block.timestamp) {
            revert PrematureWithdrawal(id);
        }

        withdrawnAmount = balanceOf(msg.sender, id);
        _forcedWithdrawal(msg.sender, id, withdrawnAmount);

        address token = id.toToken();
        if (token == address(0)) {
            recipient.safeTransferETH(withdrawnAmount);
        } else {
            token.safeTransfer(recipient, withdrawnAmount);
        }

        emit Withdrawal(msg.sender, recipient, id, withdrawnAmount);
    }

    /// @dev Moves token `id` from `from` to `to` without checking
    //  allowances or _beforeTokenTransfer / _afterTokenTransfer hooks.
    function _release(address from, address to, uint256 id, uint256 amount) internal returns (bool) {
        /// @solidity memory-safe-assembly
        assembly {
            /// Compute the balance slot and load its value.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, from)
            mstore(0x00, id)
            let fromBalanceSlot := keccak256(0x00, 0x40)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if insufficient or zero balance.
            if or(iszero(amount), gt(amount, fromBalance)) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))
            // Compute the balance slot of `to`.
            mstore(0x14, to)
            mstore(0x00, id)
            let toBalanceSlot := keccak256(0x00, 0x40)
            let toBalanceBefore := sload(toBalanceSlot)
            let toBalanceAfter := add(toBalanceBefore, amount)
            // Revert if the balance overflows.
            if lt(toBalanceAfter, toBalanceBefore) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            // Store the updated balance of `to`.
            sstore(toBalanceSlot, toBalanceAfter)
            // Emit the {Transfer} event.
            mstore(0x00, caller())
            mstore(0x20, amount)
            // forgefmt: disable-next-line
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, shr(96, shl(96, from)), shr(96, shl(96, to)), id)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x34, 0x00)
        }

        return true;
    }

    /// @dev Mints `amount` of token `id` to `to` without checking transfer hooks.
    ///
    /// Emits a {Transfer} event.
    function _deposit(address to, uint256 id, uint256 amount) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
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
            // Emit the {Transfer} event.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, 0, shr(96, shl(96, to)), id)
        }
    }

    /// @dev Burns `amount` token `id` from `from` without checking transfer hooks.
    ///
    /// Emits a {Transfer} event.
    function _forcedWithdrawal(address from, uint256 id, uint256 amount) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
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
            // Emit the {Transfer} event.
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, shr(96, shl(96, from)), 0, id)
        }
    }

    function _assertValidTime(uint256 startTime, uint256 endTime) internal view {
        assembly {
            if or(gt(startTime, timestamp()), iszero(gt(endTime, timestamp()))) {
                // revert InvalidTime(startTime, endTime);
                mstore(0, 0x21ccfeb7)
                mstore(0x20, startTime)
                mstore(0x40, endTime)
                revert(0x1c, 0x44)
            }
        }
    }

    function _assertValidSignature(bytes32 messageHash, bytes memory signature, address expectedSigner) internal view {
        // NOTE: analyze whether the signature check can safely be skipped in all
        // cases where the caller is the expected signer.
        if (msg.sender != expectedSigner) {
            if (!expectedSigner.isValidSignatureNow(_getDomainHash(messageHash), signature)) {
                revert InvalidSignature();
            }
        }
    }

    // TODO: cache domain separator based on chainId
    function _getDomainHash(bytes32 messageHash) internal view returns (bytes32 domainHash) {
        bytes32 nameHash = keccak256(bytes("The Compact"));

        assembly {
            let m := mload(0x40) // Grab the free memory pointer.

            // Prepare the 712 prefix.
            mstore(0, 0x1901)

            // Prepare the domain separator.
            mstore(m, _DOMAIN_TYPEHASH)
            mstore(add(m, 0x20), nameHash)
            mstore(add(m, 0x40), _VERSION_HASH)
            mstore(add(m, 0x60), chainid())
            mstore(add(m, 0x80), address())
            mstore(0x20, keccak256(m, 0xa0))

            // Prepare the message hash and compute the domain hash.
            mstore(0x40, messageHash)
            domainHash := keccak256(0x1e, 0x42)

            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    function _processPledge(address owner, uint256 id, uint256 maxPledge, uint256 startTime, uint256 endTime)
        internal
    {
        uint256 currentPledge = _deriveCurrentPledgeAmount(maxPledge, startTime, endTime);

        if (currentPledge != 0) {
            _release(owner, msg.sender, id, currentPledge);
        }
    }

    function _deriveCurrentPledgeAmount(uint256 maxPledge, uint256 startTime, uint256 endTime)
        internal
        view
        returns (uint256)
    {
        return (maxPledge * (block.timestamp - startTime)) / (endTime - startTime);
    }
}

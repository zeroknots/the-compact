// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Lock} from "./types/Lock.sol";
import {IdLib} from "./lib/IdLib.sol";
import {ERC6909} from "solady/tokens/ERC6909.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";
import {
    ISignatureTransfer
} from "permit2/src/interfaces/ISignatureTransfer.sol";

contract TheCompact is ERC6909 {
    using IdLib for uint256;
    using IdLib for address;
    using IdLib for Lock;
    using SafeTransferLib for address;

    error InvalidToken(address token);
    error PrematureWithdrawal(uint256 id);

    IPermit2 private constant _PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    // Rage-quit functionality
    mapping(address => mapping(uint256 => uint256)) public cutoffTime;

    event WithdrawalTendered(address indexed account, uint256 indexed id, uint256 withdrawableAt);
    event WithdrawalExecuted(
        address indexed account, address indexed recipient, uint256 indexed id, uint256 withdrawnAmount
    );

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

        _mint(recipient, id, msg.value);
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

        _mint(recipient, id, amount);
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
    )
        external
        returns (uint256 id)
    {
        if (token == address(0)) {
            revert InvalidToken(token);
        }

        Lock memory lock = token.toLock(allocator, resetPeriod);
        id = lock.toId();

        ISignatureTransfer.SignatureTransferDetails memory signatureTransferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: address(this),
            requestedAmount: amount
        });

        ISignatureTransfer.TokenPermissions memory tokenPermissions = ISignatureTransfer.TokenPermissions({
            token: token,
            amount: amount
        });

        ISignatureTransfer.PermitTransferFrom memory permitTransferFrom = ISignatureTransfer.PermitTransferFrom({
            permitted: tokenPermissions,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 witness = keccak256(abi.encode(
            keccak256("CompactDeposit(address depositor,address allocator,uint48 resetPeriod,address recipient)"),
            depositor,
            allocator,
            resetPeriod,
            recipient
        ));

        _PERMIT2.permitWitnessTransferFrom(
            permitTransferFrom,
            signatureTransferDetails,
            depositor,
            witness,
            "CompactDeposit witness)CompactDeposit(address depositor,address allocator,uint48 resetPeriod,address recipient)TokenPermissions(address token,uint256 amount)",
            signature
        );

        _mint(recipient, id, amount);
    }

    function enableWithdrawal(uint256 id) external returns (uint256 withdrawableAt) {
        withdrawableAt = block.timestamp + id.toResetPeriod();
        cutoffTime[msg.sender][id] = withdrawableAt;
        emit WithdrawalTendered(msg.sender, id, withdrawableAt);
    }

    function disableWithdrawal(uint256 id) external {
        delete cutoffTime[msg.sender][id];
        emit WithdrawalTendered(msg.sender, id, 0);
    }

    function withdraw(uint256 id, address recipient) external returns (uint256 withdrawnAmount) {
        uint256 withdrawableAt = cutoffTime[msg.sender][id];
        if (withdrawableAt == 0 || withdrawableAt > block.timestamp) {
            revert PrematureWithdrawal(id);
        }

        withdrawnAmount = balanceOf(msg.sender, id);
        _burn(msg.sender, id, withdrawnAmount);

        address token = id.toToken();
        if (token == address(0)) {
            recipient.safeTransferETH(withdrawnAmount);
        } else {
            token.safeTransfer(recipient, withdrawnAmount);
        }

        emit WithdrawalExecuted(msg.sender, recipient, id, withdrawnAmount);
    }
}

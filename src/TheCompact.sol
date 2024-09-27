// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Lock} from "./types/Lock.sol";
import {IdLib} from "./lib/IdLib.sol";
import {ERC6909} from "solady/tokens/ERC6909.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

contract TheCompact is ERC6909 {
    using IdLib for uint256;
    using IdLib for address;
    using IdLib for Lock;
    using SafeTransferLib for address;

    error InvalidToken(address token);
    error PrematureWithdrawal(uint256 id);

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

    function mint(address allocator, uint48 resetPeriod, address recipient) external payable returns (uint256 id) {
        Lock memory lock = address(0).toLock(allocator, resetPeriod);
        id = lock.toId();

        _mint(recipient, id, msg.value);
    }

    function mint(address token, address allocator, uint48 resetPeriod, uint256 amount, address recipient)
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

    function tenderWithdrawal(uint256 id) external returns (uint256 withdrawableAt) {
        withdrawableAt = block.timestamp + id.toResetPeriod();
        cutoffTime[msg.sender][id] = withdrawableAt;
        emit WithdrawalTendered(msg.sender, id, withdrawableAt);
    }

    function withdraw(uint256 id, address recipient) external returns (uint256 withdrawnAmount) {
        uint256 withdrawableAt = cutoffTime[msg.sender][id];
        if (withdrawableAt == 0 || withdrawableAt > block.timestamp) {
            revert PrematureWithdrawal(id);
        }

        delete cutoffTime[msg.sender][id];

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

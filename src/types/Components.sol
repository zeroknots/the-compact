// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

struct SplitComponent {
    address claimant;
    uint256 amount;
}

struct SplitByIdComponent {
    uint256 id;
    SplitComponent[] portions;
}

struct TransferComponent {
    uint256 id; // The token ID of the ERC6909 token to transfer or withdraw.
    uint256 amount; // The token amount to transfer or withdraw.
    address recipient; // The recipient of the transfer or withdrawal.
}

struct BatchClaimComponent {
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    address claimant; // The claim recipient; specified by the arbiter.
    uint256 amount; // The claimed token amount; specified by the arbiter.
}

struct SplitBatchClaimComponent {
    uint256 id; // The token ID of the ERC6909 token to allocate.
    uint256 allocatedAmount; // The original allocated amount of ERC6909 tokens.
    SplitComponent[] portions;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { TransferBenchmarkLib } from "./TransferBenchmarkLib.sol";

import { BenchmarkERC20 } from "./BenchmarkERC20.sol";

contract TransferBenchmarkLogic {
    using TransferBenchmarkLib for address;
    using TransferBenchmarkLib for bytes32;

    // Declare an immutable argument for the account of the benchmark ERC20 token.
    address private immutable _BENCHMARK_ERC20;

    constructor() {
        // Deploy reference ERC20 for benchmarking generic ERC20 token withdrawals. Note
        // that benchmark cannot be evaluated as part of contract creation as it requires
        // that the token account is not already warm as part of deriving the benchmark.
        _BENCHMARK_ERC20 = address(new BenchmarkERC20());
    }

    function _benchmark(bytes32 salt) internal {
        salt.setNativeTokenBenchmark();
        _BENCHMARK_ERC20.setERC20TokenBenchmark();
    }

    function _getRequiredWithdrawalFallbackStipends()
        internal
        view
        returns (uint256 nativeTokenStipend, uint256 erc20TokenStipend)
    {
        return TransferBenchmarkLib.getTokenWithdrawalBenchmarks();
    }
}

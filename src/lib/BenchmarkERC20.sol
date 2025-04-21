// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ERC20 } from "solady/tokens/ERC20.sol";

contract BenchmarkERC20 is ERC20 {
    address private immutable deployer;

    error OnlyDeployer();

    function name() public view virtual override returns (string memory) {
        return "Benchmark ERC20";
    }

    function symbol() public view virtual override returns (string memory) {
        return "BENCHMARK_ERC20";
    }

    constructor() {
        deployer = msg.sender;

        _mint(deployer, type(uint256).max);
    }

    function burn(address target) external {
        if (msg.sender != deployer) {
            revert OnlyDeployer();
        }

        _burn(target, balanceOf(target));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TheCompact} from "../src/TheCompact.sol";
import {MockERC20} from "../lib/solady/test/utils/mocks/MockERC20.sol";

contract TheCompactTest is Test {
    TheCompact public theCompact;
    MockERC20 public token;

    function setUp() public {
        theCompact = new TheCompact();
        token = new MockERC20("Mock ERC20", "MOCK", 18);
        token.mint(address(this), 1e18);
        token.approve(address(theCompact), 1e18);
    }

    function test_mintAndURI() public {
        uint256 id = theCompact.mint(address(token), address(this), 120, 1e18, address(this));
        console.log(theCompact.tokenURI(id));
    }

    function test_mintETHAndURI() public {
        uint256 id = theCompact.mint{value: 1e18}(address(this), 120, address(this));
        console.log(theCompact.tokenURI(id));
    }
}

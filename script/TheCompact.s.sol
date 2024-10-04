// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { TheCompact } from "../src/TheCompact.sol";

contract TheCompactScript is Script {
    TheCompact public theCompact;

    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        theCompact = new TheCompact();

        vm.stopBroadcast();
    }
}

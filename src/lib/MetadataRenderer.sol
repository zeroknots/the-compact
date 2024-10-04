// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { MetadataLib } from "./MetadataLib.sol";
import { Lock } from "../types/Lock.sol";

contract MetadataRenderer {
    using MetadataLib for Lock;

    function uri(Lock memory lock, uint256 id) external view returns (string memory) {
        return lock.toURI(id);
    }
}

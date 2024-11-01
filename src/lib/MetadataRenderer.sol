// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { EfficiencyLib } from "./EfficiencyLib.sol";
import { MetadataLib } from "./MetadataLib.sol";
import { Lock } from "../types/Lock.sol";

/**
 * @title MetadataRenderer
 * @notice Deployed contract implementing functionality for deriving and displaying
 * ERC6909 metadata as well as metadata specific to various underlying tokens.
 */
contract MetadataRenderer {
    using EfficiencyLib for uint256;
    using MetadataLib for Lock;
    using MetadataLib for address;

    function uri(Lock memory lock, uint256 id) external view returns (string memory) {
        return lock.toURI(id);
    }

    /// @dev Returns the symbol for token `id`.
    function name(uint256 id) public view returns (string memory) {
        return string.concat("Compact ", id.asSanitizedAddress().readNameWithDefaultValue());
    }

    /// @dev Returns the symbol for token `id`.
    function symbol(uint256 id) public view returns (string memory) {
        return string.concat(unicode"🤝-", id.asSanitizedAddress().readSymbolWithDefaultValue());
    }
}

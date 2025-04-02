// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "src/lib/TheCompactLogic.sol";
import "src/lib/ValidityLib.sol";
import "src/lib/EmissaryLib.sol";
import "src/lib/DomainLib.sol";

contract MockEmissaryLogic is TheCompactLogic {
    using EmissaryLib for bytes32;
    using DomainLib for bytes32;

    function registerAllocator(address allocator, bytes calldata proof) external {
        _registerAllocator(allocator, proof);
    }

    function scheduleEmissaryAssignment(address sponsor, address allocator) external returns (uint256) {
        return _scheduleEmissaryAssignment(sponsor, allocator);
    }

    function assignEmissary(address sponsor, address allocator, address emissary, ResetPeriod resetPeriod) external returns (bool) {
        return _assignEmissary(sponsor, allocator, emissary, resetPeriod);
    }

    function verifyWithEmissary(address sponsor, bytes calldata signature, bytes32 messageHash, uint256 allocatorId) external view returns (bool) {
        bytes32 domainSeparator = _domainSeparator();
        bytes32 claimHash = messageHash.withDomain(domainSeparator);

        return claimHash.verifyWithEmissary(sponsor, allocatorId, signature);
    }

    function getEmissaryStatus(address sponsor, address allocator) external view returns (EmissaryStatus status, uint256 assignableAt, address currentEmissary) {
        return _getEmissaryStatus(sponsor, allocator);
    }
}

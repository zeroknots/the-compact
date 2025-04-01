// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ResetPeriod } from "./ResetPeriod.sol";

enum EmissaryStatus {
    Disabled, // Not pending or enabled for forced withdrawal
    Scheduled, // Available but scheduled
    Enabled // Available for forced withdrawal on demand

}

struct EmissaryConfig {
    address emissary;
    ResetPeriod resetPeriod;
    uint48 assignableAt;
}

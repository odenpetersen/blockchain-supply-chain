// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Oracle} from "../src/Oracle.sol";

contract DeployOracle is Script {
    function run() external returns (Oracle) {
        vm.startBroadcast();
        Oracle mastercard = new Oracle();
        vm.stopBroadcast();
        return mastercard;
    }
}

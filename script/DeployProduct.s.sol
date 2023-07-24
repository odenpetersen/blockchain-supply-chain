// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Product} from "../src/Product.sol";

contract DeployProduct is Script {
    function run() external returns (Product) {
        vm.startBroadcast();
        Product milk = new Product(
            "03178471",
            "100 Boxes of Milk",
            100,
            2,
            100,
            "100 Boxes of Milk expires in 2023-08-01"
        );
        vm.stopBroadcast();
        return milk;
    }
}

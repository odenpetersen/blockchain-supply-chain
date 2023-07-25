// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Oracle} from "../src/Oracle.sol";
import {Order} from "../src/Order.sol";
import {Product} from "../src/Product.sol";

contract DeployOrder is Script {
    function run() external {
        uint256 buyerPrivateKey = vm.envUint("BUYER_PRIVATE_KEY");
        uint256 sellerPrivateKey = vm.envUint("SELLER_PRIVATE_KEY");
        uint256 oraclePrivateKey = vm.envUint("ORACLE_PRIVATE_KEY");
        uint256 londonPrivateKey = vm.envUint("LONDON_PRIVATE_KEY"); // this is also shipper's address
        uint256 singaporePrivateKey = vm.envUint("SINGAPORE_PRIVATE_KEY");
        uint256 sydneyPrivateKey = vm.envUint("SYDNEY_PRIVATE_KEY");

        address sellerAddress = vm.envAddress("SELLER_ADDRESS");
        address oracleAddress = vm.envAddress("ORACLE_ADDRESS");
        address londonAddress = vm.envAddress("LONDON_ADDRESS");
        address singaporeAddress = vm.envAddress("SINGAPORE_ADDRESS");
        address sydneyAddress = vm.envAddress("SYDNEY_ADDRESS");

        // Deploy Product
        vm.startBroadcast(sellerPrivateKey);
        Product product = new Product(
            "12345678",
            "100 carton of Milk",
            100,
            2,
            10,
            "100 carton of Milk expires on 2023-08-01"
        );
        vm.stopBroadcast();

        // Deploy Oracle
        vm.startBroadcast(oraclePrivateKey);
        Oracle oracle = new Oracle();
        vm.stopBroadcast();

        // Create Order
        string[] memory destinations = new string[](3);
        destinations[0] = "London, UK";
        destinations[1] = "Singapore, SG";
        destinations[2] = "Sydney, Australia";

        address[] memory intermediaries = new address[](3);
        intermediaries[0] = londonAddress;
        intermediaries[1] = singaporeAddress;
        intermediaries[2] = sydneyAddress;

        uint256[] memory deliveryDueTimes = new uint256[](3);
        deliveryDueTimes[0] = 1680364800; // 2023-08-01T00:00:00Z
        deliveryDueTimes[1] = 1682284800; // 2023-08-11T00:00:00Z
        deliveryDueTimes[2] = 1690364800; // 2023-08-21T00:00:00Z

        vm.startBroadcast(buyerPrivateKey);
        Order order = new Order(
            address(product),
            sellerAddress,
            londonAddress,
            address(oracle),
            destinations,
            intermediaries,
            deliveryDueTimes
        );
        vm.stopBroadcast();

        // Verify By Seller and Shipper
        vm.startBroadcast(sellerPrivateKey);
        order.verifyOrderBySeller(true);
        vm.stopBroadcast();

        vm.startBroadcast(londonPrivateKey);
        order.verifyOrderByShipper(true);
        vm.stopBroadcast();

        // Buyer pay the order offchain and oracle gets updated
        vm.startBroadcast(oracleAddress);
        oracle.setPaid(address(order), true);
        vm.stopBroadcast();

        vm.startBroadcast(buyerPrivateKey);
        order.isPaid();
        vm.stopBroadcast();

        // Shipment gets updated by 3 delivery points
        vm.startBroadcast(londonPrivateKey);
        order.updateShipment(1680364800); // 2023-08-01T00:00:00Z
        vm.stopBroadcast();

        vm.startBroadcast(singaporePrivateKey);
        order.updateShipment(1682284800); // 2023-08-11T00:00:00Z
        vm.stopBroadcast();

        vm.startBroadcast(sydneyPrivateKey);
        order.updateShipment(1690364800); // 2023-08-21T00:00:00Z
        vm.stopBroadcast();

        // Buyer receives the order
        vm.startBroadcast(buyerPrivateKey);
        order.verifyReceipt();

        vm.stopBroadcast();
    }
}

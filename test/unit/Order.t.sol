// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {Product} from "../../src/Product.sol";
import {Oracle} from "../../src/Oracle.sol";
import {Order} from "../../src/Order.sol";
import {IOrder} from "../../src/interfaces/IOrder.sol";

contract OrderTest is StdCheats, Test {
    Order order;

    address public BUYER = makeAddr("buyer");
    address public SELLER = makeAddr("seller");
    address public SHIPPER = makeAddr("shipper");
    address public ORACLE_MANAGER = makeAddr("oracle_manager");

    address public SYDNEY_AU = makeAddr("SYDNEY_AU");
    address public SINGAPORE_SG = makeAddr("SINGAPORE_SG");
    address public LONDON_UK = makeAddr("LONDON_UK");

    function setUp() public {
        vm.prank(SELLER);

        Product product = new Product(
            "12345678",
            "100 carton of Milk",
            100,
            2,
            10,
            "100 carton of Milk expires on 2023-08-01"
        );

        vm.prank(ORACLE_MANAGER);
        Oracle oracle = new Oracle();

        string[] memory destinations = new string[](3);
        destinations[0] = "London, UK";
        destinations[1] = "Singapore, SG";
        destinations[2] = "Sydney, Australia";

        address[] memory intermediaries = new address[](3);
        intermediaries[0] = LONDON_UK;
        intermediaries[1] = SINGAPORE_SG;
        intermediaries[2] = SYDNEY_AU;

        uint[] memory deliveryDueTimes = new uint[](3);
        deliveryDueTimes[0] = 1680364800; // 2023-08-01T00:00:00Z
        deliveryDueTimes[1] = 1682284800; // 2023-08-11T00:00:00Z
        deliveryDueTimes[2] = 1690364800; // 2023-08-21T00:00:00Z

        vm.prank(BUYER);
        order = new Order(
            address(product),
            SELLER,
            SHIPPER,
            address(oracle),
            destinations,
            intermediaries,
            deliveryDueTimes
        );
    }

    function test_initialAttributes() public {
        assertEq(uint(order.getOrderStatus()), 0);
        assertEq(order.getIsVerifiedBySeller(), false);
        assertEq(order.getIsVerifiedByShipper(), false);
        assertEq(order.getCurrentDeliveryPoint(), "London, UK");
        assertEq(order.getLastUpdatedAt(), 0);

        string[] memory deliveryPoints = order.getDeliveryPoints();
        assertEq(deliveryPoints.length, 3);
        assertEq(deliveryPoints[0], "London, UK");
        assertEq(deliveryPoints[1], "Singapore, SG");
        assertEq(deliveryPoints[2], "Sydney, Australia");

        address[] memory intermediaries = order.getIntermediaries();
        assertEq(intermediaries.length, 3);
        assertEq(intermediaries[0], LONDON_UK);
        assertEq(intermediaries[1], SINGAPORE_SG);
        assertEq(intermediaries[2], SYDNEY_AU);

        uint[] memory deliveryDueTimes = order.getDeliveryDueTimes();
        assertEq(deliveryDueTimes.length, 3);
        assertEq(deliveryDueTimes[0], 1680364800);
        assertEq(deliveryDueTimes[1], 1682284800);
        assertEq(deliveryDueTimes[2], 1690364800);
    }
}

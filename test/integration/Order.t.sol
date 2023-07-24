// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {Product} from "../../src/Product.sol";
import {Oracle} from "../../src/Oracle.sol";
import {Order} from "../../src/Order.sol";
import {IOrder} from "../../src/interfaces/IOrder.sol";

contract OrderTest is StdCheats, Test {
    Order order;
    Oracle oracle;
    Product product;

    address public BUYER = makeAddr("buyer");
    address public SELLER = makeAddr("seller");
    address public SHIPPER = makeAddr("shipper");
    address public ORACLE_MANAGER = makeAddr("oracle_manager");
    address public HACKER = makeAddr("hacker");

    address public SYDNEY_AU = makeAddr("SYDNEY_AU");
    address public SINGAPORE_SG = makeAddr("SINGAPORE_SG");
    address public LONDON_UK = makeAddr("LONDON_UK");

    function setUp() public {
        vm.prank(SELLER);

        product = new Product(
            "12345678",
            "100 carton of Milk",
            100,
            2,
            10,
            "100 carton of Milk expires on 2023-08-01"
        );

        vm.prank(ORACLE_MANAGER);
        oracle = new Oracle();

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

    function test_failCreatingState() public {
        string[] memory destinations = new string[](3);
        destinations[0] = "London, UK";
        destinations[1] = "Singapore, SG";
        destinations[2] = "Sydney, Australia";

        address[] memory intermediaries1 = new address[](3);
        intermediaries1[0] = LONDON_UK;
        intermediaries1[1] = SINGAPORE_SG;
        intermediaries1[2] = SYDNEY_AU;

        address[] memory intermediaries2 = new address[](2);
        intermediaries2[0] = LONDON_UK;
        intermediaries2[1] = SINGAPORE_SG;

        uint[] memory deliveryDueTimes1 = new uint[](3);
        deliveryDueTimes1[0] = 1680364800; // 2023-08-01T00:00:00Z
        deliveryDueTimes1[1] = 1682284800; // 2023-08-11T00:00:00Z
        deliveryDueTimes1[2] = 1690364800; // 2023-08-21T00:00:00

        uint[] memory deliveryDueTimes2 = new uint[](2);
        deliveryDueTimes2[0] = 1680364800; // 2023-08-01T00:00:00Z
        deliveryDueTimes2[1] = 1682284800; // 2023-08-11T00:00:00Z

        vm.prank(BUYER);
        vm.expectRevert();
        new Order(
            address(product),
            SELLER,
            SHIPPER,
            address(oracle),
            destinations,
            intermediaries1,
            deliveryDueTimes2
        );

        vm.prank(BUYER);
        vm.expectRevert();
        new Order(
            address(product),
            SELLER,
            SHIPPER,
            address(oracle),
            destinations,
            intermediaries2,
            deliveryDueTimes1
        );
    }

    function test_createdState() public {
        assertEq(uint(order.getOrderStatus()), 0);
    }

    // seller verifies first
    function test_verifyingState1() public {
        // before verifying state
        assertEq(uint(order.getOrderStatus()), 0);

        // seller verifies the order (items are in stock)
        assertEq(order.getIsVerifiedBySeller(), false);
        vm.prank(SELLER);
        order.verifyOrderBySeller(true);
        assertEq(order.getIsVerifiedBySeller(), true);

        // only seller has been verified, need to wait for shipper
        assertEq(uint(order.getOrderStatus()), 0);

        // shipper verifies the order (destinations path are right)
        assertEq(order.getIsVerifiedByShipper(), false);
        vm.prank(SHIPPER);
        order.verifyOrderByShipper(true);
        assertEq(order.getIsVerifiedByShipper(), true);

        // both seller and shipper have been verified, order is verified state
        assertEq(uint(order.getOrderStatus()), 1);
    }

    // shiper verifies first
    function test_verifyingState2() public {
        // before verifying state
        assertEq(uint(order.getOrderStatus()), 0);

        // shipper verifies the order (destinations path are right)
        assertEq(order.getIsVerifiedByShipper(), false);
        vm.prank(SHIPPER);
        order.verifyOrderByShipper(true);
        assertEq(order.getIsVerifiedByShipper(), true);

        // only shipper has been verified, need to wait for seller
        assertEq(uint(order.getOrderStatus()), 0);

        // seller verifies the order (items are in stock)
        assertEq(order.getIsVerifiedBySeller(), false);
        vm.prank(SELLER);
        order.verifyOrderBySeller(true);
        assertEq(order.getIsVerifiedBySeller(), true);

        // both seller and shipper have been verified, order is verified state
        assertEq(uint(order.getOrderStatus()), 1);
    }

    function test_failVerifyingState1() public {
        vm.prank(HACKER);
        vm.expectRevert();
        order.verifyOrderBySeller(true);

        vm.prank(HACKER);
        vm.expectRevert();
        order.verifyOrderByShipper(true);
    }

    function test_failVerifyingState2() public {
        vm.prank(LONDON_UK);
        vm.expectRevert();
        order.updateShipment(1680364800);
    }

    function test_paidState() public {
        _getIntoVerifyingState();

        order.isPaid();
        assertEq(uint(order.getOrderStatus()), 1);

        assertEq(oracle.isPaid(address(order)), false);
        vm.prank(ORACLE_MANAGER);
        oracle.setPaid(address(order), true);
        assertEq(oracle.isPaid(address(order)), true);

        order.isPaid();
        assertEq(uint(order.getOrderStatus()), 2);
    }

    function test_failPaidState() public {
        _getIntoVerifyingState();
        assertEq(oracle.isPaid(address(order)), false);
        vm.prank(HACKER);
        vm.expectRevert();
        oracle.setPaid(address(order), true);
    }

    function test_deliveredState() public {
        _getIntoPaidState();
        // record events for this test
        vm.recordLogs();

        // London -> Singapore -> Sydney

        // Pick up from London
        vm.prank(LONDON_UK);
        order.updateShipment(1680364800);
        assertEq(order.getCurrentDeliveryPoint(), "London, UK");
        assertEq(uint(order.getOrderStatus()), 3);
        assertEq(order.getLastUpdatedAt(), 1680364800);
        // expect an event to be emitted
        Vm.Log[] memory entries1 = vm.getRecordedLogs();
        assertEq(entries1.length, 1);
        assertEq(
            entries1[0].topics[0],
            keccak256("ShipmentUpdated(uint256,string)")
        );

        // Pick up from Singapore
        vm.prank(SINGAPORE_SG);
        order.updateShipment(1682284800);
        assertEq(order.getCurrentDeliveryPoint(), "Singapore, SG");
        assertEq(order.getLastUpdatedAt(), 1682284800);

        // Pick up from Sydney
        vm.prank(SYDNEY_AU);
        order.updateShipment(1690364800);
        assertEq(order.getCurrentDeliveryPoint(), "Sydney, Australia");
        assertEq(order.getLastUpdatedAt(), 1690364800);

        // getDeliveryTimes
        uint[] memory deliveryTimes = order.getDeliveryTimes();
        assertEq(deliveryTimes.length, 3);
        assertEq(deliveryTimes[0], 1680364800);
        assertEq(deliveryTimes[1], 1682284800);
        assertEq(deliveryTimes[2], 1690364800);
    }

    // testFail_deliveredState1: hacker tries to update shipment after the order is paid
    function test_failDeliveredState1() public {
        _getIntoPaidState();
        vm.prank(HACKER);
        vm.expectRevert();
        order.updateShipment(1680364800);
    }

    // testFail_deliveredState2: hacker tries to update shipment after the order is being delivered
    function test_failDeliveredState2() public {
        _getIntoPaidState();
        vm.prank(LONDON_UK);
        order.updateShipment(1680364800);
        vm.prank(HACKER);
        vm.expectRevert();
        order.updateShipment(1682284800);
    }

    // testFail_deliveredState3: hacker tries to update shipment after the order is delivered
    function test_failDeliveredState3() public {
        _getIntoDeliveredState();
        vm.prank(HACKER);
        vm.expectRevert();
        order.updateShipment(1690364805);
    }

    // testFail_deliveredState4: two updates made by the same delivery point
    function test_failDeliveredState4() public {
        _getIntoDeliveredState();
        vm.prank(SYDNEY_AU);
        vm.expectRevert();
        order.updateShipment(1690364810);
    }

    // testFail_deliveredState5: update made by the delivery point that is later in the path
    function test_failDeliveredState5() public {
        _getIntoPaidState();
        vm.prank(SYDNEY_AU);
        vm.expectRevert();
        order.updateShipment(1690364800);
    }

    // testFail_deliveredState6: incorrect timestamp
    function test_failDeliveredState6() public {
        _getIntoPaidState();
        vm.prank(LONDON_UK);
        order.updateShipment(1682284800);
        vm.prank(SINGAPORE_SG);
        vm.expectRevert();
        order.updateShipment(1680364800);
    }

    function test_receivedState() public {
        _getIntoDeliveredState();
        // confirm by buyer who received the order by verifying receipt

        vm.prank(BUYER);
        order.verifyReceipt();
        assertEq(uint(order.getOrderStatus()), 4);
    }

    function test_failReceivedState() public {
        _getIntoDeliveredState();
        // confirm by buyer who received the order by verifying receipt

        vm.prank(HACKER);
        vm.expectRevert();
        order.verifyReceipt();
        assertEq(uint(order.getOrderStatus()), 3);
    }

    function test_cancelledStateInCreatedState1() public {
        vm.prank(BUYER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInCreatedState2() public {
        vm.prank(SELLER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInCreatedState3() public {
        vm.prank(SHIPPER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_failCancelledStateInCreatedState() public {
        vm.prank(HACKER);
        vm.expectRevert();
        order.cancelOrder();
    }

    function test_cancelledStateInVerifiedState1() public {
        _getIntoVerifyingState();
        vm.prank(BUYER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInVerifiedState2() public {
        _getIntoVerifyingState();
        vm.prank(SELLER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInVerifiedState3() public {
        _getIntoVerifyingState();
        vm.prank(SHIPPER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInVerifiedState4() public {
        vm.prank(SELLER);
        order.verifyOrderBySeller(false);
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInVerifiedState5() public {
        vm.prank(SHIPPER);
        order.verifyOrderByShipper(false);
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_failCancelledStateInVerifiedState() public {
        _getIntoVerifyingState();
        vm.prank(HACKER);
        vm.expectRevert();
        order.cancelOrder();
    }

    function test_cancelledStateInPaidState1() public {
        _getIntoPaidState();
        vm.prank(BUYER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInPaidState2() public {
        _getIntoPaidState();
        vm.prank(SELLER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInPaidState3() public {
        _getIntoPaidState();
        vm.prank(SHIPPER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_failCancelledStateInPaidState() public {
        _getIntoPaidState();
        vm.prank(HACKER);
        vm.expectRevert();
        order.cancelOrder();
    }

    function test_cancelledStateInDeliveredState1() public {
        _getIntoDeliveredState();
        vm.prank(BUYER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInDeliveredState2() public {
        _getIntoDeliveredState();
        vm.prank(SELLER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_cancelledStateInDeliveredState3() public {
        _getIntoDeliveredState();
        vm.prank(SHIPPER);
        order.cancelOrder();
        assertEq(uint(order.getOrderStatus()), 5);
    }

    function test_failCancelledStateInDeliveredState() public {
        _getIntoDeliveredState();
        vm.prank(HACKER);
        vm.expectRevert();
        order.cancelOrder();
    }

    function _getIntoVerifyingState() internal {
        assertEq(uint(order.getOrderStatus()), 0);
        vm.prank(SELLER);
        order.verifyOrderBySeller(true);
        vm.prank(SHIPPER);
        order.verifyOrderByShipper(true);
        assertEq(uint(order.getOrderStatus()), 1);
    }

    function _getIntoPaidState() internal {
        _getIntoVerifyingState();
        vm.prank(ORACLE_MANAGER);
        oracle.setPaid(address(order), true);
        order.isPaid();
        assertEq(uint(order.getOrderStatus()), 2);
    }

    function _getIntoDeliveredState() internal {
        _getIntoPaidState();
        vm.prank(LONDON_UK);
        order.updateShipment(1680364800);
        vm.prank(SINGAPORE_SG);
        order.updateShipment(1682284800);
        vm.prank(SYDNEY_AU);
        order.updateShipment(1690364800);
        assertEq(uint(order.getOrderStatus()), 3);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title
/// @author

import "./interfaces/IOrder.sol";
import "./Oracle.sol";

contract Order is IOrder {
    address product; // address of the product that is being purchased
    address owner; // buyer of the order
    address seller; // seller of the product
    address shipper; // shipper of the order
    bool isVerifiedBySeller; // whether the seller has verified the order
    bool isVerifiedByShipper; // whether the shipper has verified the order

    uint currentDeliveryPoint; // current delivery point (index)
    uint lastUpdatedAt; // last updated time

    string[] destinations; // delivery points
    address[] intermediaries; // parties involved
    uint[] deliveryDueTimes; // delivery due times
    mapping(address => uint) deliveryTimes; // delivery times

    OrderStatus orderStatus;
    Oracle oracle;

    /// Creating the order
    constructor(
        address _product,
        address _seller,
        address _shipper,
        string[] memory _destinations,
        address[] memory _intermediaries,
        uint[] memory _deliveryDueTimes,
    ) {
        product = _product;
        owner = msg.sender;
        seller = _seller;
        shipper = _shipper;

        if (_destinations.length != _intermediaries.length) {
            revert DestinationsLengthAndIntermediariesLengthNotEqual();
        }

        destinations = _destinations;
        intermediaries = _intermediaries;

        if (_destinations.length != _deliveryDueTimes.length) {
            revert DestinationsLengthAndDeliveryDueTimesLengthNotEqual();
        }

        orderStatus = OrderStatus.CREATED;
    }

    /// Verify the order
    function verifyOrderBySeller(
        bool inStock
    ) external onlySeller onlyOrderCreatedState {
        if (inStock == false) {
            orderStatus = OrderStatus.CANCELLED;
            return;
        }

        isVerifiedBySeller = true;

        if (isVerifiedByShipper == true) {
            orderStatus = OrderStatus.VERIFIED;
        }
    }

    function verifyOrderByShipper(
        bool rightDestinations
    ) external onlyShipper onlyOrderCreatedState {
        if (rightDestinations == false) {
            orderStatus = OrderStatus.CANCELLED;
            return;
        }

        isVerifiedByShipper = true;

        if (isVerifiedBySeller == true) {
            orderStatus = OrderStatus.VERIFIED;
        }
    }

    /// Order being paid
    function isPaid() external onlyOrderVerifiedState returns (bool) {
        // call oracle functions
        if (oracle.isPaid(address(this)) == false) {
            return false;
        } else {
            orderStatus = OrderStatus.PAID;
            return true;
        }
    }

    /// Deliver the order
    function updateShipment(uint timestamp) external {
        if (orderStatus == OrderStatus.PAID) {
            // check if this is the first shipment
            if (intermediaries[0] != msg.sender) {
                revert UnauthorizedAccess();
            }
            orderStatus = OrderStatus.DELIVERED;
        } else if (orderStatus == OrderStatus.DELIVERED) {
            if (currentDeliveryPoint >= destinations.length) {
                revert OrderAlreadyDelivered();
            }
            if (intermediaries[currentDeliveryPoint] != msg.sender) {
                revert UnauthorizedAccess();
            }
        } else {
            revert IncorrectOrderStatusState();
        }

        ++currentDeliveryPoint;
        lastUpdatedAt = timestamp;
        emit UpdatedShipment(destinations[currentDeliveryPoint], timestamp);
    }

    /// Verify the receipt
    function verifyReceipt() external onlyOwner onlyOrderDeliveredState {
        orderStatus = OrderStatus.RECEIVED;
    }

    /// Emergency to cancel the orders
    function cancelOrder() external {
        if (
            msg.sender == owner || msg.sender == seller || msg.sender == shipper
        ) {
            orderStatus = OrderStatus.CANCELLED;
        } else {
            revert UnauthorizedAccess();
        }
    }

    // Get the status of the order
    function getOrderStatus() external view returns (OrderStatus) {
        return orderStatus;
    }

    function getIsVerifiedBySeller() external view returns (bool) {
        return isVerifiedBySeller;
    }

    function getIsVerifiedByShipper() external view returns (bool) {
        return isVerifiedByShipper;
    }

    // Get the current delivery point
    function getCurrentDeliveryPoint() external view returns (string memory) {
        return destinations[currentDeliveryPoint];
    }

    // Get the last updated time
    function getLastUpdatedAt() external view returns (uint) {
        return lastUpdatedAt;
    }

    // Get the delivery points
    function getDeliveryPoints() external view returns (string[] memory) {
        return destinations;
    }

    // Get the intermediaries
    function getIntermediaries() external view returns (address[] memory) {
        return intermediaries;
    }

    // Get the delivery due times
    function getDeliveryDueTimes() external view returns (uint[] memory) {
        return deliveryDueTimes;
    }

    // Get the delivery times
    function getDeliveryTimes() external view returns (uint[] memory) {
        uint[] memory times = new uint[](intermediaries.length);
        for (uint i = 0; i < intermediaries.length; ++i) {
            times[i] = deliveryTimes[intermediaries[i]];
        }
        return times;
    }

    // modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert UnauthorizedAccess();
        }
        _;
    }

    modifier onlySeller() {
        if (msg.sender != seller) {
            revert UnauthorizedAccess();
        }
        _;
    }

    modifier onlyShipper() {
        if (msg.sender != shipper) {
            revert UnauthorizedAccess();
        }
        _;
    }

    // order states
    modifier onlyOrderCreatedState() {
        if (orderStatus != OrderStatus.CREATED) {
            revert OrderNotCreatedState();
        }
        _;
    }

    modifier onlyOrderVerifiedState() {
        if (orderStatus != OrderStatus.VERIFIED) {
            revert OrderNotVerifiedState();
        }
        _;
    }

    modifier onlyOrderPaidState() {
        if (orderStatus != OrderStatus.PAID) {
            revert OrderNotPaidState();
        }
        _;
    }

    modifier onlyOrderDeliveredState() {
        if (orderStatus != OrderStatus.DELIVERED) {
            revert OrderNotDelivered();
        }
        _;
    }
}

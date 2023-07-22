// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// interface of the Order contract
interface IOrder {
    enum OrderStatus {
        CREATED, // created by the buyer
        VERIFIED, // verified by both seller (in stocks) and shiper (right destinations)
        PAID, // order has been paid
        DELIVERED, // order has been delivered
        RECEIVED, // order has been received by the buyer
        CANCELLED // order has been cancelled
    }

    // Errors
    error OrderNotCreatedState();
    error OrderNotVerifiedState();
    error OrderNotPaidState();
    error OrderNotDelivered();
    error OrderAlreadyDelivered();
    error IncorrectOrderStatusState();

    error DestinationsLengthAndIntermediariesLengthNotEqual();
    error DestinationsLengthAndDeliveryDueTimesLengthNotEqual();
    error UnauthorizedAccess();

    // Events
    event UpdatedShipment(string place, uint timestamp);

    // Functions

    // Verify the order
    function verifyOrderBySeller(bool) external;

    function verifyOrderByShiper(bool) external;

    // check if the order has been paid
    function isPaid() external returns (bool);

    // update shipment
    function updateShipment(uint) external;

    // The party receiving the product at a location should call this function before taking physical control of goods.
    function verifyReceipt() external;

    // status is the where the order is at and when
    function getOrderStatus() external returns (OrderStatus);

    // get the current delivery point
    function getCurrentDeliveryPoint() external returns (string memory);

    // get the last updated time
    function getLastUpdatedAt() external returns (uint);

    // get the delivery points
    function getDeliveryPoints() external returns (string[] memory);

    // get the intermediaries involved
    function getIntermediaries() external returns (address[] memory);

    // get the delivery due times
    function getDeliveryDueTimes() external returns (uint[] memory);

    // get the delivery times
    function getDeliveryTimes() external returns (uint[] memory);
}

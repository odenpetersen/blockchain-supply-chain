// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

/// @title The interface of the Order contract
/// @author Amos Tan, Oden Petersen (COMP6452 2023T2 Group 22)
interface IOrder {
    /// @notice order status of an order
    enum OrderStatus {
        CREATED, // created by the buyer
        VERIFIED, // verified by both seller (in stocks) and shipper (right destinations)
        PAID, // order has been paid
        DELIVERING, // order is delivering
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
    error IncorrectTimestamp();

    // Events
    /// @notice event emitted when the order is updated by the delivery point centres
    event ShipmentUpdated(uint timestamp, string place);

    // Functions
    /// @notice Verify the order by the seller
    function verifyOrderBySeller(bool) external;

    /// @notice Verify the order by the shipper
    function verifyOrderByShipper(bool) external;

    /// @notice check if the order has been paid
    function isPaid() external returns (bool);

    /// @notice update shipment by the delivery point centres
    function updateShipment(uint) external;

    /// @notice buyer acknowledges that they have received the order and verify the receipt
    function verifyReceipt() external;

    /// @notice get the order status
    function getOrderStatus() external returns (OrderStatus);

    /// @notice get status whether the order is verified by the seller
    function getIsVerifiedBySeller() external returns (bool);

    /// @notice get status whether the order is verified by the shipper
    function getIsVerifiedByShipper() external returns (bool);

    /// @notice get the current delivery point
    function getCurrentDeliveryPoint() external returns (string memory);

    /// @notice get the last updated time
    function getLastUpdatedAt() external returns (uint);

    /// @notice get the delivery points
    function getDeliveryPoints() external returns (string[] memory);

    /// @notice get the intermediaries involved
    function getIntermediaries() external returns (address[] memory);

    /// @notice get the delivery due times
    function getDeliveryDueTimes() external returns (uint[] memory);

    /// @notice get the delivery times
    function getDeliveryTimes() external returns (uint[] memory);
}

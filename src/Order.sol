// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "./interfaces/IOrder.sol";
import "./Oracle.sol";

/// @title The order contract
/// @author Amos Tan, Oden Peterson (COMP6452 2023T2 Group 22)
/// @notice Here is the flow to use this contract:
/// 1. Buyer creates an order
/// 2. Seller and Shipper verifies the order (order does not matter)
/// 3. Check if the order is paid by the buyer by verifying with the oracle contract
/// 4. The intermediaries update the shipment
/// 5. Buyer verifies the receipt
/// Note that Buyer, Seller, Shipper can cancels the order at any time
contract Order is IOrder {
    /** STATE variables */
    address product; // address of the product that is being purchased
    address owner; // buyer of the order
    address seller; // seller of the product
    address shipper; // shipper of the order, e.g. DHL, Fedex
    bool isVerifiedBySeller; // whether the seller has verified the order
    bool isVerifiedByShipper; // whether the shipper has verified the order

    uint currentDeliveryPoint; // current delivery point (represented by index)
    uint lastUpdatedAt; // last updated time

    string[] destinations; // delivery points (London, UK, Singapore, SG, etc.)
    address[] intermediaries; // delivery point centres' addresses (Fedex at UK, DHL at SG, etc.)
    uint[] deliveryDueTimes; // delivery due times represented by epoch (2023-08-01T00:00:00Z, 2023-08-11T00:00:00Z, etc.)
    mapping(address => uint) deliveryTimes; // delivery times represented by epoch

    OrderStatus orderStatus; // status of the order
    Oracle oracle; // oracle of the order which verifies whether the order is being paid

    /** MODIFIERS */
    /// @notice modifier to check if the caller is the owner aka buyer
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert UnauthorizedAccess();
        }
        _;
    }

    /// @notice modifier to check if the caller is the seller of the product
    modifier onlySeller() {
        if (msg.sender != seller) {
            revert UnauthorizedAccess();
        }
        _;
    }

    /// @notice modifier to check if the caller is the shipper of the order
    modifier onlyShipper() {
        if (msg.sender != shipper) {
            revert UnauthorizedAccess();
        }
        _;
    }

    /// @notice modifier to check if the order is in created state
    modifier onlyOrderCreatedState() {
        if (orderStatus != OrderStatus.CREATED) {
            revert OrderNotCreatedState();
        }
        _;
    }

    /// @notice modifier to check if the order is in verified state
    modifier onlyOrderVerifiedState() {
        if (orderStatus != OrderStatus.VERIFIED) {
            revert OrderNotVerifiedState();
        }
        _;
    }

    /// @notice modifier to check if the order is in paid state
    modifier onlyOrderPaidState() {
        if (orderStatus != OrderStatus.PAID) {
            revert OrderNotPaidState();
        }
        _;
    }

    /// @notice modifier to check if the order is in delivered state
    modifier onlyOrderDeliveringState() {
        if (orderStatus != OrderStatus.DELIVERING) {
            revert OrderNotDelivered();
        }
        _;
    }

    /** CREATED STATE function */
    /// @notice Creating an order
    /// @param _product the address of the product that is being purchased
    /// @param _seller the address of the seller of the product
    /// @param _shipper the address of the shipper of the order
    /// @param _oracle the address of the oracle contract
    /// @param _destinations the delivery points
    /// @param _intermediaries the parties involved
    /// @param _deliveryDueTimes the delivery due times
    constructor(
        address _product,
        address _seller,
        address _shipper,
        address _oracle,
        string[] memory _destinations,
        address[] memory _intermediaries,
        uint[] memory _deliveryDueTimes
    ) {
        product = _product;
        owner = msg.sender;
        seller = _seller;
        shipper = _shipper;
        oracle = Oracle(_oracle);

        if (_destinations.length != _intermediaries.length) {
            revert DestinationsLengthAndIntermediariesLengthNotEqual();
        }

        if (_destinations.length != _deliveryDueTimes.length) {
            revert DestinationsLengthAndDeliveryDueTimesLengthNotEqual();
        }

        destinations = _destinations;
        intermediaries = _intermediaries;
        deliveryDueTimes = _deliveryDueTimes;
        orderStatus = OrderStatus.CREATED;
    }

    /** VERIFIED STATE functions */
    /// @notice Verify the order by the seller (only can be done in created state)
    /// @param inStock whether the product is in stock
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

    /// @notice Verify the order by the shipper (only can be done in created state)
    /// @param rightDestinations whether the delivery points are right
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

    /** PAID STATE function */
    /// @notice Check if the order is paid by the buyer (only can be done in verified state)
    /// @dev call the oracle contract to check if the order is paid
    /// @return whether the order is paid
    function isPaid() external onlyOrderVerifiedState returns (bool) {
        // call oracle functions
        if (oracle.isPaid(address(this)) == false) {
            return false;
        } else {
            orderStatus = OrderStatus.PAID;
            return true;
        }
    }

    /** DELIVERING STATE function */
    /// @notice Update the shipment by the delivery point centres (only can be done in paid state)
    ///         Only can be called the delivery point centres' addresses
    /// @param timestamp the timestamp of the delivery
    function updateShipment(uint timestamp) external {
        if (orderStatus == OrderStatus.PAID) {
            // check if this is the first shipment
            if (intermediaries[0] != msg.sender) {
                revert UnauthorizedAccess();
            }
            orderStatus = OrderStatus.DELIVERING;
        } else if (orderStatus == OrderStatus.DELIVERING) {
            if (timestamp <= lastUpdatedAt) {
                revert IncorrectTimestamp();
            }

            if (currentDeliveryPoint >= destinations.length) {
                revert OrderAlreadyDelivered();
            }
            if (intermediaries[currentDeliveryPoint] != msg.sender) {
                revert UnauthorizedAccess();
            }
        } else {
            revert IncorrectOrderStatusState();
        }

        emit ShipmentUpdated(timestamp, destinations[currentDeliveryPoint]);
        deliveryTimes[msg.sender] = timestamp; // update the delivery time 
        ++currentDeliveryPoint;
        lastUpdatedAt = timestamp;
    }

    /** RECEIVED STATE function */
    /// @notice Buyer acknowledges that they have received the order and verify the receipt (only can be done in delivered state)
    function verifyReceipt() external onlyOwner onlyOrderDeliveringState {
        orderStatus = OrderStatus.RECEIVED;
    }

    /** CANCELLED STATE function */
    /// @notice Buyer/Seller/Shipper could make an emergency cancellation of the order at any time
    function cancelOrder() external {
        if (
            msg.sender == owner || msg.sender == seller || msg.sender == shipper
        ) {
            orderStatus = OrderStatus.CANCELLED;
        } else {
            revert UnauthorizedAccess();
        }
    }

    /** GETTER functions */
    /// @notice Get the order status of the order
    /// @return the order status
    function getOrderStatus() external view returns (OrderStatus) {
        return orderStatus;
    }

    /// @notice Get the status whether the order is verified by the seller
    /// @return whether the order is verified by the seller
    function getIsVerifiedBySeller() external view returns (bool) {
        return isVerifiedBySeller;
    }

    /// @notice Get the status whether the order is verified by the shipper
    /// @return whether the order is verified by the shipper
    function getIsVerifiedByShipper() external view returns (bool) {
        return isVerifiedByShipper;
    }

    /// @notice Get the current delivery point
    /// @dev if currentDeliveryPoint is 0, then it is the first delivery point
    ///      else it is the last delivery point which is updated
    /// @return the current delivery point (in string format)
    function getCurrentDeliveryPoint() external view returns (string memory) {
        return (
            currentDeliveryPoint == 0
                ? destinations[currentDeliveryPoint]
                : destinations[currentDeliveryPoint - 1]
        );
    }

    /// @notice Get the last updated time
    /// @return the last updated time (in epoch format)
    function getLastUpdatedAt() external view returns (uint) {
        return lastUpdatedAt;
    }

    /// @notice Get the delivery points
    /// @return the delivery points 
    function getDeliveryPoints() external view returns (string[] memory) {
        return destinations;
    }

    /// @notice Get the delivery point centres' addresses
    /// @return the delivery point centres' addresses
    function getIntermediaries() external view returns (address[] memory) {
        return intermediaries;
    }

    /// @notice Get the delivery due times
    /// @return the delivery due times (in an array with epoch format)
    function getDeliveryDueTimes() external view returns (uint[] memory) {
        return deliveryDueTimes;
    }

    /// @notice Get the delivery times
    /// @return the delivery times (in an array with epoch format)
    function getDeliveryTimes() external view returns (uint[] memory) {
        uint[] memory times = new uint[](intermediaries.length);
        for (uint i = 0; i < intermediaries.length; ++i) {
            times[i] = deliveryTimes[intermediaries[i]];
        }
        return times;
    }
}

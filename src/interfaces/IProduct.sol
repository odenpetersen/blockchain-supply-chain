// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

/// @title A product contract where seller could list their items in the marketplace
/// @author Amos Tan, Oden Peterson (COMP6452 2023T2 Group 22)
interface IProduct {
    /// @notice Get the SKU of the product
    function getSku() external view returns (string memory);

    /// @notice Get the address of the seller of the product
    function getSeller() external view returns (address);

    /// @notice Get the name of the product
    function getName() external view returns (string memory);

    /// @notice Get the price per unit of the product
    function getPricePerUnit() external view returns (uint);

    /// @notice Get the decimals of the price per unit of the product for accuracy
    function getDecimals() external view returns (uint);

    /// @notice Get the quantity of the product to be sold
    function getQuantity() external view returns (uint);

    /// @notice Get the description of the product
    function getDescription() external view returns (string memory);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "./interfaces/IProduct.sol";

/// @title A product contract where seller could list their items in the marketplace
/// @author Amos Tan, Oden Peterson (COMP6452 2023T2 Group 22)
/// @notice This contract is deployed by the seller and is used to list their products in the marketplace
contract Product is IProduct {
    string sku; // stock keeping unit
    address seller; // seller address
    string name; // name of the product
    uint pricePerUnit; // price in USD
    uint decimals; // decimals for price accuracy
    uint quantity; // quantity to buy in bulk
    string description; // description, e.g. expiry date

    /// @notice constructor to create a product
    /// @param _sku stock keeping unit
    /// @param _name name of the product
    /// @param _pricePerUnit price in USD
    /// @param _decimals decimals for price accuracy
    /// @param _quantity quantity to sell in bulk
    /// @param _description including expiry date
    constructor(
        string memory _sku,
        string memory _name,
        uint _pricePerUnit,
        uint _decimals,
        uint _quantity,
        string memory _description
    ) {
        sku = _sku;
        seller = msg.sender;
        name = _name;
        pricePerUnit = _pricePerUnit;
        decimals = _decimals;
        quantity = _quantity;
        description = _description;
    }

    /// @notice get the sku of the product
    /// @return sku of the product
    function getSku() external view override returns (string memory) {
        return sku;
    }

    /// @notice get the seller address of the product
    /// @return the address of seller of the product
    function getSeller() external view override returns (address) {
        return seller;
    }

    /// @notice get the name of the product
    /// @return the name of the product
    function getName() external view override returns (string memory) {
        return name;
    }

    /// @notice get the price per unit of the product
    /// @return the price per unit of the product
    function getPricePerUnit() external view override returns (uint) {
        return pricePerUnit;
    }

    /// @notice get the decimals of the product to calculate the price per unit accurately
    /// @return the decimals of the product price
    function getDecimals() external view override returns (uint) {
        return decimals;
    }

    /// @notice get the quantity of the product
    /// @return the quantity of the product
    function getQuantity() external view override returns (uint) {
        return quantity;
    }

    /// @notice get the description of the product
    /// @return the description of the product
    function getDescription() external view override returns (string memory) {
        return description;
    }
}

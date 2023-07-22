// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title
/// @author

import "./interfaces/IProduct.sol";

contract Product is IProduct {
    string sku; // stock keeping unit

    address seller; // seller address
    string name; // name of the product
    uint pricePerUnit; // price in USD
    uint decimals; // decimals for price accuracy
    uint quantity; // quantity to buy in bulk
    string description; // including expiry date

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

    function getSku() external view override returns (string memory) {
        return sku;
    }

    function getSeller() external view override returns (address) {
        return seller;
    }

    function getName() external view override returns (string memory) {
        return name;
    }

    function getPricePerUnit() external view override returns (uint) {
        return pricePerUnit;
    }

    function getDecimals() external view override returns (uint) {
        return decimals;
    }

    function getQuantity() external view override returns (uint) {
        return quantity;
    }

    function getDescription() external view override returns (string memory) {
        return description;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title
/// @author

interface IProduct {
    function getSku() external view returns (string memory);

    function getSeller() external view returns (address);

    function getName() external view returns (string memory);

    function getPricePerUnit() external view returns (uint);

    function getDecimals() external view returns (uint);

    function getQuantity() external view returns (uint);

    function getDescription() external view returns (string memory);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

/// @title
/// @author

interface IOracle {
    function setPaid(address, bool) external;

    function isPaid(address) external returns (bool);
}

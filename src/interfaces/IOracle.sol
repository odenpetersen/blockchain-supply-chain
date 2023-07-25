// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

/// @title The interface of the oracle contract where the oracle manager could update the paid status of the order
/// @author Amos Tan, Oden Peterson (COMP6452 2023T2 Group 22)
interface IOracle {
    /// @notice set the paid status of the order
    function setPaid(address, bool) external;

    /// @notice get the paid status of the order
    function isPaid(address) external returns (bool);
}

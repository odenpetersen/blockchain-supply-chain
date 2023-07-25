// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "./interfaces/IOracle.sol";

/// @title An oracle contract where the oracle manager could update the paid status of the order
/// @author Amos Tan, Oden Peterson (COMP6452 2023T2 Group 22)
/// @notice This contract is used to update the paid status of the order
contract Oracle is IOracle {
    address manager; // the manager of the oracle / owner of this contract
    mapping(address => bool) contractsPaid; // mapping of contracts to paid status

    /// @notice modifier to check if the caller is the manager
    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Can only be executed by the oracle manager"
        );
        _;
    }

    /// @notice initialization of the oracle to set the owner of this contract as manager
    constructor() {
        manager = msg.sender;
    }

    /// @notice set the paid status of the order (only manager can do this)
    /// @param contractAddress the address of the order contract
    /// @param _isPaid the paid status of the order
    function setPaid(
        address contractAddress,
        bool _isPaid
    ) external onlyManager {
        contractsPaid[contractAddress] = _isPaid;
    }

    /// @notice get the paid status of the order
    /// @param contractAddress the address of the order contract
    /// @return the paid status of the order
    function isPaid(address contractAddress) external view returns (bool) {
        return contractsPaid[contractAddress];
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title
/// @author

contract Oracle {
    address manager;
    mapping(address => bool) contractsPaid;

    constructor() {
        manager = msg.sender;
    }

    function hasPaid(address contractAddress) external onlyManager {
        contractsPaid[contractAddress] = true;
    }

    function isPaid(address contractAddress) external view returns (bool) {
        return contractsPaid[contractAddress];
    }

    /**
     * @notice Only the manager can do
     */
    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Can only be executed by the oracle manager"
        );
        _;
    }
}

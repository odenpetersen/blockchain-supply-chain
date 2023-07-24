// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

/// @title
/// @author

import "./interfaces/IOracle.sol";

contract Oracle is IOracle {
    address manager;
    mapping(address => bool) contractsPaid;

    constructor() {
        manager = msg.sender;
    }

    function setPaid(
        address contractAddress,
        bool _isPaid
    ) external onlyManager {
        contractsPaid[contractAddress] = _isPaid;
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

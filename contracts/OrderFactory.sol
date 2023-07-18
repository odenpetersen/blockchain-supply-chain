// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title Contract to agree on the lunch venue
/// @author Dilum Bandara , CSIRO ’s Data61

contract OrderFactory {
	address purchaser;
	address productInstance;
	address intermediaries[];
	string destinations[];

	/**
	* @dev Construct
	*/
	constructor() {
	}

	/**
	* @notice 
	* @dev 
	*
	* @param name Description
	* @return Description
	*/
	function getStatus(string memory name) public restricted returns ( uint ){
	}

	/**
	* @notice 
	* @dev 
	*
	* @param name Description
	* @return Description
	*/
	function lastUpdatedAt(string memory name) public restricted returns ( uint ){
	}

	/**
	* @notice 
	* @dev 
	*
	* @param name Description
	* @return Description
	*/
	function getDeliveryPoints(string memory name) public restricted returns ( uint ){
	}

	/**
	* @notice Only the manager can do
	*/
	modifier restricted() {
		require ( msg.sender == manager , "Can only be executed by the manager");
		_;
	}
}


// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title 
/// @author 

/*
Buyer address
Product instance address
Product details 
Delivery details 
* Delivery status/shipAt: string (which city the shipment is at eg. Sydney, Australia) 
* lastUpdatedAt: int (epoch)
* Delivery points: string[] (cities the shipment passed through)
* Addresses: address[] (which respective to destination points)

Example: 
A (supplier), B, C, D, E
UK -> India -> Singapore -> Indonesia -> Aus
*/

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


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
	address[] intermediaries;
	string[] destinations;
	address manager;

	/**
	* @dev Construct
	*/
	constructor() {
		manager = msg.sender;
	}


	/**
	* @notice Only the manager can do
	*/
	modifier restricted() {
		require ( msg.sender == manager , "Can only be executed by the manager");
		_;
	}
}


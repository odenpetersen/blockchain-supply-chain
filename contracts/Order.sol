// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title 
/// @author 

/*
Verify order
Record deliveries or cancellations
Record offchain payments via oracle (eg trusted bank(s))
Get delivery status
Update delivery status (where it is at, when)
*/
contract Order {
	int delivery_point_ids[];
	int current_delivery_point;
	int last_updated_time;
	mapping(int => string) delivery_point_names;
	mapping(int => address) parties;
	mapping(int => int) delivery_due_times;
	mapping(int => int) delivery_times;
	Oracle oracle;

	/**
	* @dev Construct
	*/
	constructor() {
	}

	function isPaidFor() public returns ( bool ) {
		//Consult oracle
	}

	/**
	* @notice 
	* @dev 
	*
	* @param name Description
	* @return Description
	*/
	function isDelivered() public returns ( bool ){
	}

	function isPaidFor() public returns ( bool ) {
		//Check if address(this) in oracle's list
	}

	//The party receiving the product at a location should call this function before taking physical control of goods.
	function verifyReceipt() public {

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

	//TODO: Getter Functions for all attributes
}


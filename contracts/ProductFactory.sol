// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title 
/// @author 

/*
amount
Name
Product Instance inherits Product
Price
Origin (where stocks at)
Expiry date 
*/
contract ProductFactory {
	string name;

	/**
	* @dev Construct
	*/
	constructor(string memory name) {
		manager = msg.sender;
	}

	/**
	* @notice Creates a new product of this type. The product should be an NFT.
	* @dev 
	*
	* @param name Description
	* @return Description
	*/
	function instantiate(string memory name) public restricted returns ( uint ){
	}
}


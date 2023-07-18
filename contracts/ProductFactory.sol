// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title Contract to agree on the lunch venue
/// @author Dilum Bandara , CSIRO ’s Data61

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


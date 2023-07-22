// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import './Product.sol';

/// @title 
/// @author 

contract ProductFactory {
	Product[] products;
	/**
	* @dev Construct
	*/
	constructor() {
		manager = msg.sender;
	}

	/**
	* @notice Creates a new product of this type. The product should be an NFT.
	* @dev 
	*
	* @param name Description
	* @return Description
	*/
	function instantiate(string memory name) public returns ( Product ){
	}
}

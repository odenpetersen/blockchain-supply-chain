// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title 
/// @author 

contract Oracle {
	address manager;
	address contracts_paid[];

	constructor() {
	}

	
	/**
	* @notice Only the manager can do
	*/
	modifier restricted() {
		require ( msg.sender == manager , "Can only be executed by the manager");
		_;
	}
}


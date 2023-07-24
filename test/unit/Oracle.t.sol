// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Oracle} from "../../src/Oracle.sol";

contract OracleTest is Test {
    Oracle oracle;

    address public ANON = makeAddr("anonymous");

    function setUp() public {
        oracle = new Oracle();
    }

    function test_isPaid() public {
        assertEq(oracle.isPaid(address(this)), false);
    }

    function test_setPaid() public {
        oracle.setPaid(address(this), true);
        assertEq(oracle.isPaid(address(this)), true);
    }

    function testFail_setPaid() public {
        vm.prank(ANON);
        oracle.setPaid(address(this), true);
    }
}

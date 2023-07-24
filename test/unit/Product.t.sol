// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Product} from "../../src/Product.sol";

contract ProductTest is Test {
    Product product;
    address public SELLER = makeAddr("seller");

    function test_productAttributes() public {
        vm.prank(SELLER);
        product = new Product(
            "12345678",
            "100 boxes of Milk",
            100,
            2,
            10,
            "100 boxes of Milk expires on 2023-08-01"
        );
        assertEq(product.getSku(), "12345678");
        assertEq(product.getSeller(), SELLER);
        assertEq(product.getName(), "100 boxes of Milk");
        assertEq(product.getPricePerUnit(), 100);
        assertEq(product.getDecimals(), 2);
        assertEq(product.getQuantity(), 10);
        assertEq(
            product.getDescription(),
            "100 boxes of Milk expires on 2023-08-01"
        );
    }
}

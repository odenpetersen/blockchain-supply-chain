pragma solidity >= 0.8.0;

contract HelloWorld {
    function sayHello(string memory extra) public pure returns (string memory) {
        return extra;
    }
}

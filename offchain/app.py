#!/usr/bin/env python3
from contracts import contracts

#Oracle.sol		Order.sol		OrderFactory.sol	Product.sol		ProductFactory.sol	ProductInstance.sol

#1. List product
#2. Compute route
#3. Place an order
#4. Oracle processes payment
#5. Verify payment
#6. Verify deliveries
#7. Generate reputation statistics


# Call contract function (this is not persisted to the blockchain)
message = contracts.HelloWorld.sayHello("hello").call()

print(message)

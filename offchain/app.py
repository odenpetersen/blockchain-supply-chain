#!/usr/bin/env python3
import routing
from termcolor import colored
from oracle import Bank
comment = lambda x : print(colored(x,'yellow'))
result = lambda x : print(colored(x,'green'))
error = lambda x : print(colored(x,'red'))

#0. Set up accounts
#alias 
#1. List product
#product
#2. Compute route
#3. Place an order
#order
#4. Oracle processes payment
#deposit
#pay
#5. Verify payment
#
#6. Verify deliveries
#7. Generate reputation statistics

commands = dict()
def com(func):
    commands[func.__name__] = func
    return func

def console():
    while True:
        try:
            command = input("cli > ")
            if command == '':
                continue
            if command == 'continue':
                return
            command,*arguments = command.split(' ')
            commands[command](*arguments)
        except Exception as e:
            error(e)

@com
def run(filename):
    comment(f"Running '{filename}'. Press return after each command execution to continue. Enter 'i' after a command to interject.")
    with open(filename) as f:
        lines = f.read().split('\n')[:-1]
    for command in lines:
        print(f"{filename} > " + command)
        if command.startswith('#'):
            continue
        command,*arguments = command.split(' ')
        commands[command](*arguments)
        if input() == 'i':
            comment("To resume execution, enter 'continue'.")
            console()

@com
def help():
    result(list(commands.keys()))

@com
def frs():
    pass

@com
def nfrs():
    pass

aliases = dict()
@com
def alias(name, public_key, private_key=None):
    comment(f"Storing account details as {name} for convenient use later.")
    accounts[name] = {'private_key' : private_key, 'address' : public_key}

@com
def product(name, sku, unit_price, quantity):
    comment("Deploying an instance of the Product contract.")
    address = None
    result(f"Deployed at {address}.")
    return address

@com
def product_details(product):
    comment(f"Looking up {product} address in alias dictionary.")
    product = aliases[product]['address']
    comment(f"Calling the getter methods of the Product contract instance at {product}.")
    #SKU, seller, name, pricePerUnit, decimals, quantity, description

@com
def order_details(order):
    if order in aliases:
        comment(f"Looking up {order} address in alias dictionary.")
        order = aliases[order]['address']
    comment(f"Calling the getter methods of the Product contract instance at {order}.")
    #SKU, seller, name, pricePerUnit, decimals, quantity, description


@com
def route(origin, destination):
    comment("Using the weighted BFS implementation in routing.py to compute the geographically optimal route. This is offchain.")
    places_list = routing.route(origin,destination)
    result(f"The optimal route to take would be {places_list}. This would take approximately {routing.estimate_days(places_list)} days.")
    return places_list

@com
def order(product_address, buyer, seller, product, origin, destination):
    places_list = route(origin,destination)
    comment(f"Looking up {buyer,seller,product} addresses in alias dictionary.")
    buyer, seller, product = aliases[buyer], aliases[seller], aliases[product]
    result(f"{buyer}\n{seller}\n{product}")
    comment(f"Deploying new instance of Order contract on chain.")
    address = None
    result(f"Deployed at {address}.")

def deploy(contract_name, sender_account, *constructor_arguments):
    pass

bank = Bank("Global Bank")
@com
def open_bank_account(username, password):
    pass

@com
def transfer_funds():
    pass

if __name__ == "__main__":
    console()

#!/usr/bin/env python3
import routing
import json
import time
from web3 import Web3, HTTPProvider
from printing import comment,result,error

from oracle import Bank
from chain import deploy,transact,call

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
#5. Verify deliveries
#6. Generate reputation statistics

commands = dict()
helpdocs = dict()
def com(helpdoc):
    def deco(func):
        helpdocs[func.__name__] = helpdoc
        commands[func.__name__] = func
        return func
    return deco

def run_command(command):
    try:
        if command == '':
            return
        elif command == 'continue':
            return 'continue'
        elif command.startswith('#'):
            return
        elif command == 'break':
            if input() == 'i':
                comment("To resume execution, enter 'continue'.")
                console()
        elif command == 'i':
            comment("To resume execution, enter 'continue'.")
            console()
        else:
            command,*arguments = command.split(' ')
            commands[command](*arguments)
    except Exception as e:
        error(e)
        

def console():
    while True:
        command = input("cli > ")
        if run_command(command) == 'continue':
            return

@com("Runs a file (e.g. 'run demo/all' to run demo) with CLI commands. Usage: run [filepath]")
def run(filename):
    comment(f"Running '{filename}'. Press return after each command execution to continue. Enter 'i' after a command to interject.")
    with open(filename) as f:
        lines = f.read().split('\n')[:-1]
    for command in lines:
        print(f"{filename} > {command}")
        if run_command(command) == 'continue':
            return

@com("Gets help. Usage 1: help; Usage 2: help [command]")
def help(fn=None):
    if fn is None:
        result(list(commands.keys()))
    else:
        result(helpdocs[fn])

def resolve_alias(account):
    if isinstance(account,str) and account in aliases:
        account = aliases[account]
    return account

aliases = dict()
@com("Creates a human-readable name for a public/private keypair. Usage 1: alias [name] [public_key]; Usage 2: alias [name] [public_key] [private_key]")
def alias(name, public_key, private_key=None):
    comment(f"Storing account details as {name} for convenient use later.")
    aliases[name] = {'private_key' : private_key, 'address' : Web3.to_checksum_address(public_key)}

@com("Deploys a product contract instance. Usage: product [seller] [name] [sku] [unit_price] [quantity] [description]")
def product(seller, name, sku, unit_price, quantity, description):
    decimals = 2
    unit_price_cents = int(float(unit_price) * (10**decimals))
    comment("Deploying an instance of the Product contract.")
    address = deploy('Product', resolve_alias(seller), sku, name, unit_price_cents, decimals, int(quantity), description)
    result(f"Deployed at {address}.")
    return address

intermediaries = dict()
@com("Designates a public/private keypair to be the intermediary for a given delivery location; OR simply returns the intermediary for a given location. Usage 1: intermediary [place] [intermediary]; Usage 2 intermediary [place]")
def intermediary(place, account=None):
    if account is None:
        result(f"Intermediary for {place} has alias {[k for k in aliases if aliases[k]['address'] == intermediaries[place]]}")
    else:
        comment(f"Looking up {account} address in alias dictionary.")
        account = aliases[account]
        intermediaries[place] = account['address']
        result(f"Added {account['address']} as designated intermediary for {place}. This is entirely off-chain.")

@com("Get the details of an instance of the Order contract. Usage: order_details [order_address]")
def order_details(order):
    if order in aliases:
        comment(f"Looking up {order} address in alias dictionary.")
        order = aliases[order]['address']
    comment(f"Calling the getter methods of the Order contract instance at {order}.")

    for method_name in ['getOrderStatus', 'getIsVerifiedBySeller', 'getIsVerifiedByShipper', 'getCurrentDeliveryPoint', 'getLastUpdatedAt', 'getDeliveryPoints', 'getIntermediaries', 'getDeliveryDueTimes', 'getDeliveryTimes']:
        value = call('Order', order, resolve_alias('default'), method_name)
        result(f"{method_name}() == {value}.")

@com("Get the details of an instance of the Product contract. Usage: product_details [product]")
def product_details(product):
    if product in aliases:
        comment(f"Looking up {product} address in alias dictionary.")
        product = aliases[product]['address']
    comment(f"Calling the getter methods of the Product contract instance at {product}.")

    for method_name in ['getSku', 'getSeller', 'getName', 'getPricePerUnit', 'getDecimals', 'getQuantity', 'getDescription']:
        value = call('Product', product, resolve_alias('default'), method_name)
        result(f"{method_name}() == {value}.")

@com("Compute the shortest route between two known cities. Usage: route [origin] [destination]")
def route(origin, destination):
    comment("Using the weighted BFS implementation in routing.py to compute the geographically optimal route. This is offchain.")
    places_list = routing.route(origin,destination)
    result(f"The optimal route to take would be {places_list}. This would take approximately {routing.estimate_days(places_list)} days.")
    return places_list

@com("Deploy an instance of the Order contract. Usage: order [buyer] [seller] [shipper] [product] [origin] [destination] [oracle_address]")
def order(buyer, seller, shipper, product, origin, destination, oracle_address):
    places_list = route(origin,destination)
    for place in places_list:
        if place not in intermediaries:
            raise Exception(f"No intermediary specified for {place}. Please use the command 'intermediary [place] [account]' to specify one.")
    intermediaries_list = [intermediaries[place] for place in places_list]

    comment(f"Looking up {buyer,seller,product} addresses in alias dictionary.")
    buyer, seller, shipper, product = aliases[buyer], aliases[seller], aliases[shipper], aliases[product]
    result(f"{buyer}\n{seller}\n{product}")

    comment(f"Deploying new instance of Order contract on chain.")

    delivery_due_times = [2147483647] * len(places_list)
    address = deploy('Order', buyer, product['address'], seller['address'], shipper['address'], oracle_address, places_list, intermediaries_list, delivery_due_times)
    result(f"Deployed at {address}.")

@com("Verify that a shipper has agreed to the terms of an Order contract instance. Usage: verify_shipper [shipper] [order]")
def verify_shipper(shipper, order):
    comment(f'Verifying shipper agreement ({shipper}) to order contract {order}.')
    transact('Order', order, resolve_alias(shipper), 'verifyOrderByShipper', True)

@com("Verify that a seller has agreed to the terms of an Order contract instance. Usage: verify_seller [seller] [order]")
def verify_seller(seller, order):
    comment(f'Verifying seller agreement ({seller}) to order contract {order}.')
    transact('Order', order, resolve_alias(seller), 'verifyOrderBySeller', True)

bank = Bank("globalbank")

@com("Add a new Oracle contract instance for globalbank and print out its address. Usage: add_oracle")
def add_oracle():
    comment(f'Deploying oracle for {bank.name}.')
    comment(f'Address of {bank.name} is aliases[bank.name].')
    address = bank.add_oracle(resolve_alias(bank.name))
    result(f'Deployed oracle at {address}.')

@com("Open a new bank account at globalbank. Usage: open_bank_account [username] [password]")
def open_bank_account(username, password):
    comment(f'Opening a new bank account {username}.')
    bank.create_account(username,password)

@com("Deposit money into an account at globalbank. Usage: deposit [username] [amount]")
def deposit(username, amount):
    amount = float(amount)
    comment(f'Depositing ${amount} into {username}.')
    bank.deposit(username, amount)

@com("Withdraw money from an account at globalbank. Usage: withdraw [username] [password] [amount]")
def withdraw(username, password, amount):
    amount = float(amount)
    comment(f'Withdrawing ${amount} from {username}.')
    bank.withdraw(username, password, amount)

@com("Transfer money between two accounts at globalbank, and publish a confirmation to a specified oracle. Usage: transfer [username_sender] [password_sender] [username_recipient] [amount] [oracle] [order]")
def transfer(username, password, recipient, amount, oracle, order_id):
    amount = float(amount)
    comment(f'Transferring ${amount} from {username} to {recipient} for order {order_id} and recording on oracle contract at {oracle}.')
    bank.transfer(username, password, recipient, amount, oracle, order_id, resolve_alias(bank.name))

@com("Update an Order contract instance to match the associated Oracle contract. Usage: verify_paid [order]")
def verify_paid(order_address):
    transact('Order', order_address, resolve_alias('default'), 'isPaid')
    result(f'Updated payment status of order.')

@com("Update an Order contract instance to attest delivery of goods to an intermediate point. Usage: receipt_intermediate [order_address] [intermediary]")
def receipt_intermediate(order_address, intermediary_id):
    transact('Order', order_address, resolve_alias(intermediary_id), 'updateShipment', int(time.time()))

@com("Update an Order contract instance to attest delivery of goods to purchaser. Usage: receipt_final [order_address] [buyer]")
def receipt_final(order_address, buyer_id):
    transact('Order', order_address, resolve_alias(buyer_id), 'verifyReceipt')

if __name__ == "__main__":
    console()

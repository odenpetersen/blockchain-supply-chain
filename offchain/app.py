#!/usr/bin/env python3
import routing
import json
from web3 import Web3, HTTPProvider
from termcolor import colored
comment = lambda x : print(colored(x,'yellow'))
result = lambda x : print(colored(x,'green'))
error = lambda x : print(colored(x,'red'))

from oracle import Bank

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
def com(func):
    commands[func.__name__] = func
    return func

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

@com
def run(filename):
    comment(f"Running '{filename}'. Press return after each command execution to continue. Enter 'i' after a command to interject.")
    with open(filename) as f:
        lines = f.read().split('\n')[:-1]
    for command in lines:
        print(f"{filename} > {command}")
        if run_command(command) == 'continue':
            return

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
    aliases[name] = {'private_key' : private_key, 'address' : Web3.to_checksum_address(public_key)}

@com
def product(seller, name, sku, unit_price, quantity, description):
    decimals = 2
    unit_price_cents = int(float(unit_price) * (10**decimals))
    comment("Deploying an instance of the Product contract.")
    address = deploy('Product', seller, sku, name, unit_price_cents, decimals, int(quantity), description)
    result(f"Deployed at {address}.")
    return address

intermediaries = dict()
@com
def intermediary(place, account):
    comment(f"Looking up {account} address in alias dictionary.")
    account = aliases[account]
    intermediaries[place] = account['address']
    result(f"Added {account['address']} as designated intermediary for {place}. This is entirely off-chain.")

@com
def product_details(product):
    comment(f"Looking up {product} address in alias dictionary.")
    product = aliases[product]['address']
    comment(f"Calling the getter methods of the Product contract instance at {product}.")
    raise Exception("unimplemented")
    #SKU, seller, name, pricePerUnit, decimals, quantity, description

@com
def order_details(order):
    if order in aliases:
        comment(f"Looking up {order} address in alias dictionary.")
        order = aliases[order]['address']
    comment(f"Calling the getter methods of the Order contract instance at {order}.")
    raise Exception("unimplemented")

@com
def route(origin, destination):
    comment("Using the weighted BFS implementation in routing.py to compute the geographically optimal route. This is offchain.")
    places_list = routing.route(origin,destination)
    result(f"The optimal route to take would be {places_list}. This would take approximately {routing.estimate_days(places_list)} days.")
    return places_list

@com
def order(buyer, seller, shipper, product, origin, destination):
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
    address = deploy('Order', buyer, product['address'], seller['address'], shipper['address'], places_list, intermediaries_list, delivery_due_times)
    result(f"Deployed at {address}.")

def deploy(contract_name, sender_account, *constructor_arguments):
    network_address = 'http://127.0.0.1:8545/'
    web3 = Web3(HTTPProvider(network_address))

    if isinstance(sender_account,str) and sender_account in aliases:
        sender_account_name = sender_account
        sender_account = aliases[sender_account]
    else:
        sender_account_name = sender_account['address']

    #Get compiled contract code
    contract_json = f'../build/contracts/{contract_name}.json'
    with open(contract_json) as f:
        content = json.load(f)
    contract_obj = web3.eth.contract(abi=content['abi'], bytecode=content['bytecode'])

    comment(f"Signing and deploying {contract_name} to {network_address} from {sender_account}.")
    tx_construct = contract_obj.constructor(*constructor_arguments).build_transaction({'from':sender_account['address'],'nonce': web3.eth.get_transaction_count(sender_account['address'])})
    tx_create = web3.eth.account.sign_transaction(tx_construct, sender_account['private_key'])
    tx_hash = web3.eth.send_raw_transaction(tx_create.rawTransaction)
    tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)

    address = tx_receipt.contractAddress
    result(f"Deployed to {address}.")

    return address

bank = Bank("Global Bank")
@com
def open_bank_account(username, password):
    raise Exception("unimplemented")

@com
def deposit_funds(username, amount):
    raise Exception("unimplemented")

@com
def withdraw_funds(username, password, amount):
    raise Exception("unimplemented")

@com
def transfer():
    raise Exception("unimplemented")

@com
def receipt_intermediate():
    raise Exception("unimplemented")

@com
def receipt_final():
    raise Exception("unimplemented")

if __name__ == "__main__":
    console()

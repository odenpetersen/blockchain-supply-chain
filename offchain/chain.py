from web3 import Web3, HTTPProvider
import json
from printing import comment,result,error

def deploy(contract_name, sender_account, *constructor_arguments):
    network_address = 'http://127.0.0.1:8545/'
    web3 = Web3(HTTPProvider(network_address))

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

def transact(contract_name, contract_address, sender_account, method_name, *arguments):
    network_address = 'http://127.0.0.1:8545/'
    web3 = Web3(HTTPProvider(network_address))

    contract_json = f'../build/contracts/{contract_name}.json'
    with open(contract_json) as f:
        content = json.load(f)
    contract_obj = web3.eth.contract(address=contract_address, abi=content['abi'])

    method_obj = getattr(contract_obj.functions,method_name)
    tx = method_obj(*arguments).build_transaction({'from' : sender_account['address'], 'nonce': web3.eth.get_transaction_count(sender_account['address'])})
    tx_create = web3.eth.account.sign_transaction(tx, sender_account['private_key'])
    tx_hash = web3.eth.send_raw_transaction(tx_create.rawTransaction)
    tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)

    result(f"Transaction recorded at {tx_receipt.transactionHash.hex()}.")
    
def call(contract_name, contract_address, sender_account, method_name, *arguments):
    network_address = 'http://127.0.0.1:8545/'
    web3 = Web3(HTTPProvider(network_address))

    contract_json = f'../build/contracts/{contract_name}.json'
    with open(contract_json) as f:
        content = json.load(f)
    contract_obj = web3.eth.contract(address=contract_address, abi=content['abi'])

    method_obj = getattr(contract_obj.functions,method_name)

    return method_obj(*arguments).call()


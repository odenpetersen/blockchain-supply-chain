

import json
from web3 import Web3, HTTPProvider

blockchain_address = 'http://127.0.0.1:9545'
web3 = Web3(HTTPProvider(blockchain_address))
web3.eth.defaultAccount = web3.eth.accounts[0]

def deploy_contract(contract_name):
    contract_json = f'../build/contracts/{contract_name}.json'
    
    with open(contract_json) as f:
        content = json.load(f)
    abi = content['abi']
    bytecode = content['bytecode']
    
def get_contract(contract_name, contract_address):
    contract_json = f'../build/contracts/{contract_name}.json'

    with open(contract_json) as f:
        content = json.load(f)
    abi = content['abi']

    contract = web3.eth.contract(address=contract_address, abi=abi)

    return contract

contract_addresses = {\
    'HelloWorld' : '0x64942A45C2CC86048a5E783F36D32805920B3712',
}

import json
from web3 import Web3, HTTPProvider

blockchain_address = 'http://127.0.0.1:9545'
web3 = Web3(HTTPProvider(blockchain_address))
web3.eth.defaultAccount = web3.eth.accounts[0]

class Contracts:
    pass

contracts = Contracts()

for contract_name, contract_address in contract_addresses.items():
    contract_json = f'../build/contracts/{contract_name}.json'

    with open(contract_json) as f:
        content = json.load(f)
        abi = content['abi']

    # Fetch deployed contract reference
    contract = web3.eth.contract(address=contract_address, abi=abi)

    setattr(contracts, contract_name, contract.functions)

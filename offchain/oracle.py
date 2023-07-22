#!/usr/bin/env python3

#Check whether the payments have been made
class Bank:
    def __init__(self,name):
        self.name = name
        self.oracles = []
        self.balances = dict()
        self.passwords = dict()

    def add_oracle(self):
        #Launch an oracle contract instance
        raise Exception("unimplemented.")
        self.oracles.append(address)

    def create_account(self,username,password):
        self.balances[username] = 0
        self.passwords[username] = password

    def deposit(self,username,amount):
        if amount > 0 and username in self.balances:
            self.balances[username] += amount

    def withdraw(self,username,password,amount):
        if amount > 0 and username in self.balances and self.balances[username] >= amount and username in self.passwords and self.passwords[username] == password:
            self.balances[user] -= amount

    def transfer(self,username,password,recipient,amount,oracle,order_id):
        if amount > 0 and username in self.balances and self.balances[username] >= amount and username in self.passwords and self.passwords[username] == password and recipient in self.balances:
            if order_id is not None:
                if oracle not in self.oracles:
                    raise Exception("Unknown oracle.")
                #Publish oracle confirmation
                pass
            self.balances[username] -= amount
            self.balances[recipient] += amount

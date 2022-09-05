from brownie import accounts, network, config


def main():
    if network.show_active() == 'development':
        deployer = accounts[0]
        testator = accounts[1]        
        new_beneficiary = accounts[2]
        beneficiaryOfERC721 = accounts[3]
        executor = accounts[4]
        beneficiaries = []
        for i, n in enumerate(config['settings']['shares']):
            beneficiaries.append(accounts[i+5])
    else:
        try:
            # change
            deployer = accounts.add(config['wallets']['deployer'])
            testator = accounts.add(config['wallets']['testator'])            
            new_beneficiary = accounts.add(config['wallets']['new_beneficiary'])
            beneficiaryOfERC721 = accounts.add(config['wallets']['beneficiaryOfERC721'])
            executor = accounts.add(config['wallets']['executor'])
            beneficiaries = [deployer, beneficiaryOfERC721, executor]
        except FileNotFoundError as error:
            print(error, '.env file not found')

    return deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor

from brownie import Willer, config, network
import scripts.get_accounts


def main():
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = scripts.get_accounts.main()
    return Willer.deploy({'from': deployer}, publish_source=config['networks'][network.show_active()]['verify'])

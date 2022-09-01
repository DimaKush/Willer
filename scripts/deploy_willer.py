from brownie import Willer, config, network
from .get_accounts import get_accounts


def main():
    deployer, testator, beneficiary, executor = get_accounts()
    return Willer.deploy({'from': deployer}, publish_source=config['networks'][network.show_active()]['verify'])

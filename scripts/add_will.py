import time
from brownie import Willer, accounts, config, network
import datetime
from ..scripts.get_accounts import get_accounts


def main():
    deployer, testator, beneficiary, executor = get_accounts()
    Willer[-1].addWill(beneficiary,
                        datetime.datetime.timestamp(datetime.datetime.now() + datetime.timedelta(seconds=10)),
                        {'from': testator}
    )



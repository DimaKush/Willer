import time
from brownie import TokenERC20, TokenERC721, TokenERC1155, Willer, accounts, config, network
import datetime
from ..scripts.get_accounts import get_accounts


def main():
    n_contracts = config['n_contracts']
    n_ids = config['n_ids']
    value = config['value']
    deployer, testator, beneficiary = get_accounts()
    time_before_release = Willer[-1].getReleaseTime(testator, beneficiary) - datetime.datetime.timestamp(
        datetime.datetime.now())
    if time_before_release > 0:
        time.sleep(time_before_release)

    Willer[-1].batchRelease(testator,
                            beneficiary,
                            list(TokenERC20),
                            list(TokenERC721),
                            list(TokenERC1155),
                            [list(range(n_ids))] * n_contracts,
                            [list(range(n_ids))] * n_contracts,
                            [[value] * n_ids] * n_contracts, {"gas_limit": 1000000000})
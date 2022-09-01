import time
from brownie import TokenERC20, TokenERC721, TokenERC1155, SimpleWiller, accounts, config, network
import datetime
from ..scripts.get_accounts import get_accounts


def main():
    n_contracts = config['n_contracts']
    n_ids = config['n_ids']
    value = config['value']
    deployer, testator, beneficiary = get_accounts()
    time_before_release = SimpleWiller[-1].getReleaseTime(testator) - datetime.datetime.timestamp(
        datetime.datetime.now())
    if time_before_release > 0:
        time.sleep(time_before_release)
    print(TokenERC20[-1].balanceOf(testator))
    print(TokenERC20[-1].balanceOf(beneficiary))
    SimpleWiller[-1].releaseERC20(testator, TokenERC20[-1])
    print(TokenERC20[-1].balanceOf(testator))
    print(TokenERC20[-1].balanceOf(beneficiary))
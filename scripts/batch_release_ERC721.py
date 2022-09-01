import time
from brownie import TokenERC721, Willer, accounts, config, network
import datetime
from ..scripts.get_accounts import get_accounts

def main():
    n_contracts = config['n_contracts']
    n_ids = config['n_ids']
    value = config['value']
    deployer, testator, beneficiary = get_accounts()
    time_before_release = Willer[-1].getReleaseTime(testator, beneficiary) - datetime.datetime.timestamp(datetime.datetime.now())
    print(TokenERC721[-1].balanceOf(testator))
    print(TokenERC721[-1].balanceOf(beneficiary))
    print(TokenERC721[-1].balanceOf(Willer[-1]))
    print(TokenERC721[-1].isApprovedForAll(testator, Willer[-1]))
    if time_before_release > 0:
        time.sleep(time_before_release)
    Willer[-1].batchReleaseERC721(testator, beneficiary, list(TokenERC721), [list(range(n_ids))] * n_contracts)
    print(TokenERC721[-1].balanceOf(testator))
    print(TokenERC721[-1].balanceOf(beneficiary))
    print(TokenERC721[-1].balanceOf(Willer[-1]))
    print(TokenERC721[-1].isApprovedForAll(testator, Willer[-1]))
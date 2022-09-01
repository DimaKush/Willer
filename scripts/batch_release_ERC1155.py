import time
from brownie import TokenERC1155, Willer, accounts, config, network
import datetime
from ..scripts.get_accounts import get_accounts

def main():
    n_contracts = config['n_contracts']
    n_ids = config['n_ids']
    value = config['value']
    deployer, testator, beneficiary = get_accounts()
    time_before_release = Willer[-1].getReleaseTime(testator, beneficiary) - datetime.datetime.timestamp(datetime.datetime.now())
    print(TokenERC1155[-1].balanceOf(testator, 0))
    print(TokenERC1155[-1].balanceOf(beneficiary, 0))
    print(TokenERC1155[-1].balanceOf(Willer[-1], 0))
    print(TokenERC1155[-1].isApprovedForAll(testator, Willer[-1]))
    if time_before_release > 0:
        time.sleep(time_before_release)
    Willer[-1].batchReleaseERC1155(testator,
                                   beneficiary,
                                   list(TokenERC1155),
                                   [list(range(n_ids))] * n_contracts,
                                   [[value] * n_ids] * n_contracts)
    print(TokenERC1155[-1].balanceOf(testator, 0))
    print(TokenERC1155[-1].balanceOf(beneficiary, 0))
    print(TokenERC1155[-1].balanceOf(Willer[-1], 0))
    print(TokenERC1155[-1].isApprovedForAll(testator, Willer[-1]))
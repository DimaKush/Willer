import time
from brownie import TokenERC20, Willer, accounts, config, network
import datetime
from ..scripts.get_accounts import get_accounts

def main():
    deployer, testator, beneficiary, executor = get_accounts()
    time_before_release = Willer[-1].getReleaseTime(testator, beneficiary) - datetime.datetime.timestamp(datetime.datetime.now())
    print(TokenERC20[-1].balanceOf(testator))
    print(TokenERC20[-1].balanceOf(beneficiary))
    print(TokenERC20[-1].allowance(testator, Willer[-1]))
    if time_before_release > 0:
        time.sleep(time_before_release)
    Willer[-1].batchReleaseERC20(testator, beneficiary, list(TokenERC20), {"from": executor})
    print(TokenERC20[-1].balanceOf(testator))
    print(TokenERC20[-1].balanceOf(beneficiary))
    print(TokenERC20[-1].allowance(testator, Willer[-1]))

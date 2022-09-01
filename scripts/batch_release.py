import time
from brownie import TokenERC20, TokenERC721, TokenERC1155, Willer, accounts, config, network
import datetime
from ..scripts.get_accounts import get_accounts

def main():
    deployer, testator, beneficiary = get_accounts()
    time_before_release = Willer[-1].getReleaseTime(testator, beneficiary) - datetime.datetime.timestamp(datetime.datetime.now())
    if time_before_release > 0:
        time.sleep(time_before_release)

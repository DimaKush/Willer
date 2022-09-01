import time
from brownie import TokenERC1155, SimpleWiller, accounts, config, network
import datetime
from ..scripts.get_accounts import get_accounts


def main():
    n_contracts, n_ids, value, publish_source = get_settings()
    deployer, testator, beneficiary = get_accounts()
    time_before_release = SimpleWiller[-1].getReleaseTime(testator) - datetime.datetime.timestamp(
        datetime.datetime.now())
    if time_before_release > 0:
        time.sleep(time_before_release)
    SimpleWiller[-1].releaseERC1155(testator, TokenERC1155[-1], list(range(n_ids)), [value]*n_ids)

from brownie import Willer, TokenERC20
from scripts import get_accounts

def main():
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = get_accounts.main()
    for t in TokenERC20:
        Willer[-1].releaseERC20(testator, t, {'from': executor})
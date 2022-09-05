from brownie import TokenERC20, Willer
from scripts import get_accounts

def main():
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = get_accounts.main()
    Willer[-1].batchReleaseERC20(testator, list(TokenERC20), {"from": executor})


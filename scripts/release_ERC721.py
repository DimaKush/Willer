from brownie import Willer, TokenERC721
from scripts import get_settings, get_accounts

def main():
    n_contracts, n_ids, value, publish_source = get_settings.main()
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = get_accounts.main()
    for nft in TokenERC721:
        Willer[-1].releaseERC721(testator, nft, list(range(n_ids)), {'from': executor})

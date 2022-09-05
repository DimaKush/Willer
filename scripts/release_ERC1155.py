from brownie import Willer, TokenERC1155
from scripts import get_settings, get_accounts

def main():
    n_contracts, n_ids, value, publish_source = get_settings.main()
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = get_accounts.main()
    for t in TokenERC1155:
        for id in range(n_ids):
            Willer[-1].releaseERC1155(testator, t, id, {'from': executor})
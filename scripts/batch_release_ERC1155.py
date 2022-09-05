from brownie import Willer, TokenERC1155
from scripts import get_settings, get_accounts

def main():
    n_contracts, n_ids, value, publish_source = get_settings.main()
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = get_accounts.main()

    for ERC1155 in TokenERC1155:
        for id in list(range(n_ids)):
            print(f'testator balance {ERC1155.balanceOf(testator, id)}')
            for b in beneficiaries:
                print(f'{b} balance {ERC1155.balanceOf(b, id)}')
        
        Willer[-1].batchReleaseERC1155(testator, ERC1155, list(range(n_ids)))

        for id in list(range(n_ids)):
            print(f'testator balance {ERC1155.balanceOf(testator, id)}')
            for b in beneficiaries:
                print(f'{b} balance {ERC1155.balanceOf(b, id)}')


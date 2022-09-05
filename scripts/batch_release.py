from brownie import Willer, TokenERC721, TokenERC20, TokenERC1155
from scripts import get_settings, get_accounts

def main():
    n_contracts, n_ids, value, publish_source = get_settings.main()
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = get_accounts.main()
    # gasBlockLimit?
    Willer[-1].batchRelease(testator,
                            list(TokenERC20),
                            list(TokenERC721),
                            list(TokenERC1155),
                            [list(range(n_ids))] * n_contracts,
                            [list(range(n_ids))] * n_contracts)

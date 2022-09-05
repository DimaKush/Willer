from brownie import TokenERC20, TokenERC721, TokenERC1155, Willer

import scripts.get_settings
import scripts.get_accounts

def main():
    n_contracts, n_ids, value, publish_source = scripts.get_settings.main()
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = scripts.get_accounts.main()
    
    for i in TokenERC20:
        i.approve(Willer[-1], value, {'from': testator})
    for i in TokenERC721:
        i.setApprovalForAll(Willer[-1], True, {'from': testator})
    for i in TokenERC1155:
        i.setApprovalForAll(Willer[-1], True, {'from': testator})

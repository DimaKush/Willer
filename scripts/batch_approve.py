from brownie import TokenERC20, TokenERC721, TokenERC1155, Willer

from ..scripts.get_settings import get_settings
from ..scripts.get_accounts import get_accounts

def main():
    n_contracts, n_ids, value, publish_source = get_settings()
    deployer, testator, beneficiary, executor = get_accounts()
    
    for i in TokenERC20:
        i.approve(Willer[-1], value, {'from': testator})
    for i in TokenERC721:
        i.setApprovalForAll(Willer[-1], True, {'from': testator})
    for i in TokenERC1155:
        i.setApprovalForAll(Willer[-1], True, {'from': testator})

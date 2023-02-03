from brownie import TokenERC20, TokenERC721, TokenERC1155

from scripts import get_settings, get_accounts

def main():
    n_contracts, n_ids, value, publish_source = get_settings.main()
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = get_accounts.main()
    
    for i in range(n_contracts):
        TokenERC20.deploy(value,
                          f"TokenERC20_{i}",
                          f"T20_{i}",
                          {'from': deployer},
                          publish_source=publish_source)
        TokenERC20[-1].transfer(testator, value, {'from': deployer})
        TokenERC721.deploy(
            f"TokenERC721_{i}",
            f"T721_{i}",
            {'from': deployer},
            publish_source=publish_source
        )
        TokenERC1155.deploy(
            f"Test_{i}",
            {'from': deployer},
            publish_source=publish_source)

        for u in range(n_ids):
            TokenERC721[-1].safeMint(testator, f"someuri_{u}", {'from': deployer})
            TokenERC1155[-1].mint(testator, u, value, "", {'from': deployer})

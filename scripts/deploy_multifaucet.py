
from brownie import TokenERC20, TokenERC721, TokenERC1155, MultiFaucet
import brownie

from scripts import get_settings, get_accounts

def main():
    ERC721URI, ERC1155URI, n_contracts, n_ids, value, publish_source = get_settings.main()
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = get_accounts.main()
    ERC20Contract = TokenERC20.deploy(value,
                          f"TokenERC20_for_Willer",
                          f"ERC20W",
                          {'from': deployer},
                          publish_source=publish_source)

    ERC721Contract = TokenERC721.deploy(
            f"TokenERC721_for_Willer",
            f"ERC721W",
            {'from': deployer},
            publish_source=publish_source
        )
    
    ERC1155Contract = TokenERC1155.deploy(
            f"TokenERC1155_for_Willer",
            ERC1155URI,
            {'from': deployer},
            publish_source=publish_source)

    multiFaucetContract = MultiFaucet.deploy(ERC20Contract.address, ERC721Contract.address, ERC1155Contract.address, {'from': deployer}, publish_source=publish_source)
    ERC20Contract.transfer(multiFaucetContract, value, {'from': deployer})
    ERC721Contract.transferOwnership(multiFaucetContract, {'from': deployer})
    ERC1155Contract.transferOwnership(multiFaucetContract, {'from': deployer}) 
    multiFaucetContract.drip({'from': testator})



from brownie import Willer
from scripts import get_settings, get_accounts, add_will, batch_approve, deploy_willer, deploy_dummy_tokens

def main():
    n_contracts, n_ids, value, publish_source = get_settings.main()
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = get_accounts.main()
    deploy_dummy_tokens.main()
    deploy_willer.main()
    batch_approve.main()
    add_will.main()
    print(f'Release time: {Willer[-1].getReleaseTime(testator)}')
    print(f'Shares: {Willer[-1].getShares(testator)}')
    print(f'SumShares: {Willer[-1].getSumShares(testator)}')
    print(f'Beneficiaries: {Willer[-1].getBeneficiaries(testator)}')
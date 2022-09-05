from brownie import Willer, config
import datetime
import scripts.get_accounts


def main():
    deployer, testator, beneficiaries, new_beneficiary, beneficiaryOfERC721, executor = scripts.get_accounts.main()
    Willer[-1].addWill(beneficiaries, config['settings']['shares'], beneficiaryOfERC721, 
                        datetime.datetime.timestamp(datetime.datetime.now() + datetime.timedelta(seconds=20)),
                        {'from': testator}
    )



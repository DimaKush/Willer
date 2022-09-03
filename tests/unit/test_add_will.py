from datetime import datetime, timedelta


def test_add_will(testator, beneficiaries, shares, beneficiaryOfERC721, willer_contract, delay):
    release_time = round(datetime.timestamp(datetime.now() + timedelta(seconds=delay)))
    willer_contract.addWill(beneficiaries, shares, beneficiaryOfERC721, release_time, {'from': testator})
    assert willer_contract.getBeneficiaries(testator) == beneficiaries
    assert willer_contract.getSumShares(testator) == sum(shares)
    assert willer_contract.getReleaseTime(testator) == release_time
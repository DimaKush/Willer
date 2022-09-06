import time

def test_add_will(testator, beneficiaries, shares, beneficiaryOfERC721, willer_contract, delay):
    release_time = round(time.time() + delay)
    willer_contract.addWill(beneficiaries, shares, beneficiaryOfERC721, release_time, {'from': testator})
    assert willer_contract.getBeneficiaries(testator) == beneficiaries
    assert willer_contract.getSumShares(testator) == sum(shares)
    assert willer_contract.getReleaseTime(testator) == release_time
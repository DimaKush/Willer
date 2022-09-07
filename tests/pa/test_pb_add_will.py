from brownie.test import given, strategy
import brownie
from brownie.network.state import Chain


@given(release_time=strategy('uint', min_value=1600000000, max_value=1800000000))
def test_add_will_valid_release_time(testator, beneficiaries, shares, beneficiaryOfERC721, willer_contract, release_time, buffer):
    chain = Chain()
    assert willer_contract.getReleaseTime(testator) == 0
    if chain.time() + willer_contract.getBuffer() < release_time:
        willer_contract.addWill(beneficiaries, shares, beneficiaryOfERC721, release_time, {'from': testator})
        assert willer_contract.getBeneficiaries(testator) == beneficiaries
        assert willer_contract.getShares(testator) == shares
        assert willer_contract.getSumShares(testator) == sum(shares)
        assert willer_contract.getReleaseTime(testator) == release_time
        assert willer_contract.getBeneficiaryOfERC721(testator) == beneficiaryOfERC721
    else:
        with brownie.reverts():
             willer_contract.addWill(beneficiaries, shares, beneficiaryOfERC721, release_time, {'from': testator})


@given(beneficiaries=strategy('address[5]'))
@given(shares=strategy('uint[5]', max_value=10))
def test_add_will_valid_beneficiaries(testator, beneficiaries, shares, beneficiaryOfERC721, willer_contract, delay):
    chain = Chain()
    assert willer_contract.getReleaseTime(testator) == 0
    assert willer_contract.getBeneficiaries(testator) == []
    release_time = chain.time() + willer_contract.getBuffer() + delay
    willer_contract.addWill(beneficiaries, shares, beneficiaryOfERC721, release_time, {'from': testator})
    assert willer_contract.getBeneficiaries(testator) == beneficiaries

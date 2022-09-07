
def test_set_new_beneficiary_of_ERC721(add_will, testator, willer_contract, beneficiaryOfERC721, new_beneficiary):
    assert beneficiaryOfERC721 == willer_contract.getBeneficiaryOfERC721(testator)
    willer_contract.setNewBeneficiaryOfERC721(new_beneficiary, {'from': testator})
    assert willer_contract.getBeneficiaryOfERC721(testator) == new_beneficiary

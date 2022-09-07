

def test_set_new_beneficiaries(testator, beneficiaries, new_beneficiary, willer_contract, shares, value):
    assert willer_contract.getBeneficiaries(testator) == beneficiaries
    assert willer_contract.getShares(testator) == shares
    willer_contract.setNewBeneficiaries(beneficiaries + [new_beneficiary], shares + [value], {'from': testator})
    assert willer_contract.getBeneficiaries(testator) == beneficiaries + [new_beneficiary]
    assert willer_contract.getShares(testator) == shares + [value]
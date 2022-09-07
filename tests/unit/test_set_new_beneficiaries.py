

def test_set_new_beneficiaries(add_will, testator, beneficiaries, new_beneficiary, willer_contract, shares):
    assert willer_contract.getBeneficiaries(testator) == beneficiaries
    assert willer_contract.getShares(testator) == shares
    willer_contract.setNewBeneficiaries(beneficiaries + [new_beneficiary], shares + [1], {'from': testator})
    assert willer_contract.getBeneficiaries(testator) == beneficiaries + [new_beneficiary]
    assert willer_contract.getShares(testator) == shares + [1]
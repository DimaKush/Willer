import brownie

def test_release_ERC20_releasable_false(extend_release_time, willer_contract, testator, executor, ERC20_token_contracts):
    for ERC20_token_contract in ERC20_token_contracts:
        with brownie.reverts("Willer: unreleasable"):
            willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': executor})


def test_release_ERC20_releasable_true(wait_release_time, willer_contract, testator, executor, ERC20_token_contracts):
    
    for ERC20_token_contract in ERC20_token_contracts:
        
        testator_balance = ERC20_token_contract.balanceOf(testator)
        expected_beneficiaries_balances = []
        beneficiaries = willer_contract.getBeneficiaries(testator)
        shares = willer_contract.getShares(testator)
        for i in shares:
            expected_beneficiaries_balances.append(round(testator_balance*i/sum(shares)))
        print(expected_beneficiaries_balances)
        willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': executor})
        assert ERC20_token_contract.balanceOf(testator) == 0
        for index, beneficiary in enumerate(beneficiaries):
            print(ERC20_token_contract.balanceOf(beneficiary))
            assert ERC20_token_contract.balanceOf(beneficiary) == expected_beneficiaries_balances[index]

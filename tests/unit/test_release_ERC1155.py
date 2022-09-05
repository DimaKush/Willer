import brownie

def test_release_ERC1155_releasable_false(extend_release_time, willer_contract, testator, executor, value, ERC1155_token_contracts, n_ids,):
    for ERC1155_token_contract in ERC1155_token_contracts:
        for id in range(n_ids):
            with brownie.reverts("Willer: unreleasable"):
                willer_contract.releaseERC1155(testator, ERC1155_token_contract, id, {'from': executor})


def test_release_ERC1155_releasable_true(wait_release_time, willer_contract, testator, executor, shares, value, ERC1155_token_contracts, n_ids):
    for ERC1155_token_contract in ERC1155_token_contracts:
        for id in range(n_ids):
            testator_balance = ERC1155_token_contract.balanceOf(testator, id)
            expected_beneficiaries_balances = []
            beneficiaries = willer_contract.getBeneficiaries(testator)
            shares = willer_contract.getShares(testator)
            for i in shares:
                expected_beneficiaries_balances.append(int(testator_balance*i/sum(shares)))
            expected_modulo = testator_balance - sum(expected_beneficiaries_balances)

            print(f'testator_balance: {testator_balance}')
            print(f'shares: {shares}')
            print(f'expected_beneficiaries_balances: {expected_beneficiaries_balances}')
            print(f'expected_modulo: {expected_modulo}')

            willer_contract.releaseERC1155(testator, ERC1155_token_contract, id,  {'from': executor})

            assert ERC1155_token_contract.balanceOf(testator, id) == 0
            
            for index, beneficiary in enumerate(beneficiaries):
                # last beneficiary receives bequest and modulo
                if index == len(beneficiaries)-1:
                    assert ERC1155_token_contract.balanceOf(beneficiary, id) == expected_beneficiaries_balances[index] + expected_modulo
                else:
                    assert ERC1155_token_contract.balanceOf(beneficiary, id) == expected_beneficiaries_balances[index]
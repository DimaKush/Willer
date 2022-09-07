import brownie

def test_batch_release_ERC1155_releasable_false(add_will, extend_release_time, willer_contract, testator, executor, ERC1155_token_contracts, n_ids):
    for ERC1155_token_contract in ERC1155_token_contracts:
        with brownie.reverts("Willer: unreleasable"):
            willer_contract.batchReleaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)), {'from': executor})


def test_batch_release_ERC1155_releasable_true(add_will, wait_release_time, willer_contract, testator, executor, shares, ERC1155_token_contracts, n_ids):
    expected = {}
    for ERC1155_token_contract in ERC1155_token_contracts:
        for id in range(n_ids):
            testator_balance = ERC1155_token_contract.balanceOf(testator, id)
            expected_beneficiaries_balances = []
            beneficiaries = willer_contract.getBeneficiaries(testator)
            shares = willer_contract.getShares(testator)
            for i in shares:
                expected_beneficiaries_balances.append(int(testator_balance*i/sum(shares)))
            expected_modulo = testator_balance - sum(expected_beneficiaries_balances)
            expected[id] = (expected_beneficiaries_balances, expected_modulo)

        willer_contract.batchReleaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)),  {'from': executor})
        for id in range(n_ids):
            assert ERC1155_token_contract.balanceOf(testator, id) == 0
            
            for index, beneficiary in enumerate(beneficiaries):
                # last beneficiary receives bequest and modulo
                if index == len(beneficiaries)-1:
                    assert ERC1155_token_contract.balanceOf(beneficiary, id) == expected[id][0][index] + expected[id][1]
                else:
                    assert ERC1155_token_contract.balanceOf(beneficiary, id) == expected[id][0][index]
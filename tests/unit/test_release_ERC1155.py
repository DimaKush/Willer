import brownie

def test_release_ERC1155_releasable_false(extend_release_time, willer_contract, testator, executor, value, ERC1155_token_contracts, n_ids,):
    for ERC1155_token_contract in ERC1155_token_contracts:
        with brownie.reverts("Willer: unreleasable"):
            willer_contract.batchReleaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)), {'from': executor})


def test_release_ERC1155_releasable_true(wait_release_time, willer_contract, testator, beneficiaries, executor, shares, value, ERC1155_token_contracts, n_ids):
    for ERC1155_token_contract in ERC1155_token_contracts:
        willer_contract.batchReleaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)),  {'from': executor})
        for id in range(n_ids):
            assert ERC1155_token_contract.balanceOf(testator, id) == 0
            for i in range(len(beneficiaries)):
                if i != len(beneficiaries) - 1:
                    assert ERC1155_token_contract.balanceOf(beneficiaries[i], id) == value * shares[i] / sum(shares)
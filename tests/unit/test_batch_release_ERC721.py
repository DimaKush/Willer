import brownie


def test_batch_release_ERC721_releasable_false(add_will, extend_release_time, willer_contract, executor, testator, ERC721_token_contracts, n_ids):
    with brownie.reverts("Willer: unreleasable"):
        willer_contract.batchReleaseERC721(testator, list(ERC721_token_contracts), [list(range(n_ids))] * len(ERC721_token_contracts), {'from': executor})


def test_batch_release_ERC721_releasable_true(add_will, wait_release_time, willer_contract, executor, testator, ERC721_token_contracts, n_ids):
    expected = {}
    for ERC721_token_contract in ERC721_token_contracts:
        expected[ERC721_token_contract] = ERC721_token_contract.balanceOf(testator)
    willer_contract.batchReleaseERC721(testator, list(ERC721_token_contracts), [list(range(n_ids))] * len(ERC721_token_contracts), {'from': executor})
    for ERC721_token_contract in ERC721_token_contracts:
        assert ERC721_token_contract.balanceOf(testator) == 0
        assert ERC721_token_contract.balanceOf(willer_contract.getBeneficiaryOfERC721(testator)) == expected[ERC721_token_contract]
        for id in range(n_ids):
            assert ERC721_token_contract.ownerOf(id) == willer_contract.getBeneficiaryOfERC721(testator)
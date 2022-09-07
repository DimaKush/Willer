import brownie


def test_release_ERC721_releasable_false(add_will, extend_release_time, willer_contract, executor, testator, ERC721_token_contracts, n_ids):
    for ERC721_token_contract in ERC721_token_contracts:
        with brownie.reverts("Willer: unreleasable"):
            willer_contract.releaseERC721(testator, ERC721_token_contract, list(range(n_ids)), {'from': executor})


def test_release_ERC721_releasable_true(add_will, wait_release_time, willer_contract, executor, testator, ERC721_token_contracts, n_ids):
    for ERC721_token_contract in ERC721_token_contracts:
        testator_balance = ERC721_token_contract.balanceOf(testator)
        willer_contract.releaseERC721(testator, ERC721_token_contract, list(range(n_ids)), {'from': executor})
        assert ERC721_token_contract.balanceOf(testator) == 0
        assert ERC721_token_contract.balanceOf(willer_contract.getBeneficiaryOfERC721(testator)) == testator_balance
        for id in range(n_ids):
            assert ERC721_token_contract.ownerOf(id) == willer_contract.getBeneficiaryOfERC721(testator)
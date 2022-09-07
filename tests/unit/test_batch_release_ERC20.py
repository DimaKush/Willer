import brownie

def test_batch_release_ERC20_releasable_false(extend_release_time, willer_contract, testator, executor, ERC20_token_contracts):
    with brownie.reverts("Willer: unreleasable"):
        willer_contract.batchReleaseERC20(testator, list(ERC20_token_contracts), {'from': executor})


def test_batch_release_ERC20_releasable_true(wait_release_time, willer_contract, testator, executor, ERC20_token_contracts):
    balances = {ERC20_token_contract: ERC20_token_contract.balanceOf(testator) for ERC20_token_contract in ERC20_token_contracts}
    willer_contract.batchReleaseERC20(testator, list(ERC20_token_contracts), {'from': executor})

    for ERC20_token_contract in balances:
        assert ERC20_token_contract.balanceOf(testator) == 0

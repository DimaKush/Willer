import brownie

def test_batch_release_ERC20_releasable_false(add_will, extend_release_time, willer_contract, testator, beneficiaries, ERC20_token_contracts):
    for b in beneficiaries:
        with brownie.reverts("Willer: unreleasable"):       
            willer_contract.batchReleaseERC20(testator, list(ERC20_token_contracts), {'from': beneficiaries[0]})


def test_batch_release_ERC20_releasable_true(add_will, wait_release_time, willer_contract, testator, beneficiaries, ERC20_token_contracts, shares):
    balances = {ERC20_token_contract: ERC20_token_contract.balanceOf(testator) for ERC20_token_contract in ERC20_token_contracts}
    willer_contract.batchReleaseERC20(testator, list(ERC20_token_contracts), {'from': beneficiaries[0]})
    for ERC20_token_contract in balances:
        assert ERC20_token_contract.balanceOf(testator) == 0
    # TODO ERC20_token_contract.balanceOf(i) == balances[ERC20_token_contract]

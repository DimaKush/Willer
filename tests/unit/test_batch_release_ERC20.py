# import brownie

# def test_batch_release_ERC20_releasable_false(extend_release_time, willer_contract, testator, executor, ERC20_token_contracts):
#     for ERC20_token_contract in ERC20_token_contracts:
#         with brownie.reverts("Willer: unreleasable"):
#             willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': executor})


# def test_batch_release_ERC20_releasable_true(wait_release_time, willer_contract, testator, executor, ERC20_token_contracts):
#     for ERC20_token_contract in ERC20_token_contracts:
#         testator_balance = ERC20_token_contract.balanceOf(testator)
    
#     willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': executor})

#     for ERC20_token_contract in ERC20_token_contracts:
#         assert ERC20_token_contract.balanceOf(testator) == 0

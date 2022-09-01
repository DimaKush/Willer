from datetime import datetime, timedelta
import time
import brownie

def new_release_time(delay):
    return datetime.timestamp(datetime.now() + timedelta(seconds=delay))


def wait_release_time(willer_contract, testator):
    time_till_release = willer_contract.getReleaseTime(testator) - datetime.timestamp(datetime.now())
    if time_till_release > 0:
        time.sleep(time_till_release + 0.1)



def test_add_will(testator, beneficiaries, shares, beneficiaryOfERC721, willer_contract, delay):
    # 
    release_time = new_release_time(delay)
    # 
    willer_contract.addWill(beneficiaries, shares, beneficiaryOfERC721, release_time, {'from': testator})
    assert willer_contract.getBeneficiaries(testator) == beneficiaries
    # assert willer_contract.getSumShares(testator) == shares.sum()
    assert willer_contract.getReleaseTime(testator) == release_time


def test_set_new_release_time(testator, willer_contract, delay):
    new_release_time = datetime.timestamp(datetime.now() + timedelta(seconds=delay))
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    assert willer_contract.getReleaseTime(testator) == new_release_time


def test_set_new_beneficiaries(testator, beneficiaries, new_beneficiary, willer_contract, add_will):
    willer_contract.setNewBeneficiaries(beneficiaries + [new_beneficiary], {'from': testator})
    # add shares
    assert willer_contract.getBeneficiaries(testator) == beneficiaries + [new_beneficiary]


def test_release_ERC20(willer_contract, deployer, beneficiaries, testator, ERC20_token_contracts, delay, add_will):
    new_release_time = datetime.timestamp(datetime.now() + timedelta(seconds=delay))
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    for ERC20_token_contract in ERC20_token_contracts:
        with brownie.reverts():
            willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': deployer})

    wait_release_time(willer_contract, testator)
    for ERC20_token_contract in ERC20_token_contracts:
        testator_balance = ERC20_token_contract.balanceOf(testator)
        willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': deployer})
        assert ERC20_token_contract.balanceOf(testator) == 0
        # assert ERC20_token_contract.balanceOf(beneficiaries) == testator_balance


def test_release_ERC721(willer_contract, deployer, testator, new_beneficiary, ERC721_token_contracts, n_ids, delay, add_will):
    new_release_time = round(datetime.timestamp(datetime.now() + timedelta(seconds=delay)))
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    for ERC721_token_contract in ERC721_token_contracts:
        with brownie.reverts():
            willer_contract.releaseERC721(testator, ERC721_token_contract.address, list(range(n_ids)), {'from': deployer})
            willer_contract.releaseERC721(testator, ERC721_token_contract.address, list(range(n_ids)), {'from': new_beneficiary})

    wait_release_time(willer_contract, testator)
    for ERC721_token_contract in ERC721_token_contracts:
        for id in range(n_ids):
            assert ERC721_token_contract.ownerOf(id) == testator
        testator_balance = ERC721_token_contract.balanceOf(testator)
        willer_contract.releaseERC721(testator, ERC721_token_contract.address, list(range(n_ids)), {'from': deployer})
        assert ERC721_token_contract.balanceOf(testator) == 0
        # assert ERC721_token_contract.balanceOf(beneficiary) == testator_balance
        # for id in range(n_ids):
        #     assert ERC721_token_contract.ownerOf(id) == beneficiaries


# def test_release_ERC1155(willer_contract, deployer, testator, beneficiaries, value, ERC1155_token_contracts, n_ids, delay, add_will):
#     # 
#     # new_release_time = datetime.timestamp(datetime.now() + datetime.timedelta(seconds=delay)) 
#     # 

#     for ERC1155_token_contract in ERC1155_token_contracts:
#         with brownie.reverts():
#             willer_contract.releaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)), [value] * n_ids,  {'from': deployer})
#     wait_release_time(willer_contract, testator)
#     for ERC1155_token_contract in ERC1155_token_contracts:
#         willer_contract.releaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)), [value] * n_ids,  {'from': deployer})
#         for id in range(n_ids):
#             assert ERC1155_token_contract.balanceOf(testator, id) == 0
#             # assert ERC1155_token_contract.balanceOf(beneficiary, id) == value

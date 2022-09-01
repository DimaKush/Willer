import datetime
import time
import brownie


def test_add_will(testator, beneficiary, willer_contract):
    release_time = round(datetime.datetime.timestamp(datetime.datetime.now() + datetime.timedelta(seconds=10)))
    willer_contract.addWill(beneficiary, release_time, {'from': testator})
    assert willer_contract.getBeneficiary(testator) == beneficiary


def test_new_release_time(testator, willer_contract):
    new_release_time = datetime.datetime.timestamp(datetime.datetime.now() + datetime.timedelta(seconds=20))
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    assert willer_contract.getReleaseTime(testator) == new_release_time


def test_set_new_beneficiary(deployer, testator, new_beneficiary, willer_contract):
    willer_contract.setNewBeneficiary(new_beneficiary, {'from': testator})
    assert willer_contract.getBeneficiary(testator) == new_beneficiary


def wait_release_time(willer_contract, testator):
    time_till_release = willer_contract.getReleaseTime(testator) - datetime.datetime.timestamp(datetime.datetime.now())
    if time_till_release > 0:
        time.sleep(time_till_release)


def test_release_ERC20(willer_contract, deployer, testator, beneficiary, new_beneficiary, ERC20_token_contracts, n_contracts, value):
    new_release_time = datetime.datetime.timestamp(datetime.datetime.now() + datetime.timedelta(seconds=value))
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    for ERC20_token_contract in ERC20_token_contracts:
        with brownie.reverts():
            willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': deployer})

    wait_release_time(willer_contract, testator)
    for ERC20_token_contract in ERC20_token_contracts:
        testator_balance = ERC20_token_contract.balanceOf(testator)
        willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': deployer})
        assert ERC20_token_contract.balanceOf(testator) == 0
        assert ERC20_token_contract.balanceOf(beneficiary) == testator_balance


def test_release_ERC721(willer_contract, deployer, testator, beneficiary, new_beneficiary, ERC721_token_contracts, n_ids, value):
    new_release_time = datetime.datetime.timestamp(datetime.datetime.now() + datetime.timedelta(seconds=value))
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    for ERC721_token_contract in ERC721_token_contracts:
        with brownie.reverts():
            willer_contract.releaseERC721(testator, ERC721_token_contract.address, list(range(n_ids)), {'from': deployer})

    wait_release_time(willer_contract, testator)
    for ERC721_token_contract in ERC721_token_contracts:
        testator_balance = ERC721_token_contract.balanceOf(testator)
        willer_contract.releaseERC721(testator, ERC721_token_contract.address, list(range(n_ids)), {'from': deployer})
        assert ERC721_token_contract.balanceOf(testator) == 0
        assert ERC721_token_contract.balanceOf(beneficiary) == testator_balance


def test_release_ERC1155(willer_contract, deployer, testator, beneficiary, value, ERC1155_token_contracts, n_contracts, n_ids):
    new_release_time = datetime.datetime.timestamp(datetime.datetime.now() + datetime.timedelta(seconds=value))
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    for ERC1155_token_contract in ERC1155_token_contracts:
        with brownie.reverts():
            willer_contract.releaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)), [value] * n_ids,  {'from': deployer})
    wait_release_time(willer_contract, testator)
    for ERC1155_token_contract in ERC1155_token_contracts:
        willer_contract.releaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)), [value] * n_ids,  {'from': deployer})
        for id in range(n_ids):
            assert ERC1155_token_contract.balanceOf(testator, id) == 0
            assert ERC1155_token_contract.balanceOf(beneficiary, id) == value

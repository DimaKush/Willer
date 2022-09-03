from datetime import datetime, timedelta
from logging import log
import time
import brownie

def extend_release_time(testator, willer_contract, delay):
    new_release_time = round(datetime.timestamp(datetime.now())) + delay
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    return new_release_time


def wait_release_time(willer_contract, testator):
    time_till_release = round(willer_contract.getReleaseTime(testator) - datetime.timestamp(datetime.now()))
    if time_till_release > 0:
        time.sleep(time_till_release + 2)


def test_add_will(testator, beneficiaries, shares, beneficiaryOfERC721, willer_contract, delay):
    # 
    release_time = datetime.timestamp(datetime.now() + timedelta(seconds=delay))
    # 
    willer_contract.addWill(beneficiaries, shares, beneficiaryOfERC721, release_time, {'from': testator})
    assert willer_contract.getBeneficiaries(testator) == beneficiaries
    assert willer_contract.getSumShares(testator) == sum(shares)
    assert willer_contract.getReleaseTime(testator) == release_time



def test_set_new_release_time(testator, willer_contract, delay):
    new_release_time = willer_contract.getReleaseTime(testator) + delay
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})
    assert willer_contract.getReleaseTime(testator) == new_release_time


def test_set_new_beneficiaries(testator, beneficiaries, new_beneficiary, willer_contract, shares, value):
    willer_contract.setNewBeneficiaries(beneficiaries + [new_beneficiary], shares + [value], {'from': testator})
    assert willer_contract.getBeneficiaries(testator) == beneficiaries + [new_beneficiary]
    # assert willer_contract.getShares(testator) == shares + [value]


def test_release_ERC20(willer_contract, deployer, beneficiaries, testator, shares, executor, ERC20_token_contracts, delay):
    if datetime.timestamp(datetime.now()) < willer_contract.getReleaseTime(testator):
        extend_release_time(testator, willer_contract, delay)
    for ERC20_token_contract in ERC20_token_contracts:
        with brownie.reverts():
            willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': executor})

    wait_release_time(willer_contract, testator)
    for ERC20_token_contract in ERC20_token_contracts:
        testator_balance = ERC20_token_contract.balanceOf(testator)
        willer_contract.releaseERC20(testator, ERC20_token_contract, {'from': executor})
        assert ERC20_token_contract.balanceOf(testator) == 0


def test_release_ERC721_before_trigger(willer_contract, deployer, testator, ERC721_token_contracts, n_ids, delay, add_will):
    if datetime.timestamp(datetime.now()) > willer_contract.getReleaseTime(testator):
        extend_release_time(testator, willer_contract, delay)
    for ERC721_token_contract in ERC721_token_contracts:
        if datetime.timestamp(datetime.now()) < willer_contract.getReleaseTime(testator):
            with brownie.reverts():
                willer_contract.releaseERC721(testator, ERC721_token_contract.address, list(range(n_ids)), {'from': deployer})

def test_release_ERC721_after_trigger(willer_contract, deployer, testator, ERC721_token_contracts, n_ids, delay, add_will):
    wait_release_time(willer_contract, testator)
    for ERC721_token_contract in ERC721_token_contracts:
        for id in range(n_ids):
            assert ERC721_token_contract.ownerOf(id) == testator
        testator_balance = ERC721_token_contract.balanceOf(testator)
        willer_contract.releaseERC721(testator, ERC721_token_contract.address, list(range(n_ids)), {'from': deployer})
        assert ERC721_token_contract.balanceOf(testator) == 0
        assert ERC721_token_contract.balanceOf(willer_contract.getBeneficiaryOfERC721(testator)) == testator_balance
        for id in range(n_ids):
            assert ERC721_token_contract.ownerOf(id) == willer_contract.getBeneficiaryOfERC721(testator)


def test_release_ERC1155_before_trigger(willer_contract, testator, executor, value, ERC1155_token_contracts, n_ids, delay):
    if datetime.timestamp(datetime.now()) > willer_contract.getReleaseTime(testator):
        new_release_time = extend_release_time(testator, willer_contract, delay)
        assert new_release_time > round(datetime.timestamp(datetime.now()))
    
    assert willer_contract.getReleaseTime(testator) > round(datetime.timestamp(datetime.now()))
    for ERC1155_token_contract in ERC1155_token_contracts:
        with brownie.reverts():
            willer_contract.batchReleaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)), {'from': executor})


def test_release_ERC1155_after_trigger(willer_contract, testator, beneficiaries, executor, shares, value, ERC1155_token_contracts, n_ids):
    wait_release_time(willer_contract, testator)
    for ERC1155_token_contract in ERC1155_token_contracts:

        willer_contract.batchReleaseERC1155(testator, ERC1155_token_contract, list(range(n_ids)),  {'from': executor})
        for id in range(n_ids):

            assert ERC1155_token_contract.balanceOf(testator, id) == 0
            for i in range(len(beneficiaries)):
                if i != len(beneficiaries) - 1:
                    assert ERC1155_token_contract.balanceOf(beneficiaries[i], id) == value * shares[i] / sum(shares)

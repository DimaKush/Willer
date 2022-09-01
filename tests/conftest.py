import datetime
from brownie import config
import brownie.network
import pytest


@pytest.fixture(scope='module')
def n_contracts():
    yield config['settings']['n_contracts']


@pytest.fixture(scope='module')
def value():
    yield config['settings']['value']


@pytest.fixture(scope='module')
def n_ids():
    yield config['settings']['n_ids']


@pytest.fixture(scope='module')
def deployer(accounts):
    yield accounts[0]


@pytest.fixture(scope='module')
def testator(accounts):
    yield accounts[1]


@pytest.fixture(scope='module')
def beneficiaries(accounts):
    yield [accounts[2], accounts[3], accounts[4]]


@pytest.fixture(scope='module')
def new_beneficiary(accounts):
    yield accounts[5]

@pytest.fixture(scope='module')
def beneficiaryOfERC721(accounts):
    yield accounts[6]

@pytest.fixture(scope='module')
def shares():
    yield [6, 3, 1]

@pytest.fixture(scope='module')
def delay():
    yield config['settings']['test_delay']


@pytest.fixture(scope='function', autouse=True)
def setup(fn_isolation):
    """
    Isolation setup fixture.
    This ensures that each test runs against the same base environment.
    """
    pass


@pytest.fixture(scope="module")
def ERC20_token_contracts(deployer, testator, TokenERC20, n_contracts, value):
    for i in range(n_contracts):
        deloyed_contract = TokenERC20.deploy(value,
                          f"TokenERC20_{i}",
                          f"T20_{i}",
                          {'from': deployer})
        deloyed_contract.transfer(testator, value)
    yield TokenERC20


@pytest.fixture(scope="module")
def ERC721_token_contracts(deployer, testator, TokenERC721, n_contracts, n_ids):
    for i in range(n_contracts):
        deployed_contract = TokenERC721.deploy(
            f"TokenERC721_{i}",
            f"T721_{i}",
            {'from': deployer}
        )
        for u in range(n_ids):
            deployed_contract.safeMint(testator,
                                       f"someuri_{u}",
                                       {'from': deployer})
    yield TokenERC721


@pytest.fixture(scope="module")
def ERC1155_token_contracts(deployer, testator, TokenERC1155, value, n_contracts, n_ids):
    for i in range(n_contracts):
        deployed_contract = TokenERC1155.deploy(
            f"https://somelink.xyz/ERC1155_{i}",
            {'from': deployer}
        )
        for u in range(n_ids):
            deployed_contract.mint(testator, u, value, "", {'from': deployer})
    yield TokenERC1155


@pytest.fixture(scope="module", autouse=True)
def willer_contract(deployer, Willer):
    yield Willer.deploy(
        {'from': deployer}
    )


@pytest.fixture(scope="module", autouse=True)
def batch_approve(testator, ERC20_token_contracts, ERC721_token_contracts, ERC1155_token_contracts, willer_contract, value):
    for i in ERC20_token_contracts:
        i.approve(willer_contract.address, value, {'from': testator})
    for i in ERC721_token_contracts:
        i.setApprovalForAll(willer_contract.address, True, {'from': testator})
    for i in ERC1155_token_contracts:
        i.setApprovalForAll(willer_contract.address, True, {'from': testator})


@pytest.fixture(scope="module", autouse=True)
def add_will(testator, beneficiaries, shares, beneficiaryOfERC721, willer_contract, delay):
    release_time = round(datetime.datetime.timestamp(datetime.datetime.now()) + delay)
    willer_contract.addWill(beneficiaries, shares, beneficiaryOfERC721, release_time, {'from': testator})

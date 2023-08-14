
from brownie import config
import pytest
import time
from brownie.network.state import Chain


@pytest.fixture(scope='function', autouse=True)
def setup(fn_isolation):
    """
    Isolation setup fixture.
    This ensures that each test runs against the same base environment.
    """
    pass


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
def new_beneficiary(accounts):
    yield accounts[2]


@pytest.fixture(scope='module')
def beneficiaryOfERC721(accounts):
    yield accounts[3]


@pytest.fixture(scope='module')
def executor(accounts):
    yield accounts[4]



@pytest.fixture(scope='module')
def beneficiaries(accounts):
    beneficiaries = []
    for i, n in enumerate(config['settings']['shares']):
        beneficiaries.append(accounts[i+5])
    yield beneficiaries


@pytest.fixture(scope='module')
def shares():
    yield config['settings']['shares']


@pytest.fixture(scope='module')
def delay():
    yield config['settings']['test_delay']


@pytest.fixture(scope='module')
def release_time(delay):
    yield time.time() + delay


@pytest.fixture(scope='module')
def buffer():
    yield 10

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
            "someName",
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

@pytest.fixture(scope='module')
def treasury(willer_contract, deployer):
    willer_contract.setTreasuryAddress(deployer, {'from': deployer})
    yield deployer

@pytest.fixture(scope="module", autouse=True)
def batch_approve(testator, ERC20_token_contracts, ERC721_token_contracts, ERC1155_token_contracts, willer_contract, value):
    for i in ERC20_token_contracts:
        i.approve(willer_contract.address, value, {'from': testator})
    for i in ERC721_token_contracts:
        i.setApprovalForAll(willer_contract.address, True, {'from': testator})
    for i in ERC1155_token_contracts:
        i.setApprovalForAll(willer_contract.address, True, {'from': testator})


@pytest.fixture(scope='function')
def add_will(testator, beneficiaries, shares, beneficiaryOfERC721, willer_contract, delay):
    release_time = round(time.time() + willer_contract.getBuffer() + delay)
    willer_contract.addWill(beneficiaries, shares, beneficiaryOfERC721, release_time, {'from': testator})


@pytest.fixture(scope='function')
def extend_release_time(testator, willer_contract, delay):
    new_release_time = round(time.time() + willer_contract.getBuffer() + delay)
    willer_contract.setNewReleaseTime(new_release_time, {'from': testator})


@pytest.fixture(scope='function')
def wait_release_time(willer_contract, testator):
    chain = Chain()
    release_time = willer_contract.getReleaseTime(testator)
    if chain.time() < release_time:
        chain.sleep(release_time - chain.time() + 1)


@pytest.fixture(scope='function')
def wait_release_to_treasury_time(willer_contract, testator):
    chain = Chain()
    release_to_treasury_time = willer_contract.getReleaseTime(testator) + willer_contract.getReapDelay()
    if chain.time() < release_to_treasury_time:
        chain.sleep(release_to_treasury_time - chain.time() + 1)

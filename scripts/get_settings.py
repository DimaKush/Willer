from brownie import config, network

def main():
    ERC721URI = config['settings']['ERC721URI']
    ERC1155URI = config['settings']['ERC1155URI']
    n_contracts = config['settings']['n_contracts']
    n_ids = config['settings']['n_ids']
    value = config['settings']['value']
    publish_source = config['networks'][network.show_active()]['verify']
    return ERC721URI, ERC1155URI, n_contracts, n_ids, value, publish_source
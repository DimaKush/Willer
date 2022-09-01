from brownie import config, network

def get_settings():
    n_contracts = config['settings']['n_contracts']
    n_ids = config['settings']['n_ids']
    value = config['settings']['value']
    publish_source = config['networks'][network.show_active()]['verify']
    return n_contracts, n_ids, value, publish_source
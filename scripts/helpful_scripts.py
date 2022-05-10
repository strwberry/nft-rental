from brownie import (
    network,
    accounts,
    config,
    # MockV3Aggregator,
    # VRFCoordinatorV2Mock,
    # LinkToken,
)

LOCAL_BLOCKCHAIN_ENVIRONMENT = ["development", "ganache-local"]
BASE_FEE = 1000000000000000000
GAS_PRICE_LINK = "0x0"


def get_account():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


# def get_price_feed_address():
#     if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
#         return config["networks"][network.show_active()]["eth_usd_price_feed"]
#     else:
#         MockV3Aggregator.deploy(8, 344400000000, {"from": accounts[0]})
#         return MockV3Aggregator[-1].address


# def get_VRF_address():
#     if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
#         return config["networks"][network.show_active()]["vrf_address"]
#     else:
#         VRFCoordinatorV2Mock.deploy(BASE_FEE, GAS_PRICE_LINK, {"from": accounts[0]})
#         return VRFCoordinatorV2Mock[-1].address


# def get_key_hash():
#     if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
#         return config["networks"][network.show_active()]["key_hash"]
#     else:
#         return "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc"


# def get_link_token_address():
#     if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
#         return config["networks"][network.show_active()]["link_token"]
#     else:
#         LinkToken.deploy({"from": accounts[0]})
#         return LinkToken[-1].address

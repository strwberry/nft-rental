from brownie import NftFactory, network
from scripts.helpful_scripts import get_account
import json

def main():
    nft_factory = NftFactory[-1]
    print(nft_factory.tokenURI(0))
    # parsed = json.loads(nft_factory.tokenURI(0))
    # print(json.dumps(parsed, indent=4, sort_keys=True))
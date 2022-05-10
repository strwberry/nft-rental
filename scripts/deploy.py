from brownie import NftFactory, network, config
from scripts.helpful_scripts import get_account
from metadata.sample_metadata import metadata_template
from pathlib import Path
import requests
import json




def upload_to_ipfs(filepath):
    with Path(filepath).open("rb") as fp:
        image_binary = fp.read()
        ipfs_url = "http://127.0.0.1:5001"
        endpoint = "/api/v0/add"
        response = requests.post(ipfs_url + endpoint, files={"file": image_binary})
        ipfs_hash = response.json()["Hash"]
        filename = filepath.split("/")[-1:][0]
        image_uri = f"https://ipfs.io/ipfs/{ipfs_hash}?filename={filename}"
        print(image_uri)
        return image_uri

def create_metadata():
    metadata = metadata_template
    metadata["name"] = "Bobby the beast"
    metadata["description"] = "Bobby is a wild beast with a big heart"
    filepath = "./img/image_1.png"
    metadata["image"] = upload_to_ipfs(filepath)
    return metadata
   
   

def main():
    account = get_account()
    nft_generator = NftFactory.deploy({"from": account})
    count = nft_generator.counter()
    nft = nft_generator.createNft(account, {"from": account})
    metadata_file_name = (f'./metadata/{network.show_active()}/{count}.json')
    if Path(metadata_file_name).exists():
        print('Metadata file already exists!')
    else:
        print('Creating metadata file...')
        metadata = create_metadata()
        with open(metadata_file_name, "w") as file:
            json.dump(metadata, file)
        token_uri = upload_to_ipfs(metadata_file_name)
    tx = nft_generator.setTokenURI(count, token_uri, {"from": account})
    tx.wait(1)
    print('NFT published!')
    print(f'https://testnets.opensea.io/assets/{nft}/{count}')
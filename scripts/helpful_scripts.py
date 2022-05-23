from brownie import network, accounts, config
from pathlib import Path
from metadata.sample_metadata import metadata_template
import requests
LOCAL_BLOCKCHAIN_ENVIRONMENT = ["development", "ganache-local"]


def get_account():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


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
    metadata["properties"]["name"]["description"] = "Bobby the beast"
    metadata["properties"]["description"]["description"] = "Bobby is a wild beast with a big heart"
    filepath = "./img/image_1.png"
    metadata["properties"]["image"]["description"] = upload_to_ipfs(filepath)
    return metadata
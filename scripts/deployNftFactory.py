from brownie import NftFactory, network
from scripts.helpful_scripts import get_account, upload_to_ipfs, create_metadata
from pathlib import Path
import json

def deploy_nft_generator():
    account = get_account()
    nft_generator = NftFactory.deploy({"from": account})
    return nft_generator

def deploy_nft_with_metadata(nft_generator):
    account = get_account()
    count = nft_generator.counter()
    nft_generator.createNft(account, {"from": account})
    metadata_file_name = (f'./metadata/{network.show_active()}/{count}.json')
    if Path(metadata_file_name).exists():
        print('Metadata file already exists!')
    else:
        print('Creating metadata file...')
        metadata = create_metadata()
        with open(metadata_file_name, "w") as file:
            json.dump(metadata, file)    
    token_uri = upload_to_ipfs(metadata_file_name)
    token_uri_str = str(token_uri)
    tx = nft_generator.setTokenURI(count, token_uri_str, {"from": account})
    tx.wait(1)
    print(f'NFT {count} published!')
    return count

def main():
    # if NftFactory[-1] == '0x0':
    #     nft_generator = deploy_nft_generator()
    # else:
    #     nft_generator = NftFactory[-1]
    # tokenId = deploy_nft_with_metadata(nft_generator)
    # print(nft_generator)
    # print(tokenId)
    print(NftFactory[-1])
    



    '''
    view the asset here:
    https://testnets.opensea.io/assets/<your_contract_address>/<token_id>
    update the metadata here:
    https://testnets-api.opensea.io/api/v1/asset/<your_contract_address>/<token_id>/?force_update=true
    '''
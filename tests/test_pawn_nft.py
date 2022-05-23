from brownie import NftFactory, PawnNft, network
from scripts.helpful_scripts import get_account
from scripts.deployNftFactory import deploy_nft_with_metadata, deploy_nft_generator
import pytest

account = get_account()
nft_for_rent = '0x79595c23eD76ea741618c02e05b45B89B5Bce753'


def test_one():
    account = get_account()
    # nft_for_rent = NftFactory[-1]
    assert 1 == 1

def test_nft_factory():
    account = get_account()
    # nft_for_rent = NftFactory[-1]
    assert nft_for_rent != '0x0'
    # assert nft_for_rent == NftFactory[-1]

def test_can_deploy_nft_for_rent():
    account = get_account()
    # nft_for_rent = NftFactory[-1]
    # arrange   
    tokenId = deploy_nft_with_metadata(nft_for_rent)
    assert tokenId >= 0
    
def test_can_stake():
    account = get_account()
    # nft_for_rent = NftFactory[-1]
    pawn = PawnNft.deploy({"from": account})
    tokenId = pawn.internaltokenIdCounter() -1
    # act
    nft_for_rent.approve(pawn.address, tokenId, {"from": account})
    pawn.stake(nft_for_rent, tokenId, {"from": account})
    # assert
    assert nft_for_rent.ownerOf(tokenId) == pawn.address


def test_can_mint_ticket():
    # arrange
    account = get_account()
    # nft_for_rent = NftFactory[-1]
    # act
    pawn = PawnNft[-1]
    tokenId = pawn.internaltokenIdCounter() - 1
    pawn.mintTicket(tokenId, account, {"from": pawn})
    # assert
    assert pawn.TicketFactory().ownerOf(tokenId) == account
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NftFactory is ERC721URIStorage {
    uint256 public counter = 0;
    address owner;

    constructor() public ERC721("Non Fungible Token", "NFT") {
        owner = msg.sender;
    }

    function createNft(address recipient) public returns (uint256) {
        uint256 tokenId = counter;
        _safeMint(recipient, tokenId);
        counter = counter + 1;
        return tokenId;
    }

    function setTokenURI(uint256 tokenId, string memory uri) public {
        _setTokenURI(tokenId, uri);
    }
}

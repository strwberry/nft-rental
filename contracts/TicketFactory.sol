// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TicketFactory is ERC721 {
    address owner;

    constructor() public ERC721("Ticket", "TKT") {
        owner = msg.sender;
    }

    function createTicket(address recipient, uint256 tokenId) public {
        require(msg.sender == owner, "Ask the owner for a ticket");
        _safeMint(recipient, tokenId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./TicketFactory.sol";

contract PawnNft is IERC721Receiver {
    enum State {
        FOR_RENT,
        RENTED,
        RETRIEVED
    }
    uint256 public internaltokenIdCounter;
    mapping(uint256 => address) private internaltokenIdToToken;
    mapping(uint256 => uint256) private internaltokenIdToTokenId;
    mapping(uint256 => address) private internaltokenIdToLender;
    mapping(uint256 => State) private internaltokenIdToState;
    TicketFactory public s_ticketFactory;

    constructor() {
        internaltokenIdCounter = 0;
        s_ticketFactory = new TicketFactory();
    }

    // recieve for-rent-token form a lending-wallet
    function stake(address token, uint256 tokenId) public {
        uint256 internaltokenId = internaltokenIdCounter;
        internaltokenIdToToken[internaltokenId] = token;
        internaltokenIdToTokenId[internaltokenId] = tokenId;
        internaltokenIdToLender[internaltokenId] = msg.sender;
        internaltokenIdToState[internaltokenId] = State.FOR_RENT;
        internaltokenIdCounter = internaltokenIdCounter + 1;
        IERC721(token).safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // mint ticket to the lending-wallet
    function mintTicket(address recipient, uint256 tokenId) public {
        s_ticketFactory.createTicket(recipient, tokenId);
    }

    // list for-rent-token on for-rent-token-list

    // de-list for-rent-token on for-rent-token-list

    // mint a borrowed-token

    // charge the borrower-wallet

    // recieve ticket

    // burn the borrowed-token

    // burn ticket

    // send rent-money
}

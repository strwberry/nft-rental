// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../interfaces/IERC721Consumable.sol";

contract NftForRent is Ownable {
    event LeaseCreated(address newAddress);

    //address new_lease;
    address[] public lease_contracts;
    mapping(address => address[]) public lessors_contracts;
    uint256 public lease_fee_in_bps = 500;

    function create_lease(uint256 on_lease_until) public returns (address) {
        Lease new_lease = new Lease(
            lease_fee_in_bps,
            address(this),
            on_lease_until
        );
        emit LeaseCreated(address(new_lease));
        lease_contracts.push(address(new_lease));
        lessors_contracts[msg.sender].push(address(new_lease));
        //return new_lease;
    }

    function set_fees_in_bps(uint256 new_fee) public onlyOwner {
        lease_fee_in_bps = new_fee;
    }

    function get_fees_in_bps() public view returns (uint256) {
        return lease_fee_in_bps;
    }

    function get_fees_balance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw_fees(uint256 amount) public onlyOwner {
        require(
            address(this).balance >= amount,
            "Not enough balance to proceed with payment !"
        );
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed.");
    }
}

contract Lease is Ownable {
    bytes4 INTERFACE_ID_4400 = 0x953c8dfa;
    address public lessor;
    address public lease_holder;
    uint256 public lease_end_date;
    uint256 public on_lease_until;
    uint256 public lease_price;
    bool public active_lease = false;
    uint256 public lease_fee;
    address public lease_fees_recipient;
    address public nft;
    uint256 public tokenID;

    constructor(
        uint256 _lease_fee,
        address _lease_fees_recipient,
        uint256 _on_lease_until
    ) Ownable() {
        lessor = payable(msg.sender);
        lease_fee = _lease_fee;
        lease_fees_recipient = _lease_fees_recipient;
        on_lease_until = _on_lease_until;
    }

    function stake_nft(
        address _nft,
        uint256 _tokenId,
        uint256 price
    ) public onlyOwner {
        require(
            active_lease == true,
            "Cannot stake more than one NFT at a time!"
        );
        require(
            IERC721Consumable(_nft).supportsInterface(INTERFACE_ID_4400),
            "Token not supported !"
        );
        set_lease_price_per_day(price);
        active_lease = true;
        IERC721Consumable(_nft).approve(address(this), _tokenId);
        IERC721Consumable(_nft).transferFrom(lessor, address(this), _tokenId);
        nft = _nft;
        tokenID = _tokenId;
    }

    function set_lease_price_per_day(uint256 price) public onlyOwner {
        lease_price = price;
    }

    function change_lease_expiry(uint256 new_expiry) public onlyOwner {
        on_lease_until = new_expiry;
    }

    //function withdraw_nft(address _nft, uint256 tokenID) public onlyOwner {
    function withdraw_nft() public onlyOwner {
        require(active_lease == true, "Nothing to withdraw.");
        require(
            block.timestamp > lease_end_date,
            "The asset is still being leased, you cannot withdraw it."
        );
        active_lease = false;
        IERC721Consumable(nft).transferFrom(address(this), lessor, tokenID);
    }

    function rent_nft(uint256 date_to) public {
        require(
            active_lease == true,
            "There is nothing to rent in this lease contract."
        );
        if (msg.sender == lease_holder) {
            extend_rental(date_to);
        } else {
            require(
                block.timestamp > lease_end_date,
                "The asset has already been leased. Check get_lease_end_date() to learn about availability."
            );
            require(
                date_to < on_lease_until,
                "The asset cannot be rented until that date. "
            );
            //duration = date_to - block.timestamp;
            //price_per_second = (lease_price * 10**18) / (24 * 60 * 60);
            //amount_to_pay = price_per_second * duration;
            pay_the_lease(
                ((lease_price * 10**18) / (24 * 60 * 60)) *
                    (date_to - block.timestamp)
            );
            IERC721Consumable(nft).changeConsumer(msg.sender, tokenID);
            lease_end_date = date_to;
            lease_holder = msg.sender;
        }
    }

    function extend_rental(uint256 date_to) public {
        require(
            msg.sender == lease_holder,
            "The address differs from the current lease holder !"
        );
        require(
            date_to > lease_end_date,
            "You must extend the lease to a later date than the current lease end date !"
        );
        require(
            date_to < on_lease_until,
            "The asset cannot be rented until that date. "
        );
        //duration = date_to - lease_end_date;
        //price_per_second = (lease_price * 10**18) / (24 * 60 * 60);
        //amount_to_pay = price_per_second * duration;
        pay_the_lease(
            ((lease_price * 10**18) / (24 * 60 * 60)) *
                (date_to - lease_end_date)
        );
        lease_end_date = date_to;
    }

    function pay_the_lease(uint256 amount) internal {
        require(
            msg.sender.balance >= amount * (1 + lease_fee),
            "Not enough balance to proceed with payment !"
        );
        (bool success_lessor, ) = payable(lessor).call{value: amount}("");
        require(success_lessor, "Transfer failed.");
        (bool success_fees, ) = payable(lease_fees_recipient).call{
            value: (amount * lease_fee)
        }("");
        require(success_fees, "Transfer failed.");
    }

    function get_lease_price_per_day() public view returns (uint256) {
        return lease_price;
    }

    function get_lease_latest_validity_date() public view returns (uint256) {
        return on_lease_until;
    }

    // function set_lease_latest_validity_date(uint256 new_date) public onlyOwner {
    //     require(
    //         new_date > lease_end_date,
    //         "Need to set a date posterior to current lease end date."
    //     );
    //     on_lease_until = new_date;
    // }
}

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
/// @param NameOfArgument Explain what the argument is
/// @return ReturnObjectName Explain what the returned object is

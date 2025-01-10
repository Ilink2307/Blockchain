// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP20Token.sol";

contract SponsorFunding {
    address public owner;
    address public tokenAddress;
    uint256 public sponsorshipAmount;

    event SponsorshipProvided(address indexed recipient, uint256 amount);
    event SponsorshipAmountUpdated(uint256 oldAmount, uint256 newAmount);
    event TokensPurchased(uint256 amount, uint256 cost);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _tokenAddress, uint256 _initialSponsorshipAmount) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
        sponsorshipAmount = _initialSponsorshipAmount;
    }

    function updateSponsorshipAmount(uint256 newAmount) public onlyOwner {
        uint256 oldAmount = sponsorshipAmount;
        sponsorshipAmount = newAmount;
        emit SponsorshipAmountUpdated(oldAmount, newAmount);
    }

    function purchaseTokens(uint256 amount) public onlyOwner payable {
        EIP20Token token = EIP20Token(tokenAddress);
        uint256 cost = amount * token.tokenPrice(); // Assume tokenPrice() returns the price of 1 token in Ether

        require(msg.value >= cost, "Insufficient Ether sent");
        require(token.purchaseTokens{value: msg.value}(amount), "Token purchase failed");

        emit TokensPurchased(amount, cost);
    }

    function provideSponsorship(address recipient) public {
        EIP20Token token = EIP20Token(tokenAddress);
        uint256 balance = token.balanceOf(address(this));

        require(balance >= sponsorshipAmount, "Insufficient token balance for sponsorship");

        require(token.transfer(recipient, sponsorshipAmount), "Token transfer failed");
        emit SponsorshipProvided(recipient, sponsorshipAmount);
    }
}

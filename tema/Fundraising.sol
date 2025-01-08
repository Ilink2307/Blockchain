// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract FundraisingToken is ERC20, Ownable {
    uint256 public tokenPrice; // Price in wei per token

    // Event to log token purchase
    event TokensPurchased(address indexed buyer, uint256 amount);

    constructor(uint256 initialSupply, uint256 _tokenPrice) ERC20("FundraisingToken", "FUND") {
        require(_tokenPrice > 0, "Token price must be greater than zero");
        tokenPrice = _tokenPrice;
        _mint(address(this), initialSupply); // Mint all tokens to the contract itself
    }

    // Function to set a new token price (only owner can call it)
    function setTokenPrice(uint256 _tokenPrice) external onlyOwner {
        require(_tokenPrice > 0, "Token price must be greater than zero");
        tokenPrice = _tokenPrice;
    }

    // Function to buy tokens
    function buyTokens(uint256 tokenAmount) external payable {
        uint256 cost = tokenAmount * tokenPrice;
        require(msg.value >= cost, "Insufficient Ether sent");
        require(balanceOf(address(this)) >= tokenAmount, "Not enough tokens available");

        // Transfer tokens to the buyer
        _transfer(address(this), msg.sender, tokenAmount);

        // Refund excess Ether, if any
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }

        emit TokensPurchased(msg.sender, tokenAmount);
    }

    // Function to withdraw Ether collected (only owner can call it)
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No Ether to withdraw");

        payable(owner()).transfer(balance);
    }
}
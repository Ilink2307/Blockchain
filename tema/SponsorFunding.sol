// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SponsorFunding {
    address public tokenAddress;
    address public owner;
    uint256 public sponsorAmount;

    event SponsorshipSent(address indexed to, uint256 amount);

    constructor(address _tokenAddress, uint256 _sponsorAmount) {
        tokenAddress = _tokenAddress;
        owner = msg.sender;
        sponsorAmount = _sponsorAmount;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function sponsor(address _crowdFunding) public onlyOwner returns (bool) {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        if (balance >= sponsorAmount) {
            IERC20(tokenAddress).transfer(_crowdFunding, sponsorAmount);
            emit SponsorshipSent(_crowdFunding, sponsorAmount);
            return true;
        }
        return false; // Sponsorizare eșuată
    }

    function buyTokens(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount must be greater than zero");

        IERC20(tokenAddress).transferFrom(owner, address(this), _amount);
    }

    function setSponsorAmount(uint256 _newAmount) public onlyOwner {
        sponsorAmount = _newAmount;
    }
}

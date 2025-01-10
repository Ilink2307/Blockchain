// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./EIP20Token.sol";
import "./SponsorFunding.sol";

contract CrowdFunding {
    address public owner;
    address public tokenAddress;
    uint256 public fundingGoal;
    uint256 public totalFunds;
    mapping(address => uint256) public contributions;

    enum FundingState { Nefinantat, Prefinantat, Finantat }
    FundingState public state;

    event Deposit(address indexed contributor, uint256 amount);
    event Withdrawal(address indexed contributor, uint256 amount);
    event GoalReached(uint256 totalFunds);
    event SponsorshipReceived(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier inState(FundingState _state) {
        require(state == _state, "Invalid state");
        _;
    }

    constructor(address _tokenAddress, uint256 _fundingGoal) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
        fundingGoal = _fundingGoal;
        state = FundingState.Nefinantat;
    }

    function deposit(uint256 amount) public inState(FundingState.Nefinantat) {
        EIP20Token token = EIP20Token(tokenAddress);

        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        contributions[msg.sender] += amount;
        totalFunds += amount;

        emit Deposit(msg.sender, amount);

        if (totalFunds >= fundingGoal) {
            state = FundingState.Prefinantat;
            emit GoalReached(totalFunds);
        }
    }

    function withdraw(uint256 amount) public inState(FundingState.Nefinantat) {
        require(contributions[msg.sender] >= amount, "Insufficient balance");

        EIP20Token token = EIP20Token(tokenAddress);
        contributions[msg.sender] -= amount;
        totalFunds -= amount;

        require(token.transfer(msg.sender, amount), "Token transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    function requestSponsorship(address sponsorContractAddress) public onlyOwner inState(FundingState.Prefinantat) {
        SponsorFunding sponsor = SponsorFunding(sponsorContractAddress);
        sponsor.provideSponsorship(address(this)); // Sponsor sends additional tokens if available

        EIP20Token token = EIP20Token(tokenAddress);
        uint256 currentBalance = token.balanceOf(address(this));

        if (currentBalance > totalFunds) {
            state = FundingState.Finantat;
            emit SponsorshipReceived(currentBalance - totalFunds);
        }
    }

    function transferToDistributor(address distributorAddress) public onlyOwner inState(FundingState.Finantat) {
        EIP20Token token = EIP20Token(tokenAddress);
        uint256 currentBalance = token.balanceOf(address(this));

        require(token.transfer(distributorAddress, currentBalance), "Token transfer failed");
        state = FundingState.Nefinantat; // Reset the state
    }

    function getFundingState() public view returns (string memory) {
        if (state == FundingState.Nefinantat) {
            return "Nefinantat";
        } else if (state == FundingState.Prefinantat) {
            return "Prefinantat";
        } else if (state == FundingState.Finantat) {
            return "Finatat";
        }
        return "Unknown";
    }
}

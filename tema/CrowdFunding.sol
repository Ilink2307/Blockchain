// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./SponsorFunding.sol"; // Modifică "./SponsorFunding.sol" conform structurii tale de fișiere
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdFunding {
    enum FundingState { Nefinantat, Prefinantat, Finantat }
    FundingState public state;

    address public tokenAddress;
    address public owner;
    uint256 public fundingGoal;
    uint256 public totalFunds;
    mapping(address => uint256) public contributions;

    event ContributionMade(address indexed contributor, uint256 amount);
    event ContributionWithdrawn(address indexed contributor, uint256 amount);
    event FundingFinalized();
    event TotalFundsTransferred(address indexed to, uint256 amount);

    constructor(address _tokenAddress, uint256 _fundingGoal) {
        tokenAddress = _tokenAddress;
        owner = msg.sender;
        fundingGoal = _fundingGoal;
        state = FundingState.Nefinantat;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier inState(FundingState _state) {
        require(state == _state, "Invalid state");
        _;
    }

    // Contribuție către fonduri
    function contribute(uint256 _amount) public inState(FundingState.Nefinantat) {
        require(_amount > 0, "Amount must be greater than zero");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);

        contributions[msg.sender] += _amount;
        totalFunds += _amount;

        emit ContributionMade(msg.sender, _amount);

        // Verificarea dacă suma țintă a fost atinsă
        if (totalFunds >= fundingGoal) {
            state = FundingState.Prefinantat;
        }
    }

    // Retragerea fondurilor depuse
    function withdrawContribution(uint256 _amount) public inState(FundingState.Nefinantat) {
        require(contributions[msg.sender] >= _amount, "Insufficient balance");

        contributions[msg.sender] -= _amount;
        totalFunds -= _amount;

        IERC20(tokenAddress).transfer(msg.sender, _amount);
        emit ContributionWithdrawn(msg.sender, _amount);
    }

    // Finalizare finanțare și inițiere sponsorizare
    function finalizeFunding(address _sponsorFunding) public onlyOwner inState(FundingState.Prefinantat) {
        SponsorFunding sponsor = SponsorFunding(_sponsorFunding);

        if (sponsor.sponsor(address(this))) {
            // Sponsorizare reușită
            state = FundingState.Finantat;
            emit FundingFinalized();
        }
    }

    // Transferarea fondurilor către contractul de distribuție
    function transferFunds(address _distributeFunding) public onlyOwner inState(FundingState.Finantat) {
        IERC20(tokenAddress).transfer(_distributeFunding, totalFunds);
        emit TotalFundsTransferred(_distributeFunding, totalFunds);

        totalFunds = 0;
    }
}

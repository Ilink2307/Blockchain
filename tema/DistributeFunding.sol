// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP20Token.sol";

contract DistributeFunding {
    EIP20Token public token;

    struct Beneficiary {
        uint256 percentage; // Share in percentage (out of 100%)
        bool hasWithdrawn;  // Indicates if the beneficiary has already withdrawn
    }

    address public owner;
    uint256 public totalDistributed;      // Total amount received for distribution
    mapping(address => Beneficiary) public beneficiaries;
    address[] public beneficiaryList;
    uint256 public totalShares;           // Total allocated percentage (<= 100)

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier hasFunds() {
        require(totalDistributed > 0, "No funds available for distribution");
        _;
    }

    constructor(address _token) {
        token = EIP20Token(_token);
        owner = msg.sender;
    }

    /// Add a new beneficiary or update the percentage of an existing one
    function addBeneficiary(address _beneficiary, uint256 _percentage) external onlyOwner {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(totalShares + _percentage <= 100, "Total shares exceed 100%");

        if (beneficiaries[_beneficiary].percentage == 0) {
            beneficiaryList.push(_beneficiary); // Add new beneficiary
        }
        totalShares = totalShares - beneficiaries[_beneficiary].percentage + _percentage;
        beneficiaries[_beneficiary].percentage = _percentage;
    }

    /// Deposit funds for distribution (from CrowdFunding contract)
    function receiveFunds(uint256 _amount) external {
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        totalDistributed += _amount;
    }

    /// Allow each beneficiary to withdraw their proportional share
    function withdraw() external hasFunds {
        Beneficiary storage beneficiary = beneficiaries[msg.sender];
        require(beneficiary.percentage > 0, "Not a beneficiary");
        require(!beneficiary.hasWithdrawn, "Already withdrawn");

        uint256 amount = (totalDistributed * beneficiary.percentage) / 100;
        require(token.transfer(msg.sender, amount), "Token transfer failed");

        beneficiary.hasWithdrawn = true;
    }

    /// View beneficiary's share amount
    function calculateShare(address _beneficiary) public view returns (uint256) {
        Beneficiary memory beneficiary = beneficiaries[_beneficiary];
        return (totalDistributed * beneficiary.percentage) / 100;
    }

    /// View all beneficiaries
    function getBeneficiaries() external view returns (address[] memory) {
        return beneficiaryList;
    }
}

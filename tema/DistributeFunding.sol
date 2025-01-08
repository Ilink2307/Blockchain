// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DistributeFunding {
    address public tokenAddress;
    address public owner;

    struct Beneficiary {
        address wallet;
        uint256 percentage;
        bool hasWithdrawn; // Marcare retragere
    }

    Beneficiary[] public beneficiaries;

    event BeneficiaryAdded(address indexed wallet, uint256 percentage);
    event FundsWithdrawn(address indexed wallet, uint256 amount);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function addBeneficiary(address _wallet, uint256 _percentage) public onlyOwner {
        require(_wallet != address(0), "Invalid address");
        require(_percentage > 0 && _percentage <= 100, "Invalid percentage");

        beneficiaries.push(Beneficiary({wallet: _wallet, percentage: _percentage, hasWithdrawn: false}));
        emit BeneficiaryAdded(_wallet, _percentage);
    }

    function withdrawFunds() public {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        require(balance > 0, "No funds available");

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i].wallet == msg.sender && !beneficiaries[i].hasWithdrawn) {
                uint256 amount = (balance * beneficiaries[i].percentage) / 100;

                IERC20(tokenAddress).transfer(beneficiaries[i].wallet, amount);
                beneficiaries[i].hasWithdrawn = true;

                emit FundsWithdrawn(beneficiaries[i].wallet, amount);
                return;
            }
        }
        revert("You are not a beneficiary or have already withdrawn");
    }
}

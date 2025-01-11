// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract   EIP20Token {
    uint256 public totalSupply;
    uint256 constant private MAX_UINT256 = 2**256 - 1;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    string public name;
    string public symbol;
    uint8 public decimals;

    address public owner;
    uint256 public tokenPrice; // Price of 1 token in Wei

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        uint256 _tokenPrice
    ) {
        owner = msg.sender;
        totalSupply = _initialAmount;
        balances[owner] = _initialAmount;
        name = _tokenName;
        symbol = _tokenSymbol;
        decimals = _decimalUnits;
        tokenPrice = _tokenPrice;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 _allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value, "Insufficient balance");
        require(_allowance >= _value, "Allowance exceeded");

        balances[_from] -= _value;
        balances[_to] += _value;

        if (_allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function purchaseTokens(uint256 amount) public payable returns (bool) {
        uint256 totalCost = amount * tokenPrice; // Calculate the total cost in Wei
        require(msg.value >= totalCost, "Insufficient Ether sent");
        require(balances[owner] >= amount, "Not enough tokens in reserve");

        balances[owner] -= amount;
        balances[msg.sender] += amount;

        emit Transfer(owner, msg.sender, amount);

        // Refund excess Ether if there is any
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        return true;
    }

    function setTokenPrice(uint256 _newPrice) public onlyOwner {
        tokenPrice = _newPrice;
    }
}

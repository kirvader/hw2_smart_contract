pragma solidity ^0.8.0;

import "./IERC20.sol";


contract MyToken is IERC20 {

    address private owner;

    uint256 private supply = 0;
    uint256 private exchangeRate;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(uint256 initialExchangeRate) {
        owner = msg.sender;
        exchangeRate = initialExchangeRate;
    }

    function totalSupply() override external view returns (uint256) {
        return supply;
    }

    function balanceOf(address account) override external view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) override external returns (bool) {
        address from = msg.sender;
        require(balances[from] >= amount, "Insufficient balance");

        balances[from] -= amount;
        balances[to] += amount;
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowed[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(amount <= balances[sender], "Insufficient balance");
        require(amount <= allowed[sender][msg.sender], "Insufficient allowance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowed[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function buyTokens(uint256 tokensAmount) external payable returns (bool) {
        require(msg.value >= tokensAmount * exchangeRate, "Not enough Ether");

        balances[msg.sender] += tokensAmount;
        supply += tokensAmount;
        return true;
    }

    function sellTokens(uint256 tokensAmount, address payable recipient) external returns (bool) {
        require(recipient != address(0), "Invalid recipient");
        require(balances[recipient] >= tokensAmount, "Insufficient tokens");

        balances[recipient] -= tokensAmount;
        supply -= tokensAmount;
        recipient.transfer(tokensAmount * exchangeRate);
        return true;
    }
}
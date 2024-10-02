// SPDX-License-Identifier: MIT
/* yak tracks all over the place */
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

event Deposit(address indexed sender, uint256 originalTokenAmount);
event Withdraw(address indexed receiver, uint256 originalTokenAmount);

contract ERC20Amplifier is ERC20 {
    ERC20 public originalToken;
    uint256 public amplification;

    constructor(address _originalToken, uint256 _amplification, string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {
        originalToken = ERC20(_originalToken);
        amplification = _amplification;
    }
    
    function deposit(uint256 _originalTokenAmount) public {
        require(_originalTokenAmount > 0, "!gt0");

        _mint(msg.sender, _originalTokenAmount * amplification);
        originalToken.transferFrom(msg.sender, address(this), _originalTokenAmount);

        emit Deposit(msg.sender, _originalTokenAmount);
    }

    function withdraw(uint256 _originalTokenAmount) external {
        require(_originalTokenAmount > 0, "!gt0");

        _burn(msg.sender, _originalTokenAmount * amplification);
        originalToken.transfer(msg.sender, _originalTokenAmount);

        emit Withdraw(msg.sender, _originalTokenAmount);
    }
}

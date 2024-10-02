// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {ERC20Amplifier} from "../src/ERC20Amplifier.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestERC20 is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract ERC20AmplifierTest is Test {
    TestERC20 public token;
    ERC20Amplifier public amplifier;

    function setUp() public {
        token = new TestERC20("Token", "TKN");
        token.mint(address(this), 1000);

        amplifier = new ERC20Amplifier(address(token), 10**18, "Amplifier", "AMP");
        assertEq(amplifier.amplification(), 10**18);
        assertEq(amplifier.totalSupply(), 0);
        assertEq(amplifier.name(), "Amplifier");
        assertEq(amplifier.symbol(), "AMP");
        assertEq(amplifier.decimals(), 18);

        token.approve(address(amplifier), 1000);
    }

    function test_Deposit() public {
        amplifier.deposit(100);

        assertEq(token.balanceOf(address(amplifier)), 100);
        assertEq(token.balanceOf(address(this)), 900);
        assertEq(amplifier.balanceOf(address(this)), 100 * 10 ** 18);
    }

    function test_Withdraw() public {
        assertEq(token.balanceOf(address(this)), 1000);
        assertEq(amplifier.balanceOf(address(this)), 0);

        amplifier.deposit(1000);
        assertEq(token.balanceOf(address(this)), 0);
        assertEq(amplifier.balanceOf(address(this)), 1000 * 10 ** 18);

        amplifier.withdraw(100);
        assertEq(token.balanceOf(address(amplifier)), 900);
        assertEq(token.balanceOf(address(this)), 100);
        assertEq(amplifier.balanceOf(address(this)), 900 * 10 ** 18);

        amplifier.withdraw(900);
        assertEq(token.balanceOf(address(amplifier)), 0);
        assertEq(token.balanceOf(address(this)), 1000);
        assertEq(amplifier.balanceOf(address(this)), 0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyToken.sol";

contract DEX {
    MyToken public token;
    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    event LiquidityAdded(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event LiquidityRemoved(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event TokensSwapped(address indexed user, uint256 ethAmount, uint256 tokenAmount);

    constructor(address tokenAddress) {
        token = MyToken(tokenAddress);
    }

    function addLiquidity(uint256 tokenAmount) public payable {
        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed.");
        uint256 ethAmount = msg.value;
        uint256 newTotalLiquidity = totalLiquidity + ethAmount;
        liquidity[msg.sender] += ethAmount;
        totalLiquidity = newTotalLiquidity;
        emit LiquidityAdded(msg.sender, ethAmount, tokenAmount);
    }

    function removeLiquidity(uint256 ethAmount) public {
        require(liquidity[msg.sender] >= ethAmount, "Not enough liquidity provided.");
        uint256 tokenAmount = (ethAmount * token.balanceOf(address(this))) / totalLiquidity;
        liquidity[msg.sender] -= ethAmount;
        totalLiquidity -= ethAmount;
        payable(msg.sender).transfer(ethAmount);
        require(token.transfer(msg.sender, tokenAmount), "Token transfer failed.");
        emit LiquidityRemoved(msg.sender, ethAmount, tokenAmount);
    }

    function swapEthForTokens() public payable {
        uint256 ethAmount = msg.value;
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 tokenAmount = (ethAmount * tokenReserve) / address(this).balance;
        require(token.transfer(msg.sender, tokenAmount), "Token transfer failed.");
        emit TokensSwapped(msg.sender, ethAmount, tokenAmount);
    }

    function swapTokensForEth(uint256 tokenAmount) public {
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethAmount = (tokenAmount * address(this).balance) / tokenReserve;
        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed.");
        payable(msg.sender).transfer(ethAmount);
        emit TokensSwapped(msg.sender, ethAmount, tokenAmount);
    }
}
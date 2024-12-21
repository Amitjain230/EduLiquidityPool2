// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC-20 interface for the EduToken
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract EduLiquidityPool {
    IERC20 public eduToken;  // The education-specific token (EduToken)
    IERC20 public otherToken;  // Another token used in the pool

    uint256 public eduTokenReserve;
    uint256 public otherTokenReserve;

    address public owner;

    constructor(address _eduToken, address _otherToken) {
        eduToken = IERC20(_eduToken);
        otherToken = IERC20(_otherToken);
        owner = msg.sender;
    }

    // Add liquidity to the pool
    function addLiquidity(uint256 _eduTokenAmount, uint256 _otherTokenAmount) external {
        require(eduToken.transferFrom(msg.sender, address(this), _eduTokenAmount), "EduToken transfer failed");
        require(otherToken.transferFrom(msg.sender, address(this), _otherTokenAmount), "OtherToken transfer failed");

        eduTokenReserve += _eduTokenAmount;
        otherTokenReserve += _otherTokenAmount;
    }

    // Remove liquidity from the pool
    function removeLiquidity(uint256 _eduTokenAmount, uint256 _otherTokenAmount) external {
        require(eduTokenReserve >= _eduTokenAmount, "Insufficient EduToken in reserve");
        require(otherTokenReserve >= _otherTokenAmount, "Insufficient OtherToken in reserve");

        eduTokenReserve -= _eduTokenAmount;
        otherTokenReserve -= _otherTokenAmount;

        require(eduToken.transfer(msg.sender, _eduTokenAmount), "EduToken transfer failed");
        require(otherToken.transfer(msg.sender, _otherTokenAmount), "OtherToken transfer failed");
    }

    // Get the current reserves of the pool
    function getReserves() external view returns (uint256, uint256) {
        return (eduTokenReserve, otherTokenReserve);
    }

    // Emergency function to withdraw tokens (only by the owner)
    function emergencyWithdraw(uint256 _eduTokenAmount, uint256 _otherTokenAmount) external {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(eduToken.transfer(owner, _eduTokenAmount), "EduToken transfer failed");
        require(otherToken.transfer(owner, _otherTokenAmount), "OtherToken transfer failed");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EgisPool is Ownable, ReentrancyGuard {
    // State variables
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public operatorStake;
    mapping(address => bool) public isOperator;
    uint256 public totalStaked;
    uint256 public operatorMinStake;

    // Events for tracking and UI
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event OperatorRegistered(address indexed operator);
    event RewardDistributed(address indexed user, uint256 amount);

    /* _operatorMinStake: Minimum stake in wei required for an operator to register. */
    constructor(uint256 _operatorMinStake) Ownable(msg.sender) {
        operatorMinStake = _operatorMinStake;
    }

    // Native staking function
    function stake() external payable nonReentrant {
        require(msg.value > 0, "Must stake non-zero amount");
        stakedAmount[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    // Register as operator
    function registerOperator() external payable {
        require(msg.value >= operatorMinStake, "Insufficient stake for operator");
        require(!isOperator[msg.sender], "Already registered");

        isOperator[msg.sender] = true;
        operatorStake[msg.sender] = msg.value;
        totalStaked += msg.value;

        emit OperatorRegistered(msg.sender);
    }

    // Basic reward distribution (to be expanded)
    function distributeRewards() external onlyOwner {
        // Implement reward distribution logic
    }

    // View functions for UI/CLI
    function getStakeInfo(address user) external view returns (uint256 userStake, bool userIsOperator) {
        return (stakedAmount[user], isOperator[user]);
    }
}

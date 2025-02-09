// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EgisPool is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Structs
    struct EVE {
        bool isRegistered;
        address rewardToken;
        uint256 lastDistributionTime;
    }

    struct RewardEpoch {
        uint256 totalRewardAmount;
        uint256 totalStakedAtDistribution;
        uint256 distributionTime;
        mapping(address => bool) claimed;
    }

    // State variables
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public operatorStake;
    mapping(address => bool) public isOperator;
    mapping(address => EVE) public registeredEVEs;
    mapping(address => mapping(uint256 => RewardEpoch)) public rewardEpochs;
    mapping(address => uint256) public currentEpochByEVE;

    uint256 public totalStaked;
    uint256 public operatorMinStake;

    // Events for tracking and UI
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event OperatorRegistered(address indexed operator);
    event RewardDistributed(address indexed user, uint256 amount);
    event EVERegistered(address indexed eve, address rewardToken);

    event RewardsDistributed(address indexed eve, uint256 epoch, uint256 amount);
    event RewardsClaimed(address indexed operator, address indexed eve, uint256 epoch, uint256 amount);

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

    // Distribute rewards for an epoch
    function distributeRewards(uint256 amount) external nonReentrant onlyOwner {
        require(registeredEVEs[msg.sender].isRegistered, "EVE not registered");
        require(amount > 0, "Amount must be greater than 0");

        EVE storage eve = registeredEVEs[msg.sender];
        uint256 currentEpoch = currentEpochByEVE[msg.sender];

        // Transfer rewards to this contract
        IERC20(eve.rewardToken).safeTransferFrom(msg.sender, address(this), amount);

        // Setup new reward epoch
        RewardEpoch storage epoch = rewardEpochs[msg.sender][currentEpoch];
        epoch.totalRewardAmount = amount;
        epoch.totalStakedAtDistribution = totalStaked;
        epoch.distributionTime = block.timestamp;

        eve.lastDistributionTime = block.timestamp;
        currentEpochByEVE[msg.sender] = currentEpoch + 1;

        emit RewardsDistributed(msg.sender, currentEpoch, amount);
    }

    // Register an EVE with its reward token
    function registerEVE(address rewardToken) external {
        require(!registeredEVEs[msg.sender].isRegistered, "EVE already registered");
        require(rewardToken != address(0), "Invalid reward token");

        registeredEVEs[msg.sender] =
            EVE({isRegistered: true, rewardToken: rewardToken, lastDistributionTime: block.timestamp});

        emit EVERegistered(msg.sender, rewardToken);
    }

    }

    // View functions for UI/CLI
    function getStakeInfo(address user) external view returns (uint256 userStake, bool userIsOperator) {
        return (stakedAmount[user], isOperator[user]);
    }
}

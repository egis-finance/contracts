// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/EgisRewards.sol";
import "forge-std/Test.sol";

contract EgisRewardsTest is Test {
    using EgisRewards for uint256;

    uint256 constant PRECISION = 1e18;

    function testExactRewardCalculation() public pure {
        uint256 operatorStake = 500 * 1e18; // 500 tokens
        uint256 totalStaked = 1000 * 1e18; // 1000 tokens
        uint256 totalReward = 100 * 1e18; // 100 reward tokens

        uint256 expectedReward = 50 * 1e18; // Should get exactly 50 tokens
        uint256 calculatedReward = EgisRewards.calculateReward(operatorStake, totalReward, totalStaked);

        assertEq(calculatedReward, expectedReward, "Reward calculation mismatch");
    }

    function testRewardCalculationRounding() public pure {
        uint256 operatorStake = 333333333333333333333; // 333.333333333333333333 tokens
        uint256 totalStaked = 1000 * 1e18; // 1000 tokens
        uint256 totalReward = 100 * 1e18; // 100 reward tokens

        EgisRewards.RewardCalculation memory calc =
            EgisRewards.calculateRewardDetailed(operatorStake, totalReward, totalStaked);

        // Precision loss occurs due to division rounding in integer arithmetic
        // When dividing operatorStake * totalReward by totalStaked, any non-divisible
        // remainder is truncated, causing a loss of precision in the final token amount
        // Example: 333.333... * 100 / 1000 = 33.3333... but integers truncate decimals
        // This is normal for Solidity and not a flaw, but needs to be considered in the
        // token economics design to ensure fair distribution over time.
        assertTrue(calc.precisionLoss > 0, "Should have precision loss");
        // 333.333333333333333333/1000 * 100 = 33.3333333333333333333 tokens
        uint256 expectedRawAmount = (operatorStake * totalReward) / totalStaked;
        assertEq(calc.rawAmount, expectedRawAmount, "Incorrect raw amount");
    }

    function testAPRCalculation() public pure {
        uint256 rewardAmount = 100 * 1e18; // 100 tokens reward
        uint256 stakingPeriod = 30 days; // 30 day period
        uint256 totalStaked = 1000 * 1e18; // 1000 tokens staked

        uint256 apr = EgisRewards.calculateAPR(rewardAmount, stakingPeriod, totalStaked);

        // Expected APR should be about 121.7% (1.217 * 1e18)
        // (100/1000) * (365/30) = 1.217
        assertTrue(apr >= 1.215 * 1e18 && apr <= 1.219 * 1e18, "APR out of expected range");
    }

    function testDistributionFairness() public pure {
        uint256[] memory stakes = new uint256[](3);
        stakes[0] = 300 * 1e18; // 300 tokens
        stakes[1] = 500 * 1e18; // 500 tokens
        stakes[2] = 200 * 1e18; // 200 tokens

        uint256[] memory rewards = new uint256[](3);
        rewards[0] = 30 * 1e18; // 30 tokens
        rewards[1] = 50 * 1e18; // 50 tokens
        rewards[2] = 20 * 1e18; // 20 tokens

        uint256 totalReward = 100 * 1e18; // 100 tokens total reward
        uint256 totalStaked = 1000 * 1e18; // 1000 tokens total staked
        uint256 maxDeviation = 0.01 * 1e18; // 1% maximum deviation allowed

        bool isFair = EgisRewards.isDistributionFair(rewards, stakes, totalReward, totalStaked, maxDeviation);
        assertTrue(isFair, "Distribution should be fair");
    }

    function testEdgeCases() public pure {
        // Test minimum stake (using larger proportion to avoid rounding to zero)
        uint256 minStakeReward = EgisRewards.calculateReward(1e15, 100 * 1e18, 1000 * 1e18);
        assert(minStakeReward > 0);

        // Test maximum stake (equal to total)
        uint256 maxStakeReward = EgisRewards.calculateReward(1000 * 1e18, 100 * 1e18, 1000 * 1e18);
        assert(maxStakeReward == 100 * 1e18);
    }

    function testZeroStakeRevert() public {
        vm.expectRevert("Division by zero");
        EgisRewards.calculateReward(100 * 1e18, 100 * 1e18, 0);
    }
}

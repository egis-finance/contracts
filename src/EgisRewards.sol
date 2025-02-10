// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library EgisRewards {
    uint256 constant PRECISION = 1e18;
    uint256 constant YEAR_IN_SECONDS = 365 days;

    struct RewardCalculation {
        uint256 rawAmount;
        uint256 precisionLoss;
    }

    /**
     * @dev Calculates reward amount with high precision
     * @param operatorStake The stake amount of the operator
     * @param totalReward Total reward amount to distribute
     * @param totalStaked Total staked amount in the pool
     * @return RewardCalculation struct containing calculation details
     */
    function calculateRewardDetailed(uint256 operatorStake, uint256 totalReward, uint256 totalStaked)
        internal
        pure
        returns (RewardCalculation memory)
    {
        require(totalStaked > 0, "Division by zero");
        require(operatorStake <= totalStaked, "Invalid stake amount");

        // Calculate reward with maximum precision
        uint256 scaledReward = (operatorStake * totalReward);
        uint256 rawReward = scaledReward / totalStaked;

        // Calculate actual precision loss
        uint256 precisionLoss = scaledReward % totalStaked;

        return RewardCalculation({rawAmount: rawReward, precisionLoss: precisionLoss});
    }

    /**
     * @dev Simplified reward calculation
     */
    function calculateReward(uint256 operatorStake, uint256 totalReward, uint256 totalStaked)
        internal
        pure
        returns (uint256)
    {
        return calculateRewardDetailed(operatorStake, totalReward, totalStaked).rawAmount;
    }

    /**
     * @dev Calculates APR based on reward rate and staking period
     * @param rewardAmount Amount of rewards distributed
     * @param stakingPeriod Period over which rewards were distributed (in seconds)
     * @param totalStaked Total amount staked
     * @return APR with PRECISION decimals (1e18 = 100%)
     */
    function calculateAPR(uint256 rewardAmount, uint256 stakingPeriod, uint256 totalStaked)
        internal
        pure
        returns (uint256)
    {
        require(stakingPeriod > 0, "Invalid period");
        require(totalStaked > 0, "No stake");

        // Calculate APR: (rewardAmount * PRECISION / totalStaked) * YEAR_IN_SECONDS / stakingPeriod
        // Reorder operations to prevent overflow and maintain precision
        return (rewardAmount * PRECISION / totalStaked) * YEAR_IN_SECONDS / stakingPeriod;
    }

    /**
     * @dev Validates that a reward distribution is fair
     * @return bool indicating if the distribution is fair
     */
    function isDistributionFair(
        uint256[] memory rewards,
        uint256[] memory stakes,
        uint256 totalReward,
        uint256 totalStaked,
        uint256 maxDeviation
    ) internal pure returns (bool) {
        require(rewards.length == stakes.length, "Array length mismatch");
        uint256 totalDistributed;

        for (uint256 i = 0; i < rewards.length; i++) {
            uint256 expectedReward = calculateReward(stakes[i], totalReward, totalStaked);
            uint256 deviation;

            if (rewards[i] > expectedReward) {
                deviation = rewards[i] - expectedReward;
            } else {
                deviation = expectedReward - rewards[i];
            }

            if (deviation * PRECISION / expectedReward > maxDeviation) {
                return false;
            }

            totalDistributed += rewards[i];
        }

        // Ensure total distributed amount matches total reward
        return totalDistributed <= totalReward;
    }
}

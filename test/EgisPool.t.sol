// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {EgisPool} from "../src/EgisPool.sol";

contract EggPoolTest is Test {
    EgisPool public pool;

    function setUp() public {
        pool = new EgisPool(1);
    }

    function _setupStake(uint256 amount) internal {
        // Deal exact amount needed for stake + operator registration
        vm.deal(address(this), amount + 1);
        pool.registerOperator{value: 1}();
        pool.stake{value: amount}();
    }

    function test_Stake() public {
        uint256 amount = 1000 gwei;
        _setupStake(amount);
        // Check combined stake (amount + operator registration)
        (uint256 staked, bool isOp) = pool.getStakeInfo(address(this));
        assertEq(staked, amount);
        assertTrue(isOp);
    }

    function testFuzz_Stake(uint256 x) public {
        vm.assume(x > 0 && x < type(uint256).max - 1);
        _setupStake(x);
        (uint256 staked, bool isOp) = pool.getStakeInfo(address(this));
        assertEq(staked, x);
        assertTrue(isOp);
    }
}


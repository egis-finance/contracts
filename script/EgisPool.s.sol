// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EgisPool} from "../src/EgisPool.sol";

contract EgisPoolScript is Script {
    EgisPool public pool;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        pool = new EgisPool(1);

        vm.stopBroadcast();
    }
}

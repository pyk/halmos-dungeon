// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {Test, console} from "forge-std/Test.sol";
import {HookTakeover} from "src/L2_HookTakeover.sol";

contract HookTakeoverTest is SymTest, Test {
    HookTakeover public target;

    function setUp() public {
        target = new HookTakeover(address(this));
    }

    function check_invariant() public {
        address caller = svm.createAddress("caller");

        vm.assume(caller != address(this));

        vm.startPrank(caller);
        target.execute();
        vm.stopPrank();

        assertTrue(target.exploited() == false);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SymTest} from "halmos-cheatcodes/SymTest.sol";

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is SymTest, Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter(10);
    }

    function check_increment() public {
        counter.increment();

        assertEq(counter.number(), 10);
    }

    function check_increment_multiple_paths() public {
        bool success;

        // Execute an arbitrary tx
        // (success,) = address(counter).call(svm.createCalldata("Counter")); // excluding view functions
        // vm.assume(success);
        for (uint256 i = 0; i < 10; i++) {
            (success,) = address(counter).call(svm.createCalldata("Counter")); // excluding view functions
            vm.assume(success);
        }

        assertEq(counter.number(), 10);
    }
}

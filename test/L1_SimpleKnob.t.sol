// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {Test, console} from "forge-std/Test.sol";
import {SimpleKnob} from "src/L1_SimpleKnob.sol";

contract SimpleKnobTest is SymTest, Test {
    SimpleKnob public target;

    function setUp() public {
        target = new SimpleKnob();
    }

    function check_invariant() public {
        bool success;

        for (uint256 i = 0; i < 10; i++) {
            (success,) = address(target).call(svm.createCalldata("SimpleKnob")); // excluding view functions
            vm.assume(success);
        }

        assertEq(target.property(), 1 ether);
    }
}

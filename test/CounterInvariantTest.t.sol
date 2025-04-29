// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterInvariantTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter(10);
    }

    function invariant_number() public view {
        assertEq(counter.number(), 10);
    }
}

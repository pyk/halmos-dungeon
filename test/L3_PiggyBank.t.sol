// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {Test, console} from "forge-std/Test.sol";
import {PiggyBank, Token} from "src/L3_PiggyBank.sol";

contract PiggyBankTest is SymTest, Test {
    PiggyBank public target;
    Token token;

    function setUp() public {
        token = new Token();
        target = new PiggyBank(token);
    }

    /**
     * This test is passed, even tho the actor:
     * 1. Does not explicitly we call the balance
     * 2. Does not explicitly approve the target contract to spend the balance
     *
     * Here is why:
     * - vm.assume force Halmos to consider only states where the balance is sufficient
     * - we didn't constrain the allowance state
     * - Halmos found a possible (symbolic) state where both balance and allowance were
     *   sufficient for the transferFrom to succeed and the final assertions to hold true.
     *   Since it found a path where the assertions pass, the test [PASS]es.
     */
    function check_deposit() public {
        address actor = address(this);
        uint256 amount = svm.createUint256("amount");
        uint256 actorBalance = token.balanceOf(actor);
        vm.assume(actorBalance == amount);

        vm.startPrank(actor);
        target.deposit(amount);
        vm.stopPrank();

        uint256 afterBalance = token.balanceOf(address(target));
        assertTrue(amount == afterBalance);
        assertEq(token.balanceOf(actor), actorBalance - amount);
    }
}

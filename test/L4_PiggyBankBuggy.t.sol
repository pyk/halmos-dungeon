// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {Test, console} from "forge-std/Test.sol";
import {PiggyBankBuggy, Token} from "src/L4_PiggyBankBuggy.sol";

contract PiggyBankBuggyTest is SymTest, Test {
    PiggyBankBuggy public target;
    Token token;

    function setUp() public {
        token = new Token();
        target = new PiggyBankBuggy(token);
    }

    /**
     * Deposit
     */
    function getSelector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

    function check_invariant() public {
        address user = svm.createAddress("user");
        address attacker = svm.createAddress("attacker");

        uint256 userDepositAmount = svm.createUint256("user_deposit_amount");
        uint256 attackerDepositAmount = svm.createUint256("attacker_deposit_amount");
        uint256 attackerWithdrawAmount = svm.createUint256("attacker_withdraw_amount");

        // Assume user & attacker have deposits
        vm.assume(token.balanceOf(user) == userDepositAmount);
        vm.assume(target.getDeposit(user) == userDepositAmount);

        vm.assume(token.balanceOf(attacker) == attackerDepositAmount);
        vm.assume(target.getDeposit(attacker) == attackerDepositAmount);
        vm.assume(attackerWithdrawAmount <= userDepositAmount + attackerDepositAmount);

        vm.assume(token.balanceOf(address(target)) == userDepositAmount + attackerDepositAmount);

        // Lets attacker explore all possible paths to gain more token
        uint256 maxCalls = 10;
        for (uint256 i = 0; i < maxCalls; i++) {
            vm.startPrank(attacker);
            (bool success,) = address(target).call(svm.createCalldata("PiggyBankBuggy"));
            vm.stopPrank();
            vm.assume(success);
        }

        vm.startPrank(attacker);
        target.withdraw(attackerWithdrawAmount);
        vm.stopPrank();

        assertEq(token.balanceOf(attacker), attackerDepositAmount);
    }
}

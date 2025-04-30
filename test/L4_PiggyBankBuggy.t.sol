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

        // Assume user & attacker have deposits
        vm.assume(token.balanceOf(user) == userDepositAmount);
        vm.assume(target.getDeposit(user) == userDepositAmount);

        vm.assume(token.balanceOf(user) == attackerDepositAmount);
        vm.assume(target.getDeposit(attacker) == attackerDepositAmount);

        vm.assume(token.balanceOf(address(target)) == userDepositAmount + attackerDepositAmount);

        // Lets attacker explore all possible paths to gain more token
        uint256 maxCalls = 10;
        bytes memory lastCallData;
        for (uint256 i = 0; i < maxCalls; i++) {
            vm.startPrank(attacker);
            lastCallData = svm.createCalldata("PiggyBankBuggy");
            (bool success,) = address(target).call(lastCallData);
            vm.stopPrank();
            vm.assume(success);
        }

        // TODO: I want to validate whether last call is PiggyBankBuggy.withdraw
        bytes4 selector;
        if (lastCallData.length >= 4) {
            assembly {
                // lastCallData holds the memory address (pointer) of the array.
                // The actual data starts 32 bytes *after* this pointer (skip the length field).
                // Load the first 32 bytes of the data.
                let word := mload(add(lastCallData, 0x20))
                // Assign the first 4 bytes (most significant) to the bytes4 variable.
                // Casting from bytes32 to bytes4 takes the high-order bytes.
                selector := word
            }
            // 'selector' now holds the first 4 bytes.
        } else {
            // Handle the case where the data is too short (e.g., revert or set default)
            revert("Data too short to extract selector");
        }

        vm.assume(selector == PiggyBankBuggy.withdraw.selector);

        assertEq(token.balanceOf(attacker), attackerDepositAmount);
    }
}

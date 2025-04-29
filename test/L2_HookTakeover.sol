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

    // Invariant: exploited should always be false.
    // Halmos should find a sequence of calls to break this.
    function check_invariant(address caller) public {
        bool success;

        vm.assume(caller != address(this));

        // Allow Halmos to explore sequences of calls (e.g., up to 5 steps)
        // Needs at least 3 for toggle -> setHook -> execute
        uint256 maxCalls = 5;

        for (uint256 i = 0; i < maxCalls; i++) {
            // Let Halmos generate a symbolic call to any function in HookTakeover.
            // By default, the msg.sender for these calls will be address(this),
            // which is the "attacker" in this scenario.
            // Halmos can choose to call toggle(), setHook(address(this)), execute(), etc.
            vm.startPrank(caller);
            (success,) = address(target).call(svm.createCalldata("HookTakeover"));
            vm.stopPrank();

            // Only follow paths where the individual call succeeded.
            // This prevents exploring paths like calling setHook before toggle.
            vm.assume(success);
        }

        // After Halmos executes a sequence of successful calls (found via svm.createCalldata),
        // check if the invariant still holds. Halmos should find the sequence:
        // 1. toggle() - success=true
        // 2. setHook(address(this)) - success=true (status is now true)
        // 3. execute() - success=true (hook is now address(this))
        // which leads to exploited == true, failing this assertion.
        assertEq(target.exploited(), false, "Invariant Broken: exploited is true");
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

/**
 * @title HookTakeover
 * @author pyk
 * @notice toggle() setHook() execute() -> 🐲
 * @dev This HookTakeover contract is used to test Halmos
 */
contract HookTakeover {
    bool public exploited;

    address hook;
    bool status;

    constructor(address _hook) {
        hook = _hook;
        exploited = false;
        status = false;
    }

    function execute() external {
        require(msg.sender == hook);
        exploited = true;
    }

    function setHook(address newHook) external {
        if (status) {
            hook = newHook;
        } else {
            revert(unicode"💀");
        }
    }

    function toggle() external {
        status = !status;
    }
}

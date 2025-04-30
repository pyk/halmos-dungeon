// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

contract LimitOrderManager {
    struct PoolKey {
        uint256 id;
    }

    constructor() {}

    function createLimitOrder(bool isToken0, int24 targetTick, uint256 amount, PoolKey calldata key) external {}
}

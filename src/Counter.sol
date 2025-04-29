// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
    uint256 a;
    uint256 b;

    constructor(uint256 value) {
        number = value;
        a = 12;
        b = 1200;
    }

    function increment() public {
        if (a == 20 && b == 100) {
            number += 10;
        }
    }

    function setAButton(uint256 value) external {
        a = value;
    }

    function setBButton(uint256 value) external {
        b = value;
    }
}

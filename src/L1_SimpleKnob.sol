// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

/**
 * @title SimpleKnob
 * @author pyk
 * @notice one() two() three() -> 🐲
 * @dev This SimpleKnob contract is used to test Halmos
 */
contract SimpleKnob {
    uint256 public property;
    uint256 internal _one;
    uint256 internal _two;

    constructor() {
        property = 1 ether;
    }

    function one() external {
        _one = 1 ether;
    }

    function two() external {
        if (_one == 1 ether) {
            _two = 2 ether;
        } else {
            revert(unicode"💀");
        }
    }

    function three() external {
        if (_one == 1 ether && _two == 2 ether) {
            property = 3 ether;
        } else {
            revert(unicode"💀");
        }
    }
}

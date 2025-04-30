// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("TEST", "TEST") {}
}

contract PiggyBank {
    ERC20 token;

    constructor(ERC20 _token) {
        token = _token;
    }

    function deposit(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
    }
}

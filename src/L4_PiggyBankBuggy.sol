// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("TEST", "TEST") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/**
 * @title PiggyBankBuggy
 * @author pyk
 * @notice I want to test wether I can use halmos to exploit this vulnerable
 * @dev setRequired() -> disableCheck() -> withdraw()
 */
contract PiggyBankBuggy {
    ERC20 token;
    mapping(address => uint256) deposits;
    bool checkWithdraw;
    uint256 required;

    constructor(ERC20 _token) {
        token = _token;
        checkWithdraw = true;
        required = 0;
    }

    function setRequired(uint256 value) external {
        required = value;
    }

    function disableCheck() external {
        if (required == 42 ether) {
            checkWithdraw = false;
        }
    }

    function deposit(uint256 amount) external {
        deposits[msg.sender] += amount;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) external {
        if (checkWithdraw) {
            require(amount <= deposits[msg.sender]);
        }
        token.transfer(msg.sender, amount);
    }

    function getDeposit(address user) external view returns (uint256 amount) {
        amount = deposits[user];
    }
}

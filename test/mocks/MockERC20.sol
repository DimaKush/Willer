// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(uint256 initialSupply) ERC20("MockToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }
} 
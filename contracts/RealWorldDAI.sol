// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealWorldDAI is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("RealWorldDAI2", "RWDAI2") {
        _mint(0x0ed972B76b14184856d79eAC93a4bFE949A16F9D, 10 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

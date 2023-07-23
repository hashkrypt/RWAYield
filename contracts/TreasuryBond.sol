pragma solidity ^0.8.18;

import "erc-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title A mintable and burnable erc20 token representing a treasury bond
 *        in real world this would be a security token erc1400 etc
 */
contract TreasuryBond is ERC20Burnable {
    uint256 price = 1 wei;
    constructor() ERC20("TreasuryBond", "TB") {}

    function BuyTreasuryBond() external payable {
        if(msg.value >= price) {
             _mint(msg.sender, 1);
        }
    }

    function mint(uint256 amount) external{
        _mint(msg.sender, amount);
    }
}
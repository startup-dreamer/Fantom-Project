// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ERC20UpgradeableModified is OwnableUpgradeable, ERC20Upgradeable {
    bool public forSale;
    uint256 public salePrice;
    bool public canRedeem;

    function putForSale(uint256 amount_) internal onlyOwner initializer {
        forSale = true;
        salePrice = amount_;
    }

    function purchase() internal {
        require(forSale, "NOT_FOR_SALE");
        require(msg.value == salePrice, "INVALID_SALE_PRICE");
        forSale = false;
        canRedeem = true;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Modified is ERC20 {
    address immutable owner;
    bool public forSale;
    uint256 public salePrice;
    bool public canRedeem;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "ERR_CALLER_IS_NOT_TOKEN_OWNER");
        _;
    }

    constructor(string memory name_, string memory symbol_, address owner_) ERC20(name_, symbol_) {
        owner = owner_;
    }

    function mint(address to_, uint256 amount_) public onlyOwner {
        _mint(to_, amount_);
    }

    function burn(address to_, uint256 amount_) public onlyOwner {
        _burn(to_, amount_);
    }

    function putForSale(uint256 amount_) public onlyOwner {
        forSale = true;
        salePrice = amount_;
    }

    function purchase() public payable {
        require(forSale, "NOT_FOR_SALE");
        require(msg.value == salePrice, "INVALID_SALE_PRICE");
        forSale = false;
        canRedeem = true;
    }
}
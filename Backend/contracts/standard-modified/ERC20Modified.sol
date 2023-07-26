// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Modified is ERC20 {
    address immutable public _owner;
    bool public isForSale;
    uint256 public salePrice;
    bool public canRedeem;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "ONLY_OWNER_ALLOWED");
        _;
    }

    constructor(string memory name_, string memory symbol_, address owner_, uint256 amount_) ERC20(name_, symbol_) {
        _owner = owner_;
        _mint(owner_, amount_);
    }

    // function mint(address to_, uint256 amount_) public onlyOwner {
    //     _mint(to_, amount_);
    // }

    // function burn(address to_, uint256 amount_) public onlyOwner {
    //     _burn(to_, amount_);
    // }

    /**
     * @dev Puts the fractional NFT up for sale at a specified price.
     * @param price_ The sale price of the fractional NFT.
     */
    function putForSale(uint256 price_) public onlyOwner {
        salePrice = price_;
        isForSale = true;
    }

    /**
     * @dev Allows a buyer to purchase the fractional NFT by paying the sale price.
     */
    function purchase() public payable {
        require(isForSale, "NOT_FOR_SALE");
        require(msg.value == salePrice, "INVALID_SALE_PRICE");
        isForSale = false;
        canRedeem = true;
    }

    /**
     * @dev Redeems a specified amount of ERC20 tokens for a proportional amount of the sale price.
     * @param amount_ The amount of ERC20 tokens to redeem.
     */
    function redeemToken(uint256 amount_) public {
        require(canRedeem, "CAN_NOT_REDEEM_TOKEN_YET");
        require(
            IERC20(address(this)).balanceOf(msg.sender) == amount_,
            "INVALID_AMOUNT_FOR_REDEMPTION"
        );
        uint256 redeemAmount = (salePrice * amount_) / totalSupply();
        _burn(msg.sender, amount_);
        (bool success, ) = payable(msg.sender).call{value: redeemAmount}("");
        require(success, "VALUE_TRANSFER_FAILED");
    }
}

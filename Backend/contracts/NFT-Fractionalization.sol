// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Fractional_NFT is ERC20, Ownable, ERC20Permit, ERC721Holder{
    IERC721 immutable nftcontract;
    uint256 public tokenId;
    uint256 public salePrice;
    bool public canRedeem;
    bool public forSale;

    constructor(string memory name_, string memory symbol_, address nftcontract_) 
    ERC20(name_, symbol_) 
    Ownable()
    ERC20Permit(name_) {
        nftcontract = IERC721(nftcontract_);
    }

    function transferNFT(uint256 tokenId_, uint256 amount_) external onlyOwner {
        require(amount_ > 0, "AMOUNT_SHOULD_BE_GREATER_THAN_ZERO");
        require(nftcontract.ownerOf(tokenId_) == msg.sender, "SEND_IS_NOT_OWNER");
        nftcontract.safeTransferFrom(msg.sender, address(this), tokenId_);
        tokenId = tokenId_;
        _mint(msg.sender, amount_);
    }

    function putForSale(
        uint256 price_
        ) external {
        salePrice = price_;
        forSale = true;
    }

    function purchase() external payable {
        require(forSale, "NOT_FOR_SALE");
        require(msg.value == salePrice, "INVALID_SALE_PRICE");
        nftcontract.transferFrom(address(this), msg.sender, tokenId);
        forSale = false;
        canRedeem = true;
    }

    function redeemToken(
        uint256 amount_
        ) external {
        require(canRedeem, "CAN'T_REDEEM_TOKEN_YET");
        require(IERC20(address(this)).balanceOf(msg.sender) == amount_, "INVALID_AMOUNT_FOR_REDEMPTION");
        uint256 redeemAmount = salePrice * (amount_ / totalSupply());
        _burn(msg.sender, amount_);
        payable(msg.sender).transfer(redeemAmount);
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Fractional_NFT
 * @dev A contract that allows fractional ownership of an NFT and enables lending and redemption of NFT fractions.
 */
contract Fractional_NFT is ERC20, Ownable, ERC20Permit, ERC721Holder {
    IERC721 immutable nftcontract;
    uint256 public tokenId;
    uint256 public salePrice;
    bool public canRedeem;
    bool public forSale;

    /**
     * @dev Initializes the Fractional_NFT contract.
     * @param name_ The name of the ERC20 token.
     * @param symbol_ The symbol of the ERC20 token.
     * @param nftcontract_ The address of the ERC721 contract.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address nftcontract_
    ) ERC20(name_, symbol_) Ownable() ERC20Permit(name_) {
        nftcontract = IERC721(nftcontract_);
    }

    /**
     * @dev Transfers an NFT to the contract and mints ERC20 tokens to the owner.
     * @param tokenId_ The ID of the NFT being transferred.
     * @param amount_ The amount of ERC20 tokens to mint to the owner.
     */
    function transferNFT(uint256 tokenId_, uint256 amount_) external onlyOwner {
        require(amount_ > 0, "AMOUNT_SHOULD_BE_GREATER_THAN_ZERO");
        require(
            nftcontract.ownerOf(tokenId_) == msg.sender,
            "SENDER_IS_NOT_OWNER"
        );
        nftcontract.safeTransferFrom(msg.sender, address(this), tokenId_);
        tokenId = tokenId_;
        _mint(msg.sender, amount_);
    }

    /**
     * @dev Puts the fractional NFT up for sale at a specified price.
     * @param price_ The sale price of the fractional NFT.
     */
    function putForSale(uint256 price_) external {
        salePrice = price_;
        forSale = true;
    }

    /**
     * @dev Allows a buyer to purchase the fractional NFT by paying the sale price.
     */
    function purchase() external payable {
        require(forSale, "NOT_FOR_SALE");
        require(msg.value == salePrice, "INVALID_SALE_PRICE");
        nftcontract.transferFrom(address(this), msg.sender, tokenId);
        forSale = false;
        canRedeem = true;
    }

    /**
     * @dev Redeems a specified amount of ERC20 tokens for a proportional amount of the sale price.
     * @param amount_ The amount of ERC20 tokens to redeem.
     */
    function redeemToken(uint256 amount_) external {
        require(canRedeem, "CAN'T_REDEEM_TOKEN_YET");
        require(
            IERC20(address(this)).balanceOf(msg.sender) == amount_,
            "INVALID_AMOUNT_FOR_REDEMPTION"
        );
        uint256 redeemAmount = (salePrice * amount_) / totalSupply();
        _burn(msg.sender, amount_);
        payable(msg.sender).transfer(redeemAmount);
    }
}

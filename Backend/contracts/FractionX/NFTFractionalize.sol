// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC721Modified.sol";
import "./ERC20Modified.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract NFTFractionlize is ERC721Holder, Context {
    mapping(IERC721Modified => address) public contractToOwner;

    struct data {
        address liquidator_;
        IERC721Modified nftcontract_;
        ERC20Modified erc20contract_;
        uint256 tokenId_;
        uint256 tokenAmount_;
    }
    mapping(address => data) public ownerData;

    function transferNFT(address nftcontract_, uint256 tokenId_, uint256 amount_) external {
        require(amount_ > 0, "TOKEN_AMOUNT_CAN'T_BE_ZERO");
        IERC721Modified nftcontract = IERC721Modified(nftcontract_);
        require(nftcontract.ownerOf(tokenId_) == _msgSender(), "SENDER_IS_NOT_OWNER");
        contractToOwner[nftcontract] = _msgSender();
        _transferMint(nftcontract, tokenId_, amount_);
    }

    function _transferMint(IERC721Modified nftcontract_, uint256 tokenId_, uint256 amount_) internal {
        ERC20Modified erc20 = new ERC20Modified(nftcontract_.name(), nftcontract_.symbol(), _msgSender());

        data memory da = data({
            liquidator_: _msgSender(),
            nftcontract_: nftcontract_,
            erc20contract_: erc20,
            tokenId_: tokenId_,
            tokenAmount_: amount_
        });
        ownerData[_msgSender()] = da;

        nftcontract_.safeTransferFrom(da.liquidator_, address(this), da.tokenId_);
        erc20.mint(da.liquidator_, da.tokenAmount_);
    }

    function putForSale(uint256 amount_) external {
        data storage da = ownerData[_msgSender()];
        require(da.liquidator_ == _msgSender(), "ERR_SENDER_IS_NOT_LIQUIDATOR");
        da.erc20contract_.putForSale(amount_);
    }

    function purchase(address erc20TokenAddress_) external payable {
        data storage da = ownerData[_msgSender()];
        da.nftcontract_.safeTransferFrom(address(this), _msgSender(), da.tokenId_);
        da.erc20contract_.purchase();
    }

    function redeemToken(uint256 amount_) external {
        data storage da = ownerData[_msgSender()];
        require(da.erc20contract_.canRedeem(), "CAN'T_REDEEM_TOKEN_YET");
        require(da.erc20contract_.balanceOf(_msgSender()) == amount_, "INVALID_AMOUNT_FOR_REDEMPTION");
        uint256 salePrice = uint256(da.erc20contract_.salePrice());
        uint256 redeemAmount = (salePrice * amount_) / da.erc20contract_.totalSupply();
        da.erc20contract_.burn(_msgSender(), amount_);
        (bool success, ) = payable(msg.sender).call{value: redeemAmount}("");
        require(success, "ERR_VALUE_NOT_TRANSFERED");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interface/IERC721Modified.sol";
import "../standard-modified/ERC20Modified.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTFractionalize is ERC721Holder, Context {
    struct FractionalData {
        address liquidator;
        IERC721Modified nftContract;
        ERC20Modified erc20Contract;
        uint256 tokenId;
        uint256 tokenAmount;
    }
    mapping(address => FractionalData) public fractionalData;

    function transferNFT(string memory name_, string memory symbol_, address nftContractAddr, uint256 tokenId, uint256 amount) external {
        require(amount > 0, "TOKEN_AMOUNT_CAN'T_BE_ZERO");
        IERC721Modified nftContract = IERC721Modified(nftContractAddr);
        require(nftContract.ownerOf(tokenId) == _msgSender(), "SENDER_IS_NOT_OWNER");
        _transferAndMint(name_, symbol_, nftContract, tokenId, amount);
    }

    function _transferAndMint(string memory name_, string memory symbol_, IERC721Modified nftContract, uint256 tokenId, uint256 amount) internal {
        ERC20Modified erc20 = new ERC20Modified(name_, symbol_, msg.sender, amount);

        FractionalData memory data = FractionalData({
            liquidator: _msgSender(),
            nftContract: nftContract,
            erc20Contract: erc20,
            tokenId: tokenId,
            tokenAmount: amount
        });

        fractionalData[address(erc20)] = data;
        (bool success, ) = address(nftContract).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), tokenId)
        );
        require(success, "Failed to transfer NFT");
    }

    function putForSale(address erc20TokenAddress, uint256 amount) external {
        (bool success, ) = erc20TokenAddress.call(
            abi.encodeWithSignature("putForSale(uint256)", amount)
        );
        require(success, "Failed to call putForSale function");
    }

    function purchase(address erc20TokenAddress) external payable {
        FractionalData memory data = fractionalData[erc20TokenAddress];
        (bool success, ) = erc20TokenAddress.call{value: data.erc20Contract.salePrice()}(
            abi.encodeWithSignature("purchase()")
        );
        require(success, "Failed to call purchase function");
        data.nftContract.transferFrom(address(this), msg.sender, data.tokenId);
    }

    function redeemToken(address erc20TokenAddress, uint256 amount) external {
        FractionalData memory data = fractionalData[erc20TokenAddress];
        (bool success, ) = erc20TokenAddress.call{value: data.erc20Contract.salePrice()}(
            abi.encodeWithSignature("redeemToken(uint256)", amount)
        );
        require(success, "Failed to call redeemToken function");
    }
}

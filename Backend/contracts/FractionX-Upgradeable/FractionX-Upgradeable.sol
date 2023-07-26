// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "./IERC721UpgradeableModified.sol";
// import "./ERC20UpgradeableModified.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

// contract FractionXupgradeable is ContextUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, ERC721HolderUpgradeable {
//     // IERC721Upgradeable immutable nftcontract;
//     mapping(IERC721Upgradeable => address) public contractToOwner;

//     struct data {
//         IERC721UpgradeableModified nftcontract_;
//         ERC20UpgradeableModified erc20contract_;
//         address liquidator_;
//         uint256 tokenId_;
//     }
//     mapping(address => data) public ownerData;

//     function transferNFT(address nftcontract_,uint256 tokenId_, uint256 amount_) external {
//         require(
//             amount_ > 0, 
//             "TOKEN_AMOUNT_CAN'T_BE_ZERO"
//         );
//         IERC721UpgradeableModified nftcontract = IERC721UpgradeableModified(nftcontract_);
//         require(
//             nftcontract.ownerOf(tokenId_) == _msgSender(),
//             "SENDER_IS_NOT_OWNER"
//         );
//         contractToOwner[nftcontract] =  _msgSender();
//         _transferMint(nftcontract, tokenId_, amount_);
//     }

//     function _transferMint(IERC721UpgradeableModified nftcontract_, uint256 tokenId_,  uint256 amount_) internal {

//         ERC20UpgradeableModified erc20 = new ERC20UpgradeableModified();
//         erc20.__ERC20_init(nftcontract_.name(), nftcontract_.symbol());

//         data memory da = data({
//           nftcontract_: nftcontract_,
//           liquidator_: _msgSender(),
//           erc20contract_: erc20,
//           tokenId_: tokenId_
//         }); 
//         ownerData[_msgSender()] = da;

//         nftcontract_.safeTransferFrom(da.liquidator_, address(this), da.tokenId_);
//         erc20._mint(da.liquidator_, da.amount_);
//     }

//     function putForSale(uint256 amount_) external {
//         data storage da = ownerData[_msgSender()];
//         require(da.liquidator_ == _msgSender(), "ERR_SENDER_IS_NOT_LIQUIDATOR");
//         da.erc20contract_.putForSale(amount_);
//     }

//     function purchase(address nftcontract_) external {
//         data storage da = ownerData[_msgSender()];
//         require(da.liquidator_ == _msgSender(), "ERR_SENDER_IS_NOT_LIQUIDATOR");
//         da.nftcontract_.safeTransferFrom(address(this), _msgSender(), da.tokenId_);
//         da.erc20contract_.purchase();
//     }

//     function redeemToken() external {
//         data storage da = ownerData[_msgSender()];
//         require(da.erc20contract_.canRedeem, "CAN'T_REDEEM_TOKEN_YET");
//         // require(
//         //     da.erc20contract_.balanceOf(_msgSender()) == amount_,
//         //     "INVALID_AMOUNT_FOR_REDEMPTION"
//         // );
//     }

// }
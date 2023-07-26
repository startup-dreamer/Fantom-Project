// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Modified is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
}
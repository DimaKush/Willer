// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenERC721 is ERC721, Ownable {
    string private baseURI;

    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner
    ) ERC721(name_, symbol_) Ownable(initialOwner) {}

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = totalSupply();
        _safeMint(to, tokenId);
        baseURI = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply();
    }

    function _totalSupply() internal view virtual returns (uint256) {
        return 0;
    }
} 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract BatchApprove is Script {
    function run() external {
        uint256 testatorPrivateKey = vm.envUint("TESTATOR_PRIVATE_KEY");
        address willer = vm.envAddress("WILLER_ADDRESS");
        
        // Get token addresses from environment
        address[] memory erc20Tokens = getERC20Tokens();
        address[] memory erc721Tokens = getERC721Tokens();
        address[] memory erc1155Tokens = getERC1155Tokens();

        vm.startBroadcast(testatorPrivateKey);
        
        // Approve ERC20 tokens
        for (uint i = 0; i < erc20Tokens.length; i++) {
            IERC20(erc20Tokens[i]).approve(willer, type(uint256).max);
        }

        // Approve ERC721 tokens
        for (uint i = 0; i < erc721Tokens.length; i++) {
            IERC721(erc721Tokens[i]).setApprovalForAll(willer, true);
        }

        // Approve ERC1155 tokens
        for (uint i = 0; i < erc1155Tokens.length; i++) {
            IERC1155(erc1155Tokens[i]).setApprovalForAll(willer, true);
        }

        vm.stopBroadcast();
    }

    function getERC20Tokens() internal returns (address[] memory) {
        string memory tokens = vm.envString("ERC20_TOKENS");
        // Parse comma-separated list of addresses
        // Implementation depends on how you want to store token addresses
        // This is just a placeholder
        address[] memory addresses = new address[](1);
        return addresses;
    }

    function getERC721Tokens() internal returns (address[] memory) {
        string memory tokens = vm.envString("ERC721_TOKENS");
        // Parse comma-separated list of addresses
        address[] memory addresses = new address[](1);
        return addresses;
    }

    function getERC1155Tokens() internal returns (address[] memory) {
        string memory tokens = vm.envString("ERC1155_TOKENS");
        // Parse comma-separated list of addresses
        address[] memory addresses = new address[](1);
        return addresses;
    }
} 
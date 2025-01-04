// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import "../src/MultiFaucet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract UseFaucet is Script {
    function run() external {
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");
        address faucet = vm.envAddress("FAUCET_ADDRESS");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        string memory tokenType = vm.envString("TOKEN_TYPE"); // "ERC20", "ERC721", or "ERC1155"
        
        vm.startBroadcast(userPrivateKey);
        
        if (keccak256(bytes(tokenType)) == keccak256(bytes("ERC20"))) {
            MultiFaucet(faucet).dripERC20(IERC20(tokenAddress));
        } else if (keccak256(bytes(tokenType)) == keccak256(bytes("ERC721"))) {
            uint256 tokenId = vm.envUint("TOKEN_ID");
            MultiFaucet(faucet).dripERC721(IERC721(tokenAddress), tokenId);
        } else if (keccak256(bytes(tokenType)) == keccak256(bytes("ERC1155"))) {
            uint256 tokenId = vm.envUint("TOKEN_ID");
            MultiFaucet(faucet).dripERC1155(IERC1155(tokenAddress), tokenId, "");
        }
        
        vm.stopBroadcast();
    }
} 
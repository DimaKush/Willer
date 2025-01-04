// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import "../src/TokenERC721.sol";
import "../src/TokenERC20.sol";
import "../src/TokenERC1155.sol";

contract DeployTokens is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address deployer = vm.addr(deployerPrivateKey);

        // Deploy ERC20 tokens
        for (uint i = 0; i < 2; i++) {
            new TokenERC20(
                1e36,
                string(abi.encodePacked("TokenERC20_", vm.toString(i))),
                string(abi.encodePacked("T20_", vm.toString(i))),
                deployer
            );
        }

        // Deploy ERC721 tokens
        for (uint i = 0; i < 2; i++) {
            new TokenERC721(
                string(abi.encodePacked("TokenERC721_", vm.toString(i))),
                string(abi.encodePacked("T721_", vm.toString(i))),
                deployer
            );
        }

        // Deploy ERC1155 tokens
        for (uint i = 0; i < 2; i++) {
            new TokenERC1155(
                "someName",
                string(abi.encodePacked("https://somelink.xyz/ERC1155_", vm.toString(i))),
                deployer
            );
        }

        vm.stopBroadcast();
    }
} 
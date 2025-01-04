// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../src/Willer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract SetupWill is Script {
    function run() external {
        uint256 testatorPrivateKey = vm.envUint("TESTATOR_PRIVATE_KEY");
        address willer = vm.envAddress("WILLER_ADDRESS");
        
        address[] memory beneficiaries = new address[](5);
        uint256[] memory shares = new uint256[](5);
        
        // Setup beneficiaries and shares
        beneficiaries[0] = vm.addr(vm.envUint("BENEFICIARY1_KEY"));
        beneficiaries[1] = vm.addr(vm.envUint("BENEFICIARY2_KEY"));
        beneficiaries[2] = vm.addr(vm.envUint("BENEFICIARY3_KEY"));
        beneficiaries[3] = vm.addr(vm.envUint("BENEFICIARY4_KEY"));
        beneficiaries[4] = vm.addr(vm.envUint("BENEFICIARY5_KEY"));
        
        shares[0] = 1;
        shares[1] = 2;
        shares[2] = 8;
        shares[3] = 4;
        shares[4] = 8;

        address beneficiaryOfERC721 = vm.addr(vm.envUint("BENEFICIARY_ERC721_KEY"));
        uint256 releaseTime = block.timestamp + 60 + 100; // buffer + delay

        vm.startBroadcast(testatorPrivateKey);
        
        Willer(willer).addWill(
            beneficiaries,
            shares,
            beneficiaryOfERC721,
            releaseTime
        );

        vm.stopBroadcast();
    }
} 
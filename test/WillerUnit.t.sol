// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/Willer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract WillerUnitTest is Test {
    Willer public willer;
    address testator;
    address[] beneficiaries;
    uint256[] shares;
    address beneficiaryOfERC721;
    address newBeneficiary;

    function setUp() public {
        willer = new Willer();
        testator = makeAddr("testator");
        beneficiaryOfERC721 = makeAddr("beneficiaryOfERC721");
        newBeneficiary = makeAddr("newBeneficiary");
        
        // Setup beneficiaries and shares
        for (uint i = 0; i < 5; i++) {
            beneficiaries.push(makeAddr(string.concat("beneficiary", vm.toString(i))));
            shares.push(i + 1);
        }
    }

    function test_SetNewBeneficiaries() public {
        vm.startPrank(testator);
        
        // Add initial will
        uint256 releaseTime = block.timestamp + willer.getBuffer() + 10;
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
        
        // Create new beneficiaries list
        address[] memory newBeneficiaries = new address[](beneficiaries.length + 1);
        for (uint i = 0; i < beneficiaries.length; i++) {
            newBeneficiaries[i] = beneficiaries[i];
        }
        newBeneficiaries[beneficiaries.length] = newBeneficiary;
        
        // Create new shares list
        uint256[] memory newShares = new uint256[](shares.length + 1);
        for (uint i = 0; i < shares.length; i++) {
            newShares[i] = shares[i];
        }
        newShares[shares.length] = 1;
        
        willer.setNewBeneficiaries(newBeneficiaries, newShares);
        
        assertEq(willer.getBeneficiaries(testator), newBeneficiaries);
        assertEq(willer.getShares(testator), newShares);
    }

    function test_SetNewReleaseTime() public {
        vm.startPrank(testator);
        
        // Add initial will
        uint256 initialReleaseTime = block.timestamp + willer.getBuffer() + 10;
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, initialReleaseTime);
        
        uint256 newReleaseTime = initialReleaseTime + willer.getBuffer() + 10;
        willer.setNewReleaseTime(newReleaseTime);
        
        assertEq(willer.getReleaseTime(testator), newReleaseTime);
    }

    function test_SetNewBeneficiaryOfERC721() public {
        vm.startPrank(testator);
        
        // Add initial will
        uint256 releaseTime = block.timestamp + willer.getBuffer() + 10;
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
        
        assertEq(beneficiaryOfERC721, willer.getBeneficiaryOfERC721(testator));
        
        willer.setNewBeneficiaryOfERC721(newBeneficiary);
        
        assertEq(willer.getBeneficiaryOfERC721(testator), newBeneficiary);
    }
} 